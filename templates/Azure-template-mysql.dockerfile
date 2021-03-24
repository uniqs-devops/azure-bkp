# Copy PosgreSQL client package
COPY src/packages/DockerEmbebed/mysql/*.rpm /tmp/
# Install PosgreSQL client 
RUN yum install -y /tmp/boost-program-options-1.53.0-28.el7.x86_64.rpm
RUN yum install -y /tmp/galera-4-26.4.4-1.rhel7.el7.centos.x86_64.rpm
RUN yum install -y /tmp/jemalloc-3.6.0-1.el7.x86_64.rpm
RUN yum install -y /tmp/libzstd-1.3.4-1.el7.x86_64.rpm
RUN yum install -y /tmp/MariaDB-common-10.4.18-1.el7.centos.x86_64.rpm
RUN yum install -y /tmp/MariaDB-compat-10.4.18-1.el7.centos.x86_64.rpm
RUN yum install -y /tmp/MariaDB-backup-10.4.18-1.el7.centos.x86_64.rpm
RUN yum install -y /tmp/MariaDB-client-10.4.18-1.el7.centos.x86_64.rpm

# Copy  backup script
COPY src/avamar/backup-mysql.sh /DUMMYINSTALLDIR/etc/scripts
RUN chmod 755 /DUMMYINSTALLDIR/etc/scripts/backup-mysql.sh
