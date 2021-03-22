#!/bin/bash
# SWO Avamar script for backup in Azure Blob Storage.
# Disclaimer: Based on an original Software One script

version="1.0"

ConfigDir=/dockerclient
SERVICE_TYPE=`cat $ConfigDir/dps-setup.json  | jq -r '.dockerType'`
KeyVault=`cat $ConfigDir/dps-setup.json  | jq -r '.keyVaultName'`
LogDir=$ConfigDir/var
RootBackupDir=/`cat $ConfigDir/dps-setup.json  | jq -r '.datadomain.RootBackupDir'`
ServiceBackupDir=${RootBackupDir}/$SERVICE_TYPE
BackupDir=${ServiceBackupDir}/backups
RestoreDir=${ServiceBackupDir}/restore
OldBackupDir=${ServiceBackupDir}/old
LogFile=${LogDir}/${SERVICE_TYPE}_`date +%Y%m%d.%T`.log

ERROR=1
[ ! -d $LogDir ] && mkdir $LogDir
exec &>> >(tee -a $LogFile)

echo "*****************************************************************************************************"
echo "******************************** STARTING swobackup.sh ver ${version} *******************************"
echo "*****************************************************************************************************"
echo !!!!! `date +%Y%m%d.%T` starting swobackup process, service $SERVICE_TYPE  !!!!!
echo -e "\n"

USER_TAG=`jq '.backupTags[] | select(.type=="user")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
PORT_TAG=`jq '.backupTags[] | select(.type=="port")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
DATABASE_TAG=`jq '.backupTags[] | select(.type=="database")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
TASK_TAG=`jq '.backupTags[] | select(.type=="task")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
SECRET_TAG=`jq '.backupTags[] | select(.type=="secret")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
USER_FIX=`jq '.fixValues[] | select(.type=="user")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
PORT_FIX=`jq '.fixValues[] | select(.type=="port")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
DATABASE_FIX=`jq '.fixValues[] | select(.type=="database")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
TASK_FIX=`jq '.fixValues[] | select(.type=="task")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
SECRET_FIX=`jq '.fixValues[] | select(.type=="secret")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
RESOURCES=`jq '.azureResources[] | select(.type=="PG" and .resourceType != null)|.resourceType' $ConfigDir/dps-setup.json | sed 's/"//g'`
TENANID=`cat $ConfigDir/dps-setup.json  | jq -r '.tenantId'`
MOUNTTYPE=`cat $ConfigDir/dps-setup.json  | jq -r '.datadomain.mountType'`
RESOURCEGROUP=`cat $ConfigDir/dps-setup.json  | jq -r '.resourceGroup'`
USETAGS=`cat $ConfigDir/dps-setup.json  | jq -r '.useTags'`
USEFQDN=`cat $ConfigDir/dps-setup.json  | jq -r '.useFQDN'`
USERSERVICEPRINCIPAL=`cat $ConfigDir/dps-setup.json  | jq -r '.servicePrincipal.useServicePrincipal'`
SERVICEPRINCIPALCLIENTID=`cat $ConfigDir/dps-setup.json  | jq -r '.servicePrincipal.servicePrincipalClientId'`
SERVICEPRINCIPALCLIENTSECRET=`cat $ConfigDir/dps-setup.json  | jq -r '.servicePrincipal.servicePrincipalClientSecret'`

# AZ Login
az login --service-principal -u http://PaaSBackup --password $ConfigDir/azurelogin.pem --tenant $TENANID

if [ ! -d $RootBackupDir ]; then mkdir mkdir ${RootBackupDir}; fi
if [ ! -d ${RootBackupDir} ]; then mkdir ${RootBackupDir}; fi
if [ ! -d ${ServiceBackupDir} ]; then mkdir ${ServiceBackupDir}; fi
if [ ! -d ${ServiceBackupDir}/backups ]; then mkdir ${ServiceBackupDir}/backups; fi
if [ ! -d ${ServiceBackupDir}/restore ]; then mkdir ${ServiceBackupDir}/restore; fi
if [ ! -d ${ServiceBackupDir}/old ]; then mkdir ${ServiceBackupDir}/old; fi
find ${LogDir}/* -mtime +15 -type f -exec rm {} \;
find ${RootBackupDir}/* -mtime +15 -type f -exec rm {} \;

if [ ! -d $ConfigDir ]; then
        echo $ConfigDir
        echo "************************* ERROR 006: Config folder not found. EXIT *************************"
        exit 6
fi

echo
echo !!!!! Processing config file !!!!!
echo
if [ -f ${ConfigDir}/swoconfig ]; then rm -rf ${ConfigDir}/swoconfig; fi
echo
echo "*********************************** SEARCHING cloud resources **************************************"
echo
az storage account list --query "[].{name:name}" --output tsv > ${ConfigDir}/swoconfig
cat ${ConfigDir}/swoconfig | while read linea
do
        set -a $linea " "
        if [ "${1::1}" != "#" ] ; then
                key="$(az storage account keys list -n $1 --query "[0].{value:value}" --output tsv)"
                containers="$(az storage container list --account-name $1 --account-key $key --query "[].{name:name}" --output tsv)"
                if [ $USEFQDN = "NO" ]; then
                        server=$(nslookup "$1"".postgres.database.azure.com" | awk -F':' '/^Address: / { matched = 1 } matched { print $2}' | xargs)
                        [[ -z "$server" ]] && echo Server Name to IP translate fail || echo IP for server "$1" is "$server"
                else
                        server=$1.postgres.database.azure.com
                fi
                ERROR=0
                username=$USER_FIX
                task=$TASK_FIX
                secret=$SECRET_FIX
                port=$PORT_FIX
                echo !!!!! Processing token from Keyvault !!!!!
                response=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true -s)
                if [ ${response:2:5} == "error" ]; then
                        echo "****************************** ERROR 001 Getting token from KeyVault ******************************"
                        ERROR=1
                        break
                fi
                access_token=$(echo $response | python3 -c 'import sys, json; print (json.load(sys.stdin)["access_token"])')
                echo !!!!! Processing value from Keyvault !!!!!
                response=$(curl https://${KeyVault}.vault.azure.net/secrets/$secret?api-version=2016-10-01 -s -H "Authorization: Bearer ${access_token}")
                if [ ${response:2:5} == "error" ]; then
                        echo "****************************** ERROR 002 Obtaining key value from KeyVault ******************************"
                        ERROR=2
                        break
                fi
                pass=$(echo $response | python3 -c 'import sys, json; print (json.load(sys.stdin)["value"])')
                for container in ${containers[@]}; do
                        echo !!!!! Running process  $1 Storage Account $3 !!!!!
                        echo "accountName ${1}" > ${ConfigDir}/${container}
                        echo "accountKey ${pass}" >> ${ConfigDir}/${container}
			if [ $USERSERVICEPRINCIPAL = "YES" ]; then
                        	echo "servicePrincipalClientId $SERVICEPRINCIPALCLIENTID" >> ${ConfigDir}/${container}
	               		echo "servicePrincipalClientSecret $SERVICEPRINCIPALCLIENTSECRET" >> ${ConfigDir}/${container}
	                	echo "servicePrincipalTenantId $TENANID" >> ${ConfigDir}/${container}
			fi
                        echo "containerName $container" >> ${ConfigDir}/${container}
                        if [ ! -d ${ServiceBackupDir}/${container} ]; then mkdir ${ServiceBackupDir}/${container}; fi
                        mountpoint -q ${ServiceBackupDir}/${container}
                        if [ "$?" == "1" ]; then
                           timeout 60s blobfuse ${ServiceBackupDir}/${container} --tmp-path=/tmp/blobfusetmp.${container} -o attr_timeout=240 -o negative_timeout=120 --config-file=${ConfigDir}/${container} --log-level=LOG_DEBUG --file-cache-timeout-in-seconds=120 -o ro -o nonempty
                        fi
                        if [ "$?" != "0" ]; then
                                echo "************************* ERROR 010: Unable to Mount. Check Data in Config file DATALAKE, EXIT *************************"
                                break
                        fi
                        echo !!!!! $task blog fuse mount of container ${container} of account $blob !!!!!
                        echo
                        echo !!!!! Container size !!!!!
                        du -hs ${ServiceBackupDir}/${container}
                        echo
                done
        fi
done  < ${ConfigDir}/swoconfig


if [ $? != "0" ] || [ $? != "1" ]; then
        echo -e "\n"
        echo !!!!! `date +%Y%m%d.%T` swobackup for service  $SERVICE_TYPE finished WRONG !!!!!
        echo "*********************************** FINISHED swobackup.sh ver ${version} *****************************"
        exit 1
else
        echo -e "\n"
        echo !!!!! `date +%Y%m%d.%T` swobackup for service  $SERVICE_TYPE finished SUCCESSFULLY !!!!!
        echo "*********************************** FINISHED swobackup.sh ver ${version} ************************************"
fi
# Logout
az logout

