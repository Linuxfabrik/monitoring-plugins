# Check nextcloud-app-updates


## Overview

Checks a Nextcloud installation for available app updates from the configured app store and alerts when an app update has been available for longer than the warning threshold (default: 72 hours). The grace period avoids alerting during maintenance windows where updates are applied promptly. Only enabled apps are listed and checked; disabled apps are ignored. The threshold is configurable. Requires root or sudo.

**Important Notes:**

* Must run on the Nextcloud server itself to access the installation directory
* Queries the Nextcloud app store, so the server needs outbound access to it
* The "pending since" age is measured by the plugin across runs. The first time an app update appears, its clock starts; alerting only kicks in once the update has been available longer than the threshold. A different available version restarts the clock.

**Data Collection:**

* Requires sudo permissions for the UID under which the Nextcloud application runs
* Runs Nextcloud `occ app:update --showonly` via sudo to list apps with a pending update
* Runs Nextcloud `occ app:list` via sudo to list every enabled app with its installed version
* Stores the first-seen timestamp of each pending update in a local SQLite database to measure how long it has been available
* Apps can be limited with `--match` and excluded with `--ignore`


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-app-updates> |
| Nagios/Icinga Check Name              | `check_nextcloud_app_updates` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: nextcloud-app-updates [-h] [-V] [--always-ok] [-c CRIT]
                             [--ignore IGNORE] [--match MATCH]
                             [--no-match-severity {ok,warn,crit,unknown}]
                             [--path PATH] [-v] [-w WARN]

Checks a Nextcloud installation for available app updates from the configured
app store and alerts when an app update has been available for longer than the
warning threshold (default: 72 hours). The grace period avoids alerting during
maintenance windows where updates are applied promptly. Only enabled apps are
listed and checked; disabled apps are ignored. The threshold is configurable.
Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for how long an app update may stay
                        available, in hours. Supports Nagios ranges. Default:
                        no critical threshold
  --ignore IGNORE       Ignore apps whose app id matches this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times.
  --match MATCH         Only check apps whose app id matches this Python
                        regular expression. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --path PATH           Local path to the Nextcloud installation, typically
                        the web server document root. Default:
                        /var/www/html/nextcloud
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood.
  -w, --warning WARN    WARN threshold for how long an app update may stay
                        available, in hours. Supports Nagios ranges. Default:
                        72
```


## Usage Examples

```bash
./nextcloud-app-updates --path=/var/www/html/nextcloud --warning=72 --critical=168
```

Output:

```text
1 of 2 app update(s) pending longer than allowed [WARNING]

App      ! Installed ! Available ! Status
---------+-----------+-----------+----------
calendar ! 5.0.0     ! 5.0.1     ! [WARNING]
contacts ! 5.9.0     ! 6.0.0     ! [OK]
files    ! 2.0.0     ! -         ! [OK]
```

With `--verbose`, the `occ` commands the plugin runs are appended to the output:

```text
Executed occ commands:
  /var/www/html/nextcloud/occ app:update --showonly
  /var/www/html/nextcloud/occ app:list --output=json
```


## States

* OK if no app update is available, or if every available update is still within the warning grace period.
* WARN if an app update has been available for longer than `--warning` hours.
* CRIT if an app update has been available for longer than `--critical` hours (no critical threshold by default).
* UNKNOWN if the Nextcloud `occ` command cannot be run.
* `--no-match-severity` sets the state reported when the filters match no app and nothing is checked (default: `ok`); set it to `warn`, `crit`, or `unknown` to alert on an empty selection (for example a filter typo or a missing app) instead of silently returning OK.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| active | Number | Number of enabled apps checked (after `--match`/`--ignore` filtering). |
| overdue | Number | Number of available app updates that exceed the threshold. |
| pending | Number | Number of available app updates. |


## Troubleshooting

### `occ` command not found

`Error running sudo -u \#48 /var/www/html/nextcloud/occ app:update --showonly: rc=1 sudo: /var/www/html/nextcloud/occ: command not found`

Permission for `/var/www/html/nextcloud/occ` must be `0755`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
