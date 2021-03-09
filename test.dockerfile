FROM centos:latest
RUN yum install -y openssh-server \
&& yum install -y iproute net-tools initscripts\
&& yum clean all 
#RUN cp /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key
#RUN cp /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
#Add Avamar Agent. 
ADD src/packages/DockerEmbebed/avamar/19.3/AvamarClient-linux-sles11-x86_64-19.3.100-149.rpm /tmp/AvamarClient-linux-sles11-x86_64-19.3.100-149.rpm
#prepare run.sh for avamar register & avagent.
ADD src/avamar/setup.sh /usr/local/sbin/setup.sh
RUN chmod 755 /usr/local/sbin/setup.sh
CMD ["/usr/local/sbin/setup.sh"]
