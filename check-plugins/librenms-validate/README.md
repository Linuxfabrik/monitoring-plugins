# Check librenms-validate


## Overview

Runs the self-validation of a LibreNMS installation and reports every check it performs: database schema, dependencies, poller activity, disk space, file ownership and more. Alerts when a validation reports a warning or a failure, for example an outstanding schema update or a poller that stopped running, which LibreNMS itself keeps reporting as a healthy web interface. Runs the validation as the LibreNMS system user. Supports extended reporting via `--lengthy`. Requires root or sudo.

This is the same set of checks LibreNMS shows under "Validate Config" in its web interface. A LibreNMS whose schema update never finished, or whose poller stopped, keeps serving a green dashboard built from the data it collected before the problem started, which is what makes this worth alerting on separately.

**Important Notes:**

* **Requires a sudo rule.** LibreNMS refuses to validate itself as `root`, and it reports a failure when any user other than its own runs the validation. The check therefore runs the validation as the LibreNMS system user (`--user`, default `librenms`). Ship the `LF_LIBRENMS_VALIDATE` block from the [sudoers files](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers) for this to work. The check itself never runs as root.
* **The sudo rule lists its commands with their exact arguments.** That is deliberate: a wildcard would hand the LibreNMS account a PHP interpreter with free arguments. An installation somewhere other than `/opt/librenms`, or a PHP binary somewhere other than `/usr/bin/php`, therefore has to be set on both sides: `--path` and `--php-path` on the check, and the same two paths in the sudoers file. Without a matching rule `sudo` asks for a password and the check reports UNKNOWN.
* **`--group=mail` sends a real e-mail.** LibreNMS tests its mail transport by delivering a message to the configured alerting address. On a check that runs hourly that is an hourly e-mail. Only request this group deliberately. Where the mail transport is not enabled in LibreNMS at all, the group reports nothing whatsoever and the check stays green without having tested anything.
* **`--group=rrdcheck` reads every RRD file.** On a grown installation that is a six-figure number of files and a runtime of minutes. Raise `--timeout` and the command timeout in the service definition before requesting it, and keep the check interval long.
* **`--timeout` applies per validation run, not to the check as a whole.** The default run plus all three optional groups are four runs, so the worst case is four times `--timeout`, well past the 90 seconds the shipped service template allows the command. Raise both when requesting optional groups.
* **On a containerised LibreNMS the `dependencies` and `updates` groups report as if it were a package installation.** Their findings are not actionable there, because the container image is what decides both. Drop them with `--ignore`, or restrict the check to the groups that do apply with `--group`.

**Data Collection:**

* Runs LibreNMS' own `validate.php` as the LibreNMS system user and reads its report
* Groups LibreNMS runs by default come out of a single run; the groups it leaves out (`distributedpoller`, `mail`, `rrdcheck`) each cost an additional run and are only started when `--group` asks for them. Asking only for those groups skips the default run altogether
* A requested group is always run, whether LibreNMS would have included it on its own or not. `distributedpoller` is worth knowing about here: on an installation with distributed polling enabled a default run already covers it, so asking for it explicitly buys nothing but a second run
* Without `--group` everything the default run reports is checked, including a validation group a later LibreNMS release adds. `--group` restricts the report to the named groups
* LibreNMS' `webserver` group is not offered. It validates the request that reached the web interface and reports nothing at all on the command line, so a check asking for it would stay green without validating anything
* The exit code of the validation is deliberately not used. It only separates "at least one failure" from everything else: it stays `0` when every finding is a warning and when no group matched, and it is `1` both for a run that found a problem and for one that never started, so only the report itself tells the check what happened
* `--match` restricts the report to the validation messages it names, `--ignore` drops the ones it names, and `--ignore` wins where both hit the same message. Findings that are known and accepted are filtered out this way and then no longer influence the check state
* Validation messages are redacted before they are printed, so a connection error quoting a data source name does not carry a credential into the plugin output
* A finding may come with a list of what exactly is wrong - the tables of an outdated schema, the files an update modified, the packages a dependency check misses. That list is part of the message and is filtered on by `--match` and `--ignore` like the rest of it. The commands that repair the finding go into the separate `Suggested Fix` column that `--lengthy` adds


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
                         [--ignore IGNORE] [--lengthy] [--match MATCH]
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
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
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

Group        ! Status ! Message                                                                ! State
-------------+--------+------------------------------------------------------------------------+----------
dependencies ! OK     ! Composer Version: 2.10.2                                               ! [OK]
dependencies ! OK     ! Dependencies up-to-date.                                               ! [OK]
database     ! OK     ! Database Connected                                                     ! [OK]
database     ! OK     ! Database Schema is current                                             ! [OK]
database     ! OK     ! SQL Server meets minimum requirements                                  ! [OK]
database     ! OK     ! lower_case_table_names is enabled                                      ! [OK]
database     ! OK     ! MySQL engine is optimal                                                ! [OK]
database     ! OK     ! Database and column collations are correct                             ! [OK]
database     ! OK     ! Database schema correct                                                ! [OK]
database     ! OK     ! MySQL and PHP time match                                               ! [OK]
poller       ! OK     ! Active pollers found                                                   ! [OK]
poller       ! OK     ! Dispatcher Service not detected                                        ! [OK]
poller       ! OK     ! Locks are functional                                                   ! [OK]
poller       ! OK     ! Python poller wrapper is polling                                       ! [OK]
poller       ! OK     ! Redis is unavailable                                                   ! [OK]
rrd          ! OK     ! rrdtool version ok                                                     ! [OK]
rrd          ! FAIL   ! /run/rrdcached.sock does not appe...rrdcached connectivity test failed ! [WARNING]
```

The same run reduced to what needs attention:

```bash
./librenms-validate --brief
```

Output:

```text
1 failure found. Checked 17 validations in 13 groups.

Group ! Status ! Message                                                                ! State
------+--------+------------------------------------------------------------------------+----------
rrd   ! FAIL   ! /run/rrdcached.sock does not appe...rrdcached connectivity test failed ! [WARNING]
```

With the full message and the command LibreNMS suggests for the finding:

```bash
./librenms-validate --brief --lengthy --group=distributedpoller
```

Output:

```text
1 failure found. Checked 1 validation in 1 group.

Group             ! Status ! Message                                 ! Suggested Fix                           ! State
------------------+--------+-----------------------------------------+-----------------------------------------+----------
distributedpoller ! FAIL   ! You have not enabled distributed_poller ! lnms config:set distributed_poller true ! [WARNING]
```

Accepting a known finding, so it stops driving the check state:

```bash
./librenms-validate --ignore='rrdcached connectivity'
```

Output:

```text
No failures found. No warnings found. Checked 16 validations in 13 groups.

Group        ! Status ! Message                                    ! State
-------------+--------+--------------------------------------------+------
dependencies ! OK     ! Composer Version: 2.10.2                   ! [OK]
dependencies ! OK     ! Dependencies up-to-date.                   ! [OK]
database     ! OK     ! Database Connected                         ! [OK]
database     ! OK     ! Database Schema is current                 ! [OK]
database     ! OK     ! SQL Server meets minimum requirements      ! [OK]
database     ! OK     ! lower_case_table_names is enabled          ! [OK]
database     ! OK     ! MySQL engine is optimal                    ! [OK]
database     ! OK     ! Database and column collations are correct ! [OK]
database     ! OK     ! Database schema correct                    ! [OK]
database     ! OK     ! MySQL and PHP time match                   ! [OK]
poller       ! OK     ! Active pollers found                       ! [OK]
poller       ! OK     ! Dispatcher Service not detected            ! [OK]
poller       ! OK     ! Locks are functional                       ! [OK]
poller       ! OK     ! Python poller wrapper is polling           ! [OK]
poller       ! OK     ! Redis is unavailable                       ! [OK]
rrd          ! OK     ! rrdtool version ok                         ! [OK]
```

Watching one thing in particular, with a second service covering the rest. The group count still names every group LibreNMS ran, while the validation count is what survived the filter:

```bash
./librenms-validate --brief --match=rrdcached
```

Output:

```text
1 failure found. Checked 1 validation in 13 groups.

Group ! Status ! Message                                                                ! State
------+--------+------------------------------------------------------------------------+----------
rrd   ! FAIL   ! /run/rrdcached.sock does not appe...rrdcached connectivity test failed ! [WARNING]
```

An installation where nothing needs attention, reduced to a single line:

```bash
./librenms-validate --brief --ignore='rrdcached connectivity'
```

Output:

```text
No failures found. No warnings found. Checked 16 validations in 13 groups.
```


## States

* OK if every validation reports success or an informational result.
* WARN if a validation reports a warning, or reports a failure and `--fail-severity` is at its default.
* WARN if a validation run did not finish within `--timeout`. The runs that did finish keep their findings and the summary names the group that was left unchecked, so a slow group cannot hide a problem another group reported. A run that finds a failure still wins over the timeout.
* CRIT only if `--fail-severity=crit` is set and a validation reports a failure.
* WARN if the installation is too broken for LibreNMS to validate it: its PHP dependencies are missing, Composer is not installed at all, or its configuration file does not parse, does not start with an opening PHP tag, or ends with a closing one. Nothing was validated in that case, but the cause is something to repair on the installation, so it belongs on the list of things to fix. LibreNMS prints these aborts in the shape of an ordinary finding, so the state comes from the report rather than from the exit code, which cannot tell them apart. The two dependency findings are worth knowing about separately: LibreNMS runs that group ahead of everything else and gives up on the whole run when it fails, so what looks like a single failed validation means no other group was looked at.
* UNKNOWN if the check cannot reach a validation at all: LibreNMS refuses to run as the configured `--user`, it does not know its own installation directory, `--path` does not hold a LibreNMS installation, or the validation produced no report. These say nothing about the installation and are usually a matter of `--path`, `--php-path` or `--user`.
* UNKNOWN if a validation reports a status this check has no meaning for. The summary counts those results separately, so an UNKNOWN never appears next to a line claiming nothing was found. This is what a LibreNMS release that introduced a new status looks like; update the check.
* OK if none of the groups named with `--group` was run. A group that is legitimately absent on a given host looks exactly like a typo in `--group`, so this stays quiet by default. Set `--no-match-severity=warn` or `--no-match-severity=unknown` on hosts where a missing group means the check is misconfigured.
* OK if `--match` and `--ignore` dropped every validation result there was, for the same reason and controlled by the same `--no-match-severity`. A group that ran and found nothing is not this case and stays a clean result.
* Always OK if `--always-ok` is set. That covers the WARN and CRIT states above, including the aborted validation of a broken installation. It does not cover UNKNOWN, which is reported whatever else is set.

The `Status` column carries the status LibreNMS itself gave the result, which the `State` column cannot stand in for: at the default `--fail-severity=warn` a failure and a warning both end up as `[WARNING]`, while the summary counts the two apart.

`--brief` and `--lengthy` change what is printed, never the state: a finding that `--brief` hides still drives the result. `--brief` hides every row that ended up OK, which includes a failure that `--fail-severity=ok` took out of the alerting. `--match` and `--ignore` do change the state, since a filtered finding is dropped before it is evaluated.


## Perfdata / Metrics

| Name             | Type   | Description |
|------------------|--------|-------------|
| fail_count       | Number | Number of validations LibreNMS reported as failed. |
| info_count       | Number | Number of validations that returned an informational result. |
| ok_count         | Number | Number of validations that returned success. |
| unknown_count    | Number | Number of validations LibreNMS reported under a status this check has no meaning for. |
| validation_count | Number | Number of validations checked in total. |
| warn_count       | Number | Number of validations LibreNMS reported as a warning. |


## Troubleshooting

### Not allowed to run the validation

`Not allowed to run the validation as "librenms". Add a sudo rule for ...`

The monitoring user may not run that exact command as the LibreNMS user. Install the `LF_LIBRENMS_VALIDATE` block from the [sudoers files](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers) and check it with `visudo --check --file=/etc/sudoers.d/<file>`, then confirm the result with `sudo --list --other-user=icinga`.

The rule lists each permitted command with its exact arguments, so the same message appears when the installation is somewhere other than `/opt/librenms`, when PHP is not at `/usr/bin/php`, when `--user` names a different account, or when `--group` asks for one of the optional groups the rule does not cover. The message quotes the command that was refused, so compare it line by line with what the rule allows. A different installation directory or PHP binary needs `--path` and `--php-path` on the check and the same paths in the rule; the two have to agree.

### `LibreNMS refuses to validate itself as root.`

`--user` points at `root` and the sudo rule permits it, so the validation started and LibreNMS exited rather than run under that account. Set `--user` to the account that owns the installation, which `stat --format='%U' /opt/librenms` will name.

### No LibreNMS installation found at the given path

`No LibreNMS installation found at "/opt/librenms".`

`--path` does not contain a `validate.php`. Point it at the directory that holds the LibreNMS installation, usually `/opt/librenms`. Note that changing it also means adjusting the sudo rule, which names the path literally.

### `You need to run this script as 'librenms' or root`

This one arrives as a normal finding rather than as an error, because LibreNMS reports it through its own `user` validation group. It means the validation ran under an account that is neither root nor the LibreNMS user, which makes the results of the `user` group meaningless. Correct `--user` and the finding disappears.

### `The LibreNMS installation is incomplete, its PHP dependencies are missing.`

LibreNMS cannot start because its PHP libraries were never installed or were removed. Run `./scripts/composer_wrapper.php install --no-dev` as the LibreNMS user in the installation directory.

### The PHP dependencies are missing or Composer is not installed

`The LibreNMS installation is missing some of its PHP dependencies, so it stops before it validates anything else.`

`LibreNMS cannot check its PHP dependencies because Composer is missing, so it stops before it validates anything else.`

LibreNMS checks its own dependencies before it validates anything else and gives up on the whole run when that check fails, so nothing at all was looked at. The first message means a dependency update never completed; run `./scripts/composer_wrapper.php install --no-dev` as the LibreNMS user in the installation directory. The second means Composer itself is not on the host; install it from <https://getcomposer.org/> and run the same command afterwards. Both are normal after an upgrade that was interrupted.

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

### A validation run timed out

`Timed out after 30s and not checked: rrdcheck.`

A validation run did not finish in time and was killed. The `rrdcheck` group is the usual reason, it reads every RRD file. Raise `--timeout`, raise the command timeout in the service definition with it (the timeout applies per run, and every optional group costs a run of its own), or drop the group from `--group`. A default run that suddenly takes this long instead points at a database or a disk that has become slow.

Everything the other runs found is still reported and still drives the state, so the timeout does not hide a problem elsewhere. Where every run timed out there is nothing left to report and the message becomes `Timeout after 30s while validating "/opt/librenms".` instead.

### `Nothing checked. The filters dropped every validation result.`

`--match` and `--ignore` between them removed every result LibreNMS reported, so nothing was evaluated. A pattern kept deliberately wide looks the same as one that is wider than intended, which is why this is OK by default. Narrow the pattern, or set `--no-match-severity=warn` on hosts where an empty report means the check is misconfigured. A group that ran and simply found nothing does not produce this message.

### `Nothing checked. None of the requested validation groups was run.`

Every group named with `--group` was skipped, which is reported as OK by default because a group that is legitimately absent on a host produces the same result. A LibreNMS release that does not have the requested group ignores it silently, so this is what an older installation looks like when the check asks it for a group a newer release introduced. Drop `--group` entirely to report everything the default run produces. Where a missing group means the check is misconfigured rather than the host being older, `--no-match-severity=warn` or `--no-match-severity=unknown` makes the gap visible.

### The check reports a finding that is known and accepted

Some findings are permanent facts of a given deployment, for example a poller running without Redis, or an installation deliberately kept off the update channel. Pass `--ignore` with a pattern matching the message to drop it, for example `--ignore='Redis is unavailable'`. Ignored findings no longer appear in the output and no longer affect the state, so keep the pattern narrow enough that a genuinely new problem is not swallowed with it. `--match` works the other way round and keeps only what it names, which suits a check that is meant to watch one thing.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
