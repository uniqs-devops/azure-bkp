$resourceGroupName = "AutoProxyRG"
$templateUri = "C:\Users\juanp\OneDrive\Documentos\GitHub\uniqs-dps\auxiliary_automation_procedures\PowerShell\SQL\sqltemplate.json"
$templateParameterFile = "C:\Users\juanp\OneDrive\Documentos\GitHub\uniqs-dps\auxiliary_automation_procedures\PowerShell\SQL\sqlparameters.json"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterFile $templateParameterFile -Location centralus