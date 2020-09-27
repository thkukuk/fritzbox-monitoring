#!/bin/sh
  
#======================================
# Functions...
#--------------------------------------
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

sed -i -e 's|WorkDir:.*|WorkDir: /srv/www/htdocs|g' /fritzbox-bandwidth-monitor/mrtg.cfg
sed -i -e 's|/usr/local/bin/upnp2mrtg.sh|/fritzbox-bandwidth-monitor/upnp2mrtg.sh|g' /fritzbox-bandwidth-monitor/mrtg.cfg
