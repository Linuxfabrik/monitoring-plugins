# Overview

This plugin lets you track statistics about a Rocket.Chat server. Requires a user with strong password and "view-statistics" permission (only).

Hints:
* Check uses a SQLite database in `/tmp` to store its historic data.

We recommend to run this check every 15 minutes.


# Installation and Usage

```bash
./rocket.chat-stats --username rocket-stats --password mypassword --url http://localhost:3000/api/v1
./rocket.chat-stats --help
```


# States and Perfdata

* WARN if a newer Rocket.Chat version is available.
* Otherwise OK.

Perfdata:

* Online Users
* Total Direct Messages
* Total Livechat
* Total Livechat Messages
* Total Livechat Visitors
* Total Messages
* Total Private Group Messages
* Total Private Groups
* Total Rooms
* Total Users
* Uploads Total
* Uploads Total Size (Byte)


# Known Issues and Limitations

* `--noproxy` not implemented
* `--insecure` not implemented


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.