echo Crontab install
echo '00 09 * * 1-5 /dockerclient/etc/scripts/backup-mariadb.sh' >> /var/spool/cron/root
