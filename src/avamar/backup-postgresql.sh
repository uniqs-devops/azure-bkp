#!/bin/bash
# SWO Avamar script for backup in Azure POSTGRES.
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
KEYVAULTSECUREACCESS=`cat $ConfigDir/dps-setup.json  | jq -r '.useKeyVaultSecureAccess'`
##--##USEENDPOINTS=`cat $ConfigDir/dps-setup.json  | jq -r '.EndPoints.useEndPoints'`
##--##ENDPOINT=`cat $ConfigDir/dps-setup.json  | jq -r '.EndPoints.EndPoint'`
USEDUMPALL=`cat $ConfigDir/dps-setup.json  | jq -r '.postgresql.useDumpall'`
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
if [ ! -d ${ServiceBackupDir}/backups ]; then mkdir ${ServiceBackupDir}/backups; fi
if [ ! -d ${ServiceBackupDir}/restore ]; then mkdir ${ServiceBackupDir}/restore; fi
if [ ! -d ${ServiceBackupDir}/old ]; then mkdir ${ServiceBackupDir}/old; fi
find ${LogDir}/* -mtime +5 -type f -exec rm {} \;
files=$(shopt -s nullglob dotglob; echo $BackupDir/*)
if (( ${#files} )); then mv ${BackupDir}/* ${OldBackupDir}; fi
oldfiles=$(shopt -s nullglob dotglob; echo $BackupDir/*)
if (( ${#oldfiles} )); then find ${OldBackupDir}/* -mtime +5 -type f -exec rm {} \;; fi
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
az resource list  --resource-type $RESOURCES  --resource-group $RESOURCEGROUP -o table | tail -n +3 | awk {'print $1'} > ${ConfigDir}/swoconfig

cat ${ConfigDir}/swoconfig | while read linea
do
        set -a $linea " "
        if [ "${1::1}" != "#" ] ; then
                if [ $USETAGS = "YES" ]; then
                        tags=(`az resource list --name $1 | jq '.[].tags | [."'"$TASK_TAG"'",."'"$DATABASE_TAG"'",."'"$USER_TAG"'",."'"$SECRET_TAG"'",."'"$PORT_TAG"'"]' | sed 's/"//g' | sed 's/,//g' | sed 's/\]//g' | sed 's/\[//g' | paste -sd " "`)
                        username=${tags[2]}
                        task=${tags[0]}
                        secret=${tags[2]}
                        if [ ${tags[1]} = "*" ]; then
                            dbs=(`az postgres db list  --resource-group $RESOURCEGROUP --server-name $1 -o table | tail -n +3 | awk {'print $4'} | grep -v azure_maintenance | grep -v azure_sys `)
                        else
                            dbs=(${tags[1]})
                        fi
                else
                        username=$USER_FIX
                        task=$TASK_FIX
                        secret=$SECRET_FIX
                        if [ $DATABASE_FIX = "ALL" ]; then
                            dbs=(`az postgres db list  --resource-group $RESOURCEGROUP --server-name $1 -o table | tail -n +3 | awk {'print $4'} | grep -v azure_maintenance | grep -v azure_sys | grep -v postgres`)
                        else
                            dbs=$DATABASE_FIX
                        fi
                fi
                if [ $USEFQDN = "NO" ]; then
                        server=$(nslookup "$1"".postgres.database.azure.com" | awk -F':' '/^Address: / { matched = 1 } matched { print $2}' | xargs)
                        [[ -z "$server" ]] && echo Server Name to IP translate fail || echo IP for server "$1" is "$server"
                else
                        server=$1.postgres.database.azure.com
                fi
                ERROR=0
                ##-##if [ $USEENDPOINTS = "YES" ]; then server=$ENDPOINT; fi
                if [ $KEYVAULTSECUREACCESS = "YES" ]; then
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
                        echo !!!!! Getting secret from Keyvault LIST priv !!!!!
                        pass=$(echo $response | python3 -c 'import sys, json; print (json.load(sys.stdin)["value"])')
                else
                        echo !!!!! Getting secret from Keyvault GET priv !!!!!
                        pass=$(az keyvault secret show --name $secret --vault-name ${KeyVault} | jq -r '.value')
                fi
                if [ $USEDUMPALL = "NO" ]; then
                     for db in ${dbs[@]}; do
                        echo PGPASSWORD=******** PGSSLMODE=require pg_dump -Fc -v --host=$server --username=$username@$server --dbname=$db -f ${BackupDir}/$server.$db.$task.$(date +%Y%m%d%H%M%S).dump
                        PGPASSWORD=${pass} PGSSLMODE=require pg_dump -Fc -v --host=$server --username=$username@$server --dbname=$db -f ${BackupDir}/$server.$db.$task.$(date +%Y%m%d%H%M%S).dump
                        if [ "$?" != "0" ] ; then
                                echo "******************** ERROR 009: Wrong Data in Config file POSTGRES, EXIT *********************"
                                ERROR=9
                                break
                        fi
                        echo !!!!! Running  process  $task Data Base  $db !!!!!
                        echo
                        echo !!!!! File size !!!!!
                        ls -lh ${BackupDir} | tail -1 |  awk {'print " File size: "$5 " / File Name: "$9'}
                        echo
                      done
                else
                       echo PGPASSWORD=******** PGSSLMODE=require pg_dumpall --host=$server --username=$username@$server --exclude-database=azure_sys --exclude-database=azure_maintenance -f ${BackupDir}/$server.$task.$(date +%Y%m%d%H%M%S).dump
                        PGPASSWORD=${pass} PGSSLMODE=require pg_dumpall --host=$server --username=$username@$server --exclude-database=azure_sys --exclude-database=azure_maintenance -f ${BackupDir}/$server.dumpall.$task.$(date +%Y%m%d%H%M%S).dump
                fi
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

