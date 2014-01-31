#!/bin/bash
# This script is intended to provide some basic security to your http service.
# It is distributed with BAMT-PoolManager, and intended to be used on BAMT and
# its derivatives. No guarantees or assurances are provided or implied.
# Please see http://httpd.apache.org/docs/2.2/ssl/ for more information.

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo "This is intended to set up some basic security for your web service."
echo "It will enable SSL and redirect all web traffic over https."
echo "It will optionally also set up a default site password." 

  if [ -e /etc/apache2/sites-available/default-ssl.ifmi ] ; then
    read -p  "It looks like this has been installed before. Reinstall?(y/n)" overwrite
    shopt -s nocasematch
    case "$overwrite" in
      y|Y|Yes)
       if [ -e /var/www/.htaccess] ; then
         rm /var/www/.htaccess
         rm /usr/lib/cgi-bin/.htaccess
       fi
        echo "continuing..." ;;
      * ) echo "installation exited"
	  exit 1 ;;
    esac
  fi

  echo "Configuring Apache for SSL..."
  if [ ! -e /etc/ssl/certs/apache.crt ] ; then
    echo "Creating cert."
    echo "Please set the country code, the rest of the cert quetions can be blank (hit enter)"
    /usr/bin/openssl req -x509 -nodes -days 1825 -newkey rsa:2048 -keyout /etc/ssl/private/apache.key -out /etc/ssl/certs/apache.crt
  else
    echo "certs appear to be installed, skipping..."
  fi
  /usr/sbin/a2enmod ssl
  if [ ! -e /etc/apache2/sites-available/default-ssl.bamt ] ; then
    cp /etc/apache2/sites-available/default-ssl /etc/apache2/sites-available/default-ssl.bamt
  else
    cp /etc/apache2/sites-available/default-ssl.bamt /etc/apache2/sites-available/default-ssl
  fi
  sed '/DocumentRoot / i\
	ServerName IFMI:443' /etc/apache2/sites-available/default-ssl > /etc/apache2/sites-available/default-ssl.ifmi
  sed -i "s/ssl-cert-snakeoil.pem/apache.crt/g" /etc/apache2/sites-available/default-ssl.ifmi
  sed -i "s/ssl-cert-snakeoil.key/apache.key/g" /etc/apache2/sites-available/default-ssl.ifmi
  cp /etc/apache2/sites-available/default-ssl.ifmi /etc/apache2/sites-available/default-ssl
  /usr/sbin/a2ensite default-ssl
  echo "Configuring Apache to use https only..."
  if [ ! -e /etc/apache2/sites-available/default.bamt ] ; then
    cp /etc/apache2/sites-available/default /etc/apache2/sites-available/default.bamt
  else
    cp /etc/apache2/sites-available/default.bamt /etc/apache2/sites-available/default
  fi
  /usr/sbin/a2enmod rewrite
  sed '/DocumentRoot / i\
	RewriteEngine On\
	RewriteCond %{HTTPS} !=on\
	RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]\
' /etc/apache2/sites-available/default > /etc/apache2/sites-available/default.ifmi
  cp /etc/apache2/sites-available/default.ifmi /etc/apache2/sites-available/default
  service apache2 restart

  read -p  "Would you like to password protect the default site?(y/n)" htaccess
  shopt -s nocasematch
  case "$htaccess" in
    y|Y|Yes)
    echo "Configuring Apache for basic authentication..."
    sed '/Directory \/>/a\
	        AuthType Basic\
        	AuthName \"Authentication Required\"\
        	AuthUserFile /var/htpasswd\
        	Require valid-user\
' /etc/apache2/sites-available/default-ssl.ifmi > /etc/apache2/sites-available/default-ssl.ifmi.htaccess
    mv /etc/apache2/sites-available/default-ssl.ifmi.htaccess /etc/apache2/sites-available/default-ssl.ifmi
    cp /etc/apache2/sites-available/default-ssl.ifmi /etc/apache2/sites-available/default-ssl
    service apache2 restart

    if [ -e /var/htpasswd ] ; then
      echo "The htpasswd file already exists. Adding to it..."
      read -p "Provide a username (single word with no spaces):" username
      `htpasswd /var/htpasswd $username`
    else
      read -p "Provide a username (single word with no spaces):" username
      `htpasswd -c /var/htpasswd $username`
    fi
    echo "Your htpassword file is '/var/htpasswd'" 
    echo "Please see 'man htpasswd' for more information on managing htaccess users."
    ;;
    * ) echo "htaccess skipped" ;;
  esac
