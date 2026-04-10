# Check network-port-tcp

## Overview

Checks whether a network port is reachable. This command works with both IPv4 and IPv6.

The check works fine for tcp connections, but not for udp. The port response for udp is based on the target application (for example DNS or OpenVPN) and is not standard like tcp.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/network-port-tcp> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |


## Help

```text
Traceback (most recent call last):
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/network-port-tcp/network-port-tcp", line 141, in 'module'
    main()
    ~~~~^^
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/network-port-tcp/network-port-tcp", line 105, in main
    args = parse_args()
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/network-port-tcp/network-port-tcp", line 72, in parse_args
    help=lib.args.help('--severity') + ' Default: %(default)s',
         ^^^^^^^^
AttributeError: module 'lib' has no attribute 'args'
```


## Usage Examples

```bash
./network-port-tcp --hostname www.linuxfabrik.ch --port 443 --portname https --timeout 1.3 --state warn
```

Output:

```text
www.linuxfabrik.ch:https/tcp is reachable.
```


## States

* WARN (default) or CRIT if port is unreachable.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
