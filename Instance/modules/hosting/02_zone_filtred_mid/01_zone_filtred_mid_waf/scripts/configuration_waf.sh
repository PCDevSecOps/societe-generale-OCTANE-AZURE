#!/bin/bash


echo "START:  ***************************  bootscript initiated ************************"  `date`   > $filelog

# cloud init file logs
filelog=/tmp/results.txt

# set varaible file to be define haproxy is ready
fileinitialize=/tmp/initialhostingvm


echo ""                                                                                             >> $filelog
echo ""                                                                                             >> $filelog
echo "-------------------------------------------------------------------------------------------"  >> $filelog
echo "-------------------------------------------------------------------------------------------"  >> $filelog
echo "STEP: erase current  package firewalld epel-release httpd"    `date`                          >> $filelog
sudo yum erase -y firewalld epel-release httpd                                                      >> $filelog



echo ""                                                                                             >> $filelog
echo ""                                                                                             >> $filelog
echo "-------------------------------------------------------------------------------------------"  >> $filelog
echo "-------------------------------------------------------------------------------------------"  >> $filelog
echo  "STEP: yum install epel-release and tools"  `date`                                            >> $filelog
sudo yum install -y epel-release                                                                    >> $filelog
sudo yum install -y elinks                                                                          >> $filelog

echo "-------------------------------------------------------------------------------------------"  >> $filelog
echo "-------------------------------------------------------------------------------------------"  >> $filelog
echo  "STEP: set boot"  `date`                                                                      >> $filelog
sudo setsebool -P use_nfs_home_dirs 1                                                               >> $filelog
sudo setsebool -P use_ecryptfs_home_dirs 1                                                          >> $filelog

echo ""                                                                                             >> $filelog
echo ""                                                                                             >> $filelog
echo "-------------------------------------------------------------------------------------------"  >> $filelog
echo "-------------------------------------------------------------------------------------------"  >> $filelog
echo  "STEP: install  packages rpm required for waf   "  `date`                                     >> $filelog


sudo yum erase -y firewalld epel-release httpd                                                      >> $filelog
sudo yum install epel-release -y  
sudo yum update -y                                                                                  >> $filelog
sudo yum groupinstall -y "Development Tools"                                                        >> $filelog
sudo yum install -y httpd httpd-devel pcre pcre-devel libxml2 libxml2-devel curl curl-devel openssl openssl-devel

# SURICATA

## PRE-REQUIREMENTS
sudo yum -y install gcc libpcap-devel pcre-devel libyaml-devel file-devel \
  zlib-devel jansson-devel libtool-ltdl nss-devel libcap-ng-devel libnet-devel tar make \
  libnetfilter_queue-devel lua-devel PyYAML libmaxminddb-devel rustc cargo \
  lz4-devel

## Install & configure SURICATA
cd /usr/src
wget http://www.openinfosecfoundation.org/download/suricata-4.0.0.tar.gz
tar xzvf suricata-4.0.0.tar.gz
cd suricata-4.0.0
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-nfqueue --enable-lua
make && make install && make install-full
echo "/usr/local/lib" >> /etc/ld.so.conf
sudo ldconfig

sudo suricata-update
sudo suricata-update update-sources

sudo suricata-update enable-source oisf/trafficid                                                   >> $filelog
sudo suricata-update                                                                                >> $filelog

mkdir /usr/src/suricata_rules
cd /usr/src/suricata_rules
wget -A rules -r -l 1 -nd  https://rules.emergingthreats.net/open/suricata/rules/
# yum install suricata

# Install & Configure nginx with ModSecurity
cd /usr/src
git clone -b nginx_refactoring https://github.com/SpiderLabs/ModSecurity.git
cd ModSecurity
sed -i '/AC_PROG_CC/a\AM_PROG_CC_C_O' configure.ac
sed -i '1 i\AUTOMAKE_OPTIONS = subdir-objects' Makefile.am
./autogen.sh
./configure --enable-standalone-module --disable-mlogc
make

# Install & Configure NGINX 
cd /usr/src
wget https://nginx.org/download/nginx-1.10.3.tar.gz
tar -zxvf nginx-1.10.3.tar.gz && rm -f nginx-1.10.3.tar.gz
groupadd -r nginx
useradd -r -g nginx -s /sbin/nologin -M nginx
cd nginx-1.10.3/
./configure --user=nginx --group=nginx --add-module=/usr/src/ModSecurity/nginx/modsecurity --with-http_ssl_module --with-http_v2_module --with-http_stub_status_module 

make
make install
sed -i "s/#user  nobody;/user nginx nginx;/" /usr/local/nginx/conf/nginx.conf


# TEST MOD_SECURITY INSTALLATION
/usr/local/nginx/sbin/nginx -t                                                                    >> $filelog
##############################

# SETUP SYSTEMD UNIT FILE

sudo sh -c 'echo "[Service]
Type=forking
ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
KillStop=/usr/local/nginx/sbin/nginx -s stop

KillMode=process
Restart=on-failure
RestartSec=42s

PrivateTmp=true
LimitNOFILE=200000

[Install]
WantedBy=multi-user.target
" >> /lib/systemd/system/nginx.service'

sudo sh -c 'echo "include modsecurity.conf
include owasp-modsecurity-crs/crs-setup.conf
include owasp-modsecurity-crs/rules/*.conf" >> /usr/local/nginx/conf/modsec_includes.conf'

sed -i '/include       mime.types;/a     include modsecurity/*.conf;' /usr/local/nginx/conf/nginx.conf
sed -i '/include       mime.types;/a     include sites/*.conf;' /usr/local/nginx/conf/nginx.conf
mkdir -p /usr/local/nginx/conf/sites/rules
mkdir -p /usr/local/nginx/conf/modsecurity
systemctl start nginx.service
systemctl stop nginx.service
systemctl restart nginx.service 

cp /usr/src/ModSecurity/modsecurity.conf-recommended /usr/local/nginx/conf/modsecurity.conf
cp /usr/src/ModSecurity/unicode.mapping /usr/local/nginx/conf/

sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" /usr/local/nginx/conf/modsecurity.conf
echo 'SecRule ARGS|REQUEST_HEADERS "@contains <script>" "id:101,msg:XSSAttack,severity:CRITICAL,deny,log,status:403"' >> /usr/local/nginx/conf/modsecurity.conf

# sed -i "s/SecRule ARGS|REQUEST_HEADERS “@rx <script>” id:101,msg: ‘XSS Attack’,severity:ERROR,deny,status:403/" /usr/local/nginx/conf/modsecurity.conf

cd /usr/local/nginx/conf
git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
cd owasp-modsecurity-crs
mv crs-setup.conf.example crs-setup.conf
cd rules
mv REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
mv RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf




# TEST MOD_SECURITY 
systemctl start nginx.service                                                                       >> $filelog
##############################


echo "STEP: Configure ssl Directories"                                                              >> $filelog

sudo mkdir /etc/ssl/private
sudo chmod 700 /etc/ssl/private

echo "STEP: Generate a self signed key and certificate pair with openssl"                         

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=FR/ST=Paris/L=Paris /O=IAPHOSTING/OU=PublicCloud/CN=COE/emailAddress=toto@toto.com"
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

echo " STEP: ADDING CONF TO /usr/local/nginx/conf/nginx.conf"      
                                     
sudo sh -c 'echo "server {
    listen 443 ssl;
    # listen [::]:443 http2 ssl;

    server_name toto.com;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
    ssl_session_cache    shared:SSL:1m;
    ssl_session_timeout  5m;

    ssl_ciphers  HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers  on;
    location / {
        ModSecurityEnabled on;
        ModSecurityConfig modsec_includes.conf;
        #proxy_pass http://localhost:8011;
        #proxy_read_timeout 180s;
        root   html;
        index  index.html index.htm;
    }
}" >> /usr/local/nginx/conf/sites/default.conf'


systemctl enable nginx.service  
systemctl stop nginx.service  
sleep 3
systemctl start nginx.service  



echo "END: **************************** bootscript done ********************************"  `date`   >> $filelog


exit 0


