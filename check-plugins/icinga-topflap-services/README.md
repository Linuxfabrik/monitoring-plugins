# Check icinga-topflap-services


## Overview

Detects fast-flapping Icinga services by counting state changes per service within a configurable lookback interval. Queries the Icinga DB event history and alerts when any service exceeds the configured number of state changes.

**Important Notes:**

* Requires Icinga DB with the Icinga Web 2 module
* The Icinga Web 2 user needs at least the "icingadb > General Module Access" permission
* Instead of specifying URL, username and password on the command line, you can create and specify an INI file:

    ```text
    [icingaweb2]
    url = http://localhost/icingaweb2/icingadb/history?limit=250
    username = alice
    password = linuxfabrik
    ```

**Data Collection:**

* Fetches data from the Icinga DB event history via the Icinga Web 2 REST API using HTTP Basic authentication
* Groups events by host and service, then counts state changes per service within the lookback window
* Uses a temporary SQLite database to store and aggregate event data per check run (dropped and recreated each run)
* Credentials can be provided via command-line parameters or a password INI file (command-line takes precedence)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/icinga-topflap-services> |
| Nagios/Icinga Check Name              | `check_icinga_topflap_services` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes (if `--pwfile` exists at the default path) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | Icinga DB, read access to `/icingaweb2/icingadb/history` |


## Help

```text
usage: icinga-topflap-services [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                               [--lookback LOOKBACK] [--no-proxy]
                               [--password PASSWORD] [--proxy PROXY]
                               [--pwfile PWFILE] [--timeout TIMEOUT]
                               [--url URL] [--username USERNAME] [-w WARN]

Detects fast-flapping Icinga services by counting state changes per service
within a configurable lookback interval. Queries the Icinga DB event history
and alerts when any service exceeds the configured number of state changes.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the number of state changes per
                       service within the lookback period. Supports Nagios
                       ranges. Default: 19
  --insecure           This option explicitly allows insecure SSL connections.
  --lookback LOOKBACK  State changes are counted within this window. Time
                       window in seconds to look back over, ending at the
                       moment of the run. Only what falls within it is
                       counted, so what is reported is how often something
                       happened lately rather than a total that keeps growing
                       for as long as the source is kept. Example:
                       `--lookback=7200`. Default: 14400 (seconds)
  --no-proxy           Do not use a proxy, not even one the environment names.
                       Overrides `--proxy`.
  --password PASSWORD  Icinga Web 2 password. Takes precedence over the value
                       in `--pwfile`.
  --proxy PROXY        Proxy to reach the target through. The scheme defaults
                       to `http` when omitted. Overrides the proxy the
                       environment names (`http_proxy`, `https_proxy`,
                       `all_proxy`) together with the exceptions it lists in
                       `no_proxy`, and is itself overridden by `--no-proxy`.
                       Without either parameter the environment applies.
                       Credentials belong into the environment variable rather
                       than here, because a command-line argument is visible
                       to every user on the host. Example:
                       `--proxy=http://proxy.example.com:3128`.
  --pwfile PWFILE      Path to a password file containing "url", "user" and
                       "password" for Icinga Web 2. Example: `--pwfile
                       /var/spool/icinga2/.icingaweb`. Default:
                       /var/spool/icinga2/.icingaweb
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  --url URL            Icinga DB event history URL including filter
                       parameters. Takes precedence over the value in
                       `--pwfile`. Example: `--url
                       https://icinga/icingaweb2/icingadb/history?limit=250`.
  --username USERNAME  Icinga Web 2 username. Takes precedence over the value
                       in `--pwfile`.
  -w, --warning WARN   WARN threshold for the number of state changes per
                       service within the lookback period. Supports Nagios
                       ranges. Default: 7

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/icinga-topflap-services/
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
