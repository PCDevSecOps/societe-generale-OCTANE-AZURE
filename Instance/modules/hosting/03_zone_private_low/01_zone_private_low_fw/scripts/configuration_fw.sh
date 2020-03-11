#!/bin/bash


echo "START:  ***************************  bootscript initiated ************************"  `date`   > $filelog

# cloud init file logs
filelog=/tmp/results.txt

# set varaible file to be define haproxy is ready
fileinitialize=/tmp/initialhostingvm


echo ""                                                                                            >> $filelog
echo ""                                                                                            >> $filelog
echo "-------------------------------------------------------------------------------------------" >> $filelog
echo "-------------------------------------------------------------------------------------------" >> $filelog
echo "STEP: erase current  package firewalld epel-release httpd"    `date`                         >> $filelog
sudo systemctl stop firewalld                                                                      >> $filelog
sudo yum erase -y firewalld epel-release httpd                                                     >> $filelog



echo ""                                                                                            >> $filelog
echo ""                                                                                            >> $filelog

echo "-------------------------------------------------------------------------------------------" >> $filelog
echo "-------------------------------------------------------------------------------------------" >> $filelog
echo  "STEP: set boot"  `date`                                                                     >> $filelog
sudo setsebool -P use_nfs_home_dirs 1                                                              >> $filelog
sudo setsebool -P use_ecryptfs_home_dirs 1                                                         >> $filelog

echo ""                                                                                            >> $filelog
echo ""                                                                                            >> $filelog
echo "-------------------------------------------------------------------------------------------" >> $filelog
echo "-------------------------------------------------------------------------------------------" >> $filelog

sudo yum update -y                                                                                 >> $filelog
echo  "STEP: yum install epel-release and tools"  `date`                                           >> $filelog
sudo yum install -y epel-release                                                                   >> $filelog
sudo yum install -y elinks                                                                         >> $filelog

echo  "STEP: install  packages rpm required for fw   "  `date`                                     >> $filelog

sudo yum install -y python-pip wget dos2unix jq vim                                                >> $filelog
sudo yum install -y nginx nginx-all-modules nginx-mod-stream                                       >> $filelog
sudo yum install -y iptables-services haproxy                                                      >> $filelog

mkdir -p /etc/nginx/sites
systemctl start iptables
sudo systemctl enable iptables
sudo iptables -A INPUT -j DROP                                                                     >> $filelog
sudo iptables -A INPUT -i eth0 -p tcp --dport 22 -j ACCEPT                                         >> $filelog
sudo /sbin/iptables-save                                                                           >> $filelog
echo ""                                                                                            >> $filelog
echo ""                                                                                            >> $filelog
echo "-------------------------------------------------------------------------------------------" >> $filelog
echo resolver $(awk 'BEGIN{ORS=" "} $1=="nameserver" {print $2}' /etc/resolv.conf) ";" > /etc/nginx/resolvers.conf

chkconfig NetworkManager off; service NetworkManager stop                                          >> $filelog

systemctl enable network.service                                                                   >> $filelog
echo ""                                                                                            >> $filelog
systemctl start network.service                                                                    >> $filelog


echo ""                                                                                            >> $filelog


echo "END: **************************** bootscript done ********************************"  `date`  >> $filelog


exit 0


