# Copy PosgreSQL client package
COPY src/packages/DockerEmbebed/postgresql/postgresql11-11.9-1PGDG.rhel8.x86_64.rpm /tmp
# Install PosgreSQL client 
RUN yum install -y /tmp/postgresql11-11.9-1PGDG.rhel8.x86_64.rpm
# Copy  backup script
COPY src/avamar/backup-postgreSQL.sh /DUMMYINSTALLDIR/etc/scripts
RUN chmod 755 /DUMMYINSTALLDIR/etc/scripts/backup-postgreSQL.sh
