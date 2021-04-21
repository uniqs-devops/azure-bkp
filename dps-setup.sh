#!/bin/bash
# Install packages used by this DCI
# Read json file keys to complete files called by dockerfile
# Build a docker images
# Install docker container on host, kubernetes or openshift
# Usage:
#    -s | --setup                               to setup environment
#    -p | --prebuild                            to complete files
#    -b | --build                               to create a docker images
#    -d | --deploy   --host  <hostname>         to run a new container on host
#
function environment {
CONTAINER_NAME=`cat dps-setup.json  | jq -r '.container.containerName'`
RESOURCES=`jq '.azureResources[] | select(.type=="PG" and .resourceType != null)|.resourceType' dps-setup.json | sed 's/"//g'`
DD_SERVER=`cat dps-setup.json  | jq -r '.datadomain.datadomainServerName'`
DDBOOST_USER=`cat dps-setup.json  | jq -r '.ddboosfs.ddboostuser'`
STORAGE_UNIT=`cat dps-setup.json  | jq -r '.ddboosfs.storageUnit'`
RootBackupDir=`cat dps-setup.json  | jq -r '.datadomain.RootBackupDir'`
AVAMAR_SERVER=`cat dps-setup.json  | jq -r '.avamar.avamarServerName'`
PORT=`cat dps-setup.json  | jq -r '.avamar.avamarClientPort'`
AVAMAR_DOMAIN=`cat dps-setup.json  | jq -r '.avamar.avamarDomain'`
KEY_VAULT=`cat dps-setup.json  | jq -r '.keyVaultName'`
AVEVERSION=`cat dps-setup.json  | jq -r '.avamar.avamarVersion'`
CLOUDPROVIDER=`cat dps-setup.json  | jq -r '.cloudProvider'`
DOCKERTYPE=`cat dps-setup.json  | jq -r '.dockerType'`
USEAVAMAR=`cat dps-setup.json  | jq -r '.avamar.useAvamar'`
MOUNTTYPE=`cat dps-setup.json  | jq -r '.datadomain.mountType'`
INSTALLDIR=`cat dps-setup.json  | jq -r '.avamar.installDir'`
USEPROXY=`cat dps-setup.json  | jq -r '.proxy.useProxy'`
PROXYHTTPNAME=`cat dps-setup.json  | jq -r '.proxy.proxyHttpName'`
PROXYHTTPSNAME=`cat dps-setup.json  | jq -r '.proxy.proxyHttpsName'`
NOPROXY=`cat dps-setup.json  | jq -r '.proxy.noProxy'`
USECERTS=`cat dps-setup.json  | jq -r '.certs.useCerts'`
CERTFILE=`cat dps-setup.json  | jq -r '.certs.certFile'`
Dockerfolder=src/dockerfiles/current
DockerfileName=$Dockerfolder/$CLOUDPROVIDER-$DOCKERTYPE-$MOUNTTYPE.dockerfile
if [ $USEAVAMAR = "YES" ]; then
        DockerfileName=$Dockerfolder/avamar.$AVEVERSION.$CLOUDPROVIDER-$DOCKERTYPE-$MOUNTTYPE.dockerfile
else
        DockerfileName=$Dockerfolder/cron.$CLOUDPROVIDER-$DOCKERTYPE-$MOUNTTYPE.dockerfile
fi
}
function setup {
# Install packeges needed by DCI
    sudo yum install -y yum-utils jq docker
    if [ -f src/packages/DockerEmbebed/azcli/azure-cli-*.rpm ] ; then
        sudo yum install -y src/packages/DockerEmbebed/azcli/azure-cli-*.rpm
    else
        sudo cp src/azure/azure-cli.repo /etc/yum.repos.d/azure-cli.repo; sudo yum install -y azure-cli
    fi
    if [ -f src/images/centos.tar ] && [ ! `sudo docker images | grep centos | awk '{print $3}'` ] ; then
            sudo docker load -i src/images/centos.tar  centos:latest
   fi
exit
}

function prebuild {
    # Get environment
    environment
    # Docker container baseline
    cp templates/Azure-header.dockerfile temp.dockerfile
    files=$(shopt -s nullglob dotglob; echo $Dockerfolder/*)
    if (( ${#files} )); then rm -rf $Dockerfolder/*.dockerfile; fi
    if [ $USECERTS = "YES" ]; then
      echo "#Certs configs" >> temp.dockerfile
      echo "COPY src/packages/DockerEmbebed/certificates/$CERTFILE /etc/pki/ca-trust/source/anchors/" >> temp.dockerfile
      echo "RUN update-ca-trust" >> temp.dockerfile
    fi
    if [ $USEPROXY = "YES" ]; then
      echo "#Proxy config" >> temp.dockerfile
      echo "ENV HTTP_PROXY=$PROXYHTTPNAME" >> temp.dockerfile
      echo "ENV HTTPS_PROXY=$PROXYHTTPSNAME" >> temp.dockerfile
      echo "ENV http_proxy=$PROXYHTTPNAME" >> temp.dockerfile
      echo "ENV https_proxy=$PROXYHTTPSNAME" >> temp.dockerfile
      echo "ENV NO_PROXY=$NOPROXY" >> temp.dockerfile
    fi
    cat templates/Azure-template.dockerfile >> temp.dockerfile
    #
    echo "#/bin/bash" > src/avamar/post_install.sh
    echo "read -n 1 -r -s -p $'Root backup dir creation, press enter to continue...\n'" > src/avamar/post_install.sh
    echo "mkdir -p /$RootBackupDir" >> src/avamar/post_install.sh
    if [ $USEAVAMAR = "YES" ]; then
      DockerfileName=$Dockerfolder/avamar.$AVEVERSION.$CLOUDPROVIDER-$DOCKERTYPE-$MOUNTTYPE.dockerfile
      # .avagent
      echo "--hostname="$CONTAINER_NAME > src/avamar/.avagent
      echo "--listenport="$PORT >> src/avamar/.avagent
      # Avamar
      echo "read -n 1 -r -s -p $'Avamar client registration on server $AVAMAR_SERVER domain /$AVAMAR_DOMAIN, press enter to continue...\n'" >> src/avamar/post_install.sh
      echo "/$INSTALLDIR/bin/avregister" >> src/avamar/post_install.sh
      echo "read -n 1 -r -s -p $'Agent restart, press enter to continue...\n'" >> src/avamar/post_install.sh
      echo "/etc/init.d/avagent restart" >> src/avamar/post_install.sh
      cat templates/Azure-template-Avamar.dockerfile >> temp.dockerfile
    else
      DockerfileName=$Dockerfolder/cron.$CLOUDPROVIDER-$DOCKERTYPE-$MOUNTTYPE.dockerfile
      echo "echo Crontab install" > src/avamar/post_install.sh
      echo "echo '00 09 * * 1-5 /$INSTALLDIR/etc/scripts/backup-$DOCKERTYPE.sh' >> /var/spool/cron/root" >> src/avamar/post_install.sh
    fi
        cat templates/Azure-template-$DOCKERTYPE.dockerfile >> temp.dockerfile
    if [ $MOUNTTYPE = "ddboostfs" ]; then
        # Ddboostfs & Lockbox
          echo "read -n 1 -r -s -p $'Creating lockbox file, press enter to continue...\n'" >> src/avamar/post_install.sh
          echo "/opt/emc/boostfs/bin/boostfs lockbox set -u $DDBOOST_USER -d $DD_SERVER -s $STORAGE_UNIT" >> src/avamar/post_install.sh
          echo "read -n 1 -r -s -p $'Adding line in /etc/fstab, press enter to continue...\n'" >> src/avamar/post_install.sh
          echo "echo '$DD_SERVER:/$STORAGE_UNIT /$RootBackupDir boostfs defaults,_netdev,bfsopt(nodsp.small_file_check=0,app-info="DDBoostFS") 0 0' >> /etc/fstab" >> src/avamar/post_install.sh
          echo "read -n 1 -r -s -p $'Mounting through /etc/fstab, press enter to continue...\n'" >> src/avamar/post_install.sh
          echo "mount -a" >> src/avamar/post_install.sh
          cat templates/Azure-template-DDBoostFS.dockerfile >> temp.dockerfile
        fi
    echo "COPY src/avamar/post_install.sh /$INSTALLDIR" >> temp.dockerfile
    echo "RUN chmod 755 /$INSTALLDIR/post_install.sh" >> temp.dockerfile
    echo "# Cleanup /tmp folder, agent start  and Configuration persist" >> temp.dockerfile
    echo "RUN rm -f /tmp/*.rpm" >> temp.dockerfile
    # About ENTRYPOINTs
    echo "ENTRYPOINT /bin/bash" >> temp.dockerfile
    sed -i -e "s/DUMMYINSTALLDIR/$INSTALLDIR/g" temp.dockerfile
    sed -i -e "s/PORT/$PORT/g" temp.dockerfile
    sed -i -e "s/DUMMYVERSION/$AVEVERSION/g" temp.dockerfile
    sed -i -e "s/DUMMYINSTALLDIR/$INSTALLDIR/g" src/avamar/backup-$DOCKERTYPE.sh
    sed -i -e "s/CONTAINER_NAME/$CONTAINER_NAME/g" src/avamar/backup-$DOCKERTYPE.sh
    # azure
    echo $RESOURCES > src/avamar/resources
    # Dockerfile Name
    mv temp.dockerfile $DockerfileName
exit
}

function build {
# Docker
    environment
    sudo docker build -t $DockerfileName:1.0 -f $DockerfileName . --network host --add-host $CONTAINER_NAME:127.0.1.1
exit
}

function deploy-launch {
# To support several docker technologies
    while [ "$1" != "" ]; do
        case $1 in
                --local )               deploy-here
                                                        ;;
                --host  )
                        if [ "$2" = "" ]; then echo "Enter hostname"; exit 1; fi
                                        deploy-on-host $2
                                                        ;;
                --kubernetes )          deploy-on-kubernetes
                                                        ;;
                --openshift )           deploy-on-openshift
                                                        ;;
                -h | --help | --ayuda ) echo "Please type '--local' to Hold here '--host' to Hold on host or '--kubernetes' to Hold on kubernetes or '--openshift' to Hold on openshift"
                                                exit
                                                        ;;
                * )                     echo "Please type '--local' to Hold here '--host' to Hold on host or '--kubernetes' to Hold on kubernetes or '--openshift' to Hold on openshift"
                                                exit  1
        esac
    done
exit
}

function deploy-here {
    environment
    if [ $DOCKERTYPE = "blobstorage" ]; then
          if [ $USEAVAMAR = "YES" ]; then
                sudo docker run --hostname $CONTAINER_NAME --name azure-$DOCKERTYPE -d -it --device /dev/fuse -p $PORT:$PORT -p 30001:30001 -p 30002:30002 -p 27000:27000 -p 28001:28001 -p 29000:29000 -p 30001:30001  -p 30003:30003  -p 27000:27000  -P --cap-add SYS_ADMIN  --network host --privileged `sudo docker images | grep $DockerfileName | awk '{print $3}'` /bin/bash
         else
                sudo docker run --hostname $CONTAINER_NAME --name azure-$DOCKERTYPE -d -it --device /dev/fuse --cap-add SYS_ADMIN  --network host --privileged `sudo docker images | grep $DockerfileName | awk '{print $3}'` /bin/bash
         fi
    else
         if [ $USEAVAMAR = "YES" ]; then
                sudo docker run --hostname $CONTAINER_NAME --name azure-$DOCKERTYPE -d -it --device /dev/fuse --cap-add SYS_ADMIN -p $PORT:$PORT -p 30001:30001 -p 30002:30002 -p 27000:27000 -p 28001:28001 -p 29000:29000 -p 30001:30001  -p 30003:30003  -p 27000:27000 -P --network host  `sudo docker images | grep $DockerfileName | awk '{print $3}'` /bin/bash
        else
                sudo docker run --hostname $CONTAINER_NAME --name azure-$DOCKERTYPE -d -it --device /dev/fuse --cap-add SYS_ADMIN --network host  `sudo docker images | grep $DockerfileName | awk '{print $3}'` /bin/bash
        fi
    fi
exit
}

function deploy-on-host {
# Deploy container on Openshift or Kubernetes cluster
# Keys must be configured before launch
    CONTAINER_NAME=`cat dps-setup.json  | jq -r '.container.containerName'`
    sudo docker save -o /tmp/avamar-pg.tar `sudo docker images | grep avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER | awk '{print $3}'`
    scp /tmp/avamar-pg.tar $1:/tmp
    ssh $1 sudo docker load \<\ /tmp/avamar-pg.tar
    if [ $DOCKERTYPE = "blobstorage" ]; then
      ssh $1 sudo docker run --hostname $CONTAINER_NAME --name  -d -it --device /dev/fuse --cap-add SYS_ADMIN  --network host --privileged `sudo docker images | grep avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER | awk '{print $3}'` /bin/bash
    else
      ssh $1 sudo docker run --hostname $CONTAINER_NAME --name  -d -it --device /dev/fuse --cap-add SYS_ADMIN  --network host  `sudo docker images | grep avamar.$AVEVERSION-$DOCKERTYPE-$CLOUDPROVIDER | awk '{print $3}'` /bin/bash
    fi
    rm -f /tmp/avamar-pg.tar
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
        -s | --setup )          setup
                                ;;
        -p | --prebuild )       prebuild
                                ;;
        -b | --build )          build
                                ;;
        -d | --deploy )         if [ "$2" = "" ]; then echo "Please type '--local' to Hold here '--host' to Hold on host or '--kubernetes' to Hold on kubernetes or '--openshift' to Hold on openshift"; exit 1; fi
                                deploy-launch $2 $3
                                ;;
        -h | --help | --ayuda ) echo "Please type '--local' to Hold here '--host' to Hold on host or '--kubernetes' to Hold on kubernetes or '--openshift' to Hold on openshift"
                                exit
                                ;;
        * )                     echo "Please type '--local' to Hold here '--host' to Hold on host or '--kubernetes' to Hold on kubernetes or '--openshift' to Hold on openshift"
                                exit  1
    esac
done
