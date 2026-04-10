# Check icinga-topflap-services

## Overview

This check plugin counts the number of state changes per service within a given lookback interval. This makes it possible to detect fast flapping services. The data is retrieved from the History \> Event Overview view in IcingaDB. To access the URL, all you need is an IcingaWeb2 user with the 'icingadb \> General Module Access' permission.

An output like `srv01 ! Swap usage ! 10 ! [WARNING]` means that the service 'Swap Usage' on host 'srv01' has had 10 service state changes in the lookback interval. With this information, you can now examine the history of the specified service.

Instead of specifying url, user and password on the command line, you can create and specify an INI file like this

```text
[icingaweb2]
url = http://localhost/icingaweb2/icingadb/history?limit=250
username = alice
password = linuxfabrik
```

Command line arguments override the settings in the password INI file.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/icinga-topflap-services> |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | IcingaDB, Read access to `/icingaweb2/icingadb/history` |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-icinga-topflap-services.db` |


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
There are warnings. (lookback=1D warn=5 crit=19)

Host            ! Service                 ! Cnt ! State     
----------------+-------------------------+-----+-----------
srv-mon01       ! Swap Usage              ! 12  ! [WARNING] 
srv-analytics01 ! Load                    ! 10  ! [WARNING] 
srv-analytics01 ! CPU Usage               ! 8   ! [WARNING] 
srv-vcs01       ! Swap Usage              ! 6   ! [WARNING] 
srv-cloud02     ! Apache httpd Status     ! 4   ! [OK]      
srv-repo01      ! Journald Usage          ! 2   ! [OK]      
srv-cloud01     ! Nextcloud Stats         ! 2   ! [OK]      
```


## States

* WARN or CRIT if a specified number of flapping services are found within the lookback interval.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
