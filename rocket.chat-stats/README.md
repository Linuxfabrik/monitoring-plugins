# Check "rocket.chat-stats" - Overview

This plugin lets you track statistics about a Rocket.Chat server. Requires a user with strong password and "view-statistics" permission (only).

We recommend to run this check every 15 minutes.


# Installation and Usage

```bash
./rocket.chat-stats --username rocket-stats --password mypassword --url http://localhost:3000/api/v1
./rocket.chat-stats --help
```


# States

* Always returns OK.


# Perfdata

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


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.