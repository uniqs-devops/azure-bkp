#!/bin/sh
FROM centos:latest
# Install SO packages
RUN yum install -y --setopt=tsflags=nodocs openssh-server \
 && yum install -y --setopt=tsflags=nodocs iproute net-tools initscripts \
 && yum install -y --setopt=tsflags=nodocs jq cronie\
 && yum clean all
workdir /tmp
# Create install folder
RUN mkdir -p /DUMMYINSTALLDIR/etc/scripts
# Copy .pem file 
COPY src/azure/azurelogin.pem /DUMMYINSTALLDIR
# Install AZ CLI
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
COPY src/azure/azure-cli.repo /etc/yum.repos.d
RUN yum install -y azure-cli
# json file
COPY dps-setup.json /DUMMYINSTALLDIR

