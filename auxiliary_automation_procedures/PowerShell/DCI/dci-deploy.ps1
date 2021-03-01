#Connect-AzAccount 
$location = Read-Host -Prompt "Enter the location (i.e. centralus) " 
$resourceGroupName = "AutoProxyRG"
$templateUri = "C:\Users\juanp\OneDrive\Documentos\GitHub\Automation\DCI\dcitemplate.json"
$templateParameterFile = "C:\Users\juanp\OneDrive\Documentos\GitHub\Automation\DCI\dciparameters.json"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterFile $templateParameterFile -Location $location
az vm identity assign -g $resourceGroupName -n dci
