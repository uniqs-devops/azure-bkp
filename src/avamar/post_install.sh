read -n 1 -r -s -p $'Root backup dir creation, press enter to continue...\n'
mkdir -p /Backup
read -n 1 -r -s -p $'Avamar client registration on server cibp1weuaval001.shared.azure.scib.gs.corp domain /clients, press enter to continue...\n'
/dockerclient/bin/avregister
read -n 1 -r -s -p $'Agent restart, press enter to continue...\n'
/etc/init.d/avagent restart
read -n 1 -r -s -p $'Creating lockbox file, press enter to continue...\n'
/opt/emc/boostfs/bin/boostfs lockbox set -u ddbost -d cibp1weuaval003.shared.azure.scib.gs.corp -s PaasBackup
read -n 1 -r -s -p $'Adding line in /etc/fstab, press enter to continue...\n'
echo 'cibp1weuaval003.shared.azure.scib.gs.corp:/PaasBackup /Backup boostfs defaults,_netdev,bfsopt(nodsp.small_file_check=0,app-info=DDBoostFS) 0 0' >> /etc/fstab
read -n 1 -r -s -p $'Mounting through /etc/fstab, press enter to continue...\n'
mount -a
