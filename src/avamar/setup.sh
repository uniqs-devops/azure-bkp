#/bin/bash
mkdir -p /Backup
#/dockerclient/bin/avagent.bin --init --daemon=false --vardir=/dockerclient/var --bindir=/dockerclient/bin/ --sysdir=/dockerclient/etc/ --mcsaddr=ave-03.pcalvo.local --dpndomain=/clients/DockerContainers/DBs-Estructured --logfile=/dockerclient/var/avagent.log
#/dockerclient/bin/avagent.bin --vardir=/dockerclient/var --bindir=/dockerclient/bin/ --sysdir=/dockerclient/etc --logfile=/dockerclient/var/avagent.log
/dockerclient/etc/avagent.d register ave-03.pcalvo.local /clients/DockerContainers/DBs-Estructured
