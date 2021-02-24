#/bin/bash
mkdir -p /Backup
/dockerclient/bin/avagent.bin --init --daemon=false --vardir=/dockerclient/var --bindir=/dockerclient/bin/ --sysdir=/dockerclient/etc/ --mcsaddr=cibp1weuaval001.shared.azure.scib.gs.corp --dpndomain=/clients --logfile=/dockerclient/var/avagent.log
/dockerclient/bin/avagent.bin --vardir=/dockerclient/var --bindir=/dockerclient/bin/ --sysdir=/dockerclient/etc --logfile=/dockerclient/var/avagent.log
#/opt/emc/boostfs/bin/boostfs mount -d cibp1weuaval003.shared.azure.scib.gs.corp -s PaaSbackup /Backup
echo 'cibp1weuaval003.shared.azure.scib.gs.corp:/PaaSbackup /Backup boostfs defaults,_netdev,bfsopt(nodsp.small_file_check=0,app-info=DDBoostFS) 0 0' >> /etc/fstab
