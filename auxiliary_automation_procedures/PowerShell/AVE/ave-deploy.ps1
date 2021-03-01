Connect-AzAccount 
$location = Read-Host -Prompt "Enter the location (i.e. centralus) " 
$resourceGroupName = "AutoProxyRG"
$templateUri = "C:\Users\juanp\OneDrive\Documentos\GitHub\uniqs-dps\auxiliary automation procedures\PowerShell\AVE\avetemplate.json"
$templateParameterFile = "C:\Users\juanp\OneDrive\Documentos\GitHub\uniqs-dps\auxiliary automation procedures\PowerShell\AVE\aveparameters.json"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterFile $templateParameterFile -Location $location
#az vm identity assign -g $resourceGroupName -n dci
