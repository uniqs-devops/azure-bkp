# Libs install
 RUN yum install -y --setopt=tsflags=nodocs cyrus-sasl cyrus-sasl-devel \
 && yum clean all
workdir /tmp
# Copy PosgreSQL client package
COPY src/packages/DockerEmbebed/mysql/mysql-community-*.x86_64.rpm /tmp/
# Install PosgreSQL client 
RUN yum install -y /tmp/mysql-community-common-*.x86_64.rpm
RUN yum install -y /tmp/mysql-community-client-plugins-*.x86_64.rpm
RUN yum install -y /tmp/mysql-community-libs-*.x86_64.rpm
RUN yum install -y /tmp/mysql-community-client-*.x86_64.rpm

# Copy  backup script
COPY src/avamar/backup-mysql.sh /DUMMYINSTALLDIR/etc/scripts
RUN chmod 755 /DUMMYINSTALLDIR/etc/scripts/backup-mysql.sh
