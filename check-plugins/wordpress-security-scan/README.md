# Check wordpress-security-scan


## Overview

Runs a WordPress security scan against a site and reports what an attacker can see from the outside. Combines the black box scan with the inventory read from the local installation directory, so plugins and themes the scanner cannot fingerprint remotely are still listed with their installed version. Findings are split into three classes: known vulnerabilities from the scanner's vulnerability database, exposures that hand an attacker credentials, the database or an account (a readable wp-config backup, an SQL dump, a listable backup folder), and hardening findings such as outdated components or a reachable readme. Alerts CRITICAL on an exposure and on a vulnerability whose CVSS base score reaches the critical threshold, because both mean the site can be taken over right now and someone has to react immediately. Everything else alerts WARNING. The vulnerability database is refreshed before every scan and only queried with an API token; without one the check says so instead of reporting a clean result it could not verify. Supports extended reporting via `--lengthy`. Requires the command-line tool `wpscan`.

**Important Notes:**

* Requires the command-line tool `wpscan` in `PATH`. It is a Ruby gem, not a distribution package; see "Installing wpscan" below for what it needs and which releases can run it. Install it system-wide, not for a single account: a gem in a user's home is invisible to the monitoring agent and to `sudo`. Keep it current: an enumeration choice the installed release does not know is skipped automatically, so an outdated scanner quietly covers less. `--help` names the release each affected choice needs.
* A missing `wpscan` is reported as WARNING, not as UNKNOWN. WordPress is a preferred target, so the scanner belongs on a host serving it, and its absence is a state the administrator has to fix rather than an internal problem of this check.
* A full scan takes minutes, not seconds. `--total-timeout` therefore defaults to 1800 seconds instead of the 8 seconds other checks use, and the shipped Director command raises its own timeout accordingly. Schedule the check once per day.
* Without a WPScan API token there is no vulnerability data at all. Version detection, the outdated flags and every exposure still work, so the check remains useful, but the "known vulnerabilities" class stays empty. The check says so in its output instead of reporting a clean result, and `--no-vuln-data-severity` decides whether that alerts. A free token with a small daily request quota is available at <https://wpscan.com/register>.
* A WPScan enterprise subscription replaces the API token with a locally held copy of the vulnerability database, which has no daily quota. Configure it with `--enterprise-db-token-file` (or `--enterprise-db-token`, or the `WPSCAN_ENTERPRISE_DB_TOKEN` environment variable). The check then keeps the vulnerable-plugins and vulnerable-themes enumeration even though no API token is set, and downloads the database dumps before every scan. `--api-token` is ignored alongside it, because the scanner refuses to run with both.
* The token is looked up in three places, in this order: `--api-token-file` (first line of the file), `--api-token`, and an already exported `WPSCAN_API_TOKEN` environment variable. Prefer `--api-token-file` with a file owned by the monitoring user and mode `0600`: a token passed as `--api-token` is visible to every user on the scanning host for as long as the check runs, because command-line arguments show up in the process list, and it additionally sits in the monitoring configuration and in the Director basket. Whichever way it is supplied, the check hands it on to `wpscan` through the environment, so it never reaches the scanner's own command line. The same order applies to `--wpscan-http-auth-file` and `--wpscan-http-auth`.
* Without a token, the `vp` and `vt` enumeration choices (vulnerable plugins, vulnerable themes) would make `wpscan` abort before it starts. The check downgrades them to `p` and `t` automatically, so a missing token results in a scan without vulnerability data rather than in an UNKNOWN result.
* The time limit is `--total-timeout`, and there is no `--timeout` beside it. It bounds the run as a whole, across the refresh of the vulnerability database, the version probe and the scan itself, and every one of those is deducted from it as it is spent. A scan repeated after a redirect or after a rejected API token therefore shares the same budget rather than starting a second one.
* The finding table stops after 50 rows and states how many were left out. That is a display limit only: the state is determined by every finding, and the performance data counts them all.
* The scan sends a large number of requests to the target and probes for backup files and admin endpoints. Run it against your own sites only, and expect it to show up in the access log and in any WAF or fail2ban rule set.
* On a stock WordPress the check reports WARNING out of the box: `readme.html` is reachable, the external WP-Cron is enabled and at least one username is usually enumerable. These are genuine hardening findings, not false alarms. Address them, or accept them with `--ignore`.
* `--path` is optional in practice. If it points nowhere, or at an installation the monitoring user cannot read, the check falls back to pure black box mode and says so. It never turns a finished scan into an UNKNOWN, so a permission change on the web root cannot hide a critical finding.
* `--url` is optional where the installation pins its own address. If it is not given, the check reads `WP_HOME` or `WP_SITEURL` from `wp-config.php` below `--path`. Most installations keep the address in the database instead, and `wp-config.php` is usually not readable for the monitoring user, so pass `--url` unless you know both apply.
* The check is part of the WordPress Service Set, so tagging a host `wordpress` activates it. The service it creates carries no `--url` and therefore reports UNKNOWN until one is set. That is deliberate: the address is per instance and cannot be guessed, and a check that says nothing is worse than one that asks to be configured.
* The vulnerability database is refreshed before every scan, so a site is graded against current data. If the refresh fails, for example on a host that cannot reach `data.wpscan.org`, the scan still runs against the local copy and the check says so. The refresh counts towards `--total-timeout`, so the check as a whole keeps to it. Use `--wpscan-no-update` where something else keeps the database current.

**Installing wpscan:**

`wpscan` is a Ruby gem. No distribution packages it, so it is installed with `gem install` and needs three things on the host: Ruby 3.3 or newer, `libcurl` at runtime, and a C compiler while the gem is being installed.

The compiler is the part worth spelling out, because putting one on a production server is a hardening question. Four of the gem's dependencies have no prebuilt binary and are compiled during `gem install`; everything else, `nokogiri` above all, arrives prebuilt. The compiler is therefore only needed while installing, not while scanning, and the last line of each block below removes it again. Only put it back for a `gem update wpscan`. Note that the scanner's own documentation asks for the distribution's full development group, which installs several hundred packages; nothing beyond the handful named below is needed.

On RHEL 10, Rocky 10, AlmaLinux 10 and Fedora, where the distribution's Ruby is already new enough:

```bash
dnf install ruby ruby-devel gcc make
gem install --no-document wpscan
dnf remove ruby-devel gcc make
```

On RHEL 9, Rocky 9 and AlmaLinux 9 the default Ruby is too old, so select a current module stream first, before anything is installed with `gem`. Switching the stream afterwards leaves the already installed gems linked against the Ruby that is gone, and they then fail to load:

```bash
dnf module reset ruby
dnf module enable ruby:3.3
dnf install ruby ruby-devel gcc make
gem install --no-document wpscan
dnf remove ruby-devel gcc make
```

On Debian and Ubuntu, two packages have to be asked for that nothing else pulls in. `libcurl` comes with `curl`; without it the gem installs cleanly and the scanner then fails to start with `Could not open library 'libcurl'`. And the C library headers come with `libc6-dev`; without them the compile stops at `fatal error: limits.h: No such file or directory`, which on some releases `ruby-dev` happens to cover and on others does not:

```bash
apt install ruby ruby-dev gcc make libc6-dev curl
gem install --no-document wpscan
apt remove ruby-dev gcc make libc6-dev
```

Afterwards, confirm what actually landed on the host:

```bash
wpscan --version --no-update
```

That last step is the one to not skip. Where Ruby is older than 3.3, `gem` does not report an error: it quietly falls back to the newest scanner release that still runs on that Ruby, which is several years old and misses the backup folder enumeration among other things. The check works with it and skips what it cannot use, so nothing in the output says the scanner is behind.

Releases whose own Ruby is too old for the current scanner, and what `gem install` produces on them:

| Release | Result |
|----|----|
| RHEL 8 | A current Ruby is available as a module stream, but the prebuilt `nokogiri` then refuses to load on its glibc, so the scanner installs and does not start. Its `libcurl` also predates the version the scanner asks for, which shows up as HTTP/2 framing errors against some targets. Run the check from a newer host against RHEL 8 sites rather than on them. |
| RHEL 9 | Fixed by the module stream above. |
| Debian 11 | Installs an old scanner that then fails to start on a dependency conflict. |
| Debian 12 | The install fails outright, because the prebuilt `nokogiri` does not cover its Ruby and building it from source needs far more than the packages above. |
| Ubuntu 22.04, Ubuntu 24.04 | Installs and runs, but with the old scanner described above. |

Everything else in current use is fine as it stands: RHEL 10, Rocky 10, AlmaLinux 10, Fedora, Debian 13 and Ubuntu 26.04 all ship a Ruby the current scanner accepts.

**Data Collection:**

Two sources are merged:

* The remote scan, run as `wpscan --url=<url> --format=json`. It contributes the known vulnerabilities including their CVSS scores, the exposures, the interesting findings and the enumerable usernames. The vulnerability database is refreshed beforehand, and the scan is adapted to what the installed `wpscan` release supports.
* The local installation below `--path`. The check reads `wp-includes/version.php` for the core version, the plugin and theme headers below `wp-content/` for the installed components and their versions, and `wp-config.php` for the site URL when `--url` is not given.

The second source exists because a black box scan can only find plugins and themes it is able to fingerprint from the outside. On a site with seventeen plugins it may recognise four. The check therefore reports both numbers ("Installed locally: 17 plugins, 3 themes. Detected by the scan: 4 plugins, 3 themes.") so the coverage of the scan is visible instead of implied.

Findings can be narrowed from both ends: `--match` keeps only what matches, `--ignore` drops what matches. Both are Python regular expressions and are tested against the component and against the finding title, so `--ignore="^akismet$"` accepts the risk for exactly one component.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wordpress-security-scan> |
| Nagios/Icinga Check Name              | `check_wordpress_security_scan` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | No (`--url`, unless the installation below `--path` pins it) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `wpscan` (Ruby gem, needs Ruby 3.3 or newer and `libcurl`, see "Installing wpscan"); a WPScan API token for the vulnerability lookup |


## Help

```text
usage: wordpress-security-scan [-h] [-V] [--always-ok] [--api-token API_TOKEN]
                               [--api-token-file API_TOKEN_FILE]
                               [--critical-cvss CRITICAL_CVSS]
                               [--enterprise-db-token ENTERPRISE_DB_TOKEN]
                               [--enterprise-db-token-file ENTERPRISE_DB_TOKEN_FILE]
                               [--ignore IGNORE] [--insecure] [--lengthy]
                               [--match MATCH]
                               [--no-match-severity {ok,warn,crit,unknown}]
                               [--no-perfdata]
                               [--no-vuln-data-severity {ok,warn,crit,unknown}]
                               [--path PATH] [--total-timeout TOTAL_TIMEOUT]
                               [--unscored-severity {ok,warn,crit}] [-u URL]
                               [-v]
                               [--wpscan-detection-mode {aggressive,mixed,passive}]
                               [--wpscan-enumerate WPSCAN_ENUMERATE]
                               [--wpscan-follow-redirect]
                               [--wpscan-http-auth WPSCAN_HTTP_AUTH]
                               [--wpscan-http-auth-file WPSCAN_HTTP_AUTH_FILE]
                               [--wpscan-ignore-main-redirect]
                               [--wpscan-no-update]
                               [--wpscan-option WPSCAN_OPTION]
                               [--wpscan-proxy WPSCAN_PROXY]
                               [--wpscan-random-user-agent]
                               [--wpscan-throttle WPSCAN_THROTTLE]
                               [--wpscan-user-agent WPSCAN_USER_AGENT]

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
alerts WARNING. The vulnerability database is refreshed before every scan and
only queried with an API token; without one the check says so instead of
reporting a clean result it could not verify. Supports extended reporting via
--lengthy. Requires the command-line tool wpscan.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --api-token API_TOKEN
                        WPScan API token, used to look up known
                        vulnerabilities. Without a token the scan still runs,
                        but reports no vulnerability data at all; the check
                        then says so and --no-vuln-data-severity decides
                        whether it alerts. Passed here, the token is visible
                        to every user on this host for as long as the check
                        runs, because a command-line argument shows up in the
                        process list; prefer --api-token-file. It is handed on
                        to wpscan through the environment either way, so it
                        never reaches the scanner's own command line. Ignored
                        where --enterprise-db-token names a locally held copy
                        of the vulnerability database, because the scanner
                        refuses to run with both. Falls back to the
                        WPSCAN_API_TOKEN environment variable when neither
                        this nor --api-token-file is given.
  --api-token-file API_TOKEN_FILE
                        Path to a file holding the WPScan API token, read from
                        its first line. Keeps the token out of the process
                        list, where a command-line argument is visible to
                        every user on the host, and out of the monitoring
                        configuration. Takes precedence over `--api-token`.
                        Keep the file readable only by the monitoring user.
                        Example: `--api-token-
                        file=/etc/icinga2/secrets/wpscan`.
  --critical-cvss CRITICAL_CVSS
                        CVSS v3 base score at or above which a known
                        vulnerability is reported as CRITICAL instead of
                        WARNING. Vulnerabilities without a score are governed
                        by --unscored-severity. Default: 7.0
  --enterprise-db-token ENTERPRISE_DB_TOKEN
                        Token for a locally held copy of the vulnerability
                        database, used instead of the hosted one. The scanner
                        downloads the database dumps with it and then looks
                        vulnerabilities up locally, so the scan makes no
                        request per finding and no daily quota applies. Rules
                        --api-token out; where both are given, this one wins.
                        Passed here, the token is visible to every user on
                        this host for as long as the check runs, because a
                        command-line argument shows up in the process list;
                        prefer --enterprise-db-token-file. It is handed on to
                        wpscan through the environment either way, so it never
                        reaches the scanner's own command line. Falls back to
                        the WPSCAN_ENTERPRISE_DB_TOKEN environment variable
                        when neither this nor --enterprise-db-token-file is
                        given.
  --enterprise-db-token-file ENTERPRISE_DB_TOKEN_FILE
                        Path to a file holding the token for a locally held
                        copy of the vulnerability database, read from its
                        first line. Keeps the token out of the process list,
                        where a command-line argument is visible to every user
                        on the host, and out of the monitoring configuration.
                        Takes precedence over `--enterprise-db-token`. Keep
                        the file readable only by the monitoring user.
                        Example: `--enterprise-db-token-
                        file=/etc/icinga2/secrets/wpscan-enterprise`.
  --ignore IGNORE       Ignore findings whose component or title matches this
                        Python regular expression. Matched against the
                        component and against the finding title separately, so
                        an anchored expression still works on either of the
                        two. Case-sensitive by default; use `(?i)` for case-
                        insensitive matching. Can be specified multiple times.
                        Example: `--ignore="^akismet$"` to accept the risk of
                        one component. Example: `--ignore="(?i)readme"` to
                        accept a reachable readme.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Only check findings whose component or title matches
                        this Python regular expression. Matched against the
                        component and against the finding title separately, so
                        an anchored expression still works on either of the
                        two. Case-sensitive by default; use `(?i)` for case-
                        insensitive matching. Can be specified multiple times.
                        If both `--match` and `--ignore` are given, an item
                        must match `--match` AND not match `--ignore` to be
                        reported (include first, exclude second). Example:
                        `--match="^WordPress$"` to watch the core alone.
                        Example: `--match="(?i)backup"` to watch the exposed
                        backups alone.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-vuln-data-severity {ok,warn,crit,unknown}
                        State to report when the vulnerability database could
                        not be queried and no vulnerability data is available.
                        The check still reports everything it can determine
                        without that data, but a clean result then only means
                        nothing else was found, not that the target is free of
                        known vulnerabilities. Default: ok
  --path PATH           Local path to your WordPress installation, typically
                        within your Webserver's Document Root. Read to
                        determine the installed core version and the installed
                        plugins and themes, which the remote scan on its own
                        cannot see completely, and to determine the site URL
                        when --url is not given. A path that does not exist is
                        not an error: the check then reports what the remote
                        scan found and says so. Default:
                        /var/www/html/wordpress
  --total-timeout TOTAL_TIMEOUT
                        Seconds the run may spend scanning, across the refresh
                        of the vulnerability database, the version probe and
                        the scan itself. A full scan of a site with many
                        plugins takes minutes, so this is much higher than the
                        network timeout of other checks. The scanner is asked
                        to give up shortly before the budget is out, so it
                        still reports what it found rather than being killed
                        with nothing to show. Keep it below the timeout the
                        monitoring agent grants the check. Raise it on a large
                        site, or narrow the scan with --wpscan-enumerate.
                        Default: 1800 (seconds)
  --unscored-severity {ok,warn,crit}
                        State to report for a finding that carries no severity
                        score of its own. A source that scores its findings
                        rarely scores all of them, and the unrated ones need a
                        state of their own rather than the one a score would
                        have earned them. Applies to a known vulnerability
                        that carries no CVSS score. The vulnerability database
                        leaves a large share of its entries unrated, so
                        treating them all as critical would page for every one
                        of them. Default: warn
  -u, --url URL         URL of the WordPress site to scan. A URL without a
                        scheme is completed to `https://`. If not specified,
                        it is taken from the `WP_HOME` or `WP_SITEURL`
                        constant of the installation below --path, which only
                        works where the installation pins them and the
                        configuration file is readable. Example:
                        `--url=https://www.example.com`.
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood.
  --wpscan-detection-mode {aggressive,mixed,passive}
                        How hard the scan looks for components. `passive` only
                        reads what the site shows on its own, `aggressive`
                        requests known file locations directly and finds the
                        most, `mixed` does both. Aggressive detection produces
                        far more requests and takes correspondingly longer, so
                        raise --total-timeout with it. Default: mixed
  --wpscan-enumerate WPSCAN_ENUMERATE
                        What the scan looks for, comma-separated. Plugins:
                        `vp` only the ones with a known vulnerability, `p` the
                        popular ones, `ap` every one known. Themes: `vt`, `t`
                        and `at` in the same order. Further: `tt` timthumb
                        scripts, `cb` wp-config backups, `dbe` database
                        exports, `bf` backup folders, `u` user names, `m`
                        media files. Only one choice per group: `vp`, `p` and
                        `ap` rule each other out, as do `vt`, `t` and `at`.
                        The wider the choice, the longer the scan takes, since
                        each one probes for every location it knows: `ap` and
                        `at` walk tens of thousands of them. `vp` and `vt`
                        need vulnerability data and are downgraded to `p` and
                        `t` when none is available. `bf` needs wpscan 4.0.0 or
                        newer and is skipped on older releases. Example:
                        `--wpscan-enumerate=cb,dbe,bf,u` looks only for
                        exposed files and user names, which is the fastest
                        useful scan. Default: vp,vt,tt,cb,dbe,bf,u
  --wpscan-follow-redirect
                        Scan the target the site redirects to, instead of
                        reporting the redirection and stopping. A site that
                        answers on `www.example.com` but serves itself under
                        `example.com` needs this, as does a plain HTTP URL
                        redirecting to HTTPS. Only one redirect is followed.
                        Pointing --url at the final address is still
                        preferable, because the scan then spends no request on
                        the redirect at all.
  --wpscan-http-auth WPSCAN_HTTP_AUTH
                        Credentials for HTTP basic authentication in front of
                        the site, as `login:password`. Unlike the API token,
                        the scanner accepts these only on its command line,
                        where they are visible to every user on the scanning
                        host while the scan runs. Prefer --wpscan-http-auth-
                        file, which at least keeps them out of the monitoring
                        configuration.
  --wpscan-http-auth-file WPSCAN_HTTP_AUTH_FILE
                        Path to a file holding the HTTP basic authentication
                        credentials, as `login:password`, read from its first
                        line. Takes precedence over `--wpscan-http-auth`. Keep
                        the file readable only by the monitoring user.
                        Example: `--wpscan-http-auth-
                        file=/etc/icinga2/secrets/wordpress-http-auth`.
  --wpscan-ignore-main-redirect
                        Scan the address given in --url even though it
                        redirects elsewhere. Use it where the redirect is the
                        very thing to look behind, for example a compromised
                        site redirecting its visitors away. Mutually exclusive
                        with --wpscan-follow-redirect in effect, since the two
                        ask for opposite behaviour.
  --wpscan-no-update    Skip the refresh of the local vulnerability database
                        before scanning. The check refreshes it on every run
                        by default, so a site is graded against current data
                        rather than against whatever was last downloaded. Use
                        this where something else keeps the database current,
                        or to save the download on a host that is scanned
                        several times an hour. A refresh that fails is not an
                        error either way: the scan runs against the local
                        copy, and the check says so.
  --wpscan-option WPSCAN_OPTION
                        Additional raw option to pass to the wpscan call, for
                        options that have no dedicated parameter here. Use it
                        only for options this check does not set itself.
                        Passing one it does set, the target address or the
                        output format above all, leaves the check with nothing
                        it can read. Can be specified multiple times. Example:
                        `--wpscan-option=--plugins-detection=aggressive`.
  --wpscan-proxy WPSCAN_PROXY
                        Proxy the scan goes through, as
                        `protocol://host:port`. Example: `--wpscan-
                        proxy=http://192.0.2.1:3128`.
  --wpscan-random-user-agent
                        Use a random user agent for the scan instead of the
                        one --wpscan-user-agent sets. Only useful where a web
                        application firewall blocks the scan outright, which
                        the scanner reports as a 403. It makes the scan harder
                        to recognize in the target's access log and impossible
                        to allow-list, so the identifiable default is the
                        better choice on a site you run yourself.
  --wpscan-throttle WPSCAN_THROTTLE
                        Milliseconds to wait between requests, to keep the
                        scan from overwhelming the target or tripping a rate
                        limit. Has to be greater than zero. Setting it makes
                        the scanner use a single thread instead of five, so
                        the scan takes considerably longer; raise --total-
                        timeout with it. Not throttled when unset. Example:
                        `--wpscan-throttle=200`.
  --wpscan-user-agent WPSCAN_USER_AGENT
                        How the scan identifies itself to the target. The
                        default names the monitoring rather than the scanner,
                        so the daily scan is recognizable in the target's
                        access log and can be allow-listed in a web
                        application firewall or in fail2ban. Default:
                        Linuxfabrik Monitoring Plugins

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/wordpress-security-scan/
```


## Usage Examples

```bash
./wordpress-security-scan --url=https://www.example.com --path=/var/www/html/wordpress
```

Output on a healthy site:

```text
No vulnerabilities found. No exposures found. WordPress v6.8.2 on https://www.example.com.
Installed locally: 3 plugins, 3 themes. Detected by the scan: 2 plugins, 3 themes.
```

Output on a site with findings:

```text
0 vulnerabilities (0 critical), 3 exposures, 4 hardening findings on https://www.example.com.
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
1 vulnerability (1 critical), 0 exposures, 0 hardening findings on https://www.example.com.
Vulnerability database queried (free plan, 22 of the daily requests left).
Installed locally: 3 plugins, 3 themes. Detected by the scan: 2 plugins, 3 themes.

Component      ! Installed ! Type   ! CVSS ! Fixed in ! Finding                                           ! State
---------------+-----------+--------+------+----------+---------------------------------------------------+-----------
contact-form-7 ! 5.0       ! plugin ! 9.8  ! 5.3.2    ! Contact Form 7 < 5.3.2 - Unrestricted File Upload ! [CRITICAL]
```

Accepting the risk for one component:

```bash
./wordpress-security-scan --url=https://www.example.com --ignore="^akismet$"
```

```text
0 vulnerabilities (0 critical), 0 exposures, 1 hardening finding on https://www.example.com.
Installed locally: 3 plugins, 3 themes. Detected by the scan: 2 plugins, 3 themes.

Component ! Installed ! Finding                             ! State
----------+-----------+-------------------------------------+----------
site      ! -         ! 1 username enumerable (linuxfabrik) ! [WARNING]
```

Reading the API token from a file instead of the command line:

```bash
./wordpress-security-scan --url=https://www.example.com --api-token-file=/etc/icinga2/wpscan.token
```

```text
No vulnerabilities found. No exposures found. WordPress v6.8.2 on https://www.example.com.
Installed locally: 3 plugins, 3 themes. Detected by the scan: 2 plugins, 3 themes.
```

Without a token, the vulnerability class is never examined and the check says so:

```bash
./wordpress-security-scan --url=https://www.example.com
```

```text
No exposures found, vulnerabilities not checked. WordPress v6.8.2 on https://www.example.com.
No vulnerability data: no API token, the vulnerability database was not queried.
Installed locally: 3 plugins, 3 themes. Detected by the scan: 2 plugins, 3 themes.
```

Alerting while no token is configured, instead of accepting the gap:

```bash
./wordpress-security-scan --url=https://www.example.com --no-vuln-data-severity=warn
```

```text
No exposures found, vulnerabilities not checked. WordPress v6.8.2 on https://www.example.com.
No vulnerability data: no API token, the vulnerability database was not queried.
Installed locally: 3 plugins, 3 themes. Detected by the scan: 2 plugins, 3 themes.
```

Letting the check take the site URL from `wp-config.php` instead of passing it:

```bash
./wordpress-security-scan --path=/var/www/html/wordpress
```

```text
No vulnerabilities found. No exposures found. WordPress v6.8.2 on https://www.example.com.
Installed locally: 3 plugins, 3 themes. Detected by the scan: 2 plugins, 3 themes.
```


## States

Findings fall into three classes, and the worst of them determines the result:

| Class | What it is | State |
|----|----|----|
| Vulnerability | A known vulnerability from the WPScan vulnerability database, attached to the core, a plugin, a theme or a timthumb script. | CRIT if its CVSS v3 base score is >= `--critical-cvss` (default 7.0), otherwise WARN. An entry without a score follows `--unscored-severity` (default `warn`). |
| Exposure | Something reachable over HTTP that hands an attacker credentials, the database or an account outright: a readable `wp-config` backup, a database export, an SQL dump in the upload directory, a backup directory or a backup folder with a listing, a debug log, a `SearchReplaceDB2`, Duplicator or ThemeMakers migration file left behind, an emergency password reset script, or a site still sitting on its installer. | CRIT, except for a backup folder the scanner could not read any entry out of, which is WARN. |
| Hardening | Everything else the scan reports: outdated core, plugins or themes, a reachable readme, an enabled external WP-Cron, upload directory listing, full path disclosure, enumerable usernames, a reachable timthumb script, and any finding type the scanner reports that is not listed above. | WARN. |

`--critical-cvss` takes a plain score rather than a Nagios range, unlike the `--warning` and `--critical` thresholds of the other checks. CVSS is a published scale with fixed severity bands, so the only thing worth configuring is where CRITICAL starts.

In detail:

* OK if nothing in any of the three classes was found.
* OK for findings that only describe how the site is set up rather than a weakness, which are never reported: HTTP headers, a multisite install, must-use plugins, a disabled PHP, open user registration, `robots.txt` and an enabled XML-RPC endpoint. All seven are WordPress defaults or deliberate choices - open registration is what a shop or a membership site is for - so alerting on them would leave the check permanently non-OK on the installations that want them.
* OK with "Nothing checked." when `--match` or `--ignore` filtered every finding away. `--no-match-severity` changes that state. Such a run still emits every metric and still reports a scan that could not consult the vulnerability database, so `--no-vuln-data-severity` keeps working and a dashboard shows a zero rather than a gap.
* WARN if the core version the scan sees differs from the one installed below `--path`. That means the scan did not look at this installation: a wrong virtual host, a stale cache, or a CDN in between.
* WARN when the scan does not finish in time. The output then names how many requests it managed and how long they took, which distinguishes too small a budget from a target that answers slowly.
* WARN if `wpscan` is not installed, so the missing scanner shows up as something to fix instead of being routed to the UNKNOWN pile.
* WARN if the vulnerability database could not be refreshed and the scan ran against the local copy instead. The reason the scanner gave is named in the output.
* WARN if the local vulnerability database has not been refreshed in more than a week. It then grades the site against what was known back then.
* Per `--no-vuln-data-severity` (default `ok`) if the vulnerability database could not be queried at all: no API token, a token that was rejected or has been rotated, an unreachable database, or an exhausted daily quota. The scan itself still runs and reports everything it found. The summary then reads "vulnerabilities not checked" rather than "no vulnerabilities found", the reason is named in the output, and `vuln_data_available=0` marks the run in the perfdata. Everything the scan could determine without that data still counts towards the state.
* CRIT as described in the table above.
* UNKNOWN if the token file cannot be read, if `--url` is neither given nor derivable from `wp-config.php`, if the scan aborted (for example because the target does not run WordPress), or if the scan produced no parsable output. A scan that failed before writing its document reports in plain text; that text is carried into the message instead of being discarded.
* `--always-ok` suppresses all alerts and always returns OK.

A message beginning with `Output from wpscan:` is the scanner's own wording, passed through unchanged. The options such a message suggests are `wpscan` options: `--wpscan-follow-redirect` and `--wpscan-ignore-main-redirect` are parameters of this check as well, everything else reaches the scanner through `--wpscan-option`.

The coverage numbers ("Detected by the scan: 4 plugins") never influence the state. A component the scanner cannot fingerprint is a limit of black box scanning, not something the administrator can fix on the monitored site.

The table lists at most 50 findings and states how many were left out. That is a display limit only: the state is determined by every finding, and the performance data counts them all. A neglected site would otherwise produce hundreds of lines that Icinga stores and mails on with every notification.


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
| vuln_data_available | Number | 1 if the vulnerability database was queried, 0 if it was not. A `vulnerabilities` value of 0 only means "none found" while this is 1. |
| vulndb_age | Seconds | Age of the local vulnerability database. Only emitted once `wpscan` has updated it at least once. |
| vulnerabilities | Number | Number of known vulnerabilities found. |
| vulnerabilities_critical | Number | Number of those vulnerabilities at or above `--critical-cvss`. |


## Troubleshooting

### `The command-line tool "wpscan" was not found`

Check the `Searched in:` line of the message first. If `wpscan` runs fine by hand but the check does not find it, it is installed outside that list rather than missing, and there are two common reasons.

`gem install` without root installs into `~/.local/share/gem/` or `~/bin` of the account that ran it, and no other account sees it:

```bash
command -v wpscan
gem list --details wpscan | grep --ignore-case "installed at"
```

The other reason is `sudo`, which discards the inherited `PATH` and uses the `secure_path` from `/etc/sudoers`, a list that deliberately holds only system directories:

```bash
sudo grep secure_path /etc/sudoers
```

Either way the fix is the same: install the gem system-wide, so every account including `root` finds it in a directory the gem owner is `root`:

```bash
sudo gem install wpscan
sudo sh -c 'command -v wpscan'
```

Do not work around this by adding a home directory to `secure_path` or by symlinking the user's copy into `/usr/local/bin`. Where the check runs as `root`, that would have `root` execute a program an unprivileged account can rewrite.

If the gem is genuinely missing, follow "Installing wpscan" in the Overview above, which names the packages each distribution needs and which releases can run the current scanner at all.

### Installing the gem fails while building a native extension

```text
Building native extensions. This could take a while...
ERROR:  Error installing wpscan:
	ERROR: Failed to build gem native extension.

	current directory: ~/.local/share/gem/ruby/gems/yajl-ruby-1.4.3/ext/yajl
/usr/bin/ruby -I/usr/share/rubygems extconf.rb
mkmf.rb can't find header files for ruby at /usr/share/include/ruby.h
```

Ruby itself is installed, but its development headers are not. Four of the gem's dependencies compile a C extension, and those need `ruby.h`. The path in the message is where Ruby expects the headers, not a file to create by hand. Install the headers and the compiler as described under "Installing wpscan" in the Overview, then repeat the `gem install`. On SLES and openSUSE the packages are named as on RHEL and are installed with `zypper install ruby-devel gcc make`.

The half-built gem the failed run leaves behind does no harm; the next `gem install wpscan` replaces it. If the build still fails after installing the headers, the real compiler error is in the `gem_make.out` the message points to, not in the summary above.

A build that fails on `nokogiri` rather than on one of those four is a different problem: that gem normally arrives prebuilt and only falls back to compiling where the host is too old to use the prebuilt copy. Compiling it needs considerably more than the three packages above, so on such a host the better answer is a newer Ruby, or running the check from a newer host against the site.

### `No vulnerability data: no API token, the vulnerability database was not queried`

The vulnerability database needs an API token. Without one the check still finds exposures and outdated components, but the vulnerability class stays empty and `vulnerabilities=0` in the perfdata regardless of the actual state of the site. That is why the check says so rather than reporting a clean result, and why `vuln_data_available=0` marks the run in the perfdata.

Register for a free token at <https://wpscan.com/register> and supply it as described in the Important Notes above, preferably through `--api-token-file`. To have the check alert while no token is configured, set `--no-vuln-data-severity=warn`.

The same message with `the vulnerability database was unreachable` means the token is fine but wpscan.com could not be reached during the scan.

### The scan reports that the target redirects elsewhere

```text
Output from wpscan: The URL supplied redirects to https://example.com/. Use the
--wpscan-follow-redirect option to automatically scan the redirected URL, the
--wpscan-ignore-main-redirect option to ignore the redirection and scan the
target, or change the --url option value to the redirected URL.
```

`wpscan` names its own options in such messages. They are rewritten to the ones this check offers, so the advice can be followed as written.

The address in `--url` is not the one the site serves itself under. A redirect from `www.example.com` to `example.com`, or from HTTP to HTTPS, is the usual cause.

Pointing `--url` at the final address is the cleanest fix, because the scan then spends no requests on the redirect:

```bash
./wordpress-security-scan --url=https://example.com
```

Where the final address is not known in advance, both options named in the message are parameters of this check as well and can be copied straight from it:

```bash
./wordpress-security-scan --url=https://www.example.com --wpscan-follow-redirect
```

One redirect is followed, so a site redirecting in a circle is not scanned repeatedly.

`--url` without a scheme is completed to `https://` here rather than to the `http://` the scanner would use, which avoids the redirect a plain HTTP address answers with.

Use `--wpscan-ignore-main-redirect` where the redirect is the thing to look behind, for example a compromised site sending its visitors elsewhere. It scans the address given, redirect and all.

### `The remote website is up, but does not seem to be running WordPress.`

The scanner reached the target but could not confirm a WordPress installation behind it. In most cases `--url` points at a host name the site does not answer on under that name: the site's own `siteurl` is different, so all the links in the response point elsewhere and the fingerprint fails. Use the URL the site actually serves itself under. A reverse proxy or a redirect to a different host causes the same result; `--wpscan-follow-redirect` makes the scanner follow it.

If the target really is WordPress but hidden behind an unusual layout, `--wpscan-option=--force` skips the check.

### The scan does not finish in time

```text
Scan did not finish within 1770s, stopping at 214 requests in 29m 30s. Raise --total-timeout, or narrow the scan with --wpscan-enumerate. Scanned https://www.example.com.
```

The request count and the time they took are in the message, so it shows how far the scan got before the budget ran out.

Check first whether something between the monitoring host and the site is slowing the scan down. A burst of requests for files that do not exist is what fail2ban, CrowdSec, a WAF and provider-side rate limiting react to, and a target that answers the front page quickly can still answer the scan slowly.

Nearly every request a scan makes is a 404, so that is the one to measure. Compare the front page against a path that does not exist:

```bash
curl --silent --output /dev/null --write-out '%{time_total}s\n' https://www.example.com/
curl --silent --output /dev/null --write-out '%{time_total}s\n' https://www.example.com/wp-content/plugins/does-not-exist/readme.txt
```

```text
0.045s
2.713s
```

A front page in milliseconds and a 404 in seconds means WordPress renders the 404 through PHP instead of the web server answering it from a cache or a static file. The scan then runs at the speed of the second number, and a few hundred probes are enough to exhaust any budget. Serving 404s for `wp-content/` from the web server, or putting a cache in front of them, speeds up the scan by an order of magnitude and takes load off the site in normal operation too. Allow-list the monitoring host there, and keep the check interval at once per day.

Otherwise raise `--total-timeout` and the Director command timeout together, since the command timeout has to stay above the scan timeout or the monitoring agent kills the check first. Or narrow the scan; dropping the plugin and theme enumeration is the biggest single saving:

```bash
./wordpress-security-scan --url=https://www.example.com --wpscan-enumerate=cb,dbe,bf,u
```

`--wpscan-no-update` saves the vulnerability database update at the start of each run. Only use it if something else refreshes that database, otherwise the check silently scans against stale data.

### The vulnerability database could not be refreshed

```text
Could not refresh the vulnerability database. Output from wpscan: Unable to get https://data.wpscan.org/plugins.json (Could not resolve host: data.wpscan.org)
```

The check refreshes the database before every scan and could not reach the host it is served from. The scan ran against the local copy instead, so the result is complete apart from being graded against what that copy knows. How old it is appears in the output and in the `vulndb_age` metric.

On a host with no route to the internet this is the normal state. Refresh the database out of band, for instance from a host that does have a route, and keep the copy under `~/.cache/wpscan/db/` of the monitoring user current. `--wpscan-no-update` then skips the attempt and the warning with it.

A host that has never refreshed the database has no local copy either, and the scan cannot run at all:

```text
Output from wpscan: Update required, you can not run a scan if a database file is missing.
```

Run `wpscan --update` once as the user the monitoring agent runs as.

### `Your API limit has been reached`

The daily request quota of the token is used up. `wpscan` refuses to start at all in that state, so the exposures and hardening findings are still reported as usual and only the vulnerability lookup is missing, with `--no-vuln-data-severity` deciding whether that alerts. The same applies to a token that was rejected or an API that could not be reached, for example after the token has been rotated:

```text
No vulnerability data. Output from wpscan: The API token provided is invalid
```

A stale token therefore costs the vulnerability class, not the whole result. It must not be able to hide a critical exposure.

The free tier's allowance is shown as the "Daily API request limit" on the wpscan.com profile page, and one request is spent per plugin, per theme and per core version looked up. A site with two dozen plugins therefore exhausts it in a single scan. The allowance refills daily, so this passes on its own; it is a reason to wait rather than to buy a plan, unless it happens every day. Keep the check interval at once per day, use one token per site, or move to a paid plan. The remaining quota is visible in the output under `--lengthy`, which names it as the daily one.

`The API token provided is invalid` behaves the same way and means the token was rejected outright.

### `You cannot use both --api-token and --enterprise-db-token`

The scanner refuses to run with both credentials and gives up before it looks at the site, the download of the database dumps included. The check therefore drops the API token as soon as a locally held copy of the vulnerability database is configured, so the message only appears where the token reaches the scanner past the check, for example from a `WPSCAN_API_TOKEN` exported inside a wrapper script that runs it. Remove the token there; the local copy supplies the vulnerability data on its own.

### The backup folder enumeration is missing from the scan

Run with `--verbose` and look at the executed command. If it shows `--enumerate=vp,vt,tt,cb,dbe,u` without the `bf`, the installed `wpscan` predates that choice and would refuse to start with it, so the check drops it rather than failing the scan. `--help` names the release the choice needs. Updating the gem brings it back:

```bash
wpscan --version --no-update
gem update wpscan
```

If `gem update` leaves the version where it was, the host's Ruby is older than the current scanner requires and `gem` is holding it on the newest release that still runs there. See "Installing wpscan" in the Overview, which lists the releases this affects and what each of them needs.

### The scan aborts on an unknown `--wpscan-enumerate` choice

```text
Output from wpscan: Scan Aborted: --enumerate Unknown choice: <choice>
```

The value of `--wpscan-enumerate` contains a choice the installed `wpscan` does not know. The check only adjusts the choices it knows a minimum version for; everything else is passed through as given. Check the value against `wpscan --help`.

### Findings that are accepted risks keep alerting

Suppress them per component or per finding title with `--ignore`, which takes a Python regular expression and can be given multiple times:

```bash
./wordpress-security-scan --url=https://www.example.com \
  --ignore="^akismet$" --ignore="(?i)wp-cron"
```

Ignored findings are removed from the state, from the table and from the counters in the perfdata, so a suppressed finding cannot come back through a metric.

### The check alerts CRITICAL right after a migration

A migration typically leaves the artifacts this check treats as exposures: a `wp-config.php.bak` next to the real one, an SQL dump in the document root, a Duplicator installer log, a backup directory with directory listing enabled. These are exactly the files an attacker looks for first, so the CRITICAL is correct. Remove them from the document root rather than suppressing the finding, and keep backups outside the web root.

### The scan goes somewhere unexpected, or reports the target as down

`wpscan` honours `http_proxy`, `https_proxy` and `no_proxy` from the environment of the monitoring user on its own. A proxy exported there routes the whole scan through it silently, and a proxy that is no longer reachable makes every target look down:

```text
Output from wpscan: The url supplied 'https://www.example.com/' seems to be down (Could not connect to server)
```

Check the environment the check actually runs in, not your login shell. `--wpscan-proxy` sets a proxy but cannot unset one; to bypass an inherited proxy, add the target to `no_proxy` or clear the variables in the service definition.

### The scan is visible in the access log or triggers fail2ban

The scan probes for hundreds of known file locations, which produces a burst of 404s from the monitoring host. Allow-list the monitoring host in the WAF, in fail2ban and in CrowdSec, and keep the check interval at once per day. Throttling also shows up as a scan that does not finish in time. `--wpscan-throttle=200` slows the scan down to one request every 200 milliseconds if the target cannot take the load.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
