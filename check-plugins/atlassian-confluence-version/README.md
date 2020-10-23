# Check "atlassian-confluence-version" - Overview

This plugin lets you track if a Atlassian Confluence server update is available. To check for updates, this plugin uses the Atlassian RSS release feed. To compare against the current/installed version of Atlassian Confluence, the check has to run on the Atlassian Confluence server itself and needs access to the Atlassian Confluence installation directory.

We recommend to run this check once a day.

The check uses a sqlite database to cache its query result.


# Installation and Usage

```bash
./atlassian-confluence-version --path /opt/atlassian/confluence
./atlassian-confluence-version --path /opt/atlassian/confluence --cache-expire 8 --always-ok
./atlassian-confluence-version --help
```


# States

* If wanted, always returns OK,
* else returns WARN if update is available.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
