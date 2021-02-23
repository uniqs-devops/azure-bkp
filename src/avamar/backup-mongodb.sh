#!/bin/bash
# SWO Avamar script for backup in Azure POSTGRES.
# Disclaimer: Based on an original Software One script
#String de ejemplo
mongodump --uri="mongodb://dps:tag2gaUPJJ87ANCG7xx5QGCsglnjYc3KTCJXoz9GtVeu1SGo3hBzmZWK7L2nXF2eueM5fRuR16yr5WokmmglKg==@dps.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@dps@" --gzip --out /backups/`date +"%Y-%m-%d"`

version="1.0"

ConfigDir=/dockerclient
SERVICE_TYPE=`cat $ConfigDir/dps-setup.json  | jq -r '.dockerType'`
KeyVault=`cat dps-setup.json  | jq -r '.keyVaultName'`
LogDir=$ConfigDir/var
RootBackupDir=/`cat dps-setup.json  | jq -r '.datadomain.RootBackupDir'`
ServiceBackupDir=${RootBackupDir}/$SERVICE_TYPE
BackupDir=${ServiceBackupDir}/backups
RestoreDir=${ServiceBackupDir}/restore
OldBackupDir=${ServiceBackupDir}/old
LogFile=${LogDir}/${SERVICE_TYPE}_`date +%Y%m%d.%T`.log
RESOURCEGROUP=`cat dps-setup.json  | jq -r '.resourceGroup'` 


find ${LogDir}/* -mtime +15 -type f -exec rm {} \;

ERROR=1

[ ! -d $LogDir ] && mkdir $LogDir
exec &>> >(tee -a $LogFile)


echo "*****************************************************************************************************"
echo "******************************** STARTING swobackup.sh ver ${version} *******************************"
echo "*****************************************************************************************************"
echo
echo !!!!! `date +%Y%m%d.%T` starting swobackup process, service $SERVICE_TYPE  !!!!!
echo -e "\n"

echo "*********************************** SEARCHING cloud resources **************************************"
echo
# Output format
# POSTGRES <task> <server> <Data Base> <User> <Key>
SERVICE_TYPE=`cat $ConfigDir/dps-setup.json  | jq -r '.dockerType'`
USER_TAG=`jq '.backupTags[] | select(.type=="user")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
PORT_TAG=`jq '.backupTags[] | select(.type=="port")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
SERVER_TAG=`jq '.backupTags[] | select(.type=="server")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
DATABASE_TAG=`jq '.backupTags[] | select(.type=="database")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
TASK_TAG=`jq '.backupTags[] | select(.type=="task")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
SECRET_TAG=`jq '.backupTags[] | select(.type=="secret")|.value' $ConfigDir/dps-setup.json | sed 's/"//g'`
RESOURCES=`jq '.azureResources[] | select(.type=="PG" and .resourceType != null)|.resourceType' $ConfigDir/dps-setup.json | sed 's/"//g'`
TENANID=`cat dps-setup.json  | jq -r '.tenantId'`
MOUNTTYPE=`cat dps-setup.json  | jq -r '.datadomain.mountType'`

# AZ Login
az login --service-principal -u http://PaaSBackup --password $ConfigDir/azurelogin.pem --tenant $TENANID

if [ ! -d $RootBackupDir ]; then mkdir mkdir ${RootBackupDir}; fi

if [ $MOUNTTYPE = "nfs" ] || [ $MOUNTTYPE = "DDBoostFS" ]; then
        if [ ! -d ${RootBackupDir} ]; then mkdir ${RootBackupDir}; fi
        if [ ! -d ${ServiceBackupDir} ]; then mkdir ${ServiceBackupDir}; fi
        if [ ! -d ${ServiceBackupDir}/backups ]; then mkdir ${ServiceBackupDir}/backups; fi
        if [ ! -d ${ServiceBackupDir}/restore ]; then mkdir ${ServiceBackupDir}/restore; fi
        if [ ! -d ${ServiceBackupDir}/old ]; then mkdir ${ServiceBackupDir}/old; fi
fi

if [ ! -d $ConfigDir ]; then
    echo $ConfigDir
    echo "************************* ERROR 006: Config folder not found. EXIT *************************"
    exit 6
fi

echo
echo !!!!! Processing config file !!!!!
echo
if [ -f ${ConfigDir}/swoconfig ]; then rm -rf ${ConfigDir}/swoconfig; fi
az keyvault list  -o table | tail -n +3 | awk {'print $2'} > ${ConfigDir}/swoconfig
cat ${ConfigDir}/swoconfig | while read linea

do
    set -a $linea " "
    
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
