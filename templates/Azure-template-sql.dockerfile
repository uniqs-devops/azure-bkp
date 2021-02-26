# Install sqlpackage repated 
RUN yum install -y --setopt=tsflags=nodocs unzip  libicu \
&& yum clean all
# Copy MongoDB repo install package
COPY src/packages/DockerEmbebed/sql/sqlpackage-linux-x64-en-US-*.zip /tmp
RUN unzip /tmp/sqlpackage-linux-x64-en-US-*.zip -d /usr/local/bin
RUN chmod 744 /usr/local/bin/sqlpackage
# Copy  backup script
COPY src/avamar/backup-sql.sh /DUMMYINSTALLDIR/etc/scripts
RUN chmod 755 /DUMMYINSTALLDIR/etc/scripts/backup-sql.sh
