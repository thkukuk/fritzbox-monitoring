# Monitor your FRITZ!Box

The repository provides the documentation for two container images to
monitor your FRITZ!Box. Additional it contains the KIWI files to build
this images and additional files, like systemd services to automatically
start the containers at boot time.

## [FRITZ!Box bandwith monitor](mrtg/README.md)

This container uses `mrtg` to monitor the bandwith usage.

## [FRITZ!Box monitor](munin/README.md)

This container uses `munin` to monitor several values of your FRITZ!Box.
E.g. bandwith usage, uptime, CPU usage, CPU temperature, memory usage, 
and other similar values. This container requires the FRITZ!Box password
to login to fetch the data.
