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
- useKeyVaultSecureAccess
``` Keyvault access using curl or az cli ```
- useProxy
``` YES if docker file needs proxy ENV variables ```
- proxyHttpName and proxyHttpsName
``` Proxies FQDN and port values ```
- noProxy
``` No proxy for FQDNs (comma separated)  ```
- changeDefaultsubscription
``` YES to change from default suscription ``` 
- subscriptionID
``` Subuscrition ID ```
- useCerts
``` YES if certificate is needed ```
- cers
``` Certificate name or * to include all src/packages/DockerEmbebed/certificates/ ```
- useServicePrincipal
``` YES for SPN ```
- servicePrincipalClientId
``` Service principal client id```
- servicePrincipalClientSecret
``` Service principal client password```
- useEndPoints
``` YES if end points are used```
- EndPoint
``` End point FQDN or IP```
- useAvamar
``` Use avamar to store backup data ```
- avamarClientPort
``` Avamar client port, FROM 28003 ```
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
- ddboostuser
``` ddboost user used to connect this container to DD ```
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
- postgresql
``` YES for pg_dumpall, NO for pg_dump ```
``` PostgreSQL related ```
