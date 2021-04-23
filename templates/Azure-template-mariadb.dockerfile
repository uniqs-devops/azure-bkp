# Copy MariaDB client package
COPY src/packages/DockerEmbebed/mariadb/*.rpm /tmp/
# Install MariaDB client 
RUN yum install -y /tmp/MariaDB-shared-*.x86_64.rpm
RUN yum install -y /tmp/MariaDB-common-*.x86_64.rpm
RUN yum install -y /tmp/MariaDB-client-*.x86_64.rpm
# Copy  backup script
COPY src/avamar/backup-mariadb.sh /DUMMYINSTALLDIR/etc/scripts
RUN chmod 755 /DUMMYINSTALLDIR/etc/scripts/backup-mariadb.sh
