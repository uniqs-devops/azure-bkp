# Copy PosgreSQL client package
COPY src/packages/DockerEmbebed/postgresql/postgresql12-*.rhel8.x86_64.rpm /tmp/
# Install PosgreSQL client 
RUN yum install -y /tmp/postgresql12-libs-*.rhel8.x86_64.rpm
RUN yum install -y /tmp/postgresql12-*.rhel8.x86_64.rpm
# Copy  backup script
COPY src/avamar/backup-postgresql.sh /DUMMYINSTALLDIR/etc/scripts
RUN chmod 755 /DUMMYINSTALLDIR/etc/scripts/backup-postgresql.sh
