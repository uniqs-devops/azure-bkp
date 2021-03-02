export resourceGroupName = "AutoProxyRG"
export templateUri = "/home/dps/azure-bkp/auxiliary_automation_procedures/PowerShell/StorageAcccount/storageaccountparameters.json"
export templateParameterFile = "/home/dps/azure-bkp/auxiliary_automation_procedures/PowerShell/StorageAcccount/storageaccountparameters.json"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterFile $templateParameterFile -Location eastus
#New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterFile $templateParameterFile -Location eastus
