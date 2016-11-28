#!/bin/bash


# This script allows you to put your ssh-key on numbers of servers
# Make sure that you have installed ansible and sshpass
# if not: sudo apt-get install ansible sshpass

# I know that it is not secure way
# you shoul run this script from root user

# Adding my ROOT public key to servers
# change $SERVER_PASS for server's password
SERVER_PASS="12345678"
# list of servers
#SERVER_LIST=( "192.168.0.1")
SERVER_LIST_FILE="/var/tmp/server_list"

# inventory file
INV="/var/tmp/inventory_for_ansible_task2_dynamic"
rm $INV
touch $INV

while read k
do
 sshpass -p "$SERVER_PASS" ssh-copy-id $k
 echo "-------------------------------------------------------------------"
 echo "root's public key to server IP-address $i has been added succefully"
 echo "-------------------------------------------------------------------"
 echo $k >> $INV

done <$SERVER_LIST_FILE

#for i in ${SERVER_LIST[*]}
#do

#done
