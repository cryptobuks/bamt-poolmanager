#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo -e "This script will install the IFMI web interface upgrade to BAMT.\n"\
     "Are you sure you want to do this? y/n"
read YN
if [ $YN == y ]; then
  if [ -e /var/www/favicon.ico.bamt ]; then
    cp /var/www/bamt/status.css /var/www/bamt/status.css.back
    cp status.css /var/www/bamt/
    cp /usr/lib/cgi-bin/status.pl /usr/lib/cgi-bin/status.pl.back
    cp status.pl /usr/lib/cgi-bin/
    cp /usr/lib/cgi-bin/poolmanage.pl /usr/lib/cgi-bin/poolmanage.pl.back
    cp poolmanage.pl /usr/lib/cgi-bin/
    cp /opt/bamt/common.pl /opt/bamt/common.pl.back
    cp common.pl /opt/bamt/
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
  fi
else 
 exit 1
fi
