#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo "This script will password protect your root web directory." 
echo  "You will also need to enable htaccess file support in Apache."
read -p "Are you sure?(y/n)" input
shopt -s nocasematch
case "$input" in
  y|Y|Yes)
  if [ -e /var/www/.htaccess ] ; then
    read -p  "It looks like this has been installed before. Overwrite files?(y/n)" overwrite
    shopt -s nocasematch
    case "$overwrite" in
      y|Y|Yes)
        echo "continuing..." ;;
      * ) echo "installation exited"
	  exit 1 ;;
    esac
  fi
  cp dot-htaccess /var/www/.htaccess
  cp dot-htaccess /usr/lib/cgi-bin/.htaccess ;;
  * ) echo "installation exited"
      exit 1 ;;
esac

read -p "provide a username (single word with no spaces):" username
  if [ -e /var/htpasswd ] ; then
  `htpasswd /var/htpasswd $username`
  else
  `htpasswd -c /var/htpasswd $username`
  fi
