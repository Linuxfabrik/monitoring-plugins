# Check librenms-validate


## Overview

Runs the self-validation of a LibreNMS installation and reports every check it performs: database schema, dependencies, poller activity, disk space, file ownership and more. Alerts when a validation reports a warning or a failure, for example an outstanding schema update or a poller that stopped running, which LibreNMS itself keeps reporting as a healthy web interface. Runs the validation as the LibreNMS system user. Supports extended reporting via `--lengthy`. Requires root or sudo.

This is the same set of checks LibreNMS shows under "Validate Config" in its web interface. A LibreNMS whose schema update never finished, or whose poller stopped, keeps serving a green dashboard built from the data it collected before the problem started, which is what makes this worth alerting on separately.

**Important Notes:**

* **Requires a sudo rule.** LibreNMS refuses to validate itself as `root`, and it reports a failure when any user other than its own runs the validation. The check therefore runs the validation as the LibreNMS system user (`--user`, default `librenms`). Ship the `LF_LIBRENMS_VALIDATE` block from the [sudoers files](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers) for this to work. The check itself never runs as root.
* **The sudo rule lists its commands with their exact arguments.** That is deliberate: a wildcard would hand the LibreNMS account a PHP interpreter with free arguments. An installation somewhere other than `/opt/librenms`, or a PHP binary somewhere other than `/usr/bin/php`, therefore has to be set on both sides: `--path` and `--php-path` on the check, and the same two paths in the sudoers file. Without a matching rule `sudo` asks for a password and the check reports UNKNOWN.
* **`--group=mail` sends a real e-mail.** LibreNMS tests its mail transport by delivering a message to the configured alerting address. On a check that runs hourly that is an hourly e-mail. Only request this group deliberately.
* **`--group=rrdcheck` reads every RRD file.** On a grown installation that is a six-figure number of files and a runtime of minutes. Raise `--timeout` and the command timeout in the service definition before requesting it, and keep the check interval long.
* **`--timeout` applies per validation run, not to the check as a whole.** The default run plus all three optional groups are four runs, so the worst case is four times `--timeout`, well past the 90 seconds the shipped service template allows the command. Raise both when requesting optional groups.
* **On a containerised LibreNMS the `dependencies` and `updates` groups report as if it were a package installation.** Their findings are not actionable there, because the container image is what decides both. Drop them with `--ignore-regex`, or restrict the check to the groups that do apply with `--group`.

**Data Collection:**

* Runs LibreNMS' own `validate.php` as the LibreNMS system user and reads its report
* Groups LibreNMS runs by default come out of a single run; the groups it leaves out (`distributedpoller`, `mail`, `rrdcheck`) each cost an additional run and are only started when `--group` asks for them. Asking only for those groups skips the default run altogether
* A requested group is always run, whether LibreNMS would have included it on its own or not. `distributedpoller` is worth knowing about here: on an installation with distributed polling enabled a default run already covers it, so asking for it explicitly buys nothing but a second run
* Without `--group` everything the default run reports is checked, including a validation group a later LibreNMS release adds. `--group` restricts the report to the named groups
* LibreNMS' `webserver` group is not offered. It validates the request that reached the web interface and reports nothing at all on the command line, so a check asking for it would stay green without validating anything
* The exit code of the validation is deliberately not used. It only separates "at least one failure" from everything else: it stays `0` when every finding is a warning and when no group matched, and it is `1` both for a run that found a problem and for one that never started, so only the report itself tells the check what happened
* Findings that are known and accepted can be filtered out with `--ignore-regex`; they then no longer influence the check state
* Validation messages are redacted before they are printed, so a connection error quoting a data source name does not carry a credential into the plugin output


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/librenms-validate> |
| Nagios/Icinga Check Name              | `check_librenms_validate` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | LibreNMS installed locally; the PHP command line interpreter (`/usr/bin/php`, `--php-path` to point elsewhere); `sudo` rule allowing the monitoring user to run the validation as the LibreNMS user |


## Help

```text
usage: librenms-validate [-h] [-V] [--always-ok] [--brief]
                         [--fail-severity {ok,warn,crit,unknown}]
                         [--group {configuration,database,dependencies,disk,distributedpoller,mail,php,poller,programs,python,rrd,rrdcheck,scheduler,system,updates,user}]
                         [--ignore-regex IGNORE_REGEX] [--lengthy]
                         [--no-match-severity {ok,warn,crit,unknown}]
                         [--no-perfdata] [--path PATH] [--php-path PHP_PATH]
                         [--timeout TIMEOUT] [--user USER]

Runs the self-validation of a LibreNMS installation and reports every check it
performs: database schema, dependencies, poller activity, disk space, file
ownership and more. Alerts when a validation reports a warning or a failure,
for example an outstanding schema update or a poller that stopped running,
which LibreNMS itself keeps reporting as a healthy web interface. Runs the
validation as the LibreNMS system user. Supports extended reporting via
--lengthy. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  --fail-severity {ok,warn,crit,unknown}
                        State to report for an item the monitored system
                        itself marks as failed. A failed item means the
                        installation is broken in a way that stops it from
                        working correctly, which is worth acting on but rarely
                        worth waking somebody up for. Default: warn
  --group {configuration,database,dependencies,disk,distributedpoller,mail,php,poller,programs,python,rrd,rrdcheck,scheduler,system,updates,user}
                        Validation group to check. Can be specified multiple
                        times. The groups distributedpoller, mail, rrdcheck
                        are left out of a default run and each costs an
                        additional run of the validation when it is asked for.
                        "distributedpoller" is the exception: where
                        distributed polling is enabled, a default run already
                        covers it. Two of them have side effects: "mail" sends
                        a real test message to the configured alerting address
                        on every check run, and "rrdcheck" reads every RRD
                        file, which takes minutes on a grown installation. If
                        not specified, everything the default run reports is
                        checked. Example: `--group=database --group=poller`
  --ignore-regex IGNORE_REGEX
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --lengthy             Extended reporting.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --path PATH           Local path to the installation. Default: /opt/librenms
  --php-path PHP_PATH   Local path to your PHP binary. Has to be the binary
                        the sudo rule names, because that rule lists the
                        permitted command with its exact arguments. Default:
                        /usr/bin/php
  --timeout TIMEOUT     Seconds to wait for a single run of the validation to
                        finish. Default: 30 (seconds)
  --user USER           System user to run the validation as. LibreNMS refuses
                        to validate itself as root and reports a failure when
                        any other user runs it, so this has to name the user
                        that owns the installation. Requires the right to
                        `sudo -u <user>` (root has this by default). Default:
                        librenms

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/librenms-validate/
```


## Usage Examples

A healthy installation with one real finding:

```bash
./librenms-validate
```

Output:

```text
1 failure found. Checked 17 validations in 13 groups.

Group        ! Message                                                                ! State
-------------+------------------------------------------------------------------------+----------
dependencies ! Composer Version: 2.10.2                                               ! [OK]
dependencies ! Dependencies up-to-date.                                               ! [OK]
database     ! Database Connected                                                     ! [OK]
database     ! Database Schema is current                                             ! [OK]
database     ! SQL Server meets minimum requirements                                  ! [OK]
database     ! lower_case_table_names is enabled                                      ! [OK]
database     ! MySQL engine is optimal                                                ! [OK]
database     ! Database and column collations are correct                             ! [OK]
database     ! Database schema correct                                                ! [OK]
database     ! MySQL and PHP time match                                               ! [OK]
poller       ! Active pollers found                                                   ! [OK]
poller       ! Dispatcher Service not detected                                        ! [OK]
poller       ! Locks are functional                                                   ! [OK]
poller       ! Python poller wrapper is polling                                       ! [OK]
poller       ! Redis is unavailable                                                   ! [OK]
rrd          ! rrdtool version ok                                                     ! [OK]
rrd          ! /run/rrdcached.sock does not appe...rrdcached connectivity test failed ! [WARNING]
```

The same run reduced to what needs attention:

```bash
./librenms-validate --brief
```

Output:

```text
1 failure found. Checked 17 validations in 13 groups.

Group ! Message                                                                ! State
------+------------------------------------------------------------------------+----------
rrd   ! /run/rrdcached.sock does not appe...rrdcached connectivity test failed ! [WARNING]
```

With the full message and the command LibreNMS suggests for the finding:

```bash
./librenms-validate --brief --lengthy --group=distributedpoller
```

Output:

```text
1 failure found. Checked 1 validation in 1 group.

Group             ! Message                                 ! Suggested Fix                           ! State
------------------+-----------------------------------------+-----------------------------------------+----------
distributedpoller ! You have not enabled distributed_poller ! lnms config:set distributed_poller true ! [WARNING]
```

Accepting a known finding, so it stops driving the check state:

```bash
./librenms-validate --ignore-regex='rrdcached connectivity'
```

Output:

```text
No failures found. No warnings found. Checked 16 validations in 13 groups.

Group        ! Message                                    ! State
-------------+--------------------------------------------+------
dependencies ! Composer Version: 2.10.2                   ! [OK]
dependencies ! Dependencies up-to-date.                   ! [OK]
database     ! Database Connected                         ! [OK]
database     ! Database Schema is current                 ! [OK]
database     ! SQL Server meets minimum requirements      ! [OK]
database     ! lower_case_table_names is enabled          ! [OK]
database     ! MySQL engine is optimal                    ! [OK]
database     ! Database and column collations are correct ! [OK]
database     ! Database schema correct                    ! [OK]
database     ! MySQL and PHP time match                   ! [OK]
poller       ! Active pollers found                       ! [OK]
poller       ! Dispatcher Service not detected            ! [OK]
poller       ! Locks are functional                       ! [OK]
poller       ! Python poller wrapper is polling           ! [OK]
poller       ! Redis is unavailable                       ! [OK]
rrd          ! rrdtool version ok                         ! [OK]
```

An installation where nothing needs attention, reduced to a single line:

```bash
./librenms-validate --brief --ignore-regex='rrdcached connectivity'
```

Output:

```text
No failures found. No warnings found. Checked 16 validations in 13 groups.
```


## States

* OK if every validation reports success or an informational result.
* WARN if a validation reports a warning, or reports a failure and `--fail-severity` is at its default.
* WARN if a validation run did not finish within `--timeout`. It is killed before it prints anything, so there is nothing to report but the timeout itself.
* CRIT only if `--fail-severity=crit` is set and a validation reports a failure.
* UNKNOWN if LibreNMS cannot validate the installation at all: it refuses to run as the configured `--user`, its PHP dependencies are missing, its configuration file is broken or does not name the installation directory, `--path` does not hold a LibreNMS installation, or the validation produced no report. The exit code of the validation cannot tell these apart from an ordinary finding, so the state comes from the report rather than from the exit code.
* UNKNOWN if a validation reports a status this check has no meaning for. The summary counts those results separately, so an UNKNOWN never appears next to a line claiming nothing was found. This is what a LibreNMS release that introduced a new status looks like; update the check.
* OK if none of the groups named with `--group` was run. A group that is legitimately absent on a given host looks exactly like a typo in `--group`, so this stays quiet by default. Set `--no-match-severity=warn` or `--no-match-severity=unknown` on hosts where a missing group means the check is misconfigured.
* Always OK if `--always-ok` is set.

`--brief` and `--lengthy` change what is printed, never the state: a finding that `--brief` hides still drives the result. `--ignore-regex` does change the state, since an ignored finding is dropped before it is evaluated.


## Perfdata / Metrics

| Name             | Type   | Description |
|------------------|--------|-------------|
| fail_count       | Number | Number of validations LibreNMS reported as failed. |
| info_count       | Number | Number of validations that returned an informational result. |
| ok_count         | Number | Number of validations that returned success. |
| validation_count | Number | Number of validations checked in total. |
| warn_count       | Number | Number of validations LibreNMS reported as a warning. |


## Troubleshooting

### Not allowed to run the validation

`Not allowed to run the validation as "librenms". Add a sudo rule for ...`

The monitoring user may not run that exact command as the LibreNMS user. Install the `LF_LIBRENMS_VALIDATE` block from the [sudoers files](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers) and check it with `visudo --check --file=/etc/sudoers.d/<file>`, then confirm the result with `sudo --list --other-user=icinga`.

The rule lists each permitted command with its exact arguments, so the same message appears when the installation is somewhere other than `/opt/librenms`, when PHP is not at `/usr/bin/php`, when `--user` names a different account, or when `--group` asks for one of the optional groups the rule does not cover. The message quotes the command that was refused, so compare it line by line with what the rule allows. A different installation directory or PHP binary needs `--path` and `--php-path` on the check and the same paths in the rule; the two have to agree.

### `LibreNMS refuses to validate itself as root.`

`--user` points at `root` and the sudo rule permits it, so the validation started and LibreNMS exited rather than run under that account. Set `--user` to the account that owns the installation, which `stat --format='%U' /opt/librenms` will name.

### `No LibreNMS installation found at "..."`

`--path` does not contain a `validate.php`. Point it at the directory that holds the LibreNMS installation, usually `/opt/librenms`. Note that changing it also means adjusting the sudo rule, which names the path literally.

### `You need to run this script as 'librenms' or root`

This one arrives as a normal finding rather than as an error, because LibreNMS reports it through its own `user` validation group. It means the validation ran under an account that is neither root nor the LibreNMS user, which makes the results of the `user` group meaningless. Correct `--user` and the finding disappears.

### `The LibreNMS installation is incomplete, its PHP dependencies are missing.`

LibreNMS cannot start because its PHP libraries were never installed or were removed. Run `./scripts/composer_wrapper.php install --no-dev` as the LibreNMS user in the installation directory.

### The configuration file does not parse

`The LibreNMS configuration file does not parse, which stops the installation from starting at all.`

Nothing works on this host, not the web interface and not the poller. Run `php -l config.php` in the installation directory to get the line number, and fix it there.

### The configuration file is missing its opening PHP tag

`The LibreNMS configuration file does not start with an opening PHP tag, so its contents are served as text instead of being executed.`

The first line of `config.php` has to be `<?php`. Anything before it, an empty line or a byte order mark included, ends up in the output of every page.

### The configuration file ends with a closing PHP tag

`The LibreNMS configuration file ends with a closing PHP tag, which lets stray whitespace behind it break every page and every poller run.`

Delete the trailing `?>` from `config.php`. A newline after it is sent to the client before anything else and breaks headers, redirects and JSON responses alike.

### The installation directory is not configured

`LibreNMS does not know where it is installed and cannot validate itself.`

The `install_dir` setting does not point at the directory the installation actually lives in, so LibreNMS cannot find its own files. Set it to the path that holds `.env`, usually `/opt/librenms`.

### `Timeout after 30s while validating "/opt/librenms".`

A single validation run did not finish in time and was killed. The `rrdcheck` group is the usual reason, it reads every RRD file. Raise `--timeout`, raise the command timeout in the service definition with it (the timeout applies per run, and every optional group costs a run of its own), or drop the group from `--group`. A default run that suddenly takes this long instead points at a database or a disk that has become slow.

### `Nothing checked. None of the requested validation groups was run.`

Every group named with `--group` was skipped, which is reported as OK by default because a group that is legitimately absent on a host produces the same result. A LibreNMS release that does not have the requested group ignores it silently, so this is what an older installation looks like when the check asks it for a group a newer release introduced. Drop `--group` entirely to report everything the default run produces. Where a missing group means the check is misconfigured rather than the host being older, `--no-match-severity=warn` or `--no-match-severity=unknown` makes the gap visible.

### The check reports a finding that is known and accepted

Some findings are permanent facts of a given deployment, for example a poller running without Redis, or an installation deliberately kept off the update channel. Pass `--ignore-regex` with a pattern matching the message to drop it, for example `--ignore-regex='Redis is unavailable'`. Ignored findings no longer appear in the output and no longer affect the state, so keep the pattern narrow enough that a genuinely new problem is not swallowed with it.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/)
