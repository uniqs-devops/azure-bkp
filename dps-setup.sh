#!/bin/bash
# Install packages used by this DCI
# Read json file keys to complete files called by dockerfile
# Build a docker images
# Install docker container on host, kubernetes or openshift
# Usage:
#    -s | --setup 				to setup environment
#    -p | --prebuild 				to complete files
#    -b | --build    				to create a docker images
#    -d | --deploy   --host  <hostname> 	to run a new container on host
# 

function environment {
CONTAINER_NAME=`cat dps-setup.json  | jq -r '.container.containerName'`
RESOURCES=`jq '.azureResources[] | select(.type=="PG" and .resourceType != null)|.resourceType' dps-setup.json | sed 's/"//g'`
DD_SERVER=`cat dps-setup.json  | jq -r '.datadomain.datadomainServerName'`
STORAGE_UNIT=`cat dps-setup.json  | jq -r '.ddboosfs.storageUnit'`
RootBackupDir=`cat dps-setup.json  | jq -r '.datadomain.RootBackupDir'` 
AVAMAR_SERVER=`cat dps-setup.json  | jq -r '.avamar.avamarServerName'`
AVAMAR_DOMAIN=`cat dps-setup.json  | jq -r '.avamar.avamarDomain'`
KEY_VAULT=`cat dps-setup.json  | jq -r '.keyVaultName'`
AVEVERSION=`cat dps-setup.json  | jq -r '.avamar.avamarVersion'`
CLOUDPROVIDER=`cat dps-setup.json  | jq -r '.cloudProvider'` 
DOCKERTYPE=`cat dps-setup.json  | jq -r '.dockerType'`
USEAVAMAR=`cat dps-setup.json  | jq -r '.avamar.useAvamar'`
MOUNTTYPE=`cat dps-setup.json  | jq -r '.datadomain.mountType'`
INSTALLDIR=`cat dps-setup.json  | jq -r '.avamar.installDir'`
}
function setup {
# Install packeges needed by DCI
    sudo yum install -y yum-utils jq docker 
    sudo cp src/azure/azure-cli.repo /etc/yum.repos.d/azure-cli.repo; sudo yum install -y azure-cli
exit
}

function prebuild {
    environment
    # .avagent
    echo "--hostname="$CONTAINER_NAME> src/avamar/.avagent
    # Docker container
    cp avamar-PG-Azure-template.dockerfile avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
    #  
    echo "#/bin/bash" > src/avamar/setup.sh
    echo "mkdir -p /$RootBackupDir" >> src/avamar/setup.sh
    if [ $MOUNTTYPE = "DDBoostFS" ]; then
	# Ddboostfs & Lockbox
	  sudo /opt/emc/boostfs/bin/boostfs lockbox add-hosts $CONTAINER_NAME;  cp /opt/emc/boostfs/lockbox/boostfs.lockbox  src/ddboostfs/boostfs.lockbox
	  echo "#/opt/emc/boostfs/bin/boostfs mount -d $DD_SERVER -s $STORAGE_UNIT /mnt/$RootBackupDir" >> src/avamar/setup.sh
	  echo "echo '$DD_SERVER:/$STORAGE_UNIT /mnt/$RootBackupDir boostfs defaults,_netdev,bfsopt(nodsp.small_file_check=0,app-info="DDBoostFS") 0 0' >> /etc/fstab" >> src/avamar/setup.sh
	  cat avamar-PG-Azure-template-DDBoostFS.dockerfile >> avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
    fi
    if [ $USEAVAMAR = "YES" ]; then
    # Avamar
	  echo "/$INSTALLDIR/bin/avagent.bin --init --daemon=false --vardir=/$INSTALLDIR/var --bindir=/$INSTALLDIR/bin/ --sysdir=/$INSTALLDIR/etc/ --mcsaddr=$AVAMAR_SERVER --dpndomain=/$AVAMAR_DOMAIN --logfile=/$INSTALLDIR/var/avagent.log" >> src/avamar/setup.sh
	  echo "/$INSTALLDIR/bin/avagent.bin --vardir=/$INSTALLDIR/var --bindir=/$INSTALLDIR/bin/ --sysdir=/$INSTALLDIR/etc --logfile=/$INSTALLDIR/var/avagent.log" >> src/avamar/setup.sh
          cat avamar-PG-Azure-template-Avamar.dockerfile >> avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
	  sed -i -e "s/DUMMYVERSION/$AVEVERSION/g" avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
    else 
	  echo "echo '00 09 * * 1-5 $INSTALLDIR/backup-postgreSQL.sh' >> /var/spool/cron/root" >> src/avamar/setup.sh
    fi
    echo "COPY src/avamar/setup.sh /$INSTALLDIR" >> avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
    echo "RUN chmod 755 /$INSTALLDIR/setup.sh" >> avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
    echo "RUN /$INSTALLDIR/setup.sh" >> avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
    echo "# Cleanup /tmp folder, agent start  and Configuration persist" >> avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
    echo "RUN rm -f /tmp/*.rpm" >> avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
# About ENTRYPOINTs
    if [ $USEAVAMAR = "YES" ]; then
    	echo "ENTRYPOINT mount -a &&  [ -f /etc/init.d/avagent ] && /etc/init.d/avagent start && /bin/bash" >> avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
    else
    	echo "ENTRYPOINT mount -a && /bin/bash" >> avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
    fi   
    sed -i -e "s/DUMMYINSTALLDIR/$INSTALLDIR/g" avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile
    # azure
    echo $RESOURCES > src/avamar/resources
exit
}

function build {
# Docker
    environment
    sudo docker build -t avamar-$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER:1.0 -f avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER.dockerfile . --network host
exit
}

function deploy-launch {
# To support several docker technologies
    while [ "$1" != "" ]; do
	case $1 in
 		--host )                deploy-on-host $2
							;;
		--kubernetes )          deploy-on-kubernetes
							;;
		--openshift )           deploy-on-openshift
							;;
		-h | --help | --ayuda ) echo "Please type '--host' to Hold on host or '--kubernetes' to Hold on kubernetes or '--openshift' to Hold on openshift"
						exit
							;;
		* )                     echo "Please type '--host' to Hold on host or '--kubernetes' to Hold on kubernetes or '--openshift' to Hold on openshift"
						exit  1
	esac
    done
exit
}

function deploy-on-host {
# Deploy container on Openshift or Kubernetes cluster
# Keys must be configured before launch
    CONTAINER_NAME=`cat dps-setup.json  | jq -r '.container.containerName'`
    sudo docker save -o /tmp/avamar-pg.tar `sudo docker images | grep avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER | awk '{print $3}'`
    scp /tmp/avamar-pg.tar $1:/tmp
    ssh $1 sudo docker load \<\ /tmp/avamar-pg.tar
    ssh $1 sudo docker run --hostname $CONTAINER_NAME --name  -d -it --device /dev/fuse `sudo docker images | grep avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER | awk '{print $3}'` /bin/bash
    rm -f /tmp/avamar-pg.tar 
    # Deploy container on Openshift or Kubernetes cluster
    # Keys must be configured before launch
    environment
    CONTAINER_NAME=`cat dps-setup.json  | jq -r '.container.containerName'`
    sudo docker save -o /tmp/avamar-pg.img `sudo docker images | grep avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER | awk '{print $3}'`
    scp /tmp/avamar-pg.img $1:/tmp
    ssh $1 sudo docker load -i /tmp/avamar-pg.img
    ssh $1 sudo docker run --hostname $CONTAINER_NAME --name   -d -it --device /dev/fuse `sudo docker images | grep avamar-pg | awk '{print $3}'` /bin/bash
    rm -f /tmp/avamar-pg.img
exit
}

function deploy-on-kubernetes {
    #
exit
}

function deploy-on-openshift {
    #
exit
}

while [ "$1" != "" ]; do
    case $1 in
        -s | --setup )      	setup
                                ;;
        -p | --prebuild )      	prebuild
                                ;;
        -b | --build )         	build
                                ;;
        -d | --deploy )         if [ "$2" = "" ]; then echo "Please type '--host' to Hold on host or '--kubernetes' to Hold on kubernetes or '--openshift' to Hold on openshift"; exit 1; fi 
                                if [ "$3" = "" ]; then echo "Enter hostname"; exit 1; fi
								deploy-launch $2 $3
                                ;;
        -h | --help | --ayuda ) echo "Please type '-s | --setup' to Setup or '-p | --prebuild' to Prebuild or '-b | --build' to Build or '-d | --deploy' to Deploy"
                                exit
                                ;;
        * )                     echo "Please type '-s | --setup' to Setup or '-p | --prebuild' to Prebuild or '-b | --build' to Build or '-d | --deploy' to Deploy"
                                exit  1
    esac
done
