# Fritzbox bandwidth monitor with mrtg

This directory contains the files to build a container with kiwi to monitor
the bandwith usage of your Fritzbox with mrtg and some scripts around it to
start and manage the container with systemd and podman.

## Run the container

With default configuration:

```
  podman run -d -p 80:80 thkukuk/fritzbox-bandwidth-monitor
```

The data get's fetched from the Fritzbox with the IP `192.168.178.1`, the
statistic can be seen on `http://localhost/fritzbox.html`.

For persistent data and HTML output:
```
  mkdir -p /srv/fritzbox
  podman run -d -v /srv/fritzbox:/srv/www/htdocs -p 80:80 thkukuk/fritzbox-bandwidth-monitor
```

## Environment Variables

- POLL_INTERVAL 	- Poll interval in seconds, default `300`
- MAX_DOWNLOAD_BYTES 	- Max. incoming traffic in Bytes per Second, default `16000000000`
- MAX_UPLOAD_BYTES      - Max. outgoing traffic in Bytes per Second, default `5300000000`
- FRITZBOX_NR           - Fritzbox model, default `7530`
- FRITZBOX              - IP address of fritzbox, default `192.168.178.1`
- RUN_WEBSERVER=[0|1]   - If a webserver should be started, default `1`

## Screenshot

![Screenshot](Screenshot.png)
