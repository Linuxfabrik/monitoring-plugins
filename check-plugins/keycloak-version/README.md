# Check "keycloak-version" - Overview

This plugin lets you track if a Keycloak update is available. To check for updates, this plugin uses the Git Repo at https://github.com/keycloak/keycloak/releases. To compare against the current/installed version of Keycloak, the check has to run on the Keycloak server itself and needs access to the Keycloak installation directory.

We recommend to run this check once a day.

The check uses a sqlite database to cache its query result.


# Installation and Usage

```bash
./keycloak-version --path /opt/keycloak
./keycloak-version --path /opt/keycloak --cache-expire 8 --always-ok
./keycloak-version --help
```


# States

* If wanted, always returns OK,
* else returns WARN if update is available.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
