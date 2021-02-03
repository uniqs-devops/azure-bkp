#!/bin/sh
FROM centos:latest
# Install SO packages
RUN yum install -y --setopt=tsflags=nodocs openssh-server \
 && yum install -y --setopt=tsflags=nodocs iproute net-tools initscripts \
 && yum install -y --setopt=tsflags=nodocs jq cronie\
 && yum clean all
workdir /tmp
RUN mkdir /DUMMYINSTALLDIR
# Copy PosgreSQL repo install package
COPY src/packages/DockerEmbebed/postgresql/pgdg-redhat-repo-latest.noarch.rpm /tmp
# Install PosgreSQL client & repo package
RUN yum install -y /tmp/pgdg-redhat-repo-latest.noarch.rpm
RUN yum install -y postgresql
# Copy  backup script
COPY src/avamar/backup-postgreSQL.sh /DUMMYINSTALLDIR
RUN chmod 755 /DUMMYINSTALLDIR/backup-postgreSQL.sh
# Copy .pem file 
COPY src/azure/azurelogin.pem /DUMMYINSTALLDIR
# Install AZ CLI
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
COPY src/azure/azure-cli.repo /etc/yum.repos.d
RUN yum install -y azure-cli
# json file
COPY dps-setup.json /DUMMYINSTALLDIR
# Open the SSH port
EXPOSE 22
