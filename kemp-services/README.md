# Check "kemp-services" - Overview

Kemp is a virtual load balancer (https://kemptechnologies.com).
This check warns on any virtual service which is marked as down, using the REST API.

Hints and Recommendations:
* Use `--filter` to only check services that contain a certain string in their NickName.
* Use `--state` to choose which state should be returned.

We recommend to run this check every minute.


# Installation and Usage

```bash
./kemp-services --hostname localhost --username user --password password
./kemp-services --hostname localhost --username user --password password --filter PROD
./kemp-services --hostname localhost --username user --password password --filter PROD --state crirt
```


# States

* WARN (default) if any virtual service is marked as down.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
