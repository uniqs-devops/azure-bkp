#!/bin/sh
FROM centos:latest
# Install SO packages
RUN yum install -y --setopt=tsflags=nodocs openssh-server \
 && yum install -y --setopt=tsflags=nodocs iproute net-tools initscripts \
 && yum install -y --setopt=tsflags=nodocs jq cronie\
 && yum clean all
workdir /tmp
RUN mkdir /dockerclient
# Copy PosgreSQL repo install package
COPY src/packages/DockerEmbebed/postgresql/pgdg-redhat-repo-latest.noarch.rpm /tmp
# Install PosgreSQL client & repo package
RUN yum install -y /tmp/pgdg-redhat-repo-latest.noarch.rpm
RUN yum install -y postgresql
# Copy  backup script
COPY src/avamar/backup-postgreSQL.sh /dockerclient
RUN chmod 755 /dockerclient/backup-postgreSQL.sh
# Copy .pem file 
COPY src/azure/azurelogin.pem /dockerclient
# Install AZ CLI
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
COPY src/azure/azure-cli.repo /etc/yum.repos.d
RUN yum install -y azure-cli
# json file
COPY dps-setup.json /dockerclient
# Open the SSH port
EXPOSE 22
# Copy DDBoostFS
COPY src/packages/DockerEmbebed/19.2/DDBoostFS*.rpm /tmp
# Install DDBoostFS
RUN yum localinstall -y /tmp/DDBoostFS*.rpm
# Copy DDBoostFS lockbox file
COPY src/ddboostfs/boostfs.lockbox /opt/emc/boostfs/lockbox/boostfs.lockbox
# Copy avamar Client to /tmp for installation
COPY src/packages/DockerEmbebed/19.2/AvamarClient-linux-sles11-x86_64-19.2.*.rpm /tmp
# Install avamar client usen RPM as Install Guide procedure
RUN rpm -ivh --relocate /usr/local/avamar=/dockerclient  /tmp/AvamarClient-linux-sles11-x86_64-19.2.*.rpm
#Copy .avagent file
COPY src/avamar/.avagent /dockerclient
# Avamar Client inbound ports
EXPOSE 28002
EXPOSE 30001
EXPOSE 30002
# Avamar Client outbound ports
EXPOSE 53
EXPOSE 123
EXPOSE 443
EXPOSE 3008
EXPOSE 8105
EXPOSE 8109
EXPOSE 8181
EXPOSE 8444
EXPOSE 27000
EXPOSE 27001
EXPOSE 29000
EXPOSE 30101
EXPOSE 30102
COPY src/avamar/setup.sh /dockerclient
RUN chmod 755 /dockerclient/setup.sh
RUN /dockerclient/setup.sh
# Cleanup /tmp folder, agent start  and Configuration persist
RUN rm -f /tmp/*.rpm
ENTRYPOINT mount -a &&  [ -f /etc/init.d/avagent ] && /etc/init.d/avagent start && /bin/bash
