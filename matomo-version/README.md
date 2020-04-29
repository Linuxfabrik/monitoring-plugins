# Check "matomo-version" - Overview

This plugin lets you track if a matomo server update is available. To check for updates, this plugin uses the Git Repo at https://github.com/matomo-org/matomo/releases. To compare against the current/installed version of Matomo, the check has to run on the Matomo server itself and needs access to the Matomo installation directory.

We recommend to run this check once a day.

The check uses a sqlite database to cache its query result.


# Installation and Usage

```bash
./matomo-version --path /var/www/html/matomo
./matomo-version --path /var/www/html/matomo --cache-expire 8 --always-ok
./matomo-version --help
```


# States

* If wanted, always returns OK,
* else returns WARN if update is available.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.