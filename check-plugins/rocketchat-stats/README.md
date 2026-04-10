# Check rocketchat-stats

## Overview

Monitors Rocket.Chat server statistics via the API, including total users, active users, online users, channels, messages, uploads, and file storage usage.

**Alerting Logic:**

* Always returns OK

**Data Collection:**

* Authenticates against the Rocket.Chat REST API and queries the statistics endpoint
* Reports users (total, online, busy, away, offline), types and distribution (connected, activated, deactivated, app users), uploads (count and size), rooms (channels, private groups, direct messages, discussions, omnichannel), and messages (total, threads, per room type)

**Important Notes:**

* Requires a Rocket.Chat user with a strong password and the `view-statistics` permission (only)
* See [Creating an API user account to monitor Rocket.Chat](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-ROCKETCHAT.md)

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rocketchat-stats> |
| Nagios/Icinga Check Name              | `check_rocketchat_stats` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Compiled for Windows                  | No |
| Requirements                          | Requires a user with strong password and `view-statistics` permission (only). |


## Help

```text
usage: rocketchat-stats [-h] [-V] [--insecure] [--no-proxy] -p PASSWORD
                        [--timeout TIMEOUT] [--url URL] --username USERNAME

Monitors Rocket.Chat server statistics via the API, including total users,
active users, online users, channels, messages, uploads, and file storage
usage. Requires a user with "view-statistics" permission.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  -p, --password PASSWORD
                        Rocket.Chat API password.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             Rocket.Chat API URL. Default:
                        http://localhost:3000/api/v1
  --username USERNAME   Rocket.Chat API username. Default: rocket-stats
```


## Usage Examples

```bash
./rocketchat-stats --username rocket-stats --password linuxfabrik --url http://rocket.chat:3000/api/v1
```

Output:

```text
8/325 users online, 295.2K msgs, 6.3K uploads, 4.3GiB upload total size, v6.4.7
* Users: 325 total (8 online, 0 busy, 1 away, 316 offline)
* Types and Distribution: 9 of 223 activated users online, 0 activated guests, 100 deactivated users, 2 Rocket.Chat app users
* Total Uploads: 6285, 4.3GiB size
* Total Rooms: 672 (1 channel, 96 private groups, 440 direct msg rooms, 0 discussions, 135 omnichannel rooms)
* Total Messages: 295.2K (829 threads, 5 in channels, 178.3K in priv groups, 115.0K in direct msg, 1.9K in omnichannel)
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| rc_activeGuests | Number | Types and Distribution: Activated Guests |
| rc_activeUsers | Number | Types and Distribution: Activated Users |
| rc_appUsers | Number | Types and Distribution: Rocket.Chat App Users |
| rc_awayUsers | Number | Users: Away |
| rc_busyUsers | Number | Users: Busy |
| rc_nonActiveUsers | Number | Types and Distribution: Deactivated Users |
| rc_offlineUsers | Number | Users: Offline |
| rc_onlineUsers | Number | Users: Online |
| rc_totalChannelMessages | Number | Total Messages: Messages in Channels |
| rc_totalChannels | Number | Total Rooms: Channels |
| rc_totalConnectedUsers | Number | Types and Distribution: Connected |
| rc_totalDirect | Number | Total Rooms: Direct Message Rooms |
| rc_totalDirectMessages | Number | Total Messages: Messages in Direct Messages |
| rc_totalDiscussions | Number | Total Rooms: Discussions |
| rc_totalLivechat | Number | Total Rooms: Omnichannel Rooms |
| rc_totalLivechatMessages | Number | Total Messages: Messages in Omnichannel |
| rc_totalMessages | Number | Total Messages: Messages |
| rc_totalPrivateGroupMessages | Number | Total Messages: Messages in Private Groups |
| rc_totalPrivateGroups | Number | Total Rooms: Private Groups |
| rc_totalRooms | Number | Total Rooms: Rooms |
| rc_totalThreads | Number | Total Messages: Threads |
| rc_totalUsers | Number | Users: Total |
| rc_uploadsTotal | Number | Uploads: Total Uploads |
| rc_uploadsTotalSize | Bytes | Uploads: Total Upload Size |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
