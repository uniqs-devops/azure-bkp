#!/bin/bash
# SWO Avamar script for backup in Azure POSTGRES.
# Disclaimer: Based on an original Software One script

version="1.0"

ConfigDir=/home/dps/uniqs-dps
SERVICE_TYPE=`cat $ConfigDir/dps-setup.json  | jq -r '.dockerType'`
KeyVault=`cat $ConfigDir/dps-setup.json  | jq -r '.keyVaultName'`
RESOURCEGROUP=`cat $ConfigDir/dps-setup.json  | jq -r '.resourceGroup'`
RootBackupDir=/`cat $ConfigDir/dps-setup.json  | jq -r '.datadomain.RootBackupDir'`
ServiceBackupDir=${RootBackupDir}/$SERVICE_TYPE
BackupDir=${ServiceBackupDir}/backups
TENANID=`cat $ConfigDir/dps-setup.json  | jq -r '.tenantId'`
MOUNTTYPE=`cat $ConfigDir/dps-setup.json  | jq -r '.datadomain.mountType'`

# AZ Login
###az login --service-principal -u http://PaaSBackup --password $ConfigDir/azurelogin.pem --tenant $TENANID

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
if [ -f ${ConfigDir}/secret.list ]; then rm -rf ${ConfigDir}/secret.list; fi

az keyvault secret list --vault-name `az keyvault list --resource-group $RESOURCEGROUP -o table | tail -n +3 | awk {'print $2'}` | jq '.[].name' | sed 's/"//g' > ${ConfigDir}/secret.list

echo
echo "*********************************** SEARCHING cloud resources **************************************"
echo

set -x
cat ${ConfigDir}/secret.list | while read linea
do
        set -a $linea " "
        az keyvault secret backup --file ${BackupDir}/$KeyVault.$1.$(date +%Y%m%d%H%M%S).bkp --vault-name $KeyVault --name $1
done

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
###az logout



