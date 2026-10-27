# Check nextcloud-app-updates


## Overview

Checks a Nextcloud installation for available app updates from the configured app store and alerts when an app update has been available for longer than the warning threshold (default: 72 hours). The grace period avoids alerting during maintenance windows where updates are applied promptly. Only enabled apps are listed and checked; disabled apps are ignored. The threshold is configurable. Requires root or sudo.

**Important Notes:**

* Must run on the Nextcloud server itself to access the installation directory
* Queries the Nextcloud app store, so the server needs outbound access to it
* The "pending since" age is measured by the plugin across runs. The first time an app update appears, its clock starts; alerting only kicks in once the update has been available longer than the threshold. A different available version restarts the clock.

**Data Collection:**

* Runs Nextcloud `occ app:update --showonly` to list apps with a pending update
* Runs Nextcloud `occ app:list` to list every enabled app with its installed version
* Runs `occ` with PHP as the account that owns `config/config.php`. When the check runs as root through its [sudoers entry](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers), it switches to that account with `sudo`, which therefore has to be installed. When it already runs as that account, for example as root with a `config.php` that belongs to root, it does without `sudo`
* Stores the first-seen timestamp of each pending update in a local SQLite database to measure how long it has been available
* Apps can be limited with `--match` and excluded with `--ignore`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-app-updates> |
| Nagios/Icinga Check Name              | `check_nextcloud_app_updates` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: nextcloud-app-updates [-h] [-V] [--always-ok] [-c CRIT]
                             [--ignore IGNORE] [--match MATCH]
                             [--no-match-severity {ok,warn,crit,unknown}]
                             [--no-perfdata] [--path PATH] [--timeout TIMEOUT]
                             [-v] [-w WARN]

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
                        multiple times. If both `--match` and `--ignore` are
                        given, an item must match `--match` AND not match
                        `--ignore` to be reported (include first, exclude
                        second).
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --path PATH           Local path to the Nextcloud installation, typically
                        the web server document root. Default:
                        /var/www/html/nextcloud
  --timeout TIMEOUT     Network timeout in seconds. Default: 25 (seconds)
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood.
  -w, --warning WARN    WARN threshold for how long an app update may stay
                        available, in hours. Supports Nagios ranges. Default:
                        72

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-app-updates/
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
* WARN if `occ` does not answer within `--timeout`.
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

### `sudo` is not installed

`Command "sudo" not found (No such file or directory). Install it, or make sure it is in the PATH of the account running this.`

`config/config.php` belongs to an account other than the one running the check, so the check switches to that account with `sudo`. Install it, for example with `dnf install sudo` or `apt install sudo`.


### Could not read the configuration below the installation

``Could not read the configuration below `/var/www/html/nextcloud`: PHP ended with rc=1. Run `php occ status` in `/var/www/html/nextcloud` as the owner of `config/config.php` to see why.``

Most often the check runs neither as root nor as the owner of `config/config.php`, and `sudo` refuses to switch to that account because it has no rule for the monitoring user. The supplied check command calls the check with `/usr/bin/sudo` and needs the matching [sudoers entry](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers); restore both if they were changed. If the check already runs as root, follow the message: `php occ status` as the owner of `config.php` shows what PHP complains about.


### Refusing an installation another account can change

`Refusing "/var/www/nextcloud": something below it can be changed by an account other than root and the trusted owners, or cannot be examined.`

`occ` runs as the owner of `config/config.php` and loads code from the whole installation, `console.php`, `lib/`, `3rdparty/`, `config/*.config.php` and every app directory `apps_paths` names, including those outside the installation. Every file and directory there therefore has to belong to root or that account, and no other user or group may write to it. The message does not name the offending object, because the account running the check may not be allowed to see it. Only `occ` and `config/config.php` themselves are named, for example `Refusing "/var/www/nextcloud/occ": "/var/www/nextcloud/occ" is writable by everyone.` Neither needs the execute bit, since the check runs `occ` through PHP; `0644` and `0755` both work, as long as no other user or group can write to the file. As root, list the candidates with (the data directory is skipped, adjust `apache` to the owner of `config.php`):

```bash
find /var/www/nextcloud -path /var/www/nextcloud/data -prune -o \( \( ! -user root ! -user apache \) -o -perm -o+w -o \( -perm -g+w ! -group root ! -group apache \) \) -print
getfacl --recursive --skip-base --absolute-names /var/www/nextcloud 2>/dev/null | grep '^# file'
```

Repeat both for every app directory outside the installation, such as `/var/lib/nextcloud/apps` on Fedora, together with its parent directories. A `config.php` that belongs to root, as `config_is_read_only` allows, makes `occ` run as root; then all of this has to belong to root.

## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
