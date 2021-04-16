#!/bin/sh
FROM centos:latest
# Install SO packages
RUN yum install -y --setopt=tsflags=nodocs openssh-server \
 && yum install -y --setopt=tsflags=nodocs iproute net-tools initscripts \
 && yum install -y --setopt=tsflags=nodocs jq cronie bind-utils \
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

# Copy PosgreSQL client package
COPY src/packages/DockerEmbebed/mysql/*.rpm /tmp/
# Install PosgreSQL client 
RUN yum install -y /tmp/boost-program-options-1.53.0-28.el7.x86_64.rpm
RUN yum install -y /tmp/galera-4-26.4.4-1.rhel7.el7.centos.x86_64.rpm
RUN yum install -y /tmp/jemalloc-3.6.0-1.el7.x86_64.rpm
RUN yum install -y /tmp/libzstd-1.3.4-1.el7.x86_64.rpm
RUN yum install -y /tmp/MariaDB-common-10.4.18-1.el7.centos.x86_64.rpm
RUN yum install -y /tmp/MariaDB-compat-10.4.18-1.el7.centos.x86_64.rpm
RUN yum install -y /tmp/MariaDB-backup-10.4.18-1.el7.centos.x86_64.rpm
RUN yum install -y /tmp/MariaDB-client-10.4.18-1.el7.centos.x86_64.rpm

# Copy  backup script
COPY src/avamar/backup-mysql.sh /dockerclient/etc/scripts
RUN chmod 755 /dockerclient/etc/scripts/backup-mysql.sh
COPY src/avamar/setup.sh /dockerclient
RUN chmod 755 /dockerclient/setup.sh
RUN /dockerclient/setup.sh
# Cleanup /tmp folder, agent start  and Configuration persist
RUN rm -f /tmp/*.rpm
ENTRYPOINT mount -a && /bin/bash
