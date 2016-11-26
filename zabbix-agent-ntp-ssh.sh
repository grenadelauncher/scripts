#!/bin/bash 


# This script allows you to update packages
# all packages would be added to all of servers
# your root's public key will be added to all of servers
# version 15.40:26.12.16

# Make sure that you have installed ansible and sshpass
# if not: sudo apt-get install ansible sshpass

# I know that it is not secure way
# you shoul run this script from root user

# Adding my ROOT public key to servers
# list of servers
SERVER_LIST=( "10.20.33.33" )
# list of packages

ZABBIX_SERVER="10.14.32.54"
ZABBIX_DOWNLOAD_URL="http://repo.zabbix.com/zabbix/3.0/rhel/6/x86_64/zabbix-agent-3.0.5-1.el6.x86_64.rpm"
NTP_SERVER_1="ntp1.ntp.com"
NTP_SERVER_2="ntp2.tpn.pt"
# inventory file
INV="/var/tmp/inventory_dynamic"
INV2="/var/tmp/inventory_all_hosts"
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
 echo "-------------------------------------------------------------------"
 echo "installing pythone bindings"
 echo "-------------------------------------------------------------------"
 sleep 1
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m yum -a "name=libselinux-python state=present"
 echo "-------------------------------------------------------------------"
 echo " pythone bindings have been successfully INSTALLED"
 echo "-------------------------------------------------------------------"
 sleep 1


# add proxy to yum.conf
# ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a 'echo -e "proxy=http://192.168.4.3:3128 \nproxy_username=proxy \nproxy_password=2010" >> /etc/yum.conf'
 echo "-------------------------------------------------------------------"
 echo "adding proxy settings to YUM"
 echo "-------------------------------------------------------------------"
 sleep 1
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m lineinfile -a "dest=/etc/yum.conf line='proxy=http://192.168.4.3:3128\nproxy_username=proxy\nproxy_password=2010'"
 echo "-------------------------------------------------------------------"
 echo "proxy settings to YUM has been added successfully"
 echo "-------------------------------------------------------------------"
 sleep 2

# add proxy to wgetrc
# ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "echo -e 'https_proxy = http://proxy:2010@192.168.4.3:3128/ \nhttp_proxy = http://proxy:2010@192.168.4.3:3128/ \nftp_proxy = http://proxy:2010@192.168.4.3:3128/' >> /etc/wgetrc"
 echo "-------------------------------------------------------------------"
 echo "adding proxy settings to WGET"
 echo "-------------------------------------------------------------------"
 sleep 1
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m lineinfile -a "dest=/etc/wgetrc line='https_proxy = http://proxy:2010@192.168.4.3:3128/ \nhttp_proxy = http://proxy:2010@192.168.4.3:3128/ \nftp_proxy = http://proxy:2010@192.168.4.3:3128/'"
 echo "-------------------------------------------------------------------"
 echo "proxy settings to WGET server has been added succefully"
 echo "-------------------------------------------------------------------"
 sleep 2

# downloading
 echo "-------------------------------------------------------------------"
 echo "Downloading package zabbix.rpm to servers"
 echo "-------------------------------------------------------------------"
 sleep 1
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "cd /var/tmp/; wget $ZABBIX_DOWNLOAD_URL" --extra-vars "ZABBIX_DOWNLOAD_URL=$ZABBIX_DOWNLOAD_URL"
 echo "-------------------------------------------------------------------"
 echo "zabbix.rpm has been succesfully downloaded to servers"
 echo "-------------------------------------------------------------------"
 sleep 2

# installing zabbix-agent
 echo "-------------------------------------------------------------------"
 echo " INSTALLING zabbix to servers"
 echo "-------------------------------------------------------------------"
 sleep 1
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "cd /var/tmp/; rpm -ivh zabbix-agent-3.0.5-1.el6.x86_64.rpm"
 echo "-------------------------------------------------------------------"
 echo "zabbix.rpm has been succesfully INSTALLED to servers"
 echo "-------------------------------------------------------------------"
 sleep 2

# removing zabbix-agent package
 echo "-------------------------------------------------------------------"
 echo "DELETING package-file zabbix.rpm from servers"
 echo "-------------------------------------------------------------------"
 sleep 1
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "cd /var/tmp/; rm -f zabbix-agent-3.0.5-1.el6.x86_64.rpm"
 echo "-------------------------------------------------------------------"
 echo "zabbix.rpm has been succesfully REMOVED from servers"
 echo "-------------------------------------------------------------------"
 sleep 3

# changing ntp settings
 echo "-------------------------------------------------------------------"
 echo "Changing NTP settings servers"
 echo "-------------------------------------------------------------------"
 sleep 1

 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "sed -i '/^server/s/^/#/' /etc/ntp.conf"
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m lineinfile -a "dest=/etc/ntp.conf regexp='#server $NTP_SERVER_2' line='server $NTP_SERVER_2' state=present" --extra-vars "NTP_SERVER_1=$NTP_SERVER_1 NTP_SERVER_2=$NTP_SERVER_2"
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m lineinfile -a "dest=/etc/ntp.conf regexp='#server $NTP_SERVER_1' line='server $NTP_SERVER_1' state=present" --extra-vars "NTP_SERVER_1=$NTP_SERVER_1 NTP_SERVER_2=$NTP_SERVER_2"
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m lineinfile -a "dest=/etc/ntp.conf line='server $NTP_SERVER_2' state=present" --extra-vars "NTP_SERVER_1=$NTP_SERVER_1 NTP_SERVER_2=$NTP_SERVER_2"
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m lineinfile -a "dest=/etc/ntp.conf line='server $NTP_SERVER_1' state=present" --extra-vars "NTP_SERVER_1=$NTP_SERVER_1 NTP_SERVER_2=$NTP_SERVER_2"
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m service -a "name=ntpd state=restarted"
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m shell -a "chkconfig ntpd on"

 echo "-------------------------------------------------------------------"
 echo "NTP settings has been succesfully CHANGED on servers"
 echo "-------------------------------------------------------------------"
 sleep 2

# updating packages yum
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m yum -a "name=nfs-utils state=latest"
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV2 -m yum -a "name=openssh-server state=latest"
 echo "-------------------------------------------------------------------"
 echo "NFS-UTILS and OPENSSH-SERVER packages have been succesfully INSTALLED on servers"
 echo "-------------------------------------------------------------------"
 sleep 3



#CHANGES TO SEPARATE SERVER

for i in ${SERVER_LIST[*]}
do


# editing zabbix.conf
# DOWNLOADING FILE FROM REMOTE SERVER
# ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV -m shell -a "HOSTNAME=$(hostname); cd /etc/zabbix/; mv zabbix_agentd.conf zabbix_agent.conf.old; wget --no-proxy -O zabbix_agentd.conf 'http://192.168.16.248/get.php?HOSTNAME=$HOSTNAME&IPADDR=$IPADDR'" --extra-vars "IPADDR=$i"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf state=present regexp='^# DebugLevel' line='DebugLevel=0'"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf state=present regexp='^Server=' line='Server=$ZABBIX_SERVER'" --extra-vars "IPADDR=$i ZABBIX-SERVER=$ZABBIX-SERVER"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf state=present regexp='^# ListenPort' line='ListenPort=10050'"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf state=present regexp='^# ListenIP' line='ListenIP=$i'" --extra-vars "IPADDR=$i"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf state=present regexp='^ServerActive' line='ServerActive=$i:10051'" --extra-vars "IPADDR=$i"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf regexp='^Hostname' state=absent"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m shell -a "hostname >> /etc/zabbix/zabbix_agentd.conf; sleep 2; sed -i '/kv00/s/^/Hostname\=/' /etc/zabbix/zabbix_agentd.conf"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf regexp='^RefreshActiveChecks' state=absent"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf insertafter='# Range: 60-3600\n# Default:' line='RefreshActiveChecks=3600' state=present"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf regexp='^AllowRoot=' state=absent"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf insertafter='# Mandatory: no\n# Default:' line='AllowRoot=1' state=present"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf regexp='^UnsafeUserParameters=' state=absent"
 ANSIBLE_HOST_KEY_CHECKING=False ansible $i -i $INV2 -m lineinfile -a "dest=/etc/zabbix/zabbix_agentd.conf insertafter='# Range: 0-1\n# Default:' line='UnsafeUserParameters=0' state=present"

 
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

