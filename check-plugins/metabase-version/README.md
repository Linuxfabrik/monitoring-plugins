# Check metabase-version


## Overview

Checks the installed Metabase version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* The check must run locally on the Metabase server because it reads the version out of the jar.
* Metabase writes the version into the jar at build time, and the check reads it from there. It does not start a JVM: `java -jar metabase.jar version` prints the same version, but only after a full Metabase has come up, which takes around 30 seconds and is far beyond what a check may spend.
* Metabase prefixes every release with the digit of its license, `0` for the open-source edition and `1` for the Enterprise Edition, and both editions ship the same release behind it. The output names the version as the jar names it, so an Enterprise host reports `v1.58.24`. endoflife.date lists the open-source cycles only, so the check looks the release up without the license digit.
* Metabase's `58` in `v0.58.24` is its major release, not the `0` in front of it. endoflife.date lists cycles as `0.58`, so a new Metabase release arrives as a new minor version and `--check-minor` is the parameter that alerts on it. `--check-major` never fires for Metabase.
* The jar is around 500 MB and its index holds a quarter of a million entries, so reading it costs a moment on slow or network-backed storage. The shipped Icinga Director command allows 30 seconds for the check.

**Data Collection:**

* Reads the installed Metabase version from `version.properties` inside `/opt/metabase/metabase.jar` (configurable via `--path`)
* Compares against the [endoflife.date API](https://endoflife.date/api/metabase.json) to determine EOL status and available updates
* Caches endoflife.date responses locally for 24 hours to reduce external requests


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/metabase-version> |
| Nagios/Icinga Check Name              | `check_metabase_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: metabase-version [-h] [-V] [--always-ok] [--check-major]
                        [--check-minor] [--check-patch] [--insecure]
                        [--no-perfdata] [--no-proxy] [--offset-eol OFFSET_EOL]
                        [--path PATH] [--proxy PROXY] [--timeout TIMEOUT]
                        [--unreachable-severity {ok,warn,crit,unknown}]

Checks the installed Metabase version against the endoflife.date API and
alerts if the version is end-of-life or if newer major, minor, or patch
releases are available. By default, alerts 30 days before the official EOL
date. The offset is configurable.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --check-major         Alert when a new major release is available, even if
                        the current version is not yet EOL. Example: running
                        v26 (not yet EOL) and v27 is available.
  --check-minor         Alert when a new major.minor release is available,
                        even if the current version is not yet EOL. Example:
                        running v26.2 (not yet EOL) and v26.3 is available.
  --check-patch         Alert when a new major.minor.patch release is
                        available, even if the current version is not yet EOL.
                        Example: running v26.2.7 (not yet EOL) and v26.2.8 is
                        available.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --offset-eol OFFSET_EOL
                        Alert n days before ("-30") or after an EOL date ("30"
                        or "+30"). Default: -30 days
  --path PATH           Full path to Metabase's `metabase.jar`. Default:
                        /opt/metabase/metabase.jar
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
  --unreachable-severity {ok,warn,crit,unknown}
                        State to report when the online source is unreachable.
                        What is used instead - bundled offline data, a cached
                        copy, or nothing at all - is named in the output, and
                        a clean result then only covers what that fallback
                        could confirm. Default: ok

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/metabase-version/
```


## Usage Examples

```bash
./metabase-version
```

Output:

```text
Metabase v0.58.24 (EOL 2027-02-17 -30d, minor 0.63.16 available)
```

```bash
./metabase-version --path=/opt/metabase-enterprise/metabase.jar --check-minor
```

Output:

```text
Metabase v1.58.24 (EOL 2027-02-17 -30d, minor 0.63.16 available) [WARNING]
```


## States

* UNKNOWN if there is no jar at `--path`, if the monitoring user may not read it, if the file is not an archive, or if it is an archive that carries no `version.properties`.
* UNKNOWN if the jar names no release. A Metabase built straight from a source checkout looks like that; a released jar always carries its version.

The end-of-life verdict, the `--check-major` / `--check-minor` / `--check-patch` alerts, `--offset-eol`, `--always-ok` and what happens when endoflife.date cannot be reached work the same way in every endoflife.date-based version plugin. They are described in [Version Plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-version/). For Metabase, the release number sits behind the license digit, so a new release is a new *minor* version and `--check-minor` is the parameter that alerts on it.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| metabase-version | Number | Installed Metabase version as float. "0.58.24" becomes "0.5824". The license digit is part of it, so the same release reads as "1.5824" on an Enterprise Edition host. |


## Troubleshooting

### `Metabase not found at ...`

The jar is not where the check looked. The Linuxfabrik default is `/opt/metabase/metabase.jar`; point `--path` at the jar the systemd unit starts if the installation puts it elsewhere:

```bash
systemctl show --property=ExecStart metabase.service
```

### `No permission to read ...`

Metabase installations often keep the jar readable by its own service account only. Grant the monitoring user read access to the file, or point `--path` at a readable copy.

### `... names no release in its version.properties`

The jar was built from a source checkout rather than downloaded from Metabase, and carries no release number. Reporting one anyway would put a version on the dashboard that upstream never shipped. Point `--path` at a released jar, or leave the check off that host.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
