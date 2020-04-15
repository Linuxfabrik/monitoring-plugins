# Check "rocket.chat-version" - Overview

This plugin lets you track if a Rocket.Chat server update is available. To check for updates, this plugin uses the Git Repo at https://github.com/RocketChat/Rocket.Chat/releases. To compare against the current/installed version of Rocket.Chat, the check needs URL/API access to the Rocket.Chat server. Requires a user with strong password and "view-statistics" permission (only).

We recommend to run this check once a day.

The check uses a sqlite database to cache its query result.


# Installation and Usage

```bash
./rocket.chat-version --username rocket-stats --password mypassword --url http://localhost:3000/api/v1 --cache-expire 8 --always-ok
./rocket.chat-version --help
```


# States

* If wanted, always returns OK,
* else returns WARN if update is available.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.