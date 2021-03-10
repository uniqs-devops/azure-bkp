# Host config 

``[dps@lx-01 azure-bkp]$ hostname -f
**lx-01.pcalvo.local**````

[dps@lx-01 azure-bkp]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:70:10 brd ff:ff:ff:ff:ff:ff
    inet **192.168.111.210/16** brd 192.168.255.255 scope global noprefixroute ens192
       valid_lft forever preferred_lft forever
    inet6 fe80::b2fc:6d3c:3751:bdc2/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: ens224: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:9d:f8 brd ff:ff:ff:ff:ff:ff
    inet 10.52.2.218/23 brd 10.52.3.255 scope global noprefixroute ens224
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fea7:9df8/64 scope link
       valid_lft forever preferred_lft forever

``` Container DNS config ```

[dps@lx-01 azure-bkp]$ nslookup dockermg-01.pcalvo.local
Server:         192.168.10.124
Address:        192.168.10.124#53

Name:   dockermg-01.pcalvo.local
Address: **192.168.111.210**


[dps@lx-01 azure-bkp]$ nslookup dockerpg-01.pcalvo.local
Server:         192.168.10.124
Address:        192.168.10.124#53

Name:   dockerpg-01.pcalvo.local
Address: **192.168.111.210**

# Docker run commands 

[dps@lx-01 azure-bkp]$ sudo docker run --hostname dockermg-01.pcalvo.local --name azure-mongodb-ave -d -it --device /dev/fuse --cap-add SYS_ADMIN -p **28002:28002** -p 30001:30001 -p 30002:30002 -p 27000:27000 -p 28001:28001 -p 29000:29000 -p 30001:30001  -p 30003:30003  -p 27000:27000   -P  --network host 3afcc903cbb3 /bin/bash

[dps@lx-01 azure-bkp]$ sudo docker run --hostname dockerpg-01.pcalvo.local --name azure-postgresql-ave -d -it --device /dev/fuse --cap-add SYS_ADMIN -p **28003:28003** -p 30001:30001 -p 30002:30002 -p 27000:27000 -p 28001:28001 -p 29000:29000 -p 30001:30001  -p 30003:30003  -p 27000:27000   -P  --network host ae062893d896 /bin/bash

``` Docker containers ```
[dps@lx-01 azure-bkp]$ sudo docker ps -a
CONTAINER ID  IMAGE                                                                        COMMAND    CREATED            STATUS                PORTS   NAMES
5cdfaef65839  localhost/src/dockerfiles/avamar.19.3.azure-postgresql-local.dockerfile:1.0  /bin/bash  About an hour ago  Up About an hour ago          **azure-postgresql-ave**
917918a9f5a1  localhost/src/dockerfiles/avamar.19.3.azure-mongodb-local.dockerfile:1.0     /bin/bash  About an hour ago  Up About an hour ago          **azure-mongodb-ave**

``` Docker ips ```
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
    inet **192.168.111.210/16** brd 192.168.255.255 scope global noprefixroute ens192
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
    inet **192.168.111.210/16** brd 192.168.255.255 scope global noprefixroute ens192
       valid_lft forever preferred_lft forever
    inet6 fe80::b2fc:6d3c:3751:bdc2/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: ens224: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:9d:f8 brd ff:ff:ff:ff:ff:ff
    inet 10.52.2.218/23 brd 10.52.3.255 scope global noprefixroute ens224
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fea7:9df8/64 scope link
       valid_lft forever preferred_lft forever

# Avamar configs 

![image](https://user-images.githubusercontent.com/77995857/110685399-fb9ae800-81bc-11eb-930a-ba929e5ca35e.png)

![image](https://user-images.githubusercontent.com/77995857/110685519-22f1b500-81bd-11eb-9984-715c0632b561.png)

![image](https://user-images.githubusercontent.com/77995857/110685582-356bee80-81bd-11eb-8220-87dad3bdac4b.png)

# Browsing 

![image](https://user-images.githubusercontent.com/77995857/110685705-56ccda80-81bd-11eb-8b5e-39b70a7fb532.png)

![image](https://user-images.githubusercontent.com/77995857/110685811-706e2200-81bd-11eb-84b3-b2d6a59c0fe5.png)

# Activity status 

![image](https://user-images.githubusercontent.com/77995857/110685917-8bd92d00-81bd-11eb-8aa7-8ddb6ffe7fa4.png)



