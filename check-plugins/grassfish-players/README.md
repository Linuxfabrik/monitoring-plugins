# Check grassfish-players

## Overview

Monitors Grassfish digital signage players via the Grassfish API. Lists players whose data transfer is overdue, whose last access exceeds the configured threshold, or who are unlicensed. The player list can be filtered. Requires a Grassfish hostname and API token. Supports extended reporting via `--lengthy`.

**Data Collection:**

* Queries the Grassfish API (`/gv2/webservices/API` by default) to retrieve all player data
* Players can be filtered by `--box-id` (regex), `--box-state`, `--custom-id` (regex), `--is-installed`, `--is-licensed`, and `--transfer-status`
* By default, only players in "activated" state are checked
* Only players with warnings are shown in the table output (truncated to 10 entries)

**Compatibility:**

* Cross-platform

**Important Notes:**

* Tested with Grassfish API v1.12
* May take more than 10 seconds to execute depending on the number of players. Consider increasing `--timeout` if needed.
* `--box-id` and `--custom-id` support Python regular expressions (case-insensitive).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/grassfish-players> |
| Nagios/Icinga Check Name              | `check_grassfish_players` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | No (`--hostname` and `--token` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: grassfish-players [-h] [-V] [--always-ok] [--api-version API_VERSION]
                         [--box-id BOX_ID]
                         [--box-state {activated,deleted,new,reserved,undefined}]
                         [--custom-id CUSTOM_ID] -H HOSTNAME [--insecure]
                         [--is-installed {yes,no}] [--is-licensed {yes,no}]
                         [--lengthy] [--no-proxy] [--port PORT] [--test TEST]
                         [--timeout TIMEOUT] --token TOKEN
                         [--transfer-status {complete,overdue,pending}]
                         [-w WARN] [-u URL]

Monitors Grassfish digital signage players via the Grassfish API. Lists
players whose data transfer is overdue, whose last access exceeds the
configured threshold, or who are unlicensed. The player list can be filtered.
Requires a Grassfish hostname and API token. Supports extended reporting via
--lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --api-version API_VERSION
                        Grassfish API version. Default: 1.12
  --box-id BOX_ID       Filter by box ID. Supports Python regular expressions
                        (case-insensitive). Example: `--box-id
                        "^player-0[1-3]$"`.
  --box-state {activated,deleted,new,reserved,undefined}
                        Filter by box state. Can be specified multiple times.
                        Default: None
  --custom-id CUSTOM_ID
                        Filter by custom ID. Supports Python regular
                        expressions (case-insensitive). Example: `--custom-id
                        "(?i)lobby"`.
  -H, --hostname HOSTNAME
                        Grassfish hostname.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --is-installed {yes,no}
                        Filter by installation status ("yes" or "no"). Can be
                        specified multiple times.
  --is-licensed {yes,no}
                        Filter by license status ("yes" or "no"). Can be
                        specified multiple times.
  --lengthy             Extended reporting.
  --no-proxy            Do not use a proxy.
  --port PORT           Grassfish port number. Default: 443
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --token TOKEN         Grassfish API token.
  --transfer-status {complete,overdue,pending}
                        Filter by data transfer status. Can be specified
                        multiple times.
  -w, --warning WARN    WARN threshold for last access in hours (player
                        considered offline above this value). Default: > 8 h.
  -u, --url URL         Grassfish API URL. Default: /gv2/webservices/API
```


## Usage Examples

```bash
./grassfish-players --hostname=ds.example.com --token=TOKEN --box-id=gp11
```

Output:

```text
There are 6 players with warnings: 2 unlicensed, 2 transfer overdue, 6 accessed > 10 hours ago. 6 players checked. Filter: --box-state=['activated']

Box ID    ! License Type            ! Name                 ! Box State ! Lic             ! Transfer          ! Last Access                                
----------+-------------------------+----------------------+-----------+-----------------+-------------------+--------------------------------------------
GP111-111 ! Player                  ! Grassfish Player 111 ! Activated ! True            ! Complete          ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING] 
GP112-112 ! DsPlayerAdvancedSaas    ! Grassfish Player 112 ! Activated ! True            ! Pending           ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING] 
GP113-113 ! ColorDoorSignPlayerSaas ! Grassfish Player 113 ! Activated ! True            ! Overdue [WARNING] ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING] 
GP114-114 ! ColorDoorSignPlayerSaas ! Grassfish Player 114 ! Activated ! True            ! Complete          ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING] 
GP115-115 ! ColorDoorSignPlayerSaas ! Grassfish Player 115 ! Activated ! False [WARNING] ! Complete          ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING] 
GP117-117 ! ColorDoorSignPlayerSaas ! Grassfish Player 117 ! Activated ! False [WARNING] ! Overdue [WARNING] ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING]
```


## States

* OK if all players are licensed, transfer status is not "Overdue", and last access is within `--warning` hours.
* WARN if a player is not licensed.
* WARN if a player's transfer status is "Overdue".
* WARN if a player's last access is > `--warning` hours ago (default: 8 hours), which considers the player offline.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| grassfish_play_access_overdue | Number | Number of players with last access > `--warning` hours ago. |
| grassfish_play_players | Number | Number of matching players found. |
| grassfish_play_transfer_overdue | Number | Number of players with transfer status "Overdue". |
| grassfish_play_unlicensed | Number | Number of unlicensed players. |
| grassfish_play_warnings | Number | Total number of players with any warning. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
