#/bin/bash
mkdir -p /Backup
/dockerclient/bin/avagent.bin --init --daemon=false --vardir=/dockerclient/var --bindir=/dockerclient/bin/ --sysdir=/dockerclient/etc/ --mcsaddr=cibp1weuaval001.shared.azure.scib.gs.corp --dpndomain=/clients --logfile=/dockerclient/var/avagent.log
/dockerclient/bin/avagent.bin --vardir=/dockerclient/var --bindir=/dockerclient/bin/ --sysdir=/dockerclient/etc --logfile=/dockerclient/var/avagent.log
