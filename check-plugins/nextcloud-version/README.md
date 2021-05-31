# Check "nextcloud-version" - Overview

This plugin lets you track if Nextcloud server updates are available.

To check for updates, this plugin does *not* use
* the Git Repo at https://github.com/nextcloud/server/releases
* the downloads at https://download.nextcloud.com/server/releases
* the downloads at https://updates.nextcloud.com/customers/YOUR-SUBSCRIPTION-KEY

Instead it uses the internal ``occ update:check`` command, assuming that the *updatenotification* app is installed and enabled. The check has to run on the Nextcloud server itself and needs access to the Nextcloud installation directory.

We recommend to run this check once a day.


# Installation and Usage

```bash
./nextcloud-version --path /var/www/html/nextcloud
./nextcloud-version --path /var/www/html/nextcloud --always-ok
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
