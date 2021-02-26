$resourceGroupName = "AutoProxyRG"
$templateUri = "C:\Users\juanp\OneDrive\Documentos\GitHub\Automation\KeyVault\keyvaulttemplate.json"
$templateParameterFile = "C:\Users\juanp\OneDrive\Documentos\GitHub\Automation\KeyVault\keyvaultparameters.json"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterFile $templateParameterFile -Location eastus
