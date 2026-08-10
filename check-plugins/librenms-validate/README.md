# Check librenms-validate


## Overview

Runs the self-validation of a LibreNMS installation and reports every check it performs: database schema, dependencies, poller activity, disk space, file ownership and more. Alerts when a validation reports a warning or a failure, for example an outstanding schema update or a poller that stopped running, which LibreNMS itself keeps reporting as a healthy web interface. Runs the validation as the LibreNMS system user. Supports extended reporting via `--lengthy`. Requires root or sudo.

This is the same set of checks LibreNMS shows under "Validate Config" in its web interface. A LibreNMS whose schema update never finished, or whose poller stopped, keeps serving a green dashboard built from the data it collected before the problem started, which is what makes this worth alerting on separately.

**Important Notes:**

* **Requires a sudo rule.** LibreNMS refuses to validate itself as `root`, and it reports a failure when any user other than its own runs the validation. The check therefore runs the validation as the LibreNMS system user (`--user`, default `librenms`). Ship the `LF_LIBRENMS_VALIDATE` block from the [sudoers files](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers) for this to work. The check itself never runs as root.
* **The sudo rule lists its commands with their exact arguments.** That is deliberate: a wildcard would hand the LibreNMS account a PHP interpreter with free arguments. If the installation does not live in `/opt/librenms`, or PHP is not at `/usr/bin/php`, the paths in the sudoers file have to be adjusted to match. Without a matching rule `sudo` asks for a password and the check reports UNKNOWN.
* **`--group=mail` sends a real e-mail.** LibreNMS tests its mail transport by delivering a message to the configured alerting address. On a check that runs hourly that is an hourly e-mail. Only request this group deliberately.
* **`--group=rrdcheck` reads every RRD file.** On a grown installation that is a six-figure number of files and a runtime of minutes. Raise `--timeout` and the command timeout in the service definition before requesting it, and keep the check interval long.
* **Containerised LibreNMS installations are only partly covered.** The official image marks itself as such through an environment variable that `sudo` removes again, so the `dependencies` and `updates` groups report what a package installation would rather than what the container actually is.

**Data Collection:**

* Runs LibreNMS' own `validate.php` as the LibreNMS system user and reads its report
* Groups LibreNMS runs by default come out of a single run; the groups it leaves out (`distributedpoller`, `mail`, `rrdcheck`, `webserver`) each cost an additional run and are only started when `--group` asks for them. Asking only for optional groups skips the default run altogether
* Without `--group` everything the default run reports is checked, including a validation group a later LibreNMS release adds. `--group` restricts the report to the named groups
* The exit code of the validation is deliberately not used. It stays `0` when the script refuses to run, when no group matched, and when every finding is a warning, so only the report itself tells the check what happened
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
| Requirements                          | LibreNMS installed locally; `sudo` rule allowing the monitoring user to run the validation as the LibreNMS user |


## Help

```text
usage: librenms-validate [-h] [-V] [--always-ok] [--brief]
                         [--fail-severity {ok,warn,crit,unknown}]
                         [--group {configuration,database,dependencies,disk,distributedpoller,mail,php,poller,programs,python,rrd,rrdcheck,scheduler,system,updates,user,webserver}]
                         [--ignore-regex IGNORE_REGEX] [--lengthy]
                         [--no-match-severity {ok,warn,crit,unknown}]
                         [--no-perfdata] [--path PATH] [--timeout TIMEOUT]
                         [--user USER]

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
                        State to report for a validation LibreNMS marks as
                        failed. A failed validation means the installation is
                        broken in a way that stops it from working correctly,
                        which is worth acting on but rarely worth waking
                        somebody up for. Default: warn
  --group {configuration,database,dependencies,disk,distributedpoller,mail,php,poller,programs,python,rrd,rrdcheck,scheduler,system,updates,user,webserver}
                        Validation group to check. Can be specified multiple
                        times. The groups distributedpoller, mail, rrdcheck,
                        webserver are not part of a default run and each costs
                        an additional run of the validation. Two of them have
                        side effects: "mail" sends a real test message to the
                        configured alerting address on every check run, and
                        "rrdcheck" reads every RRD file, which takes minutes
                        on a grown installation. If not specified, everything
                        the default run reports is checked. Example:
                        `--group=database --group=poller`
  --ignore-regex IGNORE_REGEX
                        Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --lengthy             Extended reporting.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: unknown
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --path PATH           Local path to the installation. Default: /opt/librenms
  --timeout TIMEOUT     Seconds to wait for a single run of the validation to
                        finish. Default: 30 (seconds)
  --user USER           System user to run the validation as. LibreNMS refuses
                        to validate itself as root and reports a failure when
                        any other user runs it, so this has to name the user
                        that owns the installation. Default: librenms

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/librenms-validate/
```


## Usage Examples

A healthy installation with one real finding:

```bash
./librenms-validate
```

```text
1 failure found. Checked 17 validations in 13 groups.

Group        ! Message                                                                ! State
-------------+------------------------------------------------------------------------+----------
dependencies ! Composer Version: 2.10.2                                               ! [OK]
dependencies ! Dependencies up-to-date.                                               ! [OK]
database     ! Database Connected                                                     ! [OK]
database     ! Database Schema is current                                             ! [OK]
database     ! MySQL and PHP time match                                               ! [OK]
poller       ! Active pollers found                                                   ! [OK]
poller       ! Python poller wrapper is polling                                       ! [OK]
rrd          ! rrdtool version ok                                                     ! [OK]
rrd          ! /run/rrdcached.sock does not appe...rrdcached connectivity test failed ! [WARNING]
```

The same run reduced to what needs attention:

```bash
./librenms-validate --brief
```

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

```text
1 failure found. Checked 1 validation in 1 group.

Group             ! Message                                 ! Suggested Fix                           ! State
------------------+-----------------------------------------+-----------------------------------------+----------
distributedpoller ! You have not enabled distributed_poller ! lnms config:set distributed_poller true ! [WARNING]
```

An installation where nothing needs attention:

```bash
./librenms-validate
```

```text
No failures found. No warnings found. Checked 19 validations in 13 groups.
```

Accepting a known finding, so it stops driving the check state:

```bash
./librenms-validate --ignore-regex='rrdcached connectivity'
```


## States

* OK if every validation reports success or an informational result.
* WARN if a validation reports a warning, or reports a failure and `--fail-severity` is at its default.
* CRIT only if `--fail-severity=crit` is set and a validation reports a failure.
* UNKNOWN if LibreNMS refuses to run the validation as the configured `--user`, if its PHP dependencies are missing, or if `--path` does not hold a LibreNMS installation. In each of these cases the validation itself exits successfully, so the state comes from the report rather than from an exit code.
* UNKNOWN if none of the groups named with `--group` was run, which is a misconfigured check rather than a quiet installation. Other checks default `--no-match-severity` to `ok`; here it defaults to `unknown` so the gap stays visible. Set `--no-match-severity` to change it.
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

The rule lists each permitted command with its exact arguments, so the same message appears when the installation is somewhere other than `/opt/librenms`, when PHP is not at `/usr/bin/php`, when `--user` names a different account, or when `--group` asks for one of the optional groups the rule does not cover. The message quotes the command that was refused, so compare it line by line with what the rule allows.

### `LibreNMS refuses to validate itself as root.`

`--user` points at `root` and the sudo rule permits it, so the validation started and LibreNMS exited rather than run under that account. Set `--user` to the account that owns the installation, which `stat --format='%U' /opt/librenms` will name.

### `No LibreNMS installation found at "..."`

`--path` does not contain a `validate.php`. Point it at the directory that holds the LibreNMS installation, usually `/opt/librenms`. Note that changing it also means adjusting the sudo rule, which names the path literally.

### `You need to run this script as 'librenms' or root`

This one arrives as a normal finding rather than as an error, because LibreNMS reports it through its own `user` validation group. It means the validation ran under an account that is neither root nor the LibreNMS user, which makes the results of the `user` group meaningless. Correct `--user` and the finding disappears.

### `The LibreNMS installation is incomplete, its PHP dependencies are missing.`

LibreNMS cannot start because its PHP libraries were never installed or were removed. Run `./scripts/composer_wrapper.php install --no-dev` as the LibreNMS user in the installation directory.

### `Nothing checked. None of the requested validation groups was run.`

Every group named with `--group` was skipped. LibreNMS ignores a group it does not know, and it skips `distributedpoller` unless distributed polling is enabled. Check the spelling against the list in `--help`, and drop `--group` entirely to report everything the default run produces. Where a group is legitimately absent on a given host, `--no-match-severity=ok` silences the result instead.

### The check reports a finding that is known and accepted

Some findings are permanent facts of a given deployment, for example a poller running without Redis, or an installation deliberately kept off the update channel. Pass `--ignore-regex` with a pattern matching the message to drop it, for example `--ignore-regex='Redis is unavailable'`. Ignored findings no longer appear in the output and no longer affect the state, so keep the pattern narrow enough that a genuinely new problem is not swallowed with it.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/)
