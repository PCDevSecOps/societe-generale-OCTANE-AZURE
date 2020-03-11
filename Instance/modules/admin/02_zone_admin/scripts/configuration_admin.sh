#!/bin/bash



echo "***********************   bootscript initiated ********************************************" > $filelog

# become root
sudo su -

# define bootscript logs file
filelog=/tmp/results.txt


echo ""                                                                                            >> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo"STEP : These are variables provided during terraform apply. See terraform module admin" `date`>> $filelog

echo    "randominstance                          =  ${randominstance}"                              >> $filelog
echo    "resource_group                          =  ${resource_group}"                              >> $filelog
echo    "admin_username                          =  ${admin_username_haproxy}"                      >> $filelog
echo    "ssh_port                                =  ${ssh_port_haproxy}"                            >> $filelog
echo    "access_key_storage_account_fileshare    =  ${access_key1_storage_account_fileshare}"       >> $filelog
echo    "hosting_configuration_zip_file          =  ${hosting_configuration_zip_file}"              >> $filelog
echo    "blob_container_name                     =  ${blob_container_name}"                         >> $filelog
echo    "blob_endpoint                           =  ${blob_endpoint}"                               >> $filelog
echo    "private_key_haproxy                     =  ${private_key_haproxy}"                         >> $filelog
echo    "vm_ip_addresses_haproxy                 =  ${vm_ip_addresses_haproxy}"                     >> $filelog
echo    "stack                                   =  ${stack}"                                       >> $filelog
echo    "clb_up_mid_dns_name                     =  ${clb_up_mid_dns_name}"                         >> $filelog






echo ""                                                                                            >> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog

env  >>  $filelog

echo ""                                                                                            >> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "STEP :  Installation prequsites system"    `date`  >>  $filelog
sudo yum update -y
sudo yum install epel-release -y                                                                   >>  $filelog
sudo yum makecache                                                                                 >>  $filelog
sudo yum install python-devel  -y                                                                  >>  $filelog
sudo yum groupinstall 'development tools' -y                                                       >>  $filelog
sudo yum install python-pip -y                                                                     >>  $filelog
sudo yum install dos2unix  -y                                                                      >>  $filelog
sudo yum install -y libunwind icu                                                                  >>  $filelog
sudo yum install -y jq                                                                             >>  $filelog



echo "--------------------------------------------------------------------------------------------">> $filelog
echo "STEP :  installation az cli"    `date`    >>  $filelog
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
sudo yum install azure-cli  -y                 >>  $filelog




echo "--------------------------------------------------------------------------------------------">> $filelog
echo "STEP :  az cli login"    `date`  >>  $filelog
az login --service-principal -u  ${client_id} -p ${client_secret}  --tenant ${tenant_id}
az account set --subscription   ${subscription_id}
az account show                        >>  $filelog



echo "--------------------------------------------------------------------------------------------">> $filelog
HOMEHOSTING="/root"

#global folder configuration
mkdir $HOMEHOSTING/hostingconfiguration && cd $HOMEHOSTING/hostingconfiguration                     >>  $filelog
echo "STEP: repertoire courant 1: "  `pwd`                                                          >> $filelog

sleep 30s



echo ""                                                                                            >> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "STEP: wait to download azcopy binaire from internet "                                        >> $filelog
while :
do
   wget -O azcopy.tar.gz https://aka.ms/downloadazcopylinux64                                      >> $filelog
   result=$?

	if [ $result -eq 0 ]
	then
	    echo "azcopy binaire is retrieved"  `date`                                                >> $filelog
	    break
	fi

	echo "azcopy binary is not available ... It will restart quicky"  `date`                       >> $filelog
    sleep 15s
done


echo ""                                                                                            >> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "STEP : installation azcopy"    `date`  >> $filelog
pwd                     >>  $filelog
tar -xf azcopy.tar.gz   >>  $filelog
sudo ./install.sh       >>  $filelog


echo ""                                                                                            >> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "STEP: try to download ansible configuration from azure blob endpoint" >> $filelog
while :
do
   azcopy --source  ${blob_endpoint}${blob_container_name}/${hosting_configuration_zip_file} --destination  ./${hosting_configuration_zip_file} --source-key ${access_key1_storage_account_fileshare} >> $filelog
   result=$?
	if [ $result -eq 0 ]
	then
	    echo "file zipe "  ${hosting_configuration_zip_file} "is retrieved"  `date`  >> $filelog
	    break
	fi

	echo "zip file or blob endopoint are not available yet .... try again" `date`   >> $filelog
    sleep 30s
done

sleep 5

echo ""                                                                                            >> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "STEP: retrieved hosting configuration ok"  `date`   >> $filelog
echo  azcopy --source  ${blob_endpoint}${blob_container_name}/${hosting_configuration_zip_file} --destination  ./${hosting_configuration_zip_file} --source-key ${access_key1_storage_account_fileshare} >> $filelog



echo "" >> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "--------------------------------------------------------------------------------------------">> $filelog
echo "STEP: create ssh private key for haproxy"     `date`  >> $filelog
echp "HOMEHOSTING :   $HOMEHOSTING"                           >>  $filelog
echo  "${private_key_haproxy}" | dos2unix >  $HOMEHOSTING/.ssh/haproxy
chmod 600  $HOMEHOSTING/.ssh/haproxy
ssh-add $HOMEHOSTING/.ssh/haproxy
cat $HOMEHOSTING/.ssh/haproxy                                >> $filelog

echo  "${private_key_haproxy}" | dos2unix >  /home/cloud-user/.ssh/haproxy
chmod 600  /home/cloud-user/.ssh/haproxy
chown -R cloud-user /home/cloud-user/.ssh/haproxy

echo ""                                                                                             >> $filelog
echo "     SET KEYVAULT SECRET"                                                                     >> $filelog
echo "STEP: Upload SSH KEY to key vault"                                                            >> $filelog

az keyvault create -g ${resource_group} -n "vault-${randominstance}"
sleep 2
az keyvault secret set --name "privatekey${randominstance}"  --vault-name "vault-${randominstance}" --file '/root/.ssh/haproxy' --encoding ascii

echo "--------------------------------------------------------------------------------------------" >> $filelog
echo "--------------------------------------------------------------------------------------------" >> $filelog
echo "STEP: configuration  ssh config"    `date`                                                    >> $filelog

touch   $HOMEHOSTING/.ssh/config


    echo "ssh config for all"                                                                       >> $filelog
    echo "Host *"     >>   $HOMEHOSTING/.ssh/config
    #echo "     HostName $ip"  >>  $HOMEHOSTING/.ssh/config
    echo "     User ${admin_username_haproxy}" >>  $HOMEHOSTING/.ssh/config
    echo "     StrictHostKeyChecking no">>  $HOMEHOSTING/.ssh/config
    echo "     UserKnownHostsFile /dev/null" >>  $HOMEHOSTING/.ssh/config
    echo "     IdentityFile $HOMEHOSTING/.ssh/haproxy" >> $HOMEHOSTING/.ssh/config
    echo ""  >>  $HOMEHOSTING/.ssh/config
    echo ""  >>  $HOMEHOSTING/.ssh/config

chmod 600  $HOMEHOSTING/.ssh/config

cp $HOMEHOSTING/.ssh/config   ./config

cat  $HOMEHOSTING/.ssh/config                                                                       >> $filelog


echo ""                                                                                             >> $filelog
echo "--------------------------------------------------------------------------------------------" >> $filelog
echo "--------------------------------------------------------------------------------------------" >> $filelog
echo "STEP: prepare hosting configuration"    `date`                                                >> $filelog
export hostingconfigurationfolder=`echo ${hosting_configuration_zip_file} | cut -d"." -f1`          >>  $filelog

unzip ./${hosting_configuration_zip_file}                                                           >> $filelog

# valider  le repertoire hosting suivant
cd $hostingconfigurationfolder                                                                      >> $filelog
echo "repertoire courant 2: "  `pwd`                                                                >> $filelog
ls -la                                                                                              >> $filelog


echo ""                                                                                             >> $filelog
echo "--------------------------------------------------------------------------------------------" >> $filelog
echo "--------------------------------------------------------------------------------------------" >> $filelog
echo "STEP : create script sh for granted domains"                                                  >> $filelog
current_directory=`pwd`

echo "current directory : "  $current_directory                                                     >> $filelog


publishdomain=/tmp/publishdomain.sh

touch     $publishdomain
chmod +x  $publishdomain
ls -l     $publishdomain



# provide stack parameters
cat << EOF  >> $publishdomain
#!/bin/bash


stackhosting=\$1


running_publishdomainfile=/tmp/running_publishdomain


sudo su -

echo "---------------------------------------------------------------------------------------------------------"        >> \$running_publishdomainfile
echo "step : check file  granted_domains_\$stackhosting ---"                                                             >> \$running_publishdomainfile
ls -l /tmp/granted_domains_\$stackhosting.yml                                                                            >> \$running_publishdomainfile



echo "---------------------------------------------------------------------------------------------------------"        >> \$running_publishdomainfile
echo "step : Retrieve ip application"                                                                                   >> \$running_publishdomainfile
awk '/backend_fqdn:/ {p=1}; p; /domain:/ {p=0}' /tmp/granted_domains_\$stackhosting.yml  | egrep -v 'backend_port:|backend_protocol:' |   cut -d ':'  -f2 | awk '{print \$1}' | awk 'NR%2{printf "%s " , \$0; next; }1'  > /tmp/newdomaintoetchost

echo "/tmp/newdomaintoetchost"                                                                                          >> \$running_publishdomainfile
cat /tmp/newdomaintoetchost                                                                                             >> \$running_publishdomainfile



while :
   do

     vm_ip_addresses_haproxy_var="`cat /tmp/filevmhaproxy | grep -v '\$#' |   tr ',' ' ' `"
     totalvmhaproxy=0
     countvmhaproxy=0

     echo "\$vm_ip_addresses_haproxy_var"  \$vm_ip_addresses_haproxy_var                                                >> \$running_publishdomainfile

     echo "-------------------------------------------------------"                                                     >> \$running_publishdomainfile
     echo "step : while : check haproxy vm availability..."                                                             >> \$running_publishdomainfile

     for server in `echo \$vm_ip_addresses_haproxy_var`
      do

        totalvmhaproxy=\$((totalvmhaproxy + 1 ))
        echo "totalvmhaproxy: " \$totalvmhaproxy                                                                        >> \$running_publishdomainfile
        echo "current machine: " \$server                                                                               >> \$running_publishdomainfile

        ssh \$server "ls /tmp/initialhostingvm " >  /dev/null 2>&1
        result=\$?
        echo "result : " \$result                                                                                       >> \$running_publishdomainfile

	    if [ \$result -eq 0 ]
	    then
	      echo "server \$server is available"                                                                           >> \$running_publishdomainfile
	      echo " scp  /tmp/newdomaintoetchost   \$server:/tmp/"                                                         >> \$running_publishdomainfile

	      scp  /tmp/newdomaintoetchost   \$server:/tmp/

	      echo " ssh \$server cat /tmp/newdomaintoetchost"                                                              >> \$running_publishdomainfile
	      ssh \$server "cat /tmp/newdomaintoetchost >> /etc/hosts"
	      countvmhaproxy=\$((countvmhaproxy + 1 ))

	    fi

	    echo "countvmhaproxy: "  \$countvmhaproxy                                                                       >> \$running_publishdomainfile

      done

   if [ \$countvmhaproxy -eq \$totalvmhaproxy ]
   then
        echo "ok all vm are done : "                                                                                    >> \$running_publishdomainfile
        break
   fi

   echo "haproxy vms are not all available ... try again"                                                               >> \$running_publishdomainfile
   sleep 10s

done




echo "---------------------------------------------------------------------------------------------------------"        >> \$running_publishdomainfile
echo "step : mv /tmp/granted_domains_\$stackhosting.yml  $current_directory/vars"                                            >> \$running_publishdomainfile
mv /tmp/granted_domains_\$stackhosting.yml  $current_directory/vars


echo "---------------------------------------------------------------------------------------------------------"        >> \$running_publishdomainfile
cat  $current_directory/vars/granted_domains_\$stackhosting.yml                                                              >> \$running_publishdomainfile

echo "---------------------------------------------------------------------------------------------------------"        >> \$running_publishdomainfile
echo "step : run ansible"                                                                                               >> \$running_publishdomainfile
cd $current_directory
source ./virtualenv/bin/activate
#./virtualenv/bin/ansible-playbook -i hosts main.yml -e stack=\$stackhosting --tags grantdomain --skip-tags aws -v        >> \$running_publishdomainfile
./virtualenv/bin/ansible-playbook -i azure_rm.py  main.yml -e stack=\$stackhosting  --tags grantdomain  --skip-tags aws -vvv --ssh-extra-args="-F ./config"

deactivate

#rm -rf   /tmp/granted_domains_\$stackhosting.yml


echo "---------------------------------------------------------------------------------------------------------"        >> \$running_publishdomainfile
echo "step : end script"                                                                                                >> \$running_publishdomainfile
EOF






echo ""                                                                                                 >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "STEP: content of  $publishdomain"                                                                 >> $filelog
cat  $publishdomain                                                                                     >> $filelog



echo ""                                                                                                 >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "STEP: create   ~/.azure/credentials"                                                              >> $filelog
mkdir -p ~/.azure
echo [default]                                > ~/.azure/credentials
echo "subscription_id=${subscription_id}"    >> ~/.azure/credentials
echo "client_id=${client_id}"                >> ~/.azure/credentials
echo "secret=${client_secret}"               >> ~/.azure/credentials
echo "tenant=${tenant_id}"                   >> ~/.azure/credentials



echo ""                                                                                                 >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "STEP: create variable clb_up_mid_dns_name in group_vars/all.yml"                                  >> $filelog
echo "clb_up_mid_dns_name: ${clb_up_mid_dns_name}" >>  ./group_vars/all.yml
echo "clb_mid_low_dns_name: ${clb_mid_low_dns_name}" >>  ./group_vars/all.yml



echo ""                                                                                                 >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "STEP: show content   ~/.azure/credentials"  `date` >> $filelog
cat ~/.azure/credentials                                                                                >> $filelog


echo ""                                                                                                 >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "STEP: installation and configuration virtualenv"    `date`                                        >> $filelog
pip install --upgrade pip                                                                               >> $filelog
pip install virtualenv                                                                                  >> $filelog
virtualenv virtualenv
source ./virtualenv/bin/activate
pip install --upgrade pip
pip install ansible==2.8                                                                                >> $filelog
pip install ansible[azure]                                                                              >> $filelog
pip install python-apt                                                                                  >> $filelog
pip install -U setuptools                                                                               >> $filelog
deactivate


echo ""                                                                                                 >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "STEP: make azure_rm.py  executable.  and change end of line in azure_rm.py and ini "  `date`      >> $filelog
cat  ./azure_rm.py   | dos2unix  >  ./azure_rm.tmp
mv ./azure_rm.tmp  ./azure_rm.py
chmod +x ./azure_rm.py


cat  ./azure_rm.ini   | dos2unix  >  ./azure_rm.tmp
mv ./azure_rm.tmp  ./azure_rm.ini



echo ""                                                                                                 >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "STEP: run ansible inside virualenv"   `date`                                                      >> $filelog
echo "repertoire courant 3: "  `pwd`                                                                    >> $filelog


cat  cli_api_hosting_azure.sh   | dos2unix  >  cli_api_hosting_azure.tmp

mv cli_api_hosting_azure.tmp  cli_api_hosting_azure.sh

chmod +x ./cli_api_hosting_azure.sh

# sudo ./cli_api_hosting_azure.sh  -s "${stack}"                                                          >> $filelog




echo ""                                                                                                 >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "--------------------------------------------------------------------------------------------"     >> $filelog
echo "STEP: admin vm ready /tmp/adminready"                                                             >> $filelog
touch /tmp/adminready

yum -y install yum-utils
yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
sudo yum -y install certbot python2-certbot-nginx
echo "******************** bootscript done ***********************************************"  `date`     >> $filelog

exit 0

