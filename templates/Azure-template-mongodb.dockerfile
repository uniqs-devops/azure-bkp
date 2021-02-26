# Copy MongoDB repo install package
COPY src/packages/DockerEmbebed/mongodb/mongodb-database-tools-*.x86_64.rpm /tmp
# Install MongoDB client 
RUN yum install -y /tmp/mongodb-database-tools-*.x86_64.rpm
# Copy  backup script
COPY src/avamar/backup-mongodb.sh /DUMMYINSTALLDIR/etc/scripts
RUN chmod 755 /DUMMYINSTALLDIR/etc/scripts/backup-mongodb.sh
