- cloudProvider
``` Azure or AWS or GCP ```
- dockerType
``` "postgresql" or "sql" or "keyvault" or "mongodb" or asset type to backup ```
``` is a restricted name ```
- dockerTypeName
``` Sort of dockerType ```
``` "PG" or "SQL" or "KV" or "MG" ```
``` is a restricted name ```
- keyVaultName
``` Azure Kay Vault name ```
- tenantId
``` Tenantid ```
- resourceGroup
``` resurce group name or all to all RGs ```
- useTags
``` tags or default values using fixValues ```
- useFQDN
``` FQDN or IP through nslookup ```
- proxy
``` YES if docker file needs proxy ENV variables ```
- cers
``` YES if certificate is needed ```
- useServicePrincipal
``` YES for SPN ```
- servicePrincipalClientId
``` Service principal client id```
- servicePrincipalClientSecret
``` Service principal client password```
- useAvamar
``` Use avamar to store backup data ```
- avamarServerName and datadomainServerName
``` Avamar and Data Domain FQDN ```
- avamarDomain
``` Avamar docker domain, eg. clients ```
- avamarVersion
``` Avamar version ```
- mountType
``` ddboostfs or local or nfs (not implemented yet) ```
- RootBackupDir
``` DDBoostFS or local mount point on container ```
- storageUnit
``` Data Domain Storage Unit used to hold data ```
- containerName
``` FQDN of contanier used to register this client on Avamar. Add forward and reverse DNS records to DNS Server ```
- resourceType
``` Azure resurce type to be discover ```
- backupTags \ Type
``` Type of tag ```
- backupTags \ Value
``` Value of type tag ```
- fixValues \ Type
``` Type of tag```
- fixValues \ Type
``` Hardcoded value ```
