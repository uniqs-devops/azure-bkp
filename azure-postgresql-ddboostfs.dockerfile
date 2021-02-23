#!/bin/sh
FROM centos:latest
# Install SO packages
RUN yum install -y --setopt=tsflags=nodocs openssh-server \
 && yum install -y --setopt=tsflags=nodocs iproute net-tools initscripts \
 && yum install -y --setopt=tsflags=nodocs jq cronie\
 && yum clean all
workdir /tmp
# Create install folder
RUN mkdir -p /dockerclient/etc/scripts
# Copy .pem file 
COPY src/azure/azurelogin.pem /dockerclient
# Install AZ CLI
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
COPY src/azure/azure-cli.repo /etc/yum.repos.d
RUN yum install -y azure-cli
# json file
COPY dps-setup.json /dockerclient

# Copy PosgreSQL repo install package
COPY src/packages/DockerEmbebed/postgresql/pgdg-redhat-repo-latest.noarch.rpm /tmp
# Install PosgreSQL client & repo package
RUN yum install -y /tmp/pgdg-redhat-repo-latest.noarch.rpm
RUN yum install -y postgresql
# Copy  backup script
COPY src/avamar/backup-postgresql.sh /dockerclient/etc/scripts
RUN chmod 755 /dockerclient/etc/scripts/backup-postgresql.sh
# Copy DDBoostFS
COPY src/packages/DockerEmbebed/19.3/DDBoostFS*.rpm /tmp
# Install DDBoostFS
RUN yum localinstall -y /tmp/DDBoostFS*.rpm
# Copy DDBoostFS lockbox file
COPY src/ddboostfs/boostfs.lockbox /opt/emc/boostfs/lockbox/boostfs.lockbox
COPY src/avamar/setup.sh /dockerclient
RUN chmod 755 /dockerclient/setup.sh
RUN /dockerclient/setup.sh
# Cleanup /tmp folder, agent start  and Configuration persist
RUN rm -f /tmp/*.rpm
ENTRYPOINT mount -a && /bin/bash
