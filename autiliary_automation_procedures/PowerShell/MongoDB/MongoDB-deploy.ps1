$resourceGroupName = "AutoProxyRG"
$templateUri = "C:\Users\juanp\OneDrive\Documentos\GitHub\Automation\MongoDB\mongodbparameters.json"
$templateParameterFile = "C:\Users\juanp\OneDrive\Documentos\GitHub\Automation\MongoDB\mongodbparameters.json"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterFile $templateParameterFile -Location eastus
az resource tag --tags 'bck_user=BackupUser@dbserver777' 'bck_port=5432' 'bck_database=postgres' 'bck_task=PostgreSQL' 'bck_server=dbserver777.postgres.database.azure.com' 'bck_secret=secret777' -g $resourceGroupName -n postgres777 --resource-type "Microsoft.DBforPostgreSQL/servers"