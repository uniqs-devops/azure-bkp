#/bin/bash
mkdir -p /Backup
#/opt/emc/boostfs/bin/boostfs mount -d dvedemo01.internal.cloudapp.net -s st-ddboostfs /mnt/Backup
echo 'dvedemo01.internal.cloudapp.net:/st-ddboostfs /mnt/Backup boostfs defaults,_netdev,bfsopt(nodsp.small_file_check=0,app-info=DDBoostFS) 0 0' >> /etc/fstab
/dockerclient/bin/avagent.bin --init --daemon=false --vardir=/dockerclient/var --bindir=/dockerclient/bin/ --sysdir=/dockerclient/etc/ --mcsaddr=avedemo01.internal.cloudapp.net --dpndomain=/clients --logfile=/dockerclient/var/avagent.log
/dockerclient/bin/avagent.bin --vardir=/dockerclient/var --bindir=/dockerclient/bin/ --sysdir=/dockerclient/etc --logfile=/dockerclient/var/avagent.log
