# Check "nextcloud-version" - Overview

This plugin lets you track if a Nextcloud server update is available. To check for updates, this plugin does _not_ use the Git Repo at https://github.com/nextcloud/server/releases or the downloads at https://download.nextcloud.com/server/releases/. Instead it uses the official Nextcloud Update Server, like your Nextcloud installation itself at `index.php/settings/admin/overview` does. To compare against the current/installed version of Nextcloud, the check has to run on the Nextcloud server itself and needs access to the Nextcloud installation directory.

We recommend to run this check once a day.

The check uses a sqlite database to cache its query result.


# Installation and Usage

```bash
./nextcloud-version --path /var/www/html/nextcloud
./nextcloud-version --path /var/www/html/nextcloud --cache-expire 8 --always-ok
./nextcloud-version --help
```


# States

* If wanted, always returns OK,
* else returns WARN if update is available.


# Perfdata

There is no perfdata.


# Troubleshooting

`sudo: unknown user: #-1, sudo: error initializing audit plugin sudoers_audit`
    Nextcloud installation was not found.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
