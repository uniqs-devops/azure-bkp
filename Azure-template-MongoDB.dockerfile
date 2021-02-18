# Copy MongoDB repo install package
COPY src/mongodb/mongodb-org-4.4.repo /etc/yum.repos.d
# Install MongoDB client 
RUN yum install -y mongodb-org
# Copy  backup script
COPY src/avamar/backup-MongoDB.sh /DUMMYINSTALLDIR/etc/scripts
RUN chmod 755 /DUMMYINSTALLDIR/etc/scripts/backup-MongoDB.sh
