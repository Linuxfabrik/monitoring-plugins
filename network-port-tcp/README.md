Limitations:
* Works only for TCP connections: The check Works fine for tcp connections, but not for udp. The port response for udp is based on the target application (for example, DNS or OpenVPN) and is not standard like tcp.
* No perfdata.

./network-port-tcp
./network-port-tcp --port=22
./network-port-tcp --hostname=www.google.ch --port=443 --portname=https --timeout=1.3 --state=warn