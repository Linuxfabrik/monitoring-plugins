# Check wordpress-security-scan

## Overview

Runs a WordPress security scan against a site and reports what an attacker can see from the outside. Combines the black box scan with the inventory read from the local installation directory, so plugins and themes the scanner cannot fingerprint remotely are still listed with their installed version. Findings are split into three classes: known vulnerabilities from the scanner's vulnerability database, exposures that hand an attacker credentials, the database or an account (a readable wp-config backup, an SQL dump, a listable backup folder), and hardening findings such as outdated components or a reachable readme. Alerts CRITICAL on an exposure and on a vulnerability whose CVSS base score reaches the critical threshold, because both mean the site can be taken over right now and someone has to react immediately. Everything else alerts WARNING. Supports extended reporting via `--lengthy`. Requires the command-line tool `wpscan`.

**Important Notes:**

* Requires the command-line tool `wpscan` in `PATH`. It is a Ruby gem: `gem install wpscan`.
* A full scan takes minutes, not seconds. `--scan-timeout` therefore defaults to 600 seconds instead of the 8 seconds other checks use, and the shipped Director command raises its own timeout accordingly. Schedule the check once per day.
* Without a WPScan API token there is no vulnerability data at all. Version detection, the outdated flags and every exposure still work, so the check remains useful, but the "known vulnerabilities" class stays empty. See [API Token](#api-token).
* The scan sends a large number of requests to the target and probes for backup files and admin endpoints. Run it against your own sites only, and expect it to show up in the access log and in any WAF or fail2ban rule set.
* `--path` is optional in practice. If it points nowhere, or at an installation the monitoring user cannot read, the check falls back to pure black box mode and says so. It never turns a finished scan into an UNKNOWN, so a permission change on the web root cannot hide a critical finding.

**Data Collection:**

Two sources are merged:

* The remote scan, run as `wpscan --url=<url> --format=json`. It contributes the known vulnerabilities including their CVSS scores, the exposures, the interesting findings and the enumerable usernames.
* The local installation below `--path`. The check reads `wp-includes/version.php` for the core version and the plugin and theme headers below `wp-content/` for the installed components and their versions.

The second source exists because a black box scan can only find plugins and themes it is able to fingerprint from the outside. On a site with seventeen plugins it may recognise four. The check therefore reports both numbers ("Installed locally: 17 plugins, 3 themes. Detected by the scan: 4 plugins, 3 themes.") so the coverage of the scan is visible instead of implied.

Findings can be narrowed with `--match` and widened out with `--ignore`. Both are Python regular expressions and are tested against the component and against the finding title, so `--ignore="^akismet$"` accepts the risk for exactly one component.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wordpress-security-scan> |
| Nagios/Icinga Check Name              | `check_wordpress_security_scan` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | No (`--url` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `wpscan` |
| 3rd Party Python modules              | None |


## API Token

The WPScan vulnerability database is only queried when an API token is present. A free token with a small daily request quota is available at <https://wpscan.com/register>.

The token can be supplied in three ways, checked in this order:

1. `--api-token=<token>`
2. `--api-token-file=<path>`, which reads the first line of the file
3. the `WPSCAN_API_TOKEN` environment variable, if it is already exported

Prefer `--api-token-file` with a file owned by the monitoring user and mode `0600`. It keeps the token out of the monitoring configuration and out of the Director basket.

Whichever way it is supplied, the check hands the token to `wpscan` through the environment and never on the command line, so it does not appear in the process list of the scanning host.

Without a token, the `vp` and `vt` enumeration choices (vulnerable plugins, vulnerable themes) would make `wpscan` abort before it starts. The check downgrades them to `p` and `t` automatically, so a missing token results in a scan without vulnerability data rather than in an UNKNOWN result.


## Help

```text
usage: wordpress-security-scan [-h] [-V] [--always-ok] [--api-token API_TOKEN]
                               [--api-token-file API_TOKEN_FILE]
                               [--critical-cvss CRITICAL_CVSS]
                               [--ignore IGNORE] [--insecure] [--lengthy]
                               [--match MATCH]
                               [--no-match-severity {ok,warn,crit,unknown}]
                               [--no-perfdata] [--path PATH]
                               [--scan-timeout SCAN_TIMEOUT]
                               [--unscored-severity {ok,warn,crit}] -u URL
                               [-v] [--wpscan-enumerate WPSCAN_ENUMERATE]
                               [--wpscan-no-update]
                               [--wpscan-option WPSCAN_OPTION]

Runs a WordPress security scan against a site and reports what an attacker can
see from the outside. Combines the black box scan with the inventory read from
the local installation directory, so plugins and themes the scanner cannot
fingerprint remotely are still listed with their installed version. Findings
are split into three classes: known vulnerabilities from the scanner's
vulnerability database, exposures that hand an attacker credentials, the
database or an account (a readable wp-config backup, an SQL dump, a listable
backup folder), and hardening findings such as outdated components or a
reachable readme. Alerts CRITICAL on an exposure and on a vulnerability whose
CVSS base score reaches the critical threshold, because both mean the site can
be taken over right now and someone has to react immediately. Everything else
alerts WARNING. Supports extended reporting via --lengthy. Requires the
command-line tool wpscan.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --api-token API_TOKEN
                        WPScan API token, used to look up known
                        vulnerabilities. Without a token the scan still runs,
                        but reports no vulnerability data at all. The token is
                        handed to wpscan through the environment, never on the
                        command line, so it does not show up in the process
                        list. Takes precedence over --api-token-file and over
                        a token already present in the WPSCAN_API_TOKEN
                        environment variable.
  --api-token-file API_TOKEN_FILE
                        Path to the file containing the WPScan API token. Use
                        this instead of --api-token to keep the token out of
                        the monitoring configuration. Only the first line is
                        read, surrounding whitespace is stripped.
  --critical-cvss CRITICAL_CVSS
                        CVSS v3 base score at or above which a known
                        vulnerability is reported as CRITICAL instead of
                        WARNING. Vulnerabilities without a score are governed
                        by --unscored-severity. Default: 7.0
  --ignore IGNORE       Ignore findings whose component or title matches this
                        Python regular expression. Case-sensitive by default;
                        use `(?i)` for case-insensitive matching. Can be
                        specified multiple times. Example:
                        `--ignore="^akismet$"` to accept the risk of one
                        component.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Only report findings whose component or title matches
                        this Python regular expression. Case-sensitive by
                        default; use `(?i)` for case-insensitive matching. Can
                        be specified multiple times. If not specified, all
                        findings are reported.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --path PATH           Local path to your WordPress installation, typically
                        within your Webserver's Document Root. Read to
                        determine the installed core version and the installed
                        plugins and themes, which the remote scan on its own
                        cannot see completely. A path that does not exist is
                        not an error: the check then reports what the remote
                        scan found and says so. Default:
                        /var/www/html/wordpress
  --scan-timeout SCAN_TIMEOUT
                        Seconds to wait for the scan to finish. A full scan of
                        a site with many plugins takes minutes, so this is
                        much higher than the network timeout of other checks.
                        Default: 600 (seconds)
  --unscored-severity {ok,warn,crit}
                        State to report for a known vulnerability that carries
                        no CVSS score. The vulnerability database has no score
                        for a large share of its entries, so treating them all
                        as critical would page for every one of them. Default:
                        warn
  -u, --url URL         URL of the WordPress site to scan. Example:
                        `--url=https://www.example.com`
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood.
  --wpscan-enumerate WPSCAN_ENUMERATE
                        Enumeration options passed to wpscan (its
                        `--enumerate`). Comma-separated. `vp`/`vt` (vulnerable
                        plugins/themes) need an API token and are downgraded
                        to `p`/`t` automatically when none is available,
                        because wpscan aborts otherwise. Default:
                        vp,vt,tt,cb,dbe,bf,u
  --wpscan-no-update    Skip the update of the local vulnerability database
                        before scanning. Speeds up the check, at the price of
                        scanning against possibly stale vulnerability data.
  --wpscan-option WPSCAN_OPTION
                        Additional raw option to pass to the wpscan call, for
                        options that have no dedicated parameter here. Can be
                        specified multiple times. Example: `--wpscan-
                        option=--plugins-detection=aggressive`

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/wordpress-security-scan/
```


## Usage Examples

```bash
./wordpress-security-scan --url=https://www.example.com --path=/var/www/html/wordpress
```

Output on a healthy site:

```text
No vulnerabilities found. No exposures found. WordPress v7.0.2 on https://www.example.com
Installed locally: 3 plugins, 3 themes. Detected by the scan: 2 plugins, 3 themes.
```

Output on a site with findings:

```text
0 vulnerabilities (0 critical), 3 exposures, 4 hardening findings on https://www.example.com
Installed locally: 3 plugins, 3 themes. Detected by the scan: 2 plugins, 3 themes.

Component                                    ! Installed ! Finding                                  ! State
---------------------------------------------+-----------+------------------------------------------+-----------
contact-form-7                               ! 5.0       ! outdated, 6.1.6 is available             ! [WARNING]
https://www.example.com/wp-config.bak        ! -         ! Readable wp-config backup                ! [CRITICAL]
https://www.example.com/wordpress.sql        ! -         ! Readable database export                 ! [CRITICAL]
https://www.example.com/readme.html          ! -         ! WordPress readme found                   ! [WARNING]
https://www.example.com/wp-content/debug.log ! -         ! Debug Log found                          ! [CRITICAL]
https://www.example.com/wp-cron.php          ! -         ! The external WP-Cron seems to be enabled ! [WARNING]
site                                         ! -         ! 1 username enumerable (linuxfabrik)      ! [WARNING]
```

With `--lengthy`, which adds the finding type, the CVSS score and the release that fixes it:

```bash
./wordpress-security-scan --url=https://www.example.com --path=/var/www/html/wordpress --lengthy
```

```text
1 vulnerability (1 critical), 0 exposures, 0 hardening findings on https://www.example.com
Installed locally: 3 plugins, 3 themes. Detected by the scan: 2 plugins, 3 themes.

Component      ! Installed ! Type   ! CVSS ! Fixed in ! Finding                                            ! State
---------------+-----------+--------+------+----------+----------------------------------------------------+-----------
contact-form-7 ! 5.0       ! plugin ! 9.8  ! 5.3.2    ! Contact Form 7 < 5.3.2 - Unrestricted File Upload  ! [CRITICAL]
```

Accepting the risk for one component:

```bash
./wordpress-security-scan --url=https://www.example.com --ignore="^akismet$"
```

Reading the API token from a file instead of the command line:

```bash
./wordpress-security-scan --url=https://www.example.com --api-token-file=/etc/icinga2/wpscan.token
```


## States

Findings fall into three classes, and the worst of them determines the result:

| Class | What it is | State |
|----|----|----|
| Vulnerability | A known vulnerability from the WPScan vulnerability database, attached to the core, a plugin, a theme or a timthumb script. | CRIT if its CVSS v3 base score is >= `--critical-cvss` (default 7.0), otherwise WARN. An entry without a score follows `--unscored-severity` (default `warn`). |
| Exposure | Something reachable over HTTP that hands an attacker credentials, the database or an account outright: a readable `wp-config` backup, a database export, a backup folder with directory listing, a debug log, a `SearchReplaceDB2` or Duplicator installer left behind, an emergency password reset script, or a site still sitting on its installer. | Always CRIT. |
| Hardening | Everything else the scan reports: outdated core, plugins or themes, a reachable readme, an enabled external WP-Cron, upload directory listing, full path disclosure, enumerable usernames, a reachable timthumb script, and any finding type the scanner may add in the future. | WARN. |

In detail:

* OK if nothing in any of the three classes was found.
* OK for findings that only describe how the site is set up rather than a weakness, which are never reported: HTTP headers, a multisite install, must-use plugins, a disabled PHP, `robots.txt` and an enabled XML-RPC endpoint. All six are WordPress defaults or deliberate choices, so alerting on them would leave the check permanently non-OK on every installation.
* OK with "Nothing checked." when `--match` or `--ignore` filtered every finding away. `--no-match-severity` changes that state.
* WARN if the core version the scan sees differs from the one installed below `--path`. That means the scan did not look at this installation: a wrong virtual host, a stale cache, or a CDN in between.
* WARN on a timeout, whether the scan ran past `--scan-timeout` or past its own internal budget.
* CRIT as described in the table above.
* UNKNOWN if `wpscan` is not installed, if the token file cannot be read, if the scan aborted (for example because the target does not run WordPress), or if the scan produced no parsable output.
* `--always-ok` suppresses all alerts and always returns OK.

The coverage numbers ("Detected by the scan: 4 plugins") never influence the state. A component the scanner cannot fingerprint is a limit of black box scanning, not something the administrator can fix on the monitored site.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| exposures | Number | Number of exposures found. |
| hardening_findings | Number | Number of hardening findings. |
| plugins_detected | Number | Number of plugins the remote scan was able to fingerprint. |
| plugins_installed | Number | Number of plugins installed below `--path`. Zero when the local installation is not readable. |
| plugins_outdated | Number | Number of detected plugins for which a newer release exists. |
| scan_duration | Seconds | Wall clock time the scan took. |
| themes_detected | Number | Number of themes the remote scan was able to fingerprint, including the active theme. |
| themes_installed | Number | Number of themes installed below `--path`. Zero when the local installation is not readable. |
| themes_outdated | Number | Number of detected themes for which a newer release exists. |
| users | Number | Number of usernames that can be enumerated from the outside. |
| vulnerabilities | Number | Number of known vulnerabilities found. |
| vulnerabilities_critical | Number | Number of those vulnerabilities at or above `--critical-cvss`. |


## Troubleshooting

### `The command-line tool "wpscan" is not installed.`

`wpscan` is a Ruby gem and is not packaged by most distributions. Install Ruby and its development headers, then the gem itself, because one of its dependencies builds a native extension:

```bash
dnf install ruby ruby-devel gcc make
gem install wpscan
```

On Debian and Ubuntu the packages are `ruby`, `ruby-dev`, `build-essential`. Verify with `wpscan --version` as the user the monitoring agent runs as, since a `gem install --user-install` puts the executable into that user's home directory only.

### `The remote website is up, but does not seem to be running WordPress.`

The scanner reached the target but could not confirm a WordPress installation behind it. In most cases `--url` points at a host name the site does not answer on under that name: the site's own `siteurl` is different, so all the links in the response point elsewhere and the fingerprint fails. Use the URL the site actually serves itself under. A reverse proxy or a redirect to a different host causes the same result; `--wpscan-option=--follow-redirect` makes the scanner follow it.

If the target really is WordPress but hidden behind an unusual layout, `--wpscan-option=--force` skips the check.

### `Timeout after 600s while scanning ...`

A full enumeration against a large site, a slow target, or an aggressive detection mode can exceed the budget. Raise `--scan-timeout` and the Director command timeout together, since the command timeout has to stay above the scan timeout or the monitoring agent kills the check first.

Alternatively narrow the scan. Dropping the plugin and theme enumeration is the biggest single saving:

```bash
./wordpress-security-scan --url=https://www.example.com --wpscan-enumerate=cb,dbe,bf,u
```

`--wpscan-no-update` saves the vulnerability database update at the start of each run. Only use it if something else refreshes that database, otherwise the check silently scans against stale data.

### No vulnerabilities are ever reported

The vulnerability database needs an API token. Without one the check still finds exposures and outdated components, but the vulnerability class stays empty and `vulnerabilities=0` in the perfdata regardless of the actual state of the site. Run with `--verbose` and check the executed command: if it shows `--enumerate=p,t,...` instead of `--enumerate=vp,vt,...`, no token was resolved. See [API Token](#api-token).

### Findings that are accepted risks keep alerting

Suppress them per component or per finding title with `--ignore`, which takes a Python regular expression and can be given multiple times:

```bash
./wordpress-security-scan --url=https://www.example.com \
  --ignore="^akismet$" --ignore="(?i)wp-cron"
```

Ignored findings are removed from the state, from the table and from the counters in the perfdata, so a suppressed finding cannot come back through a metric.

### The check alerts CRITICAL right after a migration

A migration typically leaves the artifacts this check treats as exposures: a `wp-config.php.bak` next to the real one, an SQL dump in the document root, a Duplicator installer log, a backup directory with directory listing enabled. These are exactly the files an attacker looks for first, so the CRITICAL is correct. Remove them from the document root rather than suppressing the finding, and keep backups outside the web root.

### The scan is visible in the access log or triggers fail2ban

The scan probes for hundreds of known file locations, which produces a burst of 404s from the monitoring host. Whitelist the monitoring host in the WAF and in fail2ban, and keep the check interval at once per day. `--wpscan-option=--throttle=200` slows the scan down to one request every 200 milliseconds if the target cannot take the load.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/)
