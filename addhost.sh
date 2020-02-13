#!/bin/bash

vhostName=$1
userName=$USER
WWWROOT="/Users/$userName/www/$vhostName/htdocs"

if [[ "$2" == "laravel" ]]; then
    WWWPUBLIC="$WWWROOT/public"
else
    WWWPUBLIC="$WWWROOT/public_html"
fi

mkdir -p $WWWPUBLIC
echo '<?php phpinfo();' > "$WWWPUBLIC/phpinfo.php"

vhostConfig="/usr/local/etc/httpd/extra/httpd-vhosts.conf"

echo "
<VirtualHost *:80>
    ServerAdmin webmaster@$vhostName
    DocumentRoot "$WWWPUBLIC"
    ServerName $vhostName
    ServerAlias www.$vhostName
    ErrorLog "$WWWROOT/error_log"
    CustomLog "$WWWROOT/access_log" common
    <Directory  $WWWPUBLIC>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride all
        Require all granted
    </Directory>
</VirtualHost>

<IfModule mod_ssl.c>
    <VirtualHost *:443>
    ServerAdmin webmaster@$vhostName
        DocumentRoot "$WWWPUBLIC"
        ServerName $vhostName
        ServerAlias www.$vhostName
        ErrorLog "$WWWROOT/ssl_error_log"
        CustomLog "$WWWROOT/ssl_access_log" common    
        SSLEngine on
        SSLCertificateFile "/usr/local/etc/httpd/server.crt"
        SSLCertificateKeyFile "/usr/local/etc/httpd/server.key"
        <Directory  $WWWPUBLIC>
            Options Indexes FollowSymLinks MultiViews
            AllowOverride all
            Require all granted
        </Directory>
    </VirtualHost>
</IfModule>" >> $vhostConfig

#sed -i "1s/^/127.0.0.1 $vhostName\n/" /etc/hosts
#sudo echo -e "127.0.0.1\t$vhostName" >> /etc/hosts

echo "127.0.0.1\t$vhostName" | sudo tee -a /etc/hosts > /dev/null

sudo apachectl configtest
sudo apachectl -k restart

echo "Added http://$vhostName !"