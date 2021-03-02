# Copy avamar Client to /tmp for installation
COPY src/packages/DockerEmbebed/avamar/DUMMYVERSION/AvamarClient-linux-sles11-x86_64-DUMMYVERSION.*.rpm /tmp
# Install avamar client usen RPM as Install Guide procedure
RUN rpm -ivh --relocate /usr/local/BackupScripts=/DUMMYINSTALLDIR  /tmp/AvamarClient-linux-sles11-x86_64-DUMMYVERSION.*.rpm
#Copy .avagent file
COPY src/BackupScripts/.avagent /DUMMYINSTALLDIR
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
