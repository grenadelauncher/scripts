#!/bin/bash


# This script allows you to create numbers of users on numbers of servers
# all of users would be added to all of servers
# your root's public key will be added to all of servers
# version 12.39:27.10.16

# Make sure that you have installed ansible and sshpass
# if not: sudo apt-get install ansible sshpass

# I know that it is not secure way
# you shoul run this script from root user

# Adding my ROOT public key to servers
# change $SERVER_PASS for server's password
SERVER_PASS=""
# list of servers
SERVER_LIST=( "IP1" "IP2" )
# list of users
USER_LIST=("user1" "user2" "user3" "user4")
# list of passwords for users
PASSWORD_LIST=("user1-pass" "user2-pass" "user3-pass" "user4-pass")
k=0

# inventory file location
INV="/var/tmp/inventory"
rm $INV
touch $INV

for i in ${SERVER_LIST[*]}
do
 sshpass -p "$SERVER_PASS" ssh-copy-id $i
 echo "-------------------------------------------------------------------"
 echo "root's public key to server IP-address $i has been added succefully"
 echo "-------------------------------------------------------------------"

 echo $i >> $INV
done

for u in ${USER_LIST[*]}
do
 ANSIBLE_HOST_KEY_CHECKING=False ansible all -i $INV -m shell -a "useradd $u; echo ${PASSWORD_LIST[$k]} | passwd $u --stdin"
 echo "----------------------------------------------------------------------------------"
 echo "user $u with password ${PASSWORD_LIST[$k]} has been successfully added to servers"
 echo "----------------------------------------------------------------------------------"
 k=$k+1
done
