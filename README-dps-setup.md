# dps-setup script

Complete **dps-setup.json** file before run 

```
Usage:
    -p | --prebuild                         to complete files (do first)
    -b | --build                            to create a docker images
    -d | --deploy   --host  <hostname>      to run a new container on host
```
```
Examples: 
dps-setup.sh --prebuild
dps-setup-sh --build
dps-setup-sh --deploy --host <hostname>
```

# Docker tips
## Network 
### vlan creation

```
# docker network create --driver macvlan --attachable --subnet=192.168.111.0/16 --gateway=192.168.111.206 --ip-range=192.168.111.230/28 --opt parent=ens192 my_net2

```

### Bridge setup on host

```
ip link add mac0 link enp0s3 type macvlan mode bridge
ip addr add 192.168.0.100/24 dev mac0
ifconfig mac0 up

```

## Images & containers
### BUILD 

```
docker build -t avamar-pg/norman:1.0 -f avamar19-2-PG.dockerfile . --network host

```
### List images

```
# docker images 
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
avamar-pg/norman    1.0                 21709aea0009        2 hours ago         619MB
centos              8.1.1911            470671670cac        6 months ago        237MB
```

### Run image on container

```
# docker run --hostname dockerPG-01 --name docker-avamar-PG -d -it --device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined --network my_net2 21709aea0009 /bin/bash

```
### List containers 

```
# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                                                                                                                                                         NAMES
ab1168018474        21709aea0009        "/bin/bash"         2 hours ago         Up 2 hours          22/tcp, 53/tcp, 123/tcp, 443/tcp, 3008/tcp, 8105/tcp, 8109/tcp, 8181/tcp, 8444/tcp, 27000-27001/tcp, 28002/tcp, 29000/tcp, 30001-30002/tcp, 30101-30102/tcp   docker-avamar-PG

```

## Get shell on container ⚙

```
# docker exec -it docker-avamar-PG /bin/bash

```

```
[root@ab1168018474 tmp]# pwd
/tmp
[root@ab1168018474 tmp]# ls -lrth
total 57M
-rwx------ 1 root root 1.4K Jan 13  2020 ks-script-gpqu_kuo
-rwx------ 1 root root  671 Jan 13  2020 ks-script-_srt3u3c
-rw-r--r-- 1 root root  55M Aug 11 15:33 AvamarClient-linux-sles11-x86_64-19.2.100-155.rpm
-rw-r--r-- 1 root root 2.5M Aug 11 15:33 DDBoostFS-7.0.0.0-633922.rhel.x86_64.rpm
-rw-r--r-- 1 root root 6.6K Aug 11 15:33 pgdg-redhat-repo-latest.noarch.rpm
-rwxr-xr-x 1 root root  333 Aug 11 15:33 ddbostfs-setup.sh
[root@ab1168018474 tmp]#

```
# Requirements 
## DDBoostFS config (server side)
Data Domain user and storage unit creation (Using sysadmin user from command line)

```
user add ddboostfs role <user>
user password aging show
user password aging set <user> max-days-between-change 99999 (if necesary)
ddboost storage-unit create <storage unit> user <user>