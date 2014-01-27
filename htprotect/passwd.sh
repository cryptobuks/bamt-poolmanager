#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
read -p "provide a username (single word with no spaces):" username
  if [ -e /var/htpasswd ] ; then
  `htpasswd /var/htpasswd $username`
  else
  `htpasswd -c /var/htpasswd $username`
  fi

