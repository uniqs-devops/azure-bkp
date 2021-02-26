- cloudProvider
``` Azure or AWS or GCP ```
- dockerType
``` PostgreSQL or CosmoDB or asset type to backup ```
- dockerTypeName
``` Sort of dockerType ```
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
- useAvamar
``` Use avamar to store backup data ```
- avamarServerName and datadomainServerName
``` Avamar and Data Domain FQDN ```
- avamarDomain
``` Avamar docker domain, eg. clients ```
- avamarVersion
``` Avamar version ```
- mountType
``` ddboostfs or nfs ```
- RootBackupDir
``` DDBoostFS or NFS mount point on container ```
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
