This repository contains code examples for setup PostgreSQL PaaS backup in Azure.

Repo layout:

```
├── avamar-PG-Azure-template.dockerfile
├── avamar-PG-Azure-template-Avamar.dockerfile
├── avamar-PG-Azure-template-DDBoostFS.dockerfile
├── dps-setup.json
├── dps-setup.sh
├── README1st.md (This file)
├── README-dockerfile.md
├── README-dps-setup.json.md
├── README-dps-setup.md
└── src
    ├── avamar
	│   ├── .avagent
    │   ├── backup-postgreSQL.sh
    ├── azure
    │   └── azure-cli.repo
    │   └── azurelogin.pem
    ├── ddboostfs
    │   └── boostfs.lockbox
    └── packages
        └── DockerEmbebed
		    └── 19.1
            └── 19.2
                ├── AvamarClient-linux-sles11-x86_64-19.2.100-155.rpm
                ├── DDBoostFS-7.0.0.0-633922.rhel.x86_64.rpm
                └── pgdg-redhat-repo-latest.noarch.rpm
			└── 19.3
			└── postgresql

```
How to deploy a DCI (Deploy Control Instance) (*)

```
- Deploy a standard VM (RedHat 8.1 (Ootpa) Standard_B2s)

```
(*) DCI is used to create docker images, IS NOT used to run docker containers

How to install this repo:

```
- Install git on Deploy Control Instance
	 sudo dnf install git
	 git clone https://<your_site>/<your_repo>.git
```
or
```
- Copy file <your_repo>.zip. Unzip.	 
```

Requirements when use DDboostFS
 
	a) Create DD Boost user (Data Domain side - sysadmin access or similar is required)

	```
	- user add <DDBoost user> role user
	- user password aging show
	- user password aging set <DDBoost user> max-days-between-change 99999
	```

	b) Create storage unit (Data Domain side - sysadmin access or similar is required)

	```
	- ddboost storage-unit create <storage-unit name> user <DDboost user>
	```
		
	c) Install DDBoostFS (DCI side)

	```	
	- sudo yum localinstall -y src/packages/DockerEmbebed/<version>/DDBoostFS-<version>.rhel.x86_64.rpm
	```

	d) Create a lockbox file (DCI side)

	```
	- sudo /opt/emc/boostfs/bin/boostfs lockbox set -u <DDboost user> -d <Data Domain> -s <storage-unit>
	```

	Note: Don't forget to add container name DNS record (forward and reverse) to DNS Server. 

Requirements when use NFS (to be complete)

Deployment sequence (from DCI):

1) Run ```dps-setup.sh -s``` to setup DCI environment.
   See file ``` README dps-setup.json ``` for more details
   
   Run ```az ad sp create-for-rbac``` to create cert (.pem) file. Please run before 'az login' to setup account if you are no logged in yet.
   ```	
   - az ad sp create-for-rbac --name 'PaaSBackup' --create-cert; mv ~/*.pem src/azure/azurelogin.pem
   ```

2) Run ```dps-setup.sh -p``` to prebuild dockerfile.
   See file ``` README dps-setup.json ``` for more details. Complete  ```dps-setup.json``` file before!!!.

3) Run ```dps-setup.sh -b``` to create a new docker images.
   See file ``` README dps-setup.json ``` for more details.

4) Run ```dps-setup.sh -d <hostname>``` to deploy a new contanier.
   See file ``` README dps-setup.json ``` for more details.
   
6) Configure an Avamar policy backup as usual.

```
==========================================================================================================================================
Reference resources

- Video demo https://youtu.be/isaHN4K6Quk 
- Code repository https://github.com/uniqs-devops/bkp-proxy.git 
- Leveraging Avamar for File Level Backup of apps running on Kubernetes https://github.com/cn-dp/K8s-Avamar 
- Data Protection: Avamar, NetWorker, Data Domain, RecoverPoint, PowerProtect, CSM https://nsrd.info/blog/2019/03/05/proof-of-concept-docker-with-boostfs/ 

==========================================================================================================================================
 

