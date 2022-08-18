#!/bin/sh
  
#======================================
# Functions...
#--------------------------------------
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

rm -f /etc/munin/plugins/*
mkdir -p /entrypoint
cp -a /srv/www/htdocs/munin/.htaccess /entrypoint/.htaccess

for py in /fritzbox-munin/*.py ; do
  spy=$(basename $py)
  sed -e 's|#!/usr/bin/env python3|#!/usr/bin/python3|g' $py > /usr/lib/munin/plugins/$spy
  chmod 755 /usr/lib/munin/plugins/$spy
done
