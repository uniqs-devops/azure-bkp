# Create install folder
RUN mkdir -p /DUMMYINSTALLDIR/etc/scripts
# Copy .pem file 
COPY src/azure/azurelogin.pem /DUMMYINSTALLDIR
# Copy AZ CLI client package
COPY src/packages/DockerEmbebed/azcli/azure-cli-*.x86_64.rpm /tmp
# Install AZ CLI
RUN yum install -y /tmp/azure-cli-*.x86_64.rpm
# json file
COPY dps-setup.json /DUMMYINSTALLDIR

