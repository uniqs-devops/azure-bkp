$resourceGroupName = "AutoProxyRG"
$templateUri = "C:\Users\juanp\OneDrive\Documentos\GitHub\Automation\MongoDB\mongodbtemplate.json"
$templateParameterFile = "C:\Users\juanp\OneDrive\Documentos\GitHub\Automation\MongoDB\mongodbparameters.json"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterFile $templateParameterFile -Location centralus