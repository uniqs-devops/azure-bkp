# Install sqlpackage repated 
RUN yum install -y --setopt=tsflags=nodocs unzip libicu libssl.so.10 \
&& yum clean all
# Copy MongoDB repo install package
COPY src/packages/DockerEmbebed/sql/libunwind-1*.x86_64.rpm /tmp
RUN yum install -y /tmp/libunwind-1*.x86_64.rpm
COPY src/packages/DockerEmbebed/sql/sqlpackage-linux-x64-en-US-*.zip /tmp
RUN unzip /tmp/sqlpackage-linux-x64-en-US-*.zip -d /usr/local/bin
RUN chmod 744 /usr/local/bin/sqlpackage
# Copy  backup script
COPY src/BackupScripts/backup-sql.sh /DUMMYINSTALLDIR/etc/scripts
RUN chmod 755 /DUMMYINSTALLDIR/etc/scripts/backup-sql.sh
