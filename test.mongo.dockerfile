# #!/bin/sh
FROM centos:latest
# Install SO packages
RUN yum install -y --setopt=tsflags=nodocs openssh-server \
 && yum install -y --setopt=tsflags=nodocs iproute net-tools initscripts \
 && yum install -y --setopt=tsflags=nodocs jq cronie bind-utils\
 && yum clean all
workdir /tmp
# Create install folder
RUN mkdir -p /dockerclient/etc/scripts
# json file
COPY dps-setup.json /dockerclient
# Copy MongoDB repo install package
COPY src/packages/DockerEmbebed/mongodb/mongodb-database-tools-*.x86_64.rpm /tmp
# Install MongoDB client 
RUN yum install -y /tmp/mongodb-database-tools-*.x86_64.rpm
# Copy  backup script
COPY src/avamar/backup-MongoDB.sh /dockerclient/etc/scripts
RUN chmod 755 /dockerclient/etc/scripts/backup-MongoDB.sh
