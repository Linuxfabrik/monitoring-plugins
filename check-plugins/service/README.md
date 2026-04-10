# Check service

## Overview

Checks the state of one or more Windows services. Accepts the case-insensitive service name (not the display name) and supports Python regular expressions to match multiple services. Verifies that the number of services in the expected state falls within the specified Nagios range thresholds.

**Alerting Logic:**

* WARN if the number of services in the expected status falls outside the `--warning` range (default: `1:`, meaning at least one must match)
* CRIT if the number of services in the expected status falls outside the `--critical` range (default: none)
* `--always-ok` suppresses all alerts and always returns OK

**Data Collection:**

* Uses `psutil.win_service_iter()` to enumerate all Windows services
* Filters services by name (regex), start type (`--starttype`, default: automatic), and expected status (`--status`, default: running)
* Counts how many matching services are in the expected status and compares against the threshold ranges

**Important Notes:**

* Provide the case-insensitive Windows "Service Name", not the "Display Name". Example: Display Name "Diagnostic Policy Service" has Service Name `DPS` (provide `DPS`)
* For use in Icinga Director: If the service name contains a `$`, this dollar sign must be escaped with another dollar sign. Since the plugin is capable of regular expressions, this character must also be escaped with a backslash. So if you want to check `my$service`, you have to specify `my\$$service`.
* On the Windows command line: If you want to check `my$service`, you have to specify `my\$service`.
* On the Windows command line: Only use double quotes to provide regexes to `--service`; if running unit tests on Linux, use single quotes instead.

**Compatibility:**

* Windows


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/service> |
| Nagios/Icinga Check Name              | `check_service` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--service` is required) |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: service [-h] [-V] [--always-ok] [-c CRIT] --service SERVICE
               [--starttype {automatic,disabled,manual}]
               [--status {continue_pending,pause_pending,paused,running,start_pending,stop_pending,stopped}]
               [--test TEST] [-w WARN]

Checks the state of one or more Windows services. Accepts the case-insensitive
service name (not the display name) and supports regular expressions to match
multiple services. Alerts on services that are not in the expected state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the number of services in the
                        expected status. Accepts Nagios ranges. Default: None
  --service SERVICE     Name of the Windows service(s) to check. Supports
                        Python regular expressions (regex).
  --starttype {automatic,disabled,manual}
                        Filter by service start type. Can be specified
                        multiple times. Default: automatic.
  --status {continue_pending,pause_pending,paused,running,start_pending,stop_pending,stopped}
                        Expected service status. Can be specified multiple
                        times. Default: running.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  -w, --warning WARN    WARN threshold for the number of services in the
                        expected status. Accepts Nagios ranges. Default: 1:
```


## Usage Examples

Check that exactly one service named "BFE" (exact match) is running, otherwise WARN:

```bash
service --service="^bfe$" --status=running --warning=1:1
```

Output:

```text
Everything is ok. 1 service named r`^bfe$` and start type ['automatic'] found, 1 in status ['running'] (thresholds 1:1/None).

Display Name          ! Service Name ! Status  ! Startup
----------------------+--------------+---------+-----------
Base Filtering Engine ! BFE          ! running ! automatic
```

Check that there are at least 10 but not more than 20 Windows services named "myapp followed by a 4-digit serial number" meeting the status "running":

```bash
service --service="^myapp[0-9]{4}$" --starttype=automatic --status=running --warning=10:19
```

Output:

```text
2 services named r`^myapp[0-9]{4}$` and start type ['automatic'] found, 2 in status ['running'] (thresholds 10:19/None) [WARNING].

Display Name      ! Service Name ! Status  ! Startup
------------------+--------------+---------+-----------
myapp0815         ! myapp0815    ! running ! automatic
myapp4711         ! myapp4711    ! running ! automatic
```

Check that ALL services with startup type "automatic" are running, except for a few that are known for a delayed or triggered start:

```bash
service --service="^(?!DPS|MSDTC|MapsBroker|UsoSvc|Dnscache|gpsvc$).*$" --starttype=automatic --status=continue_pending --status=pause_pending --status=paused --status=start_pending --status=stop_pending --status=stopped --warning 0
```


## States

* OK if the number of services in the expected status falls within the threshold ranges.
* WARN if the number of services in the expected status falls outside `--warning` (default: `1:`).
* CRIT if the number of services in the expected status falls outside `--critical`.
* UNKNOWN if the service regex is invalid or no matching services are found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Development

How to create and delete a service on Windows (it will be removed on next boot):

```
sc.exe create tie-adt-importer binPath= "C:\Windows\System32\cmd.exe /c exit 0" DisplayName= "iengine - adt-importer" start= demand type= own
sc.exe query tie-adt-importer
sc.exe delete tie-adt-importer
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
