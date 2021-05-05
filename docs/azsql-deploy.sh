#!/bin/bash
# Creates a AZ SQL server and database 
# Prompt for parameters
# To run: cd $HOME/az-dps-azure-sql; docs/automation/azsql-deploy.sh
#
read -p "Enter resource group [SANTANDERBCK]: " resourceGroupName
resourceGroupName=${resourceGroupName:-SANTANDERBCK}
read -p "Enter template file [docs/automation/azsql-template.json]: " templateFile
templateFile=${templateFile:-docs/automation/azsql-template.json}
read -p "Enter parameters file [docs/automation/azsql-parameters.json]: " templateParameterFile
templateParameterFile=${templateParameterFile:-docs/automation/azsql-parameters.json}
read -p "Enter resource name [sand2weusqlplatfoglob001]: " resourcename
resourcename=${resourcename:-sand2weusqlplatfoglob001}
read -p "Enter username [pablo.calvo@uniqs.com.ar]: " username
username=${username:-pablo.calvo@uniqs.com.ar}
read -p "Enter Tenant id [6299e5dd-5f24-42d9-b428-4aa9c7721fc4]: " tenantid
tenantid=${tenantid:-6299e5dd-5f24-42d9-b428-4aa9c7721fc4}
az login -u $username --tenant $tenantid
az deployment group create --resource-group $resourceGroupName --template-file $templateFile --parameters $templateParameterFile --name $resourcename
