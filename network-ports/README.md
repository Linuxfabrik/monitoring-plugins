Limitations:
* Currently just works for TCP connections.
* No perfdata.

./network-ports
./network-ports --port=22
./network-ports --hostname=www.google.ch --port=443 --portname=https --type=tcp --timeout=1.3 --state=warn