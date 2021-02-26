$resourceGroupName = "AutoProxyRG"
$templateUri = "C:\Users\juanp\OneDrive\Documentos\GitHub\uniqs-dps\auxiliary automation procedures\PowerShell\PostgreSQL\postgresqltemplate.json"
$templateParameterFile = "C:\Users\juanp\OneDrive\Documentos\GitHub\uniqs-dps\auxiliary automation procedures\PowerShell\PostgreSQL\postgresqlparameters.json"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterFile $templateParameterFile -Location centralus
az resource tag --tags 'bck_user=BackupUser@dbserver888' 'bck_port=5432' 'bck_database=postgres' 'bck_task=PostgreSQL' 'bck_server=dbserver888.postgres.database.azure.com' 'bck_secret=secret778' -g $resourceGroupName -n postgres888 --resource-type "Microsoft.DBforPostgreSQL/servers"