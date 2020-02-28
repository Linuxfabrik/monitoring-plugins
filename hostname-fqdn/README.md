# Check "hostname-fqdn" - Overview

Checks if the local or a given hostname is a valid fully qualified domain name in full compliance with RFC 1035. The parameter `--hostname` checks the given string, not a remote host.

We recommend to run this check once a week or once in the lifetime of a machine.


# Installation and Usage

```bash
./hostname-fqdn
./hostname-fqdn --help
```


# States

* WARN if hostname is not a valid fully qualified domain name in full compliance with RFC 1035.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.