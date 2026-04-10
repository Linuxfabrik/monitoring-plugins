# Check grassfish-screens

## Overview

Checks if screens attached to Grassfish digital signage players are on or off via the Grassfish API. The player list can be filtered by box state, customer ID, or custom ID. Requires a Grassfish hostname and API token. Alerts when screens are unexpectedly off. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Tested with Grassfish API v1.12
* Takes approximately 5 minutes for 1000 screens because each player's screen data requires a separate API call.
* `--box-id` and `--custom-id` support Python regular expressions (case-insensitive).


**Data Collection:**

* Queries the Grassfish API (`/gv2/webservices/API` by default) to retrieve all player data, then fetches screen status for each matching player via the `Players/<id>/Screens` endpoint
* Screen data is cached locally to reduce API load (configurable via `--cache-expire`, default: 8 hours)
* A screen is considered "off" when its last update exceeds the `--warning` threshold
* Players can be filtered by `--box-id` (regex), `--box-state`, `--custom-id` (regex), `--is-installed`, `--is-licensed`, and `--transfer-status`
* By default, only players in "activated" state are checked
* Only players with screen warnings are shown in the table output (truncated to 20 entries)

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/grassfish-screens> |
| Nagios/Icinga Check Name              | `check_grassfish_screens` |
| Check Interval Recommendation         | Every 8 hours |
| Can be called without parameters      | No (`--hostname` and `--token` are required) |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-grassfish-screens.db` |


## Help

```text
usage: grassfish-screens [-h] [-V] [--always-ok] [--api-version API_VERSION]
                         [--box-id BOX_ID]
                         [--box-state {activated,deleted,new,reserved,undefined}]
                         [--cache-expire CACHE_EXPIRE] [--custom-id CUSTOM_ID]
                         -H HOSTNAME [--insecure] [--is-installed {yes,no}]
                         [--is-licensed {yes,no}] [--lengthy] [--no-proxy]
                         [--port PORT] [--test TEST] [--timeout TIMEOUT]
                         --token TOKEN
                         [--transfer-status {complete,overdue,pending}]
                         [-w WARN] [-u URL]

Checks if screens attached to Grassfish digital signage players are on or off
via the Grassfish API. The player list can be filtered by box state, customer
ID, or custom ID. Requires a Grassfish hostname and API token. Alerts when
screens are unexpectedly off. Supports extended reporting via --lengthy.

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
  --cache-expire CACHE_EXPIRE
                        Time after which cached screen data expires, in hours.
                        Default: 8
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
  -w, --warning WARN    WARN threshold for last screen update in hours (screen
                        considered off above this value). Default: > 8 h.
  -u, --url URL         Grassfish API URL. Default: /gv2/webservices/API
```


## Usage Examples

```bash
./grassfish-screens --hostname=ds.example.com --token=TOKEN --box-id=gp11
```

Output:

```text
1 screen is off (accessed > 10 hours ago). 1 screen checked. Filter: --box-state=['activated']

Box ID    ! Name                 ! Screen1 On      ! Screen2 On 
----------+----------------------+-----------------+------------
GP111-111 ! Grassfish Player 111 ! False [WARNING] ! None
```


## States

* OK if all screens were updated within `--warning` hours.
* WARN if a screen's last update is > `--warning` hours ago (default: 8 hours), which considers the screen switched off.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| grassfish_scr_screens | Number | Number of screens attached to matching players. |
| grassfish_scr_screens_off | Number | Number of screens considered off. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
