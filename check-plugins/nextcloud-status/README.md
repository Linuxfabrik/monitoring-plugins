# Check nextcloud-status


## Overview

Monitors the health of a Nextcloud instance via its status endpoint (`/status.php`), reporting whether the instance is installed, whether a pending database upgrade blocks it, and whether maintenance mode is active. Also reports the running version, the product name and the extended support flag. The status endpoint bypasses the router and the maintenance gate, so it answers with HTTP 200 even while the instance serves nobody. A plain HTTP check cannot see that. This check therefore reads the flags out of the response instead of trusting the status code. Alerts when the instance reports that it is not installed, when a database upgrade is pending, while maintenance mode is on, and when the endpoint does not answer with a status document at all. Every severity except the one for an uninstalled instance is configurable.

**Important Notes:**

* The status endpoint bypasses Nextcloud's router, middleware and maintenance gate. It answers with HTTP 200 even while the instance answers HTTP 503 to everybody else. A plain HTTP check cannot see that, which is why this check reads the flags out of the response instead of trusting the status code.
* A pending database upgrade means the code on disk was replaced but `occ upgrade` never ran. Until it does, Nextcloud answers every request with the upgrade page: no web UI, no WebDAV, no desktop and mobile sync. This is the condition the check exists for.
* `occ upgrade` turns maintenance mode on for its duration, so a running upgrade sets both flags. The check caps the upgrade alert at `--maintenance-severity` in that case, so planned work does not page anyone.
* The endpoint needs no credentials and imposes no rate limiting, so it is safe to poll frequently. This is the difference to `nextcloud-stats`, which needs an admin account for the serverinfo API and is not reachable while the instance is in maintenance mode.
* Probing the instance under a host name that is not listed in the `trusted_domains` array of the Nextcloud `config.php` returns HTTP 400 instead of the status document. The check reports that as such, and always as UNKNOWN: the URL is wrong, the instance is not.
* An instance that gives up before it gets as far as the status document answers with an error page naming the reason. The check quotes that reason instead of the bare status code, and alerts at `--unavailable-severity` (CRIT by default), because an instance in that state serves nobody either.
* The `edition` field is not evaluated. Nextcloud hardcodes it to an empty string since v11.

**Data Collection:**

* Fetches `/status.php` over HTTP or HTTPS without authentication.
* Alerts on `needsDbUpgrade`, `maintenance` and `installed`, and reports `version`, `versionstring`, `productname` and `extendedSupport` as facts.
* Treats an answer without the `installed` flag as no status document at all, rather than as an uninstalled instance.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-status> |
| Nagios/Icinga Check Name              | `check_nextcloud_status` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |


## Help

```text
usage: nextcloud-status [-h] [-V] [--always-ok] [--insecure]
                        [--maintenance-severity {ok,warn,crit,unknown}]
                        [--no-perfdata] [--no-proxy] [--proxy PROXY]
                        [--timeout TIMEOUT]
                        [--unavailable-severity {ok,warn,crit,unknown}]
                        [--upgrade-severity {ok,warn,crit,unknown}]
                        [--url URL]

Monitors the health of a Nextcloud instance via its status endpoint, reporting
whether the instance is installed, whether a pending database upgrade blocks
it, and whether maintenance mode is active. Also reports the running version,
the product name and the extended support flag. The status endpoint bypasses
the router and the maintenance gate, so it answers with HTTP 200 even while
the instance serves nobody. A plain HTTP check cannot see that. This check
therefore reads the flags out of the response instead of trusting the status
code. Alerts when the instance reports that it is not installed, when a
database upgrade is pending, while maintenance mode is on, and when the
endpoint does not answer with a status document at all. Every severity except
the one for an uninstalled instance is configurable.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --maintenance-severity {ok,warn,crit,unknown}
                        State to report while the instance is in maintenance
                        mode. Also caps the state of a pending database
                        upgrade, because a running `occ upgrade` turns
                        maintenance mode on for its duration. Default: warn
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --unavailable-severity {ok,warn,crit,unknown}
                        State to report when the instance does not answer with
                        a status document. A refused connection, a timeout, an
                        HTTP error or an unparsable body all mean that the
                        instance is serving nobody. A rejected host name is
                        reported as UNKNOWN regardless of this setting,
                        because that is a wrong `--url` rather than a broken
                        instance. Default: crit
  --upgrade-severity {ok,warn,crit,unknown}
                        State to report when the instance needs a database
                        upgrade while maintenance mode is off. The instance
                        answers every request with the upgrade page until `occ
                        upgrade` has run, so it serves nobody. Default: crit
  --url URL             Nextcloud status URL endpoint. Default:
                        http://localhost/nextcloud/status.php

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-status/
```


## Usage Examples

```bash
./nextcloud-status --url=https://cloud.example.com/status.php
```

Output:

```text
Nextcloud v31.0.14 is up and does not need an upgrade.

* Product: Nextcloud
* Version: 31.0.14 (31.0.14.1)
* Installed: yes
* Maintenance mode: off
* Database upgrade: not required
* Extended support: no
```

A pending database upgrade:

```bash
./nextcloud-status --url=https://cloud.example.com/status.php
```

Output:

```text
[CRITICAL] Database upgrade pending, run `occ upgrade`.

* Product: Nextcloud
* Version: 31.0.14 (31.0.14.1)
* Installed: yes
* Maintenance mode: off
* Database upgrade: pending
* Extended support: no
```

Do not alert while an administrator has put the instance into maintenance mode on purpose:

```bash
./nextcloud-status --url=https://cloud.example.com/status.php --maintenance-severity=ok
```

Output:

```text
Maintenance mode is on.

* Product: Nextcloud
* Version: 31.0.14 (31.0.14.1)
* Installed: yes
* Maintenance mode: on
* Database upgrade: not required
* Extended support: no
```

An instance that never gets as far as the status document:

```bash
./nextcloud-status --url=https://cloud.example.com/status.php
```

Output:

```text
Nextcloud answered HTTP 503 instead of a status document: Cannot write into "config" directory! This can usually be fixed by giving the web server write access to the config directory. But, if you prefer to keep config.php file read only, set the option "con...
```


## States

* OK if the instance is installed, is not in maintenance mode and does not need a database upgrade.
* CRIT (default) or the state given by `--upgrade-severity` if a database upgrade is pending while maintenance mode is off.
* WARN (default) or the state given by `--maintenance-severity` if maintenance mode is on. The same state applies to a pending database upgrade while maintenance mode is on, because a running `occ upgrade` sets both flags.
* CRIT if the instance reports that it is not installed.
* CRIT (default) or the state given by `--unavailable-severity` if the instance does not answer with a status document at all: a refused connection, a timeout, an HTTP error, or a body that is not one. The metric keeps being reported in this case, so the graph does not break off exactly while the instance is down.
* UNKNOWN if the instance rejects the host name used in `--url` as an untrusted domain. `--unavailable-severity` does not apply, because this is a wrong URL rather than a broken instance.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| nextcloud-status | Number | The current state (0 = OK, 1 = WARN, 2 = CRIT, 3 = UNKNOWN). |


## Troubleshooting

### HTTP 400 Trusted domain error

`HTTP 400 "Trusted domain error" from http://192.0.2.10/status.php.`

Nextcloud only answers under the host names listed in the `trusted_domains` array of its `config.php`. Probing by IP address is the usual cause. Either add the name used in `--url` to `trusted_domains`, or point `--url` at a name that is already listed.

### HTTP 500 while fetching the status endpoint

The instance failed to boot: an unreachable database, a broken `config.php`, or an attempted downgrade to an older code version. These abort so early that Nextcloud has nothing left to say, so the check reports the status code alone. Check the Nextcloud log and the web server error log. The one HTTP 500 that does carry a message is a PHP version outside the range the installed Nextcloud supports; the message names both the required and the running version.

### HTTP 503 while fetching the status endpoint

Nextcloud stopped itself during startup and says why on its error page, which the check quotes back. The usual reasons are a `config` directory the web server cannot write to, a sample configuration that was copied into place, and the startup checks failing over a missing PHP module or an unusable data directory. Fix what the message names; the hint that follows it is Nextcloud's own.

Do not confuse this with the HTTP 503 that maintenance mode produces for everybody else. The status endpoint is not behind that gate and keeps answering HTTP 200 with `maintenance` set, which is why the check reports maintenance mode as its own state.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
