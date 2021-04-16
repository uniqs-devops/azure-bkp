#!/bin/bash
# SWO Avamar script for backup in Azure Blob Storage.
# Disclaimer: Based on an original Software One script

version="1.0"

ConfigDir=/dockerclient
SERVICE_TYPE=`cat $ConfigDir/dps-setup.json  | jq -r '.dockerType'`
LogDir=$ConfigDir/var
RootBackupDir=/`cat $ConfigDir/dps-setup.json  | jq -r '.datadomain.RootBackupDir'`
ServiceBackupDir=${RootBackupDir}/$SERVICE_TYPE
BackupDir=${ServiceBackupDir}/backups
RestoreDir=${ServiceBackupDir}/restore
LogFile=${LogDir}/${SERVICE_TYPE}_`date +%Y%m%d.%T`.log

ERROR=1
[ ! -d $LogDir ] && mkdir $LogDir
exec &>> >(tee -a $LogFile)

echo "*****************************************************************************************************"
echo "******************************** STARTING swobackup.sh ver ${version} *******************************"
echo "*****************************************************************************************************"
echo !!!!! `date +%Y%m%d.%T` starting swobackup process, service $SERVICE_TYPE  !!!!!
echo -e "\n"

RESOURCES=`jq '.azureResources[] | select(.type=="PG" and .resourceType != null)|.resourceType' $ConfigDir/dps-setup.json | sed 's/"//g'`
TENANID=`cat $ConfigDir/dps-setup.json  | jq -r '.tenantId'`
RESOURCEGROUP=`cat $ConfigDir/dps-setup.json  | jq -r '.resourceGroup'`
USERSERVICEPRINCIPAL=`cat $ConfigDir/dps-setup.json  | jq -r '.servicePrincipal.useServicePrincipal'`
SERVICEPRINCIPALCLIENTID=`cat $ConfigDir/dps-setup.json  | jq -r '.servicePrincipal.servicePrincipalClientId'`
SERVICEPRINCIPALCLIENTSECRET=`cat $ConfigDir/dps-setup.json  | jq -r '.servicePrincipal.servicePrincipalClientSecret'`
CHANGEDEFAULTSUSCRIPTION=`cat $ConfigDir/dps-setup.json  | jq -r '.subscription.changeDefaultsubscription'`
SUSCRIPTIONID=`cat $ConfigDir/dps-setup.json  | jq -r '.subscription.subscriptionID'`

# AZ Login
if [ $USERSERVICEPRINCIPAL = "YES" ]; then 
	az login --service-principal --username $SERVICEPRINCIPALCLIENTID --password  $SERVICEPRINCIPALCLIENTSECRET --tenant $TENANID
else
	az login --service-principal -u http://PaaSBackup -p $ConfigDir/azurelogin.pem --tenant $TENANID
fi
if [ $CHANGEDEFAULTSUSCRIPTION = "YES" ]; then az account set --subscription $SUSCRIPTIONID; fi
if [ ! -d $RootBackupDir ]; then mkdir mkdir ${RootBackupDir}; fi
if [ ! -d ${RootBackupDir} ]; then mkdir ${RootBackupDir}; fi
if [ ! -d ${ServiceBackupDir} ]; then mkdir ${ServiceBackupDir}; fi
find ${LogDir}/* -mtime +15 -type f -exec rm {} \;

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
                key="$(az keyvault secret show --name $secret --vault-name ${KeyVault} | jq -r '.value')"
                containers="$(az storage container list --account-name $1 --account-key $key --query "[].{name:name}" --output tsv)"
                ERROR=0
                for container in ${containers[@]}; do
                        echo !!!!! Running container  $container Storage Account $1 !!!!!
                        echo "accountName ${1}" > ${ConfigDir}/${container}
                        echo "accountKey ${key}" >> ${ConfigDir}/${container}
                        if [ $USERSERVICEPRINCIPAL = "YES" ]; then
                                echo "authType SPN" >> ${ConfigDir}/${container}
                                echo "servicePrincipalClientId $SERVICEPRINCIPALCLIENTID" >> ${ConfigDir}/${container}
                                echo "servicePrincipalClientSecret $SERVICEPRINCIPALCLIENTSECRET" >> ${ConfigDir}/${container}
                                echo "servicePrincipalTenantId $TENANID" >> ${ConfigDir}/${container}
                        fi
                        echo "containerName $container" >> ${ConfigDir}/${container}
                        if [ ! -d ${ServiceBackupDir}/$1/${container} ]; then mkdir -p ${ServiceBackupDir}/$1/${container}; fi
                        if [ ! -d ${ServiceBackupDir}/$1/restore ]; then mkdir -p ${ServiceBackupDir}/$1/restore; fi
                        mountpoint -q ${ServiceBackupDir}/$1/${container}
                        if [ "$?" == "1" ]; then
                           timeout 60s blobfuse ${ServiceBackupDir}/$1/${container} --tmp-path=/tmp/blobfusetmp.$1.${container} -o attr_timeout=240 -o negative_timeout=120 --config-file=${ConfigDir}/${container} --log-level=LOG_WARNING --file-cache-timeout-in-seconds=120 -o ro -o nonempty
                        fi
                        if [ "$?" != "0" ]; then
                                echo "************************* ERROR 010: Unable to Mount. Check Data in Config file DATALAKE, EXIT *************************"
                                break
                        fi
                        echo !!!!! $task blog fuse mount of container ${container} of account $blob !!!!!
                        echo
                        echo !!!!! Container size !!!!!
                        du -hs ${ServiceBackupDir}/$1/${container}
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
