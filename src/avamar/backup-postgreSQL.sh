#!/bin/bash
# SWO Avamar script for backup in Azure POSTGRES.
# Disclaimer: Based on an original Software One script

version="1.0"

SERVICE_TYPE=`cat $ConfigDir/dps-setup.json  | jq -r '.dockerType'`
KeyVault=`cat dps-setup.json  | jq -r '.keyVaultName'`
ConfigDir=/`cat dps-setup.json  | jq -r '.avamar.installDir'`
LogDir=$ConfigDir/var
RootBackupDir=`cat dps-setup.json  | jq -r '.datadomain.RootBackupDir'`
ServiceBackupDir=${RootBackupDir}/$SERVICE_TYPE
BackupDir=${ServiceBackupDir}/backups
RestoreDir=${ServiceBackupDir}/restore
OldBackupDir=${ServiceBackupDir}/old
LogFile=${LogDir}/${SERVICE_TYPE}_`date +%Y%m%d.%T`.log

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

if [ -f ${ConfigDir}/swoconfig ]; then rm -rf ${ConfigDir}/swoconfig; fi
for resource in $RESOURCES
do
                az resource list  --resource-type $resource -o json > /tmp/az.json
                echo $SERVICE_TYPE >> ${ConfigDir}/swoconfig.tmp
                for i in $TASK_TAG $SERVER_TAG $DATABASE_TAG $USER_TAG $SECRET_TAG
                do
                        jq '.[].tags' /tmp/az.json -r | grep $i | awk {'print $2'} | sed 's/"//g' | sed 's/,//g' >> ${ConfigDir}/swoconfig.tmp
                done
                paste -sd " " ${ConfigDir}/swoconfig.tmp >  ${ConfigDir}/swoconfig; rm -f  ${ConfigDir}/swoconfig.tmp
done

if [ ! -d $RootBackupDir ]; then
    echo ********************* "ERROR 004:  Mount Point folder $RootBackupDir not found, EXIT" *********************
    exit 4 
fi
if [ $MOUNTTYPE = "NFS" ]; then
	if [ ! -d ${RootBackupDir}/$SERVICE_TYPE ]; then mkdir ${RootBackupDir}/$SERVICE_TYPE; fi
	if [ ! -d ${ServiceBackupDir}/backups ]; then mkdir ${ServiceBackupDir}/backups; fi
	if [ ! -d ${ServiceBackupDir}/restore ]; then mkdir ${ServiceBackupDir}/restore; fi
	if [ ! -d ${ServiceBackupDir}/old ]; then mkdir ${ServiceBackupDir}/old; fi
fi

if [ ! -d $ConfigDir ]; then
    echo $ConfigDir
    echo "************************* ERROR 006: Config folder not found. EXIT *************************"
    exit 6
fi

if [ ! -f ${ConfigDir}/swoconfig ]; then
    echo "************************* ERROR 007: Config file not found. EXIT *************************"
    exit 7
fi
echo 
echo !!!!! Processing config file !!!!!
echo
cat ${ConfigDir}/swoconfig | while read linea

do
    set -a $linea " "
    if [ "${1::1}" != "#" ] ; then
        ERROR=0 
		echo !!!!! Processing token from Keyvault !!!!!
	    response=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true -s)
        if [ ${response:2:5} == "error" ]; then
            echo "****************************** ERROR 001 Getting token from KeyVault ******************************"
            ERROR=1
            break
        fi
        access_token=$(echo $response | python3 -c 'import sys, json; print (json.load(sys.stdin)["access_token"])')
        echo !!!!! Processing value from Keyvault !!!!!
	    response=$(curl https://${KeyVault}.vault.azure.net/secrets/$6?api-version=2016-10-01 -s -H "Authorization: Bearer ${access_token}")
           if [ ${response:2:5} == "error" ]; then
               echo "****************************** ERROR 002 Obtaining key value from KeyVault ******************************"
               ERROR=2
               break
           fi
           pass=$(echo $response | python3 -c 'import sys, json; print (json.load(sys.stdin)["value"])')

           echo
           echo PGPASSWORD=******** pg_dump -Fc -v --host=$3 --username=$5 --dbname=$4 -f ${BackupDir}/${2}.dump
           PGPASSWORD=${pass} pg_dump -Fc -v --host=$3 --username=$5 --dbname=$4 -f ${BackupDir}/${2}.dump

           if [ "$?" != "0" ] ; then
              echo "******************** ERROR 009: Wrong Data in Config file POSTGRES, EXIT *********************"
              ERROR=9
              break
           fi
           
           echo !!!!! Running  process  $1 Data Base  $5 !!!!!
           echo
           echo !!!!! File size !!!!!
	       du -sh ${BackupDir}/${2}.dump 
           echo
        
fi
done  < ${ConfigDir}/swoconfig


if [ "$ERROR" != "0" ]; then
     echo -e "\n"
     echo !!!!! `date +%Y%m%d.%T` swobackup for service  $SERVICE_TYPE finished WRONG !!!!!
     echo
     echo "******************************************************************************************************"
     echo "********************** $SERVICE_TYPE not found in file swobackup or data error ***************************"
     echo "******************************************************************************************************"
     echo "*********************************** FINISHED swobackup.sh ver ${version} *****************************"
     echo "******************************************************************************************************"
     exit 1
else
     echo -e "\n"
     echo !!!!! `date +%Y%m%d.%T` swobackup for service  $SERVICE_TYPE finished SUCCESSFULLY !!!!!
     echo
     echo "******************************************************************************************************"
     echo "*********************************** FINISHED swobackup.sh ver ${version} ************************************"
     echo "******************************************************************************************************"
fi
# Logout
az logout


