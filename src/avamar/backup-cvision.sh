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
echo !!!!! `date +%Y%m%d.%T` starting process, service $SERVICE_TYPE  !!!!!
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
az resource list --resource-group $RESOURCEGROUP --resource-type $RESOURCES --query "[].{name:name}" -o tsv | grep -v Prediction > ${ConfigDir}/swoconfig
cat ${ConfigDir}/swoconfig | while read linea
do
        set -a $linea " "

        if [ "${1::1}" != "#" ] ; then
                key=$(az cognitiveservices account keys list --name $1 --resource-group $RESOURCEGROUP | jq -r '.key1')
                location=$(az resource show --resource-group $RESOURCEGROUP --resource-type $RESOURCES --name $1 | jq .location | sed 's/"//g')
                projectids=$(curl "https://$location.api.cognitive.microsoft.com/customvision/v3.3/Training/projects" -H "Training-key: $key" | jq '.' | grep id | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
                ERROR=0
                for projectid in ${projectids[@]}; do
                        echo !!!!! Getting token for $projectid cognitive service $1 !!!!!
                        token=$(curl "https://$location.api.cognitive.microsoft.com/customvision/v3.3/Training/projects/$projectid/export" -H "Training-key: $key" | jq '.' | grep token | awk '{print $2}' | sed 's/"//g')
                        echo "Token de $projectid: "$token
                        echo $token > ${ServiceBackupDir}/$projectid.bck
                        if [ $? != "0" ] || [ $? != "1" ]; then
                                echo "************************* `date +%Y%m%d.%T` ERROR 001: Unable to get token. EXIT *************************"
                                break
                        fi
                        echo !!!!! `date +%Y%m%d.%T` $task backup token ${token} in cognitive service $1 !!!!!
                done
        fi
done  < ${ConfigDir}/swoconfig
# Logout
az logout

