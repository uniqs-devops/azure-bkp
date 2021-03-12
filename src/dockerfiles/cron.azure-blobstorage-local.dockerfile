#!/bin/sh
FROM centos:latest
# Install SO packages
RUN yum install -y --setopt=tsflags=nodocs openssh-server \
 && yum install -y --setopt=tsflags=nodocs iproute net-tools initscripts \
 && yum install -y --setopt=tsflags=nodocs jq cronie bind-utils wget \
 && yum clean all
workdir /tmp
# Create install folder
RUN mkdir -p /dockerclient/etc/scripts
# Copy .pem file 
COPY src/azure/azurelogin.pem /dockerclient
# Copy AZ CLI client package
COPY src/packages/DockerEmbebed/azcli/azure-cli-*.x86_64.rpm /tmp
# Install AZ CLI
RUN yum install -y /tmp/azure-cli-*.x86_64.rpm
# json file
COPY dps-setup.json /dockerclient

# Copy MongoDB repo install package
COPY src/packages/DockerEmbebed/blobstorage/boost-*.rpm /tmp
COPY src/packages/DockerEmbebed/blobstorage/blobfuse-*-x86_64.rpm /tmp
# Install MongoDB client 
RUN yum install -y /tmp/boost-*.rpm
RUN yum install -y /tmp/blobfuse-*-x86_64.rpm
# Copy  backup script
COPY src/avamar/backup-blobstorage.sh /dockerclient/etc/scripts
RUN chmod 755 /dockerclient/etc/scripts/backup-blobstorage.sh
COPY src/avamar/setup.sh /dockerclient
RUN chmod 755 /dockerclient/setup.sh
#RUN /dockerclient/setup.sh
# Cleanup /tmp folder, agent start  and Configuration persist
RUN rm -f /tmp/*.rpm
#CMD echo localhost localhost.localdomain dockerbs-01.shared.azure.scib.gs.corp > /etc/hosts; supervisord -n;
ENTRYPOINT mount -a && /bin/bash
