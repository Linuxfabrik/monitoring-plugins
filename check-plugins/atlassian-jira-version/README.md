# Check "atlassian-jira-version" - Overview

This plugin lets you track if a Atlassian Jira server update is available. To check for updates, this plugin uses the Atlassian RSS release feed. To compare against the current/installed version of Atlassian Jira, the check has to run on the Atlassian Jira server itself and needs access to the Atlassian Jira installation directory.

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
