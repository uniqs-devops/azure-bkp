#!/bin/bash
# SWO Avamar script for backup in Azure POSTGRES.
# Disclaimer: Based on an original Software One script

version="1.0"

ConfigDir=/dockerclient
SERVICE_TYPE=`cat $ConfigDir/dps-setup.json  | jq -r '.dockerType'`
LogDir=$ConfigDir/var
RESOURCEGROUP=`cat $ConfigDir/dps-setup.json  | jq -r '.resourceGroup'`
RootBackupDir=/`cat $ConfigDir/dps-setup.json  | jq -r '.datadomain.RootBackupDir'`
ServiceBackupDir=${RootBackupDir}/$SERVICE_TYPE
BackupDir=${ServiceBackupDir}/backups
TENANID=`cat $ConfigDir/dps-setup.json  | jq -r '.tenantId'`
MOUNTTYPE=`cat $ConfigDir/dps-setup.json  | jq -r '.datadomain.mountType'`
LogFile=${LogDir}/${SERVICE_TYPE}_`date +%Y%m%d.%T`.log
USERSERVICEPRINCIPAL=`cat $ConfigDir/dps-setup.json  | jq -r '.servicePrincipal.useServicePrincipal'`
SERVICEPRINCIPALCLIENTID=`cat $ConfigDir/dps-setup.json  | jq -r '.servicePrincipal.servicePrincipalClientId'`
SERVICEPRINCIPALCLIENTSECRET=`cat $ConfigDir/dps-setup.json  | jq -r '.servicePrincipal.servicePrincipalClientSecret'`
CHANGEDEFAULTSUSCRIPTION=`cat $ConfigDir/dps-setup.json  | jq -r '.subscription.changeDefaultsubscription'`
SUSCRIPTIONID=`cat $ConfigDir/dps-setup.json  | jq -r '.subscription.subscriptionID'`
ERROR=1
[ ! -d $LogDir ] && mkdir $LogDir
exec &>> >(tee -a $LogFile)
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
if [ -f ${ConfigDir}/certificate.list ]; then rm -rf ${ConfigDir}/certificate.list; fi

echo
echo "*********************************** SEARCHING cloud resources **************************************"
echo
set -x
for keyvault in `az keyvault list --resource-group $RESOURCEGROUP -o table | tail -n +3 | awk {'print $2'}`
do
        az keyvault secret list --vault-name $keyvault -o table | tail -n +3 |  sed 's/"//g' > ${ConfigDir}/secret.list
        cat ${ConfigDir}/secret.list | while read linea
        do
                set -a $linea " "
                echo
                echo "***************************** Backup of secret $1 of KeyVault $keyvault *********************************"
                az keyvault secret backup --file ${BackupDir}/$keyvault.$1.$(date +%Y%m%d%H%M%S).bkp --vault-name $keyvault --name $1
        done
        az keyvault certificate list --vault-name $keyvault -o table | tail -n +3 |  sed 's/"//g' > ${ConfigDir}/certificate.list
        cat ${ConfigDir}/certificate.list | while read linea
        do
                set -a $linea " "
                echo
                echo "***************************** Backup of certificate $1 of KeyVault $keyvault *********************************"
                az keyvault certificate backup --file ${BackupDir}/$keyvault.$1.$(date +%Y%m%d%H%M%S).bkp --vault-name $keyvault --name $1
        done
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
az logout

