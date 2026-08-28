# Check icingaweb2-module-updates

## Overview

Checks the Icinga Web 2 modules installed on this host against their releases on GitHub, so a module installed from a tarball or a Git checkout does not quietly fall behind. Modules that belong to a distribution package are left to the package manager and reported as such, which is why the check stays silent on a host whose modules all come from packages. Optionally reports how many commits a module trails a development branch by. Alerts when a module is behind its latest release. Supports extended reporting via `--lengthy`.

Icinga Web 2 itself has no update display for modules, and the usual package checks cannot help where a module never came from a package. On the Red Hat family that is the normal case rather than the exception: the Icinga packages for RHEL 9 and newer sit behind a subscription, so administrators install their modules from a tarball or a Git checkout and have nothing telling them when a new release appears.


### Important Notes

* **No elevated rights are needed.** The check reads the module directory, which is world-readable. It deliberately does not read `/etc/icingaweb2`, which only the `icingaweb2` group may read. The price is that it cannot tell an enabled module from a disabled one: every installed module is reported.
* **A module that came from a package is not compared.** A distribution deliberately trails upstream, so comparing a packaged module against GitHub would report an update that the administrator is not supposed to install by hand. Those modules are listed with `package` and `rpm-updates` or `deb-updates` covers them. Use `--include-packaged` to compare them anyway.
* **The modules shipped with Icinga Web 2 are skipped.** `doc`, `migrate`, `monitoring`, `setup`, `test` and `translation` are versioned together with Icinga Web 2 and have no repository of their own.
* **A module has to be in the check's list to be compared.** Where a module is published cannot be derived from its name, so the check carries a list of the modules it knows. Anything else is reported as `no repository` until `--repo` says where to look.
* **The GitHub API is rate limited** to 60 requests per hour and IP address without a token, and a run spends one request per module that is actually compared, two with `--check-branch`. Answers are therefore cached for a day (`--cache-expire`), and `--token` or `--token-file` raises the limit to 5000.
* **The shipped Icinga Director template enables `--check-branch`**, so the commit distance to the development branch is reported out of the box. That doubles the requests a run makes. On the daily interval the template also sets, a host with a dozen source-installed modules stays well inside the anonymous limit; several Icinga Web 2 hosts behind one address, or a shorter interval, want a token.
* **A Git checkout has no version to compare.** Such an installation reports its branch name (`main`) instead of a version, and a module without a `module.info` reports nothing at all. Both are listed as `no version` rather than being reported as outdated forever. `--no-version-severity` grades them.


### Data Collection

Every subdirectory of the module directory is a module, named after the directory. Its version is read from the `module.info` the module ships, the same file and the same way Icinga Web 2 reads it. The module directory defaults to `/usr/share/icingaweb2/modules`; where `module_path` in `/etc/icingaweb2/config.ini` names another one, pass it with `--path`, which can be given more than once.

Whether a module belongs to a package is asked of `rpm` or `dpkg`, whichever the host has. The version to compare against comes from the GitHub releases API, falling back to the tag list for the repositories that tag their versions but never publish a release. With `--check-branch`, the commit distance between the installed version and the development branch is fetched as well.

`Installed` and `Latest` carry version numbers and nothing else, so the two can be read against each other at a glance. `Source` says where the comparison came from, or why there was none:

| Source | Meaning |
|----|----|
| `github` | Compared against the repository's latest release or tag. |
| `package` | Belongs to a distribution package and was left to the package manager. |
| `no repository` | The check does not know where this module is published. Supply it with `--repo`. |
| `no version` | The module declares no comparable version, for example a Git checkout reporting its branch name. |
| `no release` | The repository has published neither a release nor a tag. |
| `unreachable` | GitHub did not answer. The reason is printed below the table. |

`--lengthy` adds `Origin`, which names the package or the repository behind that verdict, and the directory the module was found in, abbreviated the way a shell prompt shortens a long path (`/u/s/i/m/director`).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/icingaweb2-module-updates> |
| Nagios/Icinga Check Name              | `check_icingaweb2_module_updates` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | Icinga Web 2; `rpm` or `dpkg` to recognise packaged modules; network access to `api.github.com` |
| 3rd Party Python modules              | `httpx` |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: icingaweb2-module-updates [-h] [-V] [--always-ok] [--branch BRANCH]
                                 [--cache-expire CACHE_EXPIRE]
                                 [--check-branch] [-c CRIT] [--ignore IGNORE]
                                 [--include-packaged] [--insecure] [--lengthy]
                                 [--match MATCH]
                                 [--no-match-severity {ok,warn,crit,unknown}]
                                 [--no-perfdata] [--no-proxy]
                                 [--no-version-severity {ok,warn,crit,unknown}]
                                 [--path PATH] [--proxy PROXY] [--repo REPO]
                                 [--timeout TIMEOUT] [--token TOKEN]
                                 [--token-file TOKEN_FILE]
                                 [--unknown-repo-severity {ok,warn,crit,unknown}]
                                 [--unreachable-severity {ok,warn,crit,unknown}]
                                 [-w WARN]

Checks the Icinga Web 2 modules installed on this host against their releases
on GitHub, so a module installed from a tarball or a Git checkout does not
quietly fall behind. Modules that belong to a distribution package are left to
the package manager and reported as such, which is why the check stays silent
on a host whose modules all come from packages. Optionally reports how many
commits a module trails a development branch by. Alerts when a module is
behind its latest release. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --branch BRANCH       Name of the development branch `--check-branch`
                        compares against. `main` and `master` stand in for
                        each other, so the default already covers repositories
                        that disagree on the name and this rarely has to be
                        set. Example: `--branch=develop` Default: main
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 1440
  --check-branch        Also report how far behind its development branch each
                        module is, as a number of commits. Costs one
                        additional API request per module. Name the branch
                        with `--branch`.
  -c, --critical CRIT   CRIT threshold for the number of commits a module is
                        behind its branch. Supports Nagios ranges. Only used
                        with `--check-branch`. Default: no critical threshold
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --include-packaged    Compare modules that came from an RPM or DEB package
                        against GitHub too. Without this they are listed but
                        not compared, because the distribution decides their
                        version and `rpm-updates` or `deb-updates` already
                        reports those updates.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead).
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --no-version-severity {ok,warn,crit,unknown}
                        State to report for a module whose version cannot be
                        compared, which is what a Git checkout reporting its
                        branch name instead of a version looks like, and a
                        module shipping no module.info at all. Default: ok
  --path PATH           Directory holding the Icinga Web 2 modules. Set this
                        where `module_path` in `/etc/icingaweb2/config.ini`
                        names another one. Can be specified multiple times.
                        Default: /usr/share/icingaweb2/modules
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
  --repo REPO           Where a module is published, as `module,
                        user/repository`. Adds a module the check does not
                        know, and overrides one it does. Can be specified
                        multiple times. Example: `--repo="mymodule,
                        ExampleOrg/icingaweb2-module-mymodule"`
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --token TOKEN         GitHub API token. Raises the API limit from 60
                        requests per hour and IP address to 5000. Passed here,
                        the token is visible to every user on this host for as
                        long as the check runs, because a command-line
                        argument shows up in the process list; prefer --token-
                        file.
  --token-file TOKEN_FILE
                        Path to a file holding the GitHub API token, read from
                        its first line. Keeps the token out of the process
                        list, where a command line argument is visible to
                        every user on this host. Takes precedence over
                        `--token`. Example: `--token-
                        file=/etc/icinga2/secrets/github`
  --unknown-repo-severity {ok,warn,crit,unknown}
                        State to report for a module the check has no
                        repository for. Supply one with `--repo` to have the
                        module compared. Default: ok
  --unreachable-severity {ok,warn,crit,unknown}
                        State to report when the online source is unreachable.
                        What is used instead - bundled offline data, a cached
                        copy, or nothing at all - is named in the output, and
                        a clean result then only covers what that fallback
                        could confirm. Default: ok
  -w, --warning WARN    WARN threshold for the number of commits a module is
                        behind its branch. Supports Nagios ranges. Only used
                        with `--check-branch`. Default: no warning threshold

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/icingaweb2-module-updates/
```


## Usage Examples

A host whose modules all come from packages. Nothing is asked of GitHub:

```bash
./icingaweb2-module-updates
```

```text
Everything is ok. 3 module(s) found, 3 managed by the package manager

Module    ! Installed ! Latest ! Source  ! Status
----------+-----------+--------+---------+-------
director  ! 1.11.9    ! -      ! package ! [OK]
incubator ! 0.23.0    ! -      ! package ! [OK]
x509      ! 1.4.0     ! -      ! package ! [OK]
```

A host mixing packages, tarballs and a Git checkout:

```bash
./icingaweb2-module-updates
```

```text
1 of 2 module(s) outdated, 4 managed by the package manager, 2 without a known repository, 1 without a comparable version [WARNING]

Module          ! Installed ! Latest ! Source        ! Status
----------------+-----------+--------+---------------+----------
businessprocess ! 2.6.0     ! -      ! package       ! [OK]
company         ! 1.0.0     ! v1.0.0 ! github        ! [OK]
director        ! 1.11.9    ! -      ! package       ! [OK]
incubator       ! 0.23.0    ! -      ! package       ! [OK]
nomoduleinfo    ! 0.0.0     ! -      ! no repository ! [OK]
ourthing        ! 3.2.1     ! -      ! no repository ! [OK]
reporting       ! 1.0.2     ! v1.1.0 ! github        ! [WARNING]
vspheredb       ! main      ! -      ! no version    ! [OK]
x509            ! 1.4.0     ! -      ! package       ! [OK]
```

With `--lengthy`, where each version came from and where the module sits on disk:

```bash
./icingaweb2-module-updates --lengthy
```

```text
1 of 1 module(s) outdated, 4 managed by the package manager, 1 without a known repository, 1 without a comparable version [WARNING]

Module          ! Installed ! Latest ! Source        ! Origin                                         ! Directory                ! Status
----------------+-----------+--------+---------------+------------------------------------------------+--------------------------+----------
businessprocess ! 2.6.0     ! -      ! package       ! icinga-businessprocess-web-2.6.0-1.fc43.noarch ! /u/s/i/m/businessprocess ! [OK]
director        ! 1.11.9    ! -      ! package       ! icinga-director-php-1.11.9-1.fc43.noarch       ! /u/s/i/m/director        ! [OK]
incubator       ! 0.23.0    ! -      ! package       ! icinga-php-incubator-0.23.0-1.fc43.noarch      ! /u/s/i/m/incubator       ! [OK]
ourthing        ! 3.2.1     ! -      ! no repository ! -                                              ! /u/s/i/m/ourthing        ! [OK]
reporting       ! 1.0.2     ! v1.1.0 ! github        ! Icinga/icingaweb2-module-reporting             ! /u/s/i/m/reporting       ! [WARNING]
vspheredb       ! main      ! -      ! no version    ! Icinga/icingaweb2-module-vspheredb             ! /u/s/i/m/vspheredb       ! [OK]
x509            ! 1.4.0     ! -      ! package       ! icinga-x509-php-1.4.0-1.fc43.noarch            ! /u/s/i/m/x509            ! [OK]
```

Also report how far each module trails the development branch, and alert once it trails by more than 30 commits:

```bash
./icingaweb2-module-updates --check-branch --warning=~:10 --critical=~:30
```

```text
1 of 2 module(s) outdated [CRITICAL]

Module   ! Installed          ! Latest             ! Source ! Branch           ! Status
---------+--------------------+--------------------+--------+------------------+-----------
director ! v1.11.8.2026040201 ! v1.11.9.2026070601 ! github ! 38 behind master ! [CRITICAL]
x509     ! 1.4.0              ! v1.4.0             ! github ! 0 behind main    ! [OK]
```

Teach the check about a module of your own, and raise the API limit with a token kept out of the process list:

```bash
./icingaweb2-module-updates --repo='mymodule, ExampleOrg/icingaweb2-module-mymodule' --token-file=/etc/icinga2/secrets/github
```


## States

* OK if every module that could be compared is at its latest release.
* WARN if a module is behind its latest release.
* WARN or CRIT if `--check-branch` is given and a module trails its development branch by more commits than `--warning` or `--critical` allow. Without those thresholds the commit distance is reported but does not change the state.
* The four cases in which a module cannot be compared each have their own parameter, all defaulting to OK, so an administrator decides which of them are worth an alert:
    * `--unknown-repo-severity` for a module the check has no repository for.
    * `--no-version-severity` for a module declaring no comparable version, and for a repository that published neither a release nor a tag.
    * `--unreachable-severity` for a GitHub that did not answer, for example because the rate limit is exhausted. The reason is printed below the table.
    * `--no-match-severity` where `--match` and `--ignore` leave nothing to check.
* UNKNOWN if the module directory does not exist, if the Python module `httpx` is missing while a module would have to be compared, or on a wrong parameter.
* `--always-ok` always returns OK.

A run in which nothing could be compared does not claim "Everything is ok." It states what it found and why it could not compare it.


## Perfdata / Metrics

| Name         | Type   | Description |
|--------------|--------|-------------|
| checked      | Number | Modules considered, after the bundled ones and the `--match` / `--ignore` filters are applied. |
| compared     | Number | Modules actually compared against a repository. |
| outdated     | Number | Modules behind their latest release. |
| packaged     | Number | Modules belonging to a distribution package, and therefore left to the package manager. |
| unknown_repo | Number | Modules the check has no repository for. |
| no_version   | Number | Modules declaring no comparable version, plus repositories without a release or tag. |
| unreachable  | Number | Modules whose repository GitHub did not answer for. |


## Troubleshooting

### `Python module "httpx" is not installed`

The check compares versions over the GitHub API and needs an HTTP client for it. Install it with `dnf install python3-httpx python3-h2` or `pip install 'httpx[http2]'`. A host whose modules all come from packages never reaches this point, because it makes no requests at all.

### `GitHub refused the request with HTTP 403`

The API allows 60 requests per hour and IP address without a token, and a run spends one request per compared module, two with `--check-branch`. Several Icinga Web 2 hosts behind the same address share that budget. Supply a token with `--token-file`, which raises the limit to 5000, or raise `--cache-expire` so the check asks less often. The default of one day is already chosen with the limit in mind.

### `Module directory "/usr/share/icingaweb2/modules" not found`

Either Icinga Web 2 is not installed on this host, or `module_path` in `/etc/icingaweb2/config.ini` names a different directory. Pass that directory with `--path`, once per path.

### A module is reported as `no repository`

Where a module is published cannot be derived from its name, so the check only compares the modules it carries in its list. Tell it where to look:

```bash
./icingaweb2-module-updates --repo='mymodule, ExampleOrg/icingaweb2-module-mymodule'
```

### A module is reported as `no version`

The module declares no version the check can compare. Two things look like this. A Git checkout reports its branch name, because `module.info` on a branch carries `Version: main` and only a release tag replaces it with a number. And a module without a `module.info` reports `0.0.0`, which Icinga Web 2 substitutes for "no version declared" rather than meaning version zero. Both are listed instead of being reported as outdated forever; `--no-version-severity=warn` makes them visible.

### A packaged module is reported as outdated

`--include-packaged` compares packaged modules against GitHub too, and a distribution deliberately trails upstream. Drop the parameter and let `rpm-updates` or `deb-updates` report the update instead.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
