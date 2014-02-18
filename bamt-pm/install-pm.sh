#!/bin/bash

# Install script for IFMI PoolManager

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
      mkdir -p /var/www/IFMI/graphs
      mkdir -p /opt/ifmi/rrdtool
      cp /var/www/bamt/status.css /var/www/bamt/status.css.back
      cp status.css /var/www/bamt/
      cp /var/www/bamt/mgpumon.css /var/www/bamt/mgpumon.css.back
      cp mgpumon.css /var/www/bamt/
      cp ./bimages/*.png /var/www/bamt/
      cp ./images/*.png /var/www/IFMI
      ln -s /var/www/IFMI/IFMI-logo-small.png /var/www/bamt/
      cp /usr/lib/cgi-bin/status.pl /usr/lib/cgi-bin/status.pl.back
      cp status.pl /usr/lib/cgi-bin/
      cp /usr/lib/cgi-bin/confedit.pl /usr/lib/cgi-bin/confedit.pl.back
      cp confedit.pl /usr/lib/cgi-bin/
      cp /usr/lib/cgi-bin/poolmanage.pl /usr/lib/cgi-bin/poolmanage.pl.back
      cp poolmanage.pl /usr/lib/cgi-bin/
      cp /opt/bamt/sendstatus.pl /opt/bamt/sendstatus.pl.back
      cp sendstatus.pl /opt/bamt/
      cp /opt/bamt/mgpumon /opt/bamt/mgpumon.back
      cp mgpumon /opt/bamt/
      cp /opt/bamt/common.pl /opt/bamt/common.pl.back
      cp common.pl /opt/bamt/
      cp pmgraph.pl /opt/ifmi/rrdtool
      if ! grep -q  "pmgraph" "/etc/crontab" ; then
        echo "*/5 * * * * root /opt/ifmi/rrdtool/pmgraph.pl" >> /etc/crontab
      fi   
      chmod +x /usr/lib/cgi-bin/*.pl #because windows
      if ! grep coldreboot /etc/sudoers ; then
       sed -i '/\/bin\/cp/ s/$/,\/sbin\/coldreboot\n/' /etc/sudoers
      fi
      echo "Done!";;
      * ) echo "installation exited";;
    esac
  else
    if [ -d /var/www/bamt ] && [ -d /opt/bamt ]; then
      echo "Copying files..."
      mkdir -p /var/www/IFMI/graphs
      mkdir -p /opt/ifmi/rrdtool
      cp /var/www/favicon.ico /var/www/favicon.ico.bamt
      cp favicon.ico /var/www/
      cp /var/www/bamt/status.css /var/www/bamt/status.css.bamt
      cp status.css /var/www/bamt/
      cp /var/www/bamt/mgpumon.css /var/www/bamt/mgpumon.css.bamt
      cp mgpumon.css /var/www/bamt/
      cp ./bimages/*.png /var/www/bamt/
      cp ./images/*.png /var/www/IFMI
      ln -s /var/www/IFMI/IFMI-logo-small.png /var/www/bamt/
      cp /usr/lib/cgi-bin/status.pl /usr/lib/cgi-bin/status.pl.bamt
      cp status.pl /usr/lib/cgi-bin/
      cp confedit.pl /usr/lib/cgi-bin/
      cp poolmanage.pl /usr/lib/cgi-bin/
      cp /opt/bamt/common.pl /opt/bamt/common.pl.bamt
      cp common.pl /opt/bamt/
      cp /opt/bamt/sendstatus.pl /opt/bamt/sendstatus.pl.bamt
      cp sendstatus.pl /opt/bamt/
      cp /opt/bamt/mgpumon /opt/bamt/mgpumon.bamt
      cp mgpumon /opt/bamt/
      cp pmgraph.pl /opt/ifmi/rrdtool
      echo "*/5 * * * * root /opt/ifmi/rrdtool/pmgraph.pl" >> /etc/crontab
      chmod +x /usr/lib/cgi-bin/*.pl #because windows
      echo "Modifying sudoers...."
      sed \$a"Defaults targetpw\n"\
"www-data ALL=(ALL) /usr/sbin/mine,/bin/cp,/sbin/coldreboot\n" /etc/sudoers > /etc/sudoers.ifmi
      cp /etc/sudoers /etc/sudoers.bamt
      cp /etc/sudoers.ifmi /etc/sudoers
      echo "Running Apache security script..."
      ./htsec.sh
      echo "Done! Please read the README and edit your conf file as required. Thank you for flying IFMI!\n"
    else
      echo "This doesn't appear to be a BAMT distribution! Quitting.\n"
      exit 1;
    fi
  fi ;;
  * ) echo "installation exited";;
esac
