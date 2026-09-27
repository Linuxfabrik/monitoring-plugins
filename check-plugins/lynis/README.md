# Check lynis


## Overview

Runs a lynis security audit on the local host and reports its hardening index, its findings (the lynis warnings) and the hardening suggestions of lynis. Alerts when the hardening index is below the threshold or lynis reports a finding. Alternatively audits the hosts of a subnet or a host list from a single management host (`--host`, `--network`, `--interface`): it connects to each target over SSH, copies a self-contained copy of lynis over, runs the audit there via password-less sudo, retrieves the report and removes its temporary files. The worst per-host result then determines the overall state, and the check also alerts when the scan audited no host at all, naming why the targets did not answer. The network scan runs as an unprivileged user and refuses to run as root. Security posture is informational drift rather than a time-critical availability event, so by default only WARNING is raised. The check is meant to run at most once per day.

**Important Notes:**

* Without `--host`, `--network` or `--interface`, the check audits the host it runs on. That needs `lynis` on the host (the `lynis` package, from EPEL on the RHEL family, or the upstream tree in `/usr/local/lynis`) and root, so run it via `sudo` (see the sudoers files in `assets/sudoers`). The `Lynis Service Set` in the Icinga Director does exactly that on every host tagged `lynis`.
* A local audit takes about two minutes (measured on Rocky Linux 8 and Fedora). `--audit-timeout` (default 600 seconds) ends a run that takes longer and reports WARNING; keep it below the timeout of the check command, which the Director basket sets to 3600 seconds, or the monitoring system kills the check before it can report anything. A run cut off this way leaves the lynis PID file and a `/tmp/lynis.*` directory behind; the next run notices that the PID file belongs to no running audit and removes it.
* If another lynis audit is running (a lynis cron job, for example), the check does not start a second one and reports UNKNOWN; the next run tries again.
* The report stays at `/var/log/lynis-report.dat` and the log at `/var/log/lynis.log`, on the audited host, for the admin to inspect. `lynis show details <test>` prints the details of a finding or suggestion from that log.
* On the local host lynis runs as root, so nothing the caller passes may redirect it: `--lynis-profile` has to name a `.prf` file that only root can change, `--lynis-option` accepts only options that change the output or skip work, and lynis starts in `/` so that it does not pick up profiles from the caller's working directory.
* The network scan requires SSH access to every target host, with password-less public key authentication and password-less `sudo` on the targets by default. Host aliases from `~/.ssh/config` are honored. Run it as an unprivileged user: as root, its SSH parameters would hand root to whoever may run the check, so it refuses.
* The network scan requires `lynis` on the management host; a self-contained copy is assembled from it and pushed to the targets, so `lynis` does not need to be installed there. The management host's `lynis` must support the `--usecwd` option (lynis 2.7+).
* The network scan uses the first target partition that is writable and not mounted `noexec` (hardened hosts often mount `/var/tmp` and `/tmp` `noexec`), and pushes the copy with `rsync` when it is available on the management host, otherwise with `scp -r`.
* Auto-discovery hands over every address of the subnet, so a /24 means 254 probed addresses and only a handful of hosts. The summary reports both numbers, and a scan that audited nothing raises WARNING instead of reporting an empty success (`--no-match-severity`).
* The hardening index sums up a full audit. With `--lynis-test`, `--lynis-test-group` or `--lynis-test-category` only a part of the tests runs, and the index drops accordingly; set `--warning` to match or rely on the warnings alone.
* A security audit is posture drift, not a time-critical availability event, so by default only WARNING is raised. The default critical threshold is empty on purpose, to avoid paging someone at night for a hardening drop.

**Data Collection:**

* The state is the worst of: the hardening index against `--warning` / `--critical` (Nagios ranges, default warns below 65), and the presence of any lynis warning.
* Every lynis warning is listed under "Findings" with its test ID, its details where lynis gives any (the interface behind a `NETW-3015`, for example) and a `[WARNING]` marker, so nobody has to collect the reports by hand. A warning is a concrete finding, not noise; accept it on the host (see Troubleshooting), not in this plugin.
* lynis suggestions are hardening advice. They are listed under "Suggestions" and do not change the state.
* Both lists are sorted by test ID. In the network scan the same finding on several hosts therefore stands together.
* In the network scan every finding names its host, and addresses that do not answer on SSH are not listed one by one but counted by reason (`254 x Connection timed out`). This separates an address with no host behind it from a target the check cannot reach because of a configuration problem.
* Auto-discovery probes raw IP addresses, which do not match per-host `~/.ssh/config` aliases. For `--network` / `--interface` discovery, provide working credentials with `--username` and `--identity`.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/lynis> |
| Nagios/Icinga Check Name              | `check_lynis` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `lynis`; User with higher permissions (local audit); command-line tools `ssh`, `rsync` or `scp` (network scan) |


## Help

```text
usage: lynis [-h] [-V] [--always-ok] [--audit-timeout AUDIT_TIMEOUT]
             [--configfile CONFIGFILE] [--connect-timeout CONNECT_TIMEOUT]
             [-c CRIT] [--disable-pseudo-terminal] [-H HOST]
             [--identity IDENTITY] [--interface INTERFACE] [--ipv4] [--ipv6]
             [--lynis-auditor LYNIS_AUDITOR] [--lynis-option LYNIS_OPTION]
             [--lynis-profile LYNIS_PROFILE]
             [--lynis-skip-test LYNIS_SKIP_TEST] [--lynis-source LYNIS_SOURCE]
             [--lynis-test LYNIS_TEST]
             [--lynis-test-category LYNIS_TEST_CATEGORY]
             [--lynis-test-group LYNIS_TEST_GROUP] [--max-workers MAX_WORKERS]
             [--network NETWORK] [--no-match-severity {ok,warn,crit,unknown}]
             [--no-perfdata] [-p PASSWORD] [--port PORT] [--quiet]
             [--ssh-option SSH_OPTION] [-u USERNAME] [--verbose] [-w WARN]

Runs a lynis security audit on the local host and reports its hardening index,
its findings (the lynis warnings) and the hardening suggestions of lynis.
Alerts when the hardening index is below the threshold or lynis reports a
finding. Alternatively audits the hosts of a subnet or a host list from a
single management host (--host, --network, --interface): it connects to each
target over SSH, copies a self-contained copy of lynis over, runs the audit
there via password-less sudo, retrieves the report and removes its temporary
files. The worst per-host result then determines the overall state, and the
check also alerts when the scan audited no host at all, naming why the targets
did not answer. The network scan runs as an unprivileged user and refuses to
run as root. Security posture is informational drift rather than a
time-critical availability event, so by default only WARNING is raised. The
check is meant to run at most once per day. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --audit-timeout AUDIT_TIMEOUT
                        Seconds to wait for the audit of a single host to
                        finish. Default: 600 (seconds)
  --configfile CONFIGFILE
                        SSH: Alternative per-user configuration file. If a
                        configuration file is given on the command line, the
                        system-wide configuration file (`/etc/ssh/ssh_config`)
                        will be ignored. The default for the per-user
                        configuration file is `~/.ssh/config`. If set to
                        `none`, no configuration files will be read.
  --connect-timeout CONNECT_TIMEOUT
                        Seconds to wait for the SSH connection to a target
                        host before skipping it. Default: 3 (seconds)
  -c, --critical CRIT   CRIT threshold for the per-host hardening index
                        (0-100). Supports Nagios ranges. Empty by default,
                        because a daily hardening scan is posture drift, not a
                        time-critical event that should page someone at night.
                        Default: (no critical)
  --disable-pseudo-terminal
                        SSH: Disable pseudo-terminal allocation.
  -H, --host HOST       Target host to audit over SSH instead of the local
                        host. Can be specified multiple times. Takes
                        precedence over --network and --interface. If none of
                        the three is specified, the local host is audited.
  --identity IDENTITY   SSH: File from which the identity (private key) for
                        public key authentication is read. You can also
                        specify a public key file to use the corresponding
                        private key that is loaded in ssh-agent(1) when the
                        private key file is not present locally. The default
                        is `~/.ssh/id_dsa`, `~/.ssh/id_ecdsa`,
                        `~/.ssh/id_ecdsa_sk`, `~/.ssh/id_ed25519`,
                        `~/.ssh/id_ed25519_sk` and `~/.ssh/id_rsa`. Identity
                        files may also be specified on a per-host basis in the
                        configuration file. It is possible to have multiple
                        --identity options (and multiple identities specified
                        in configuration files). If no certificates have been
                        explicitly specified by the CertificateFile directive,
                        ssh will also try to load certificate information from
                        the filename obtained by appending `-cert.pub` to
                        identity filenames.
  --interface INTERFACE
                        Network interface whose subnet is scanned over SSH
                        instead of auditing the local host. Ignored when
                        --host or --network is given. Example:
                        `--interface=eth0`
  --ipv4                SSH: Forces ssh to use IPv4 addresses only.
  --ipv6                SSH: Forces ssh to use IPv6 addresses only.
  --lynis-auditor LYNIS_AUDITOR
                        Name of the auditor to record in the report (lynis
                        `--auditor`). If not specified, lynis uses its own
                        default.
  --lynis-option LYNIS_OPTION
                        Additional raw option to pass to `lynis audit system`,
                        for options that have no dedicated parameter here. On
                        the local host lynis runs as root, so only these
                        options are accepted there: `--debug`, `--developer`,
                        `--devops`, `--no-log`, `--no-plugins`, `--pentest`,
                        `--quiet`, `--verbose`, `--warnings-only`. Can be
                        specified multiple times. Example: `--lynis-
                        option=--no-plugins`
  --lynis-profile LYNIS_PROFILE
                        Additional profile file for the audit (lynis
                        `--profile`), read on top of lynis' own `default.prf`
                        and `custom.prf`. On the local host the file and every
                        directory above it must be writable by root only. In
                        the network scan the path is resolved on the target
                        host. If not specified, lynis uses only its own
                        profiles.
  --lynis-skip-test LYNIS_SKIP_TEST
                        Lynis test ID to skip (passed to lynis as `skip-
                        test`), for exceptions controlled from the monitoring
                        configuration. Can be specified multiple times. Host-
                        specific exceptions belong in the host's own
                        `/etc/lynis/custom.prf` instead. Example: `--lynis-
                        skip-test=MAIL-8818`
  --lynis-source LYNIS_SOURCE
                        Network scan only. Path to a self-contained lynis
                        directory (the directory that contains the `lynis`
                        executable next to its `include`, `db` and `plugins`
                        subdirectories). This is the copy that gets pushed to
                        and run on every target host. If not specified, a
                        self-contained copy is assembled from the local lynis
                        installation.
  --lynis-test LYNIS_TEST
                        Only run these lynis tests (lynis `--tests`). Can be
                        specified multiple times. If not specified, all tests
                        are run. Example: `--lynis-test=SSH-7408 --lynis-
                        test=KRNL-5820`
  --lynis-test-category LYNIS_TEST_CATEGORY
                        Only run lynis tests of this category (lynis `--tests-
                        from-category`). lynis runs one category at a time. If
                        not specified, all categories are run. Example:
                        `--lynis-test-category=security`
  --lynis-test-group LYNIS_TEST_GROUP
                        Only run lynis tests of these groups (lynis `--tests-
                        from-group`). Can be specified multiple times. If not
                        specified, all groups are run. Example: `--lynis-test-
                        group=ssh --lynis-test-group=kernel`
  --max-workers MAX_WORKERS
                        Maximum number of hosts to audit in parallel in the
                        network scan. Default: 10
  --network NETWORK     Network in CIDR notation whose hosts are audited over
                        SSH instead of the local host. Can be specified
                        multiple times. Takes precedence over --interface.
                        Example: `--network=192.0.2.0/24`
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: warn
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  -p, --password PASSWORD
                        SSH: Password authentication. NOT RECOMMENDED.
                        Requires `sshpass`. If you need to use password-based
                        SSH login, run this plugin only on trusted hosts. `ps`
                        will expose the SSH password.
  --port PORT           SSH: Port to connect to on the remote host. This can
                        be specified on a per-host basis in the configuration
                        file. Default: 22
  --quiet               SSH: Quiet mode. Causes most warning and diagnostic
                        messages to be suppressed.
  --ssh-option SSH_OPTION
                        SSH: Can be used to give options in the format used in
                        the configuration file. This is useful for specifying
                        options for which there is no separate command-line
                        flag. For full details of the options, and their
                        possible values, see ssh_config(5). Can be specified
                        multiple times.
  -u, --username USERNAME
                        SSH: Username. If not specified, ssh determines the
                        user from `~/.ssh/config` or falls back to the current
                        local user.
  --verbose             Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood.
  -w, --warning WARN    WARN threshold for the per-host hardening index
                        (0-100). Supports Nagios ranges. The default alerts
                        when the index drops below 65. Default: 65:

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/lynis/
```


## Usage Examples

Audit the local host:

```bash
sudo ./lynis
```

```text
Hardening index 61 [WARNING], 1 finding [WARNING], 29 suggestions

Findings:
* LOGG-2138: klogd is not running, which could lead to missing kernel messages in log files. [WARNING]

Suggestions:
* ACCT-9622: Enable process accounting.
* ACCT-9626: Enable sysstat to collect accounting (no results).
* ACCT-9628: Enable auditd to collect audit information.
...
* USB-1000: Disable drivers like USB storage when not used, to prevent unauthorized storage or data theft.

To look up an item, run `lynis show details LOGG-2138` on the host. To accept it, add `skip-test=LOGG-2138` to `/etc/lynis/custom.prf`.
```

Warn below a hardening index of 70, critical below 50:

```bash
sudo ./lynis --warning=70: --critical=50:
```

Accept a finding on every host, controlled from the monitoring configuration:

```bash
sudo ./lynis --lynis-skip-test=MAIL-8818
```

Audit every reachable host in a subnet from a management host, as an unprivileged user, logging in as `linuxfabrik` with an explicit key, 20 hosts at a time:

```bash
./lynis --network=192.0.2.0/24 --username=linuxfabrik --identity=~/.ssh/id_ed25519 --max-workers=20
```

```text
16/16 hosts audited (254 addresses probed)

Not reachable over SSH: 238 x Connection timed out
...
```

For each host, the table shows its IP address, the number of warnings and suggestions and the hardening index. The findings and suggestions follow, each with the host it was found on (here the output for a single host, `--host=myhost`):

```text
1/1 host audited (1 address probed)

Host:Report                      ! IP         ! Warn ! Sugg ! HIdx ! State
---------------------------------+------------+------+------+------+----------
myhost:/var/log/lynis-report.dat ! 192.0.2.27 ! 1    ! 3    ! 68   ! [WARNING]

Findings:
* myhost: MAIL-8818: Found some information disclosure in SMTP banner (OS or software name). [WARNING]

Suggestions:
* myhost: AUTH-9230: Configure password hashing rounds in /etc/login.defs.
* myhost: BOOT-5264: Consider hardening system services. Run '/usr/bin/systemd-analyze security SERVICE' for each service.
* myhost: KRNL-5820: If not required, consider explicit disabling of core dump.

To look up an item, run `lynis show details MAIL-8818` on the host. To accept it, add `skip-test=MAIL-8818` to `/etc/lynis/custom.prf`.
```

A full audit takes roughly one to two minutes per host. Because the network scan audits hosts in parallel (`--max-workers`, default 10), the scan above audited 16 reachable hosts out of a /24 in about 3 minutes.

Audit a single host over SSH (using a `~/.ssh/config` alias), and follow what the plugin is doing:

```bash
./lynis --host=myhost --verbose
```


## States

* OK if the hardening index is within the `--warning` / `--critical` range and lynis reports no warning.
* WARN if the hardening index drops below `--warning` (default: 65), or lynis reports at least one warning.
* WARN if `lynis` is not installed on a host that runs the local audit, because the host is then not being audited.
* WARN if the local audit does not finish within `--audit-timeout`.
* WARN if the network scan did not audit a single host, so that a scan which checked nothing is not reported as a clean result. The reasons the addresses gave are listed with the summary. Use `--no-match-severity` to report OK, CRITICAL or UNKNOWN instead.
* CRIT if the hardening index drops below `--critical` (empty by default, so CRIT is never raised unless a threshold is set).
* UNKNOWN if the local audit runs without root, another lynis audit is running, a parameter is refused, or lynis wrote no report.
* UNKNOWN for a reachable host in the network scan that could not be audited (SSH authentication failed, no executable work directory, audit produced no report, ...), and if the network scan is started as root.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| findings | Number | Number of findings (lynis warnings), across all audited hosts in the network scan. |
| hardening_index | Number | Hardening index of the local host (0-100). Local audit only. |
| hosts_audited | Number | Number of hosts that were successfully audited. Network scan only. |
| hosts_reachable | Number | Number of addresses that answered on SSH. Network scan only. |
| hosts_total | Number | Number of addresses probed. Network scan only. |
| suggestions | Number | Number of lynis suggestions, across all audited hosts in the network scan. |


## Lynis Profiles

Lynis reads its settings from profile files. `default.prf` is the default profile and ships with lynis; it defines which tests run, their thresholds, and which tests to skip. `custom.prf` is the place for site-specific overrides and survives package upgrades. Lynis discovers both automatically in `/etc/lynis` and merges them, so you do not need to edit `default.prf`. `--lynis-profile` adds one more profile on top of these two. On the local host it has to be a `.prf` file that only root can change, because a profile can tell lynis where to load its plugins from, and lynis runs them as root.


## Troubleshooting

### `The local lynis audit needs root.`

The check runs the audit on the host itself, which needs root. Call it via `sudo`, as the `Lynis Service Set` and the `tpl-service-lynis-sudo` template in the Icinga Director do, and deploy the sudoers file from `assets/sudoers`. To audit other hosts instead, pass `--host`, `--network` or `--interface`.

### `The command-line tool "lynis" was not found`

lynis is not installed, or not where the check looks for it: in the `PATH` and in `/usr/local/lynis`. Install the `lynis` package (from EPEL on the RHEL family, from the distribution on Debian and Ubuntu) or put the upstream tree into `/usr/local/lynis`. A lynis installed somewhere else is not found when the check runs via `sudo`, because `sudo` replaces the `PATH` with its own `secure_path`.

### `Another lynis audit is running`

A lynis audit started elsewhere, a lynis cron job for example, is still running. lynis refuses to run twice at the same time, so this run did not start; the next check run tries again. If this shows up every day, move the cron job or the check to another time of day.

### `lynis did not finish within`

The local audit took longer than `--audit-timeout` and was stopped. Raise `--audit-timeout`, and keep it below the timeout of the check command. The next run removes the PID file the stopped audit left behind.

### `The network scan does not run as root`

The network scan was started as root, most likely via `sudo` or with the `-sudo` Director template. Its SSH parameters (`--configfile`, `--identity`, `--ssh-option`) would hand root to whoever may run the check, so it refuses. Run it as the unprivileged account of the monitoring agent, with the plain `tpl-service-lynis` template.

### `--lynis-profile has to name an existing .prf file`

On the local host lynis runs as root, and a profile can tell it where to load plugins from. The profile, and every directory above it, therefore has to be changeable by root only, and it has to be a `.prf` file. Put it under `/etc/lynis` (owned by root, mode `0644`) or use the host's `/etc/lynis/custom.prf`, which lynis reads anyway.

### `--lynis-option ... is not accepted on the local host`

On the local host only options that change the output or skip work are passed to lynis. Options that make lynis load, run or write files elsewhere (`--plugin-dir`, `--bindirs`, `--logfile`, `--report-file`, `--rootdir`, `--usecwd`, `--upload`) are refused, and the ones with a dedicated parameter here (`--profile`, `--tests`, `--tests-from-group`, `--tests-from-category`, `--auditor`) are used through that parameter.

### The scan audited no host

```text
0/0 hosts audited (254 addresses probed)
```

Every address was probed and none of them answered on SSH, so nothing was audited and the check reports WARNING. The reasons the addresses gave are listed right below the summary, so read them first.

`Connection timed out` or `No route to host` on every address of a subnet usually means the scan is pointed at the wrong network, or that SSH is filtered between the management host and the targets. `Connection refused` means something answered at that address but nothing listens on the SSH port, so check `--port`. `Host key verification failed` means the target's host key is unknown or has changed for the account running the check; verify the key and update that account's `known_hosts`. `Could not resolve hostname` names a target that DNS does not know.

On a subnet scan, a large number of timeouts next to a handful of audited hosts is normal: a /24 has 254 addresses and rarely 254 hosts.

### `SSH authentication failed`

The host answered on SSH, but authentication failed. Auto-discovery connects to raw IP addresses, which do not match a `Host myhost` alias in `~/.ssh/config`. Pass working credentials with `--username` and `--identity`, or add a matching `Host` / `Match` block to the SSH config.

### `no executable (non-noexec) work directory found`

Every candidate partition on the target is mounted `noexec`, so the pushed `lynis` script cannot be executed. Mount one of `/var/tmp`, `/tmp` or the user's home without `noexec`, or provide another writable, executable partition.

### `audit produced no report`

The audit ran but lynis wrote no report. The plugin appends the underlying lynis error to this message, so read it first. Common causes are a target that asks for a password on `sudo` (the audit needs password-less `sudo`), or a tool that lynis depends on being absent from a stripped-down host (for example `awk`). Grant password-less `sudo` or install the missing tool, then re-run.

### Accepting a finding you do not want to fix

The plugin never silences individual lynis warnings; every warning raises at least WARNING. Acceptance belongs in lynis itself, where a test is skipped when its ID is listed with `skip-test=` in a profile.

For a single host, add the test ID to the host's `custom.prf`. For example, to accept this warning:

```text
* MAIL-8818: Found some information disclosure in SMTP banner (OS or software name). [WARNING]
```

Run on the affected host:

```bash
mkdir --parents /etc/lynis && echo 'skip-test=MAIL-8818' >> /etc/lynis/custom.prf
```

The next audit no longer reports `MAIL-8818`.

Fleet-wide, pass `--lynis-skip-test` in the monitoring configuration, for example on the service template. lynis reads it as one more profile, merged with each host's `custom.prf`:

```bash
sudo ./lynis --lynis-skip-test=MAIL-8818
```

As a best practice, silence recurring, host- or runtime-dependent noise centrally instead of changing host roles. Findings such as `ACCT-9622` / `ACCT-9626` (process accounting / `sysstat` not installed), `HRDN-7222` (a compiler is present), `FIRE-4513` (iptables has no rules), `LOGG-2190` (deleted files still in use), `BOOT-5264` and `AUTH-9282` / `AUTH-9284` (password aging) are often not worth a configuration change just to satisfy the audit. Rather than installing packages, rebuilding firewall rules or reworking roles only to lift the index, decide once which of these your organisation accepts and skip them fleet-wide with `--lynis-skip-test` (or a shared `custom.prf`). Keep `skip-test` for consciously accepted findings; fix the rest.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
