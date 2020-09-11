# Check "wordpress-version" - Overview

This plugin lets you track if a WordPress server update is available. To check for updates, this plugin uses the GitHub free API. To compare against the current/installed version of WordPress, the check has to run on the WordPress server itself and needs access to the WordPress installation directory.

We recommend to run this check once a day.

The check uses a sqlite database to cache its query result.


# Installation and Usage

```bash
./atlassian-jira-version --path /opt/atlassian/jira
./atlassian-jira-version --path /opt/atlassian/jira --cache-expire 8 --always-ok
./atlassian-jira-version --help
```


# States

* If wanted, always returns OK,
* else returns WARN if update is available.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
