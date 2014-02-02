#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo "This script will install the IFMI PoolManager web interface upgrade to BAMT."
read -p "Are you sure?(y/n)" input
shopt -s nocasematch
case "$input" in
  y|Y|Yes)
  if [ -d /var/www/IFMI ]; then
    read -p  "It looks like this has been installed before. Overwrite?(y/n)" overwrite
    shopt -s nocasematch
    case "$overwrite" in
      y|Y|Yes)
      echo "Copying files..."
      cp /var/www/bamt/status.css /var/www/bamt/status.css.back
      cp status.css /var/www/bamt/
      cp ./*.png /var/www/bamt/
      cp /usr/lib/cgi-bin/status.pl /usr/lib/cgi-bin/status.pl.back
      cp status.pl /usr/lib/cgi-bin/
      cp /usr/lib/cgi-bin/confedit.pl /usr/lib/cgi-bin/confedit.pl.back
      cp confedit.pl /usr/lib/cgi-bin/
      cp /usr/lib/cgi-bin/poolmanage.pl /usr/lib/cgi-bin/poolmanage.pl.back
      cp poolmanage.pl /usr/lib/cgi-bin/
      cp /opt/bamt/common.pl /opt/bamt/common.pl.back
      cp common.pl /opt/bamt/
      echo "Done!";;
      * ) echo "installation exited";;
    esac
  else
    echo "Copying files..."
    cp /var/www/favicon.ico /var/www/favicon.ico.bamt
    cp favicon.ico /var/www/
    mkdir /var/www/IFMI
    cp IFMI-logo-small.png /var/www/IFMI/
    cp /var/www/bamt/status.css /var/www/bamt/status.css.bamt
    cp status.css /var/www/bamt/
    cp ./*.png /var/www/bamt/
    cp /usr/lib/cgi-bin/status.pl /usr/lib/cgi-bin/status.pl.bamt
    cp status.pl /usr/lib/cgi-bin/
    cp confedit.pl /usr/lib/cgi-bin/
    cp poolmanage.pl /usr/lib/cgi-bin/
    cp /opt/bamt/common.pl /opt/bamt/common.pl.bamt
    cp common.pl /opt/bamt/
    echo "Modifying sudoers...."
    sed \$a"Defaults targetpw\n"\
"www-data ALL=(ALL) /usr/sbin/mine,/bin/cp\n" /etc/sudoers > /etc/sudoers.ifmi
    cp /etc/sudoers /etc/sudoers.bamt
    cp /etc/sudoers.ifmi /etc/sudoers
    echo "Running Apache security script..."
    ./htsec.sh
    echo "Done! Please read the README and edit your conf file as required. Thank you for flying IFMI!"
  fi ;;
  * ) echo "installation exited";;
esac
