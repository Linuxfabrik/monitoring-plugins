# Check lynis


## Overview

Runs a full security audit across the hosts of a subnet and reports each host's hardening posture. From a single management host it discovers the targets (the subnet of the default interface, a chosen interface, or an explicit host list), connects to each one over SSH, copies a self-contained copy of the audit tool over, runs a privileged system audit (root via password-less sudo by default), retrieves the machine-readable report, and removes its temporary files. A host that does not answer within the connect timeout is skipped. The check is meant to run at most once per day; the worst per-host result determines the overall state. Security posture is informational drift rather than a time-critical availability event, so by default only WARNING is raised. Hosts are audited in parallel.

**Important Notes:**

* Requires SSH access to every target host. Without parameters the plugin assumes password-less public key authentication and password-less `sudo` on the targets. Host aliases from `~/.ssh/config` are honored.
* Requires `lynis` on the management host (where the plugin runs); a self-contained copy is assembled and pushed to the targets, so `lynis` does not need to be installed on them.
* The audit runs privileged (via `sudo`) so the hardening index reflects a complete scan. The report is left on each target at `/var/log/lynis-report.dat` for the admin to inspect.
* `lynis` is a script that must be executed, so the plugin uses the first target partition that is writable and not mounted `noexec` (hardened hosts often mount `/var/tmp` and `/tmp` `noexec`).
* The copy is pushed with `rsync` when it is available on the management host (faster), otherwise with `scp -r`; neither requires `tar` on the target.
* A security audit is posture drift, not a time-critical availability event, so by default only WARNING is raised. The default critical threshold is empty on purpose, to avoid paging someone at night for a hardening drop.

**Data Collection:**

* The per-host state is the worst of: the hardening index against `--warning` / `--critical` (Nagios ranges, default warns below 65), and the presence of any lynis warning.
* Every lynis warning raises at least WARNING. A warning is a concrete finding, not noise; accept it on the host (see Troubleshooting), not in this plugin.
* Auto-discovery probes raw IP addresses, which do not match per-host `~/.ssh/config` aliases. For `--network` / `--interface` discovery, provide working credentials with `--username` and `--identity`.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/lynis> |
| Nagios/Icinga Check Name              | `check_lynis` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requires on the management host       | `ssh`, `lynis`, and `rsync` or `scp` |


## Help

```text
usage: lynis [-h] [-V] [--always-ok] [--audit-timeout AUDIT_TIMEOUT]
             [--configfile CONFIGFILE] [--connect-timeout CONNECT_TIMEOUT]
             [-c CRIT] [--disable-pseudo-terminal] [-H HOST]
             [--identity IDENTITY] [--interface INTERFACE] [--ipv4] [--ipv6]
             [--lengthy] [--lynis-auditor LYNIS_AUDITOR]
             [--lynis-option LYNIS_OPTION] [--lynis-profile LYNIS_PROFILE]
             [--lynis-skip-test LYNIS_SKIP_TEST] [--lynis-source LYNIS_SOURCE]
             [--lynis-test LYNIS_TEST]
             [--lynis-test-category LYNIS_TEST_CATEGORY]
             [--lynis-test-group LYNIS_TEST_GROUP] [--max-workers MAX_WORKERS]
             [--network NETWORK] [-p PASSWORD] [--port PORT] [--quiet]
             [--ssh-option SSH_OPTION] [--test TEST] [-u USERNAME] [--verbose]
             [-w WARN]

Runs a full security audit across the hosts of a subnet and reports each
host's hardening posture. From a single management host it discovers the
targets (the subnet of the default interface, a chosen interface, or an
explicit host list), connects to each one over SSH, copies a self-contained
copy of the audit tool over, runs a privileged system audit (root via
password-less sudo by default), retrieves the machine-readable report, and
removes its temporary files. A host that does not answer within the connect
timeout is skipped. The check is meant to run at most once per day; the worst
per-host result determines the overall state. Security posture is
informational drift rather than a time-critical availability event, so by
default only WARNING is raised.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --audit-timeout AUDIT_TIMEOUT
                        Seconds to wait for the remote audit of a single host
                        to finish. Default: 600 (seconds)
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
  -H, --host HOST       Target host to audit. Overrides subnet auto-discovery.
                        Can be specified multiple times. If not specified, the
                        subnet of the default interface is scanned.
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
                        when --host is given. If not specified, the default
                        interface (the one carrying the default route) is
                        used.
  --ipv4                SSH: Forces ssh to use IPv4 addresses only.
  --ipv6                SSH: Forces ssh to use IPv6 addresses only.
  --lengthy             Extended reporting.
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
                        Profile file to use for the audit (lynis `--profile`).
                        The path is resolved on the target host. If not
                        specified, lynis uses the bundled default profile.
  --lynis-skip-test LYNIS_SKIP_TEST
                        Lynis test ID to skip on every target (injected as
                        `skip-test` into the pushed profile), for fleet-wide
                        exceptions controlled from the monitoring
                        configuration. Can be specified multiple times. Host-
                        specific exceptions belong in the target's own
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
                        Only run lynis tests of these categories (lynis
                        `--tests-from-category`). Can be specified multiple
                        times. If not specified, all categories are run.
                        Example: `--lynis-test-category=security`
  --lynis-test-group LYNIS_TEST_GROUP
                        Only run lynis tests of these groups (lynis `--tests-
                        from-group`). Can be specified multiple times. If not
                        specified, all groups are run. Example: `--lynis-test-
                        group=ssh --lynis-test-group=kernel`
  --max-workers MAX_WORKERS
                        Maximum number of hosts to audit in parallel. Default:
                        10
  --network NETWORK     Network in CIDR notation to scan for targets via auto-
                        discovery. Can be specified multiple times. Takes
                        precedence over --interface. Example:
                        `--network=192.0.2.0/24`
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
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  -u, --username USERNAME
                        SSH: Username. If not specified, ssh determines the
                        user from `~/.ssh/config` or falls back to the current
                        local user.
  --verbose             Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Default: False
  -w, --warning WARN    WARN threshold for the per-host hardening index
                        (0-100). Supports Nagios ranges. The default alerts
                        when the index drops below 65. Default: 65:
```


## Usage Examples

Audit a single host (using a `~/.ssh/config` alias):

```bash
./lynis --host=myhost
```

Audit every reachable host in a subnet, logging in as `linuxfabrik` with an explicit key, 20 hosts at a time:

```bash
./lynis --network=192.0.2.0/24 --username=linuxfabrik --identity=~/.ssh/id_ed25519 --max-workers=20
```

Show the per-host details and follow what the plugin is doing:

```bash
./lynis --host=myhost --lengthy --verbose
```

Warn below a hardening index of 70, critical below 50:

```bash
./lynis --host=myhost --warning=70: --critical=50:
```

Accept a finding on every target (fleet-wide), controlled from the monitoring configuration:

```bash
./lynis --network=192.0.2.0/24 --lynis-skip-test=MAIL-8818
```

Output of a subnet scan (without `--lengthy` parameter):

```text
16/254 hosts audited

Host:Report                            ! Warn ! HIdx ! State
---------------------------------------+------+------+----------
app01:/var/log/lynis-report.dat        ! 0    ! 71   !
app02:/var/log/lynis-report.dat        ! 0    ! 72   !
proxy01:/var/log/lynis-report.dat      ! 0    ! 73   !
mon01:/var/log/lynis-report.dat        ! 2    ! 70   ! [WARNING]
mariadb01:/var/log/lynis-report.dat    ! 0    ! 71   !
postgresql01:/var/log/lynis-report.dat ! 0    ! 71   !
redis01:/var/log/lynis-report.dat      ! 0    ! 71   !
web01:/var/log/lynis-report.dat        ! 0    ! 71   !
matomo01:/var/log/lynis-report.dat     ! 0    ! 72   !
deploy01:/var/log/lynis-report.dat     ! 0    ! 71   !
web02:/var/log/lynis-report.dat        ! 0    ! 71   !
cache01:/var/log/lynis-report.dat      ! 2    ! 70   ! [WARNING]
vault01:/var/log/lynis-report.dat      ! 2    ! 70   ! [WARNING]
backup01:/var/log/lynis-report.dat     ! 0    ! 73   !
dns01:/var/log/lynis-report.dat        ! 0    ! 73   !
mail01:/var/log/lynis-report.dat       ! 0    ! 72   !
```

A full audit takes roughly one minute per host (measured on Rocky Linux 9). Because hosts are audited in parallel (`--max-workers`, default 10), wall-clock time for a subnet is far lower: the scan above audited 16 reachable hosts out of a /24 in about 3 minutes.


## States

* OK if the hardening index is within the `--warning` / `--critical` range and the host reports no lynis warnings.
* WARN if the hardening index drops below `--warning` (default: 65), or the host reports at least one lynis warning.
* CRIT if the hardening index drops below `--critical` (empty by default, so CRIT is never raised unless a threshold is set).
* UNKNOWN for a reachable host that could not be audited (SSH authentication failed, no executable work directory, audit produced no report, ...). Hosts that do not answer on SSH are skipped silently.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| hosts_total | Number | Number of target hosts considered. |
| hosts_audited | Number | Number of hosts that were successfully audited. |
| warnings | Number | Total number of lynis warnings across all audited hosts. |
| suggestions | Number | Total number of lynis suggestions across all audited hosts. |


## Lynis Profiles

Lynis reads its settings from profile files. `default.prf` is the default profile and ships with lynis; it defines which tests run, their thresholds, and which tests to skip. `custom.prf` is the place for site-specific overrides and survives package upgrades. Lynis discovers both automatically (searching `/etc/lynis` and the current directory) and merges them, so you do not need to edit `default.prf`. Use `--lynis-profile` to point at a specific profile file on the target instead.


## Troubleshooting

### `SSH authentication failed`

The host answered on SSH, but authentication failed. Auto-discovery connects to raw IP addresses, which do not match a `Host myhost` alias in `~/.ssh/config`. Pass working credentials with `--username` and `--identity`, or add a matching `Host` / `Match` block to the SSH config.

### `no executable (non-noexec) work directory found`

Every candidate partition on the target is mounted `noexec`, so the pushed `lynis` script cannot be executed. Mount one of `/var/tmp`, `/tmp` or the user's home without `noexec`, or provide another writable, executable partition.

### Accepting a finding you do not want to fix

The plugin never silences individual lynis warnings; every warning raises at least WARNING. Acceptance belongs in lynis itself, where a test is skipped when its ID is listed with `skip-test=` in a profile.

For a single host, add the test ID to the host's `custom.prf`. For example, to accept this warning:

```text
warning[]=MAIL-8818|Found some information disclosure in SMTP banner (OS or software name)|-|-|
```

Run on the affected host:

```bash
mkdir --parents /etc/lynis && echo 'skip-test=MAIL-8818' >> /etc/lynis/custom.prf
```

The next audit no longer reports `MAIL-8818`.

Fleet-wide, pass `--lynis-skip-test`, which is injected into the pushed profile on every host and merged with each host's `custom.prf`:

```bash
./lynis --network=192.0.2.0/24 --lynis-skip-test=MAIL-8818
```

As a best practice, silence recurring, host- or runtime-dependent noise centrally instead of changing host roles. Findings such as `ACCT-9622` / `ACCT-9626` (process accounting / `sysstat` not installed), `HRDN-7222` (a compiler is present), `FIRE-4513` (iptables has no rules), `LOGG-2190` (deleted files still in use), `BOOT-5264` and `AUTH-9282` / `AUTH-9284` (password aging) are often not worth a configuration change just to satisfy the audit. Rather than installing packages, rebuilding firewall rules or reworking roles only to lift the index, decide once which of these your organisation accepts and skip them fleet-wide with `--lynis-skip-test` (or a shared `custom.prf`). Keep `skip-test` for consciously accepted findings; fix the rest.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
