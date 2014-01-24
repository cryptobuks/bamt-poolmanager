#!/bin/bash

if { -f /var/www/favicon.ico.bamt } { 

  cp /var/www/bamt/status.css /var/www/bamt/status.css.back
  cp status.css /var/www/bamt/

  cp /usr/lib/cgi-bin/status.pl /usr/lib/cgi-bin/status.pl.back
  cp status.pl /usr/lib/cgi-bin/

  cp /usr/lib/cgi-bin/poolmanage.pl /usr/lib/cgi-bin/poolmanage.pl.back
  cp poolmanage.pl /usr/lib/cgi-bin/

  cp /opt/bamt/common.pl /opt/bamt/common.pl.back
  cp common.pl /opt/bamt/

} else { 

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

}

