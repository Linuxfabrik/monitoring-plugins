# Check "wordpress-version" - Overview

This plugin lets you track if a WordPress update is available. To check for updates, this plugin uses the Git Repo at https://github.com/WordPress/WordPress/releases. To compare against the current/installed version of WordPress, the check has to run on the WordPress server itself and needs access to the WordPress installation directory.

We recommend to run this check once a day.

The check uses a sqlite database to cache its query result.


# Installation and Usage

```bash
./wordpress-version --path /var/www/html/wordpress
./wordpress-version --path /var/www/html/wordpress --cache-expire 8 --always-ok
./wordpress-version --help
```


# States

* If wanted, always returns OK,
* else returns WARN if update is available.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
