#!/bin/bash

[ "${DEBUG}" = "1" ] && set -x

export PATH=/usr/sbin:/sbin:${PATH}
export LANG=C

RUN_INTERVAL=${RUN_INTERVAL:-300}
RUN_WEBSERVER=${RUN_WEBSERVER:-1}
FRITZBOX=${FRITZBOX:-192.168.178.1}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'FRITZBOX_PASSWORD' 'example'
# (will allow for "$FRITZBOX_PASSWORD_FILE" to fill in the value of
#  "$FRITZBOX_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    var="$1"
    fileVar="${var}_FILE"
    def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

setup_timezone() {
    if [ -n "$TZ" ]; then
	TZ_FILE="/usr/share/zoneinfo/$TZ"
	if [ -f "$TZ_FILE" ]; then
	    echo "Setting container timezone to: $TZ"
	    ln -snf "$TZ_FILE" /etc/localtime
	else
	    echo "Cannot set timezone \"$TZ\": timezone does not exist."
	fi
    fi
}

stop_nginx() {
    rv=$?
    [ "${RUN_WEBSERVER}" = "1" ] && nginx -s quit

    exit $rv
}

init_trap() {
    trap stop_nginx TERM INT EXIT
}

# Generic setup
setup_timezone
init_trap

test -d /srv/www/htdocs || mkdir -p /srv/www/htdocs

if [ ! -d /run/munin ]; then
  mkdir -p /run/munin
  chown munin:munin /run/munin
fi

test -d /var/lib/munin/plugin-state || mkdir -p /var/lib/munin/plugin-state

test -e /srv/www/htdocs/munin/.htaccess || cp -a /entrypoint/.htaccess /srv/www/htdocs/munin/.htaccess

munin-check -f

file_env 'FRITZBOX_PASSWORD'
if [ -z "${FRITZBOX_PASSWORD}" ]; then
    echo "Password for Fritzbox (FRITZBOX_PASSWORD) not set!" >&2
    exit 1
fi

# Rewrite munin.conf, much easier then to rewrite the examples
echo "includedir /etc/munin/munin-conf.d" > /etc/munin/munin.conf
echo "[${FRITZBOX}]" >> /etc/munin/munin.conf
echo "    address 127.0.0.1" >> /etc/munin/munin.conf
echo "    use_node_name no" >> /etc/munin/munin.conf

echo '[fritzbox_*]' > /etc/munin/plugin-conf.d/munin-node
echo "env.fritzbox_ip ${FRITZBOX}" >> /etc/munin/plugin-conf.d/munin-node
echo "env.fritzbox_username ${FRITZBOX_LOGIN}" >> /etc/munin/plugin-conf.d/munin-node
echo "env.fritzbox_password ${FRITZBOX_PASSWORD}" >> /etc/munin/plugin-conf.d/munin-node
echo "host_name ${FRITZBOX}" >> /etc/munin/plugin-conf.d/munin-node
echo "#env.traffic_remove_max true" >> /etc/munin/plugin-conf.d/munin-node

for py in /usr/lib/munin/plugins/fritzbox_*.py ; do
  spy=$(basename "$py")
  ln -sf "$py" "/etc/munin/plugins/${spy}"
done

/usr/sbin/munin-node

[ "${RUN_WEBSERVER}" = "1" ] && nginx

while true; do
  DATE=$(date -Iseconds)
  echo "$DATE Fetch new data"
  su - munin -c /usr/bin/munin-cron
  sleep "${RUN_INTERVAL}"
done
