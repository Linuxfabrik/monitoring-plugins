# Check icinga-topflap-services

## Overview

Detects fast-flapping Icinga services by counting state changes per service within a configurable lookback interval. Queries the IcingaDB event history and alerts when any service exceeds the configured number of state changes.

**Data Collection:**

* Fetches data from the IcingaDB event history via the IcingaWeb2 REST API using HTTP Basic authentication
* Groups events by host and service, then counts state changes per service within the lookback window
* Uses a temporary SQLite database to store and aggregate event data per check run (dropped and recreated each run)
* Credentials can be provided via command-line parameters or a password INI file (command-line takes precedence)

**Compatibility:**

* Requires IcingaDB with the IcingaWeb2 module
* The IcingaWeb2 user needs at least the "icingadb > General Module Access" permission

**Important Notes:**

* Instead of specifying URL, username and password on the command line, you can create and specify an INI file:

    ```text
    [icingaweb2]
    url = http://localhost/icingaweb2/icingadb/history?limit=250
    username = alice
    password = linuxfabrik
    ```


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/icinga-topflap-services> |
| Nagios/Icinga Check Name              | `check_icinga_topflap_services` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes (if `--pwfile` exists at the default path) |
| Compiled for Windows                  | No |
| Requirements                          | IcingaDB, read access to `/icingaweb2/icingadb/history` |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-icinga-topflap-services.db` |


## Help

```text
usage: icinga-topflap-services [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                               [--lookback LOOKBACK] [--no-proxy]
                               [--password PASSWORD] [--pwfile PWFILE]
                               [--timeout TIMEOUT] [--url URL]
                               [--username USERNAME] [-w WARN]

Detects fast-flapping Icinga services by counting state changes per service
within a configurable lookback interval. Queries the IcingaDB event history
and alerts when any service exceeds the configured number of state changes.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the number of state changes per
                       service within the lookback period. Supports Nagios
                       ranges. Default: 19
  --insecure           This option explicitly allows insecure SSL connections.
  --lookback LOOKBACK  Time window in seconds to consider for state change
                       counting. Default: 14400
  --no-proxy           Do not use a proxy.
  --password PASSWORD  IcingaWeb password. Takes precedence over the value in
                       `--pwfile`.
  --pwfile PWFILE      Path to a password file containing "url", "user" and
                       "password" for IcingaWeb. Example: `--pwfile
                       /var/spool/icinga2/.icingaweb`. Default:
                       /var/spool/icinga2/.icingaweb
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  --url URL            IcingaDB event history URL including filter parameters.
                       Takes precedence over the value in `--pwfile`. Example:
                       `--url
                       https://icinga/icingaweb2/icingadb/history?limit=250`.
  --username USERNAME  IcingaWeb username. Takes precedence over the value in
                       `--pwfile`.
  -w, --warning WARN   WARN threshold for the number of state changes per
                       service within the lookback period. Supports Nagios
                       ranges. Default: 7
```


## Usage Examples

```bash
./icinga-topflap-services \
    --username=alice \
    --password=linuxfabrik \
    --url='https://icinga/icingaweb2/icingadb/history?limit=250' \
    --lookback=86400
```

Output:

```text
There are warnings. (lookback=1D warn=7 crit=19)

Host            ! Service                 ! Cnt ! State     
----------------+-------------------------+-----+-----------
srv-mon01       ! Swap Usage              ! 12  ! [WARNING] 
srv-analytics01 ! Load                    ! 10  ! [WARNING] 
srv-analytics01 ! CPU Usage               ! 8   ! [WARNING] 
srv-vcs01       ! Swap Usage              ! 6   ! [OK]      
srv-cloud02     ! Apache httpd Status     ! 4   ! [OK]      
srv-repo01      ! Journald Usage          ! 2   ! [OK]      
srv-cloud01     ! Nextcloud Stats         ! 2   ! [OK]      
```


## States

* OK if no service exceeds the warning threshold for state changes within the lookback period.
* WARN if any service has >= `--warning` (default: 7) state changes.
* CRIT if any service has >= `--critical` (default: 19) state changes.
* UNKNOWN on missing credentials, unreadable password file, or invalid command-line arguments.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
