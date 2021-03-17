# Copy blobfuse repo install package
COPY src/packages/DockerEmbebed/blobstorage/boost-*.rpm /tmp/
COPY src/packages/DockerEmbebed/blobstorage/blobfuse-*-x86_64.rpm /tmp/
# Install blobfuse client 
RUN yum install -y /tmp/boost-*.rpm
RUN yum install -y /tmp/blobfuse-*-x86_64.rpm
# Copy  backup script
COPY src/avamar/backup-blobstorage.sh /DUMMYINSTALLDIR/etc/scripts
RUN chmod 755 /DUMMYINSTALLDIR/etc/scripts/backup-blobstorage.sh
