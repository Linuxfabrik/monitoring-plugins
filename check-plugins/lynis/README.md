# Check lynis


## Overview

Runs a lynis security audit across the hosts of a subnet or a host list from a single management host, and reports each host's hardening index, its findings (the lynis warnings) and the hardening suggestions of lynis. It discovers the targets (the subnet of the default interface, a chosen interface or network, or an explicit host list), connects to each one over SSH, copies a self-contained copy of lynis over, runs the audit there via password-less sudo, retrieves the report and removes its temporary files. Alerts when a host is below the hardening index threshold or reports a finding, and when the scan audited no host at all, naming why the targets did not answer. The worst per-host result determines the overall state. The scan runs as an unprivileged user and refuses to run as root. Security posture is informational drift rather than a time-critical availability event, so by default only WARNING is raised. The check is meant to run at most once per day. To evaluate the audit a host runs on its own, use [lynis-logfile](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/lynis-logfile) on that host.

**Important Notes:**

* Without `--host`, `--network` or `--interface`, the check scans the subnet of the default interface, the one carrying the default route.
* The scan requires SSH access to every target host, with password-less public key authentication and password-less `sudo` on the targets by default. Host aliases from `~/.ssh/config` are honored. Run it as an unprivileged user: as root, its SSH parameters would hand root to whoever may run the check, so it refuses.
* The scan requires `lynis` on the management host; a self-contained copy is assembled from it and pushed to the targets, so `lynis` does not need to be installed there. The management host's `lynis` must support the `--usecwd` option (lynis 2.7+).
* The scan uses the first target partition that is writable and not mounted `noexec` (hardened hosts often mount `/var/tmp` and `/tmp` `noexec`), and pushes the copy with `rsync` when it is available on the management host, otherwise with `scp -r`.
* The report stays at `/var/log/lynis-report.dat` and the log at `/var/log/lynis.log` on every audited host, for the admin to inspect. `lynis show details <test>` prints the details of a finding or suggestion from that log.
* Auto-discovery hands over every address of the subnet, so a /24 means 254 probed addresses and only a handful of hosts. The summary reports both numbers, and a scan that audited nothing raises WARNING instead of reporting an empty success (`--no-match-severity`).
* The hardening index sums up a full audit. With `--lynis-test`, `--lynis-test-group` or `--lynis-test-category` only a part of the tests runs, and the index drops accordingly; set `--warning` to match or rely on the warnings alone.
* A security audit is posture drift, not a time-critical availability event, so by default only WARNING is raised. The default critical threshold is empty on purpose, to avoid paging someone at night for a hardening drop.

**Data Collection:**

* The state of a host is the worst of: its hardening index against `--warning` / `--critical` (Nagios ranges, default warns below 65), and the presence of any lynis warning. The worst host determines the overall state.
* Every lynis warning is listed under "Findings" with its host, its test ID, its details where lynis gives any (the interface behind a `NETW-3015`, for example) and a `[WARNING]` marker, so nobody has to collect the reports by hand. A warning is a concrete finding, not noise; accept it on the host (see Troubleshooting), not in this plugin.
* lynis suggestions are hardening advice. They are listed under "Suggestions" and do not change the state.
* Both lists are sorted by test ID, so the same finding on several hosts stands together.
* Addresses that do not answer on SSH are not listed one by one but counted by reason (`254 x Connection timed out`). This separates an address with no host behind it from a target the check cannot reach because of a configuration problem.
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
| Requirements                          | command-line tools `lynis`, `ssh`, and `rsync` or `scp` |


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

Runs a lynis security audit across the hosts of a subnet or a host list from a
single management host, and reports each host's hardening index, its findings
(the lynis warnings) and the hardening suggestions of lynis. It discovers the
targets (the subnet of the default interface, a chosen interface or network,
or an explicit host list), connects to each one over SSH, copies a
self-contained copy of lynis over, runs the audit there via password-less
sudo, retrieves the report and removes its temporary files. Alerts when a host
is below the hardening index threshold or reports a finding, and when the scan
audited no host at all, naming why the targets did not answer. The worst
per-host result determines the overall state. The scan runs as an unprivileged
user and refuses to run as root. Security posture is informational drift
rather than a time-critical availability event, so by default only WARNING is
raised. The check is meant to run at most once per day. To evaluate the audit
a host runs on its own, use lynis-logfile on that host.

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
  -H, --host HOST       Target host to audit. Can be specified multiple times.
                        Takes precedence over --network and --interface. If
                        none of the three is specified, the subnet of the
                        default interface is scanned.
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
                        Network interface whose subnet is scanned. Ignored
                        when --host or --network is given. If not specified,
                        the default interface (the one carrying the default
                        route) is used. Example: `--interface=eth0`
  --ipv4                SSH: Forces ssh to use IPv4 addresses only.
  --ipv6                SSH: Forces ssh to use IPv6 addresses only.
  --lynis-auditor LYNIS_AUDITOR
                        Name of the auditor to record in the report (lynis
                        `--auditor`). If not specified, lynis uses its own
                        default.
  --lynis-option LYNIS_OPTION
                        Additional raw option to pass to the remote `lynis
                        audit system` call, for options that have no dedicated
                        parameter here. Can be specified multiple times.
                        Example: `--lynis-option=--no-plugins`
  --lynis-profile LYNIS_PROFILE
                        Additional profile file for the audit (lynis
                        `--profile`), read on top of lynis' own `default.prf`
                        and `custom.prf`. The path is resolved on the target
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
                        Path to a self-contained lynis directory (the
                        directory that contains the `lynis` executable next to
                        its `include`, `db` and `plugins` subdirectories).
                        This is the copy that gets pushed to and run on every
                        target host. If not specified, a self-contained copy
                        is assembled from the local lynis installation.
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
  --network NETWORK     Network in CIDR notation whose hosts are audited. Can
                        be specified multiple times. Takes precedence over
                        --interface. Example: `--network=192.0.2.0/24`
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

Audit every reachable host in a subnet, as an unprivileged user, logging in as `linuxfabrik` with an explicit key, 20 hosts at a time:

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

An audit takes between 20 seconds and a minute per host (measured on Debian 12/13, Rocky 8/9/10 and Ubuntu 22.04/24.04/26.04). Because the scan audits hosts in parallel (`--max-workers`, default 10), a /24 with a few dozen hosts is done within minutes.

Warn below a hardening index of 70, critical below 50, and accept a finding on every host, controlled from the monitoring configuration:

```bash
./lynis --host=myhost --warning=70: --critical=50: --lynis-skip-test=MAIL-8818
```

Audit a single host over SSH (using a `~/.ssh/config` alias), and follow what the plugin is doing:

```bash
./lynis --host=myhost --verbose
```


## States

* OK if the hardening index of every audited host is within the `--warning` / `--critical` range and lynis reports no warning.
* WARN if the hardening index of a host drops below `--warning` (default: 65), or lynis reports at least one warning on a host.
* WARN if the scan did not audit a single host, so that a scan which checked nothing is not reported as a clean result. The reasons the addresses gave are listed with the summary. Use `--no-match-severity` to report OK, CRITICAL or UNKNOWN instead.
* CRIT if the hardening index of a host drops below `--critical` (empty by default, so CRIT is never raised unless a threshold is set).
* UNKNOWN for a reachable host that could not be audited (SSH authentication failed, no executable work directory, audit produced no report, ...), if a parameter is refused, and if the scan is started as root.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| findings | Number | Number of findings (lynis warnings), across all audited hosts. |
| hosts_audited | Number | Number of hosts that were successfully audited. |
| hosts_reachable | Number | Number of addresses that answered on SSH. |
| hosts_total | Number | Number of addresses probed. |
| suggestions | Number | Number of lynis suggestions, across all audited hosts. |


## Lynis Profiles

Lynis reads its settings from profile files. `default.prf` is the default profile and ships with lynis; it defines which tests run, their thresholds, and which tests to skip. `custom.prf` is the place for site-specific overrides and survives package upgrades. Lynis discovers both automatically in `/etc/lynis` and merges them, so you do not need to edit `default.prf`. The scan copies each target's own `/etc/lynis/custom.prf` next to the pushed lynis, so the exceptions of a host apply to the scan as well. `--lynis-profile` adds one more profile on top, resolved on the target host.


## Troubleshooting

### `The network scan does not run as root`

The scan was started as root, most likely via `sudo`. Its SSH parameters (`--configfile`, `--identity`, `--ssh-option`) would hand root to whoever may run the check, so it refuses. Run it as the unprivileged account of the monitoring agent, with the plain `tpl-service-lynis` template.

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
./lynis --host=myhost --lynis-skip-test=MAIL-8818
```

As a best practice, silence recurring, host- or runtime-dependent noise centrally instead of changing host roles. Findings such as `ACCT-9622` / `ACCT-9626` (process accounting / `sysstat` not installed), `HRDN-7222` (a compiler is present), `FIRE-4513` (iptables has no rules), `LOGG-2190` (deleted files still in use), `BOOT-5264` and `AUTH-9282` / `AUTH-9284` (password aging) are often not worth a configuration change just to satisfy the audit. Rather than installing packages, rebuilding firewall rules or reworking roles only to lift the index, decide once which of these your organisation accepts and skip them fleet-wide with `--lynis-skip-test` (or a shared `custom.prf`). Keep `skip-test` for consciously accepted findings; fix the rest.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
