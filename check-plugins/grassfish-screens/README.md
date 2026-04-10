# Check grassfish-screens

## Overview

The Grassfish Platform offers a unified way to manage Digital Signage touchpoints. This monitoring plugin checks if the screens attached to a Grassfish player are on or off. You must provide both the Grassfish hostname and a Grassfish token for this check to work.

Tested with Grassfish v1.12.

Hints:

* Takes round about 5 minutes for 1'000 screens.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/grassfish-screens> |
| Check Interval Recommendation         | Every 8 hours |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-grassfish-screens.db` |


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
                        Grassfish API version. Default: 1.12.
  --box-id BOX_ID       Filter by box ID. Supports Python regular expressions
                        (case-insensitive). Example: `--box-id
                        "^player-0[1-3]$"`.
  --box-state {activated,deleted,new,reserved,undefined}
                        Filter by box state. Can be specified multiple times.
                        Default: None.
  --cache-expire CACHE_EXPIRE
                        Time after which cached screen data expires, in hours.
                        Default: 8.
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
  --port PORT           Grassfish port number. Default: 443.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --token TOKEN         Grassfish API token.
  --transfer-status {complete,overdue,pending}
                        Filter by data transfer status. Can be specified
                        multiple times.
  -w, --warning WARN    WARN threshold for last screen update in hours (screen
                        considered off above this value). Default: > 8 h.
  -u, --url URL         Grassfish API URL. Default: /gv2/webservices/API.
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

* WARN if screen's last access timestamp is \> `--warning` hours (which considers screen is switched off)


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| grassfish_scr_screens | Number | Number of screens attached to matching players found |
| grassfish_scr_screens_off | Number | Number of powered off screens |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
