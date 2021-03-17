#/bin/bash
mkdir -p /Backup
#/dockerclient/bin/avagent.bin --init --daemon=false --vardir=/dockerclient/var --bindir=/dockerclient/bin/ --sysdir=/dockerclient/etc/ --mcsaddr=cibp1weuaval001.shared.azure.scib.gs.corp --dpndomain=/clients/SUBCLIENTLEVEL01/subclientelevel-02 --logfile=/dockerclient/var/avagent.log
#/dockerclient/bin/avagent.bin --vardir=/dockerclient/var --bindir=/dockerclient/bin/ --sysdir=/dockerclient/etc --logfile=/dockerclient/var/avagent.log
/dockerclient/etc/avagent.d register cibp1weuaval001.shared.azure.scib.gs.corp /clients/SUBCLIENTLEVEL01/subclientelevel-02
