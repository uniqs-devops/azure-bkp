 
[dps@lx-01 azure-bkp]$ hostname -f
lx-01.pcalvo.local

[dps@lx-01 azure-bkp]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:70:10 brd ff:ff:ff:ff:ff:ff
    inet 192.168.111.210/16 brd 192.168.255.255 scope global noprefixroute ens192
       valid_lft forever preferred_lft forever
    inet6 fe80::b2fc:6d3c:3751:bdc2/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: ens224: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:9d:f8 brd ff:ff:ff:ff:ff:ff
    inet 10.52.2.218/23 brd 10.52.3.255 scope global noprefixroute ens224
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fea7:9df8/64 scope link
       valid_lft forever preferred_lft forever


[dps@lx-01 azure-bkp]$ nslookup dockermg-01.pcalvo.local
Server:         192.168.10.124
Address:        192.168.10.124#53

Name:   dockermg-01.pcalvo.local
Address: 192.168.111.210


[dps@lx-01 azure-bkp]$ nslookup dockerpg-01.pcalvo.local
Server:         192.168.10.124
Address:        192.168.10.124#53

Name:   dockerpg-01.pcalvo.local
Address: 192.168.111.210


[dps@lx-01 azure-bkp]$ sudo docker ps -a
CONTAINER ID  IMAGE                                                                        COMMAND    CREATED            STATUS                PORTS   NAMES
5cdfaef65839  localhost/src/dockerfiles/avamar.19.3.azure-postgresql-local.dockerfile:1.0  /bin/bash  About an hour ago  Up About an hour ago          azure-postgresql-ave
917918a9f5a1  localhost/src/dockerfiles/avamar.19.3.azure-mongodb-local.dockerfile:1.0     /bin/bash  About an hour ago  Up About an hour ago          azure-mongodb-ave

[dps@lx-01 azure-bkp]$ sudo docker exec -it azure-mongodb-ave /bin/bash
[root@dockermg-01 tmp]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:70:10 brd ff:ff:ff:ff:ff:ff
    inet 192.168.111.210/16 brd 192.168.255.255 scope global noprefixroute ens192
       valid_lft forever preferred_lft forever
    inet6 fe80::b2fc:6d3c:3751:bdc2/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: ens224: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:9d:f8 brd ff:ff:ff:ff:ff:ff
    inet 10.52.2.218/23 brd 10.52.3.255 scope global noprefixroute ens224
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fea7:9df8/64 scope link
       valid_lft forever preferred_lft forever

[dps@lx-01 azure-bkp]$ sudo docker exec -it azure-postgresql-ave /bin/bash
[root@dockerpg-01 tmp]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:70:10 brd ff:ff:ff:ff:ff:ff
    inet 192.168.111.210/16 brd 192.168.255.255 scope global noprefixroute ens192
       valid_lft forever preferred_lft forever
    inet6 fe80::b2fc:6d3c:3751:bdc2/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: ens224: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:9d:f8 brd ff:ff:ff:ff:ff:ff
    inet 10.52.2.218/23 brd 10.52.3.255 scope global noprefixroute ens224
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fea7:9df8/64 scope link
       valid_lft forever preferred_lft forever

![image](https://user-images.githubusercontent.com/77995857/110685399-fb9ae800-81bc-11eb-930a-ba929e5ca35e.png)



