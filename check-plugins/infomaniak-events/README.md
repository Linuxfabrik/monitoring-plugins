# Check infomaniak-events

## Overview

Informs you about open events at Infomaniak via the Infomaniak API. To use this check, you have to create a Bearer Token with scope "event" at Infomaniak first. A filter for `--service` is applied before the `--ignore-regex` parameter.

"Services" (service categories) that we know about and that can be filtered:

* administration_console
* certificate
* cloud
* drive
* email_hosting
* hosting
* housing
* jelastic
* public_cloud
* radio
* swiss_backup
* web_hosting
* webmail

Links:

* API Documentation: <https://developer.infomaniak.com/docs/api/get/2/events>
* API Tokens: <https://manager.infomaniak.com/v3/$ACCOUNT_ID/ng/accounts/token>
* Infomaniak Status Page: <https://infomaniakstatus.com/>

Hints:

* Might take more than 10 seconds to execute.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/infomaniak-events> |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |


## Help

```text
usage: infomaniak-events [-h] [-V] [--always-ok] [--ignore-regex IGNORE_REGEX]
                         [--insecure] [--no-proxy] [--service SERVICE]
                         [--timeout TIMEOUT] --token TOKEN [--test TEST]

Informs you about open events at Infomaniak.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --ignore-regex IGNORE_REGEX
                        Any english title matching this python regex will be
                        ignored (repeating). Example: '(?i)linuxfabrik' for a
                        case-insensitive search for "linuxfabrik".
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: False
  --no-proxy            Do not use a proxy. Default: False
  --service SERVICE     Only report this service category (repeating).
                        Example: `--service=swiss_backup
                        --service=public_cloud`. Default: none (so report all)
  --timeout TIMEOUT     Network timeout in seconds. Default: 28 (seconds)
  --token TOKEN         Infomaniak API token
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
```


## Usage Examples

```bash
./infomaniak-events --token=TOKEN --service=public_cloud --service=swiss_backup --ignore-regex='(?i)acronis'
```

Output:

```text
information: Wave of fraudulent e-mails () - see https://infomaniakstatus.com/en/

Type        ! Title                            ! Services     ! Start               ! End                             ! Duration 
------------+----------------------------------+--------------+---------------------+---------------------------------+----------
impacting   ! Public Cloud: service disruption ! public_cloud ! 2023-05-10 19:30:15 ! 2023-05-10 20:12:02 (1M 3W ago) ! 41m 47s  
```


## States

* WARN if an event is not in state "terminated"


## Perfdata / Metrics

| Name  | Type   | Description                         |
|-------|--------|-------------------------------------|
| event | Number | 0 = no event, 1 = event in progress |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
