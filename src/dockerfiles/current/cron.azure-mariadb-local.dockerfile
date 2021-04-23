#!/bin/sh
FROM centos:ave-dd-az-v1
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

# Copy MariaDB client package
COPY src/packages/DockerEmbebed/mariadb/*.rpm /tmp/
# Install MariaDB client 
RUN yum install -y /tmp/MariaDB-shared-*.x86_64.rpm
RUN yum install -y /tmp/MariaDB-common-*.x86_64.rpm
RUN yum install -y /tmp/MariaDB-client-*.x86_64.rpm
# Copy  backup script
COPY src/avamar/backup-mariadb.sh /dockerclient/etc/scripts
RUN chmod 755 /dockerclient/etc/scripts/backup-mariadb.sh
COPY src/avamar/post_install.sh /dockerclient
RUN chmod 755 /dockerclient/post_install.sh
# Cleanup /tmp folder, agent start  and Configuration persist
RUN rm -f /tmp/*.rpm
ENTRYPOINT /bin/bash
