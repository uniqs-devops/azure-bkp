#!/bin/sh
FROM centos:latest
# Install SO packages
RUN yum install -y --setopt=tsflags=nodocs openssh-server \
 && yum install -y --setopt=tsflags=nodocs iproute net-tools initscripts \
 && yum install -y --setopt=tsflags=nodocs jq cronie bind-utils\
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

# Copy avamar Client to /tmp for installation
COPY src/packages/DockerEmbebed/avamar/19.3/AvamarClient-linux-sles11-x86_64-19.3.*.rpm /tmp
# Install avamar client usen RPM as Install Guide procedure
RUN rpm -ivh --relocate /usr/local/avamar=/dockerclient  /tmp/AvamarClient-linux-sles11-x86_64-19.3.*.rpm
#Copy .avagent file
COPY src/avamar/.avagent /dockerclient
# Avamar Client inbond ports
EXPOSE 28002
EXPOSE 30001
EXPOSE 30002
# Avamar Client outbond ports
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
# Copy MongoDB repo install package
COPY src/packages/DockerEmbebed/mongodb/mongodb-database-tools-*.x86_64.rpm /tmp
# Install MongoDB client 
RUN yum install -y /tmp/mongodb-database-tools-*.x86_64.rpm
# Copy  backup script
COPY src/avamar/backup-mongodb.sh /dockerclient/etc/scripts
RUN chmod 755 /dockerclient/etc/scripts/backup-mongodb.sh
COPY src/avamar/setup.sh /dockerclient
RUN chmod 755 /dockerclient/setup.sh
RUN /dockerclient/setup.sh
# Cleanup /tmp folder, agent start  and Configuration persist
RUN rm -f /tmp/*.rpm
RUN echo 127.0.1.1 dockermg-01.pcalvo.local > /etc/hosts && wget http://dockermg-01.pcalvo.local
CMD echo localhost localhost.localdomain dockermg-01.pcalvo.local > /etc/hosts; supervisord -n;
ENTRYPOINT mount -a &&  [ -f /etc/init.d/avagent ] && /etc/init.d/avagent start && /bin/bash
