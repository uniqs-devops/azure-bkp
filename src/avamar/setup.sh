#/bin/bash
mkdir -p /Backup
echo '00 09 * * 1-5 /dockerclient/etc/scripts/backup-mongodb.sh' >> /var/spool/cron/root
