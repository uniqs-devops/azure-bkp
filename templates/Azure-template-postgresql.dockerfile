# Copy PosgreSQL client package
COPY src/packages/DockerEmbebed/postgresql/postgresql11-*.rhel8.x86_64.rpm /tmp
# Install PosgreSQL client 
RUN yum install -y /tmp/postgresql11-libs-11.11*.rhel8.x86_64.rpm
RUN yum install -y /tmp/postgresql11-11.11*.rhel8.x86_64.rpm
# Copy  backup script
COPY src/avamar/backup-postgresql.sh /DUMMYINSTALLDIR/etc/scripts
RUN chmod 755 /DUMMYINSTALLDIR/etc/scripts/backup-postgresql.sh
