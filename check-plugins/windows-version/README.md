# Check windows-version


## Overview

Checks the installed Windows or Windows Server version against the endoflife.date API and alerts if the version is end-of-life. The lifecycle is chosen by the feature release and the edition, because Home and Pro, Enterprise and Education, and the Long-Term Servicing Channel go out of support on different dates. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* The check must run locally on the host because it reads the version from the local registry.
* Windows 11 still names itself "Windows 10" in the registry. The check tells the two apart by the build number and reports the right one.
* Editions follow the grouping of endoflife.date: Home, Pro, Pro Education and Pro for Workstations share one lifecycle, Enterprise, Education and IoT Enterprise share a longer one, and the Long-Term Servicing Channel (LTSC) editions have their own. An edition outside these groups, such as Windows Team on a Surface Hub, is judged by the shorter Home and Pro lifecycle, and the output says so.
* Windows releases before Windows 10 are all past their end of life and report WARN.
* Unlike the other version checks, there is no `--check-major`, `--check-minor` or `--check-patch`. endoflife.date names one build number per feature release for all editions, and a newer feature release is not necessarily an upgrade path for the installed edition.

**Data Collection:**

* Reads build, update revision, feature release, edition and installation type from the registry key `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion` via `reg query`
* Compares against the endoflife.date API, [windows](https://endoflife.date/api/windows.json) for clients and [windows-server](https://endoflife.date/api/windows-server.json) for servers (including Server Core), to determine the EOL status
* Caches endoflife.date responses locally for 24 hours to reduce external requests


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/windows-version> |
| Nagios/Icinga Check Name              | `check_windows_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Windows |
| Compiled for Windows                  | Yes |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: windows-version [-h] [-V] [--always-ok] [--extended-support]
                       [--insecure] [--no-perfdata] [--no-proxy]
                       [--offset-eol OFFSET_EOL] [--proxy PROXY]
                       [--timeout TIMEOUT]
                       [--unreachable-severity {ok,warn,crit,unknown}]

Checks the installed Windows or Windows Server version against the
endoflife.date API and alerts if the version is end-of-life. The lifecycle is
chosen by the feature release and the edition, because Home and Pro,
Enterprise and Education, and the Long-Term Servicing Channel go out of
support on different dates. By default, alerts 30 days before the official EOL
date. The offset is configurable.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --extended-support    Instead of the end of servicing (default), check for
                        the end of the paid Extended Security Updates (ESU).
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
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/windows-version/
```


## Usage Examples

```bash
./windows-version --offset-eol=-30
```

Output:

```text
Windows Server 2025 Standard Evaluation, build 26100.1742 (EOL 2034-11-14 -30d)
```

A Windows 10 host covered by Extended Security Updates:

```bash
./windows-version --extended-support
```

Output:

```text
Windows 10 Pro 22H2, build 19045.6128 (full support ended on 2025-10-14; EOL 2028-10-10 -30d)
```


## States

The end-of-life verdict, `--offset-eol`, `--always-ok` and what happens when endoflife.date cannot be reached work the same way in every endoflife.date-based version plugin. They are described in [Version Plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-version/). In addition:

* WARN on every Windows release before Windows 10.
* UNKNOWN if endoflife.date has no cycle for the installed feature release and edition, for example a feature release published only days ago.
* UNKNOWN if the build number cannot be read from the registry.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| windows-version | Number | Installed build number, for example 26100 for Windows 11 24H2 and Windows Server 2025. |


## Troubleshooting

### `version 26100.6700 unknown`

endoflife.date does not list the feature release and edition of this host (yet). This happens in the first days after Microsoft publishes a new feature release. The end-of-life dates come from endoflife.date, so a missing or wrong cycle is fixed in [their repository](https://github.com/endoflife-date/endoflife.date), and the check picks the correction up on its next run.

### `unknown edition <EditionID>, assuming the Home and Pro lifecycle`

The edition of this host belongs to none of the groups endoflife.date distinguishes. The check assumes the shorter lifecycle, so it warns early rather than late. If the edition in fact follows the Enterprise or LTSC lifecycle, please [open an issue](https://github.com/Linuxfabrik/monitoring-plugins/issues) with the output of `reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
