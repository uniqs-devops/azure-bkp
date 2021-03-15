This repository contains code examples for setup PostgreSQL. Azure SQL, CosmoDB (MongoDB), Storage Account and Keyvault PaaS backup in Azure.

# Repo layout 

```
auxiliary_automation_procedures : Powershell script to create azure objects for test purposes.
docs : Documents
src/avamar/ : Avamar config files. Backup scripts
src/azure/  : Pem file to avoid expouse password 
src/ddboostfs/ : DDBoost FS lockbox file  
src/dockerfiles/ : Docker file work space
packages/AvamarServerPackages : Unused
src/packages/DockerEmbebed/ : Packages used by dockerfiles to configure containers
```


# How to deploy a DCI (Deploy Control Instance) (*)


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
	- sudo yum localinstall -y src/packages/DockerEmbebed/ddboostfs/DDBoostFS-<version>.rhel.x86_64.rpm
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

