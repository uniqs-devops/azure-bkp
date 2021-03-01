$resourceGroupName = "AutoProxyRG"
$templateUri = "C:\Users\juanp\OneDrive\Documentos\GitHub\uniqs-dps\auxiliary_automation_procedures\PowerShell\KeyVault\keyvaulttemplate.json"
$templateParameterFile = "C:\Users\juanp\OneDrive\Documentos\GitHub\uniqs-dps\auxiliary_automation_procedures\PowerShell\KeyVault\keyvaultparameters.json" 
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterFile $templateParameterFile -Location eastus
