#!/bin/sh

[ "${DEBUG}" = "1" ] && set -x

export PATH=/usr/sbin:/sbin:${PATH}
export LANG=C

POLL_INTERVAL=${POLL_INTERVAL:-300}
MAX_DOWNLOAD_BYTES=${MAX_DOWNLOAD_BYTES:-16000000000}
MAX_UPLOAD_BYTES=${MAX_UPLOAD_BYTES:-5300000000}
FRITZBOX_NR=${FRITZBOX_NR:-7530}
FRITZBOX=${FRITZBOX:-192.168.178.1}
RUN_WEBSERVER=${RUN_WEBSERVER:-1}

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
    [ "${RUN_WEBSERVER}" = "1" ] && nginx -s quit
}

init_trap() {
    trap stop_nginx TERM INT
}

# Generic setup
setup_timezone
init_trap

if [ ! -f /etc/mrtg.cfg ]; then
    sed -e "s|7490|${FRITZBOX_NR}|g" \
	-e "s|^MaxBytes1[fritzbox]:|MaxBytes1[fritzbox]: ${MAX_DOWNLOAD_BYTES}|g" \
	-e "s|^MaxBytes2[fritzbox]:|MaxBytes2[fritzbox]: ${MAX_UPLOAD_BYTES}|g" \
	-e "s|192.168.178.1 (fritzbox.home.lan)|${FRITZBOX}|g" \
	/fritzbox-bandwidth-monitor/mrtg.cfg > /etc/mrtg.cfg
fi

if [ ! -f /etc/upnp2mrtg.cfg ]; then
    echo "HOST=\"${FRITZBOX}\"" > /etc/upnp2mrtg.cfg
    echo "NETCAT=\"nc\"" >> /etc/upnp2mrtg.cfg
fi

test -d /srv/www/htdocs || mkdir -p /srv/www/htdocs

[ "${RUN_WEBSERVER}" = "1" ] && nginx

while true; do
  DATE=$(date -Iseconds)
  echo "$DATE Fetch new data"
  /usr/bin/mrtg /etc/mrtg.cfg
  sleep "${POLL_INTERVAL}"
done
