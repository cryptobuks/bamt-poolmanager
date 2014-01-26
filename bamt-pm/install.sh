#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo "This script will install the IFMI web interface upgrade to BAMT."
read -p "Are you sure?(y/n)" input
shopt -s nocasematch
case "$input" in
  y|Y|Yes)
  if [ -e /var/www/favicon.ico.bamt ]; then
    read -p  "It looks like this has been installed before. Continue?(y/n)" overwrite
    shopt -s nocasematch
    case "$overwrite" in
      y|Y|Yes)
      cp /var/www/bamt/status.css /var/www/bamt/status.css.back
      cp status.css /var/www/bamt/
      cp /usr/lib/cgi-bin/status.pl /usr/lib/cgi-bin/status.pl.back
      cp status.pl /usr/lib/cgi-bin/
      cp /usr/lib/cgi-bin/poolmanage.pl /usr/lib/cgi-bin/poolmanage.pl.back
      cp poolmanage.pl /usr/lib/cgi-bin/
      cp /opt/bamt/common.pl /opt/bamt/common.pl.back
      cp common.pl /opt/bamt/
      echo "Done!";;
      * ) echo "installation exited";;
    esac
  else
    cp /var/www/favicon.ico /var/www/favicon.ico.bamt
    cp favicon.ico /var/www/
    mkdir /var/www/IFMI
    cp IFMI-logo-small.png /var/www/IFMI/
    cp /var/www/bamt/status.css /var/www/bamt/status.css.bamt
    cp status.css /var/www/bamt/
    cp /usr/lib/cgi-bin/status.pl /usr/lib/cgi-bin/status.pl.bamt
    cp status.pl /usr/lib/cgi-bin/
    cp poolmanage.pl /usr/lib/cgi-bin/
    cp /opt/bamt/common.pl /opt/bamt/common.pl.bamt
    cp common.pl /opt/bamt/
    echo "Done! Please read the README and edit files as required. Thank you for flying IFMI!"
  fi ;;
  * ) echo "installation exited";;
esac
