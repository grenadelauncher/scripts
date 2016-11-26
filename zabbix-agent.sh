#!/bin/bash 


# This script allows you to update packages and install zabbix-agent
# all packages would be added to all of servers
# version 11.31:25.12.16

# Make sure that you have installed ansible and 
# your root's public key is on the remote server
# if not: sudo apt-get install ansible; sudo ssh-copy-id

# I know that it is not secure way
# you shoul run this script from root user

# list of servers
SERVER_LIST=( "IP1" "IP2" )
# list of packages
# PACKAGE_LIST=("ssh" "statd")

# inventory file
INV="/var/tmp/inventory_zabb_dynamic"
INV2="/var/tmp/inventory_zabb_all_hosts"
rm $INV
touch $INV

rm $INV2
touch $INV2

for k in ${SERVER_LIST[*]}
do
 echo $k >> $INV2
done


#CHANGES TO ALL SERVERS THE SAME

# installing pythone bindings
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m yum -a "name=libselinux-python state=present"

# add proxy to yum.conf
# ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a 'echo -e "proxy=http://192.168.4.3:3128 \nproxy_username=proxy \nproxy_password=2010" >> /etc/yum.conf'
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m lineinfile -a "dest=/etc/yum.conf line='proxy=http://192.168.4.3:3128\nproxy_username=proxy\nproxy_password=2010'"
 echo "-------------------------------------------------------------------"
 echo "proxy settings to YUM has been added succefully"
 echo "-------------------------------------------------------------------"
 sleep 3

# add proxy to wgetrc
# ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "echo -e 'https_proxy = http://proxy:2010@192.168.4.3:3128/ \nhttp_proxy = http://proxy:2010@192.168.4.3:3128/ \nftp_proxy = http://proxy:2010@192.168.4.3:3128/' >> /etc/wgetrc"
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m lineinfile -a "dest=/etc/wgetrc line='https_proxy = http://proxy:2010@192.168.4.3:3128/ \nhttp_proxy = http://proxy:2010@192.168.4.3:3128/ \nftp_proxy = http://proxy:2010@192.168.4.3:3128/'"
 echo "-------------------------------------------------------------------"
 echo "proxy settings to WGET server has been added succefully"
 echo "-------------------------------------------------------------------"
 sleep 3

# downloading  
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "cd /var/tmp/; wget http://repo.zabbix.com/zabbix/3.0/rhel/6/x86_64/zabbix-agent-3.0.5-1.el6.x86_64.rpm"
 echo "-------------------------------------------------------------------"
 echo "zabbix.rpm has been succesfully downloaded to servers"
 echo "-------------------------------------------------------------------"
 sleep 3

# installing zabbix-agent
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "cd /var/tmp/; rpm -ivh zabbix-agent-3.0.5-1.el6.x86_64.rpm"
 echo "-------------------------------------------------------------------"
 echo "zabbix.rpm has been succesfully INSTALLED to servers"
 echo "-------------------------------------------------------------------"
 sleep 3

# removing zabbix-agent package
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "cd /var/tmp/; rm -f zabbix-agent-3.0.5-1.el6.x86_64.rpm"
 echo "-------------------------------------------------------------------"
 echo "zabbix.rpm has been succesfully REMOVED from servers"
 echo "-------------------------------------------------------------------"
 sleep 3

# changing ntp settings
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "sed -i '/server/s/^/#/' /etc/ntp.conf; echo -e 'server dc2.bank.local \nserver dc1.bank.local' >> /etc/ntp.conf"
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m service -a "name=ntpd state=restarted"
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "chkconfig ntpd on"

 echo "-------------------------------------------------------------------"
 echo "NTP settings has been succesfully CHANGED on servers"
 echo "-------------------------------------------------------------------"
 sleep 3

# updating package yum
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m yum -a "name=nfs-utils state=latest"
 #ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m service -a "name=nfs-utils state=latest"
 echo "-------------------------------------------------------------------"
 echo "NFS-UTILS package has been succesfully INSTALLED on servers"
 echo "-------------------------------------------------------------------"
 sleep 3



#CHANGES TO SEPARATE SERVER

for i in ${SERVER_LIST[*]}
do


# editing zabbix.conf
# DOWNLOADING FILE FROM REMOTE SERVER
# ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV -m shell -a "HOSTNAME=$(hostname); cd /etc/zabbix/; mv zabbix_agentd.conf zabbix_agent.conf.old; wget --no-proxy -O zabbix_agentd.conf 'http://192.168.16.248/get.php?HOSTNAME=$HOSTNAME&IPADDR=$IPADDR'" --extra-vars "IPADDR=$i"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf state=present regexp='^# DebugLevel' line='DebugLevel=0'"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf state=present regexp='^Server=127.0.0.1' line='Server=$i'" --extra-vars "IPADDR=$i"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf state=present regexp='^# ListenPort' line='ListenPort=10050'"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf state=present regexp='^# ListenIP' line='ListenIP=$i'" --extra-vars "IPADDR=$i"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf state=present regexp='^ServerActive' line='ServerActive=$i:10051'" --extra-vars "IPADDR=$i"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf state=present regexp='^Hostname' line='ServerActive=$i:10051'" --extra-vars "IPADDR=$i"
 
 echo "-------------------------------------------------------------------"
 echo "zabbix_agent.conf has been succesfully downloaded to server IP-address $i"
 echo "-------------------------------------------------------------------"
 sleep 3

# Starting service
  ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m shell -a "chkconfig zabbix-agent on"
  ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m service -a "name=zabbix-agent state=started" 
 echo "-------------------------------------------------------------------"
 echo "service zabbix-agent has been succesfully started on server IP-address $i"
 echo "-------------------------------------------------------------------"
 sleep 3


 echo $i >> $INV
done

echo "===================================================================="
echo "================ DIFF BETWEEN ALL INVENTORY ========================"
echo "================ AND FINAL INVENTORY FILE =========================="

diff $INV $INV2

echo "***************** END OF DIFF OUT **********************************"
echo "********************************************************************"

