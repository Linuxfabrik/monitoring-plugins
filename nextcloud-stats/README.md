# Overview

./nextcloud-stats --url https://myserver:8443/ocs/v2.php/apps/serverinfo/api/v1/info --username myuser --password mypassword

We recommend to run this check every 15 minutes.


Might take up to 30 seconds for the first time; after that, takes approx. 1 to 2 seconds.

Only throws a warning if app updates are available.

Hints:
* If a Nextcloud App leads to a "500 Internal Server Error", the Nextcloud API often still remains intact. If you want to check the availability of the web frontend, you have to use other checks.
* Check uses a SQLite database in `/tmp` to store its historic data.


Tested with Nextcloud >= 15.0.4

Inspired by: https://github.com/BornToBeRoot/check_nextcloud


# Installation and Usage

```bash
./0-example --help
```


# States and Perfdata


# Known Issues and Limitations


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.



