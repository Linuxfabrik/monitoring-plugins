# Check by-ssh

## Overview

Executes a command on a remote host via SSH and evaluates the result. Returns STDOUT and, in case of failure, STDERR and the command's exit code. Supports pattern matching on STDOUT to detect specific conditions, with configurable alert severities per match. Can also alert on single numeric return values against warning and critical thresholds.

**Important Notes:**

* Requires SSH access to the remote host
* Requires the `sshpass` command-line tool if password-based authentication is used
* Password-based authentication (`--password`) is not recommended. If used, `ps` will expose the SSH password on the monitoring host.
* The `--shell` option enables shell expansion for environment variables and file globs but can be a security hazard. Without it, only simple commands without globs or pipes are supported.
* Supports multiple `--identity` files and `--ssh-option` parameters for fine-grained SSH configuration


**Data Collection:**

* Connects to the remote host via SSH and executes the specified command
* Captures STDOUT, STDERR, and the command's return code
* Evaluates results through pattern matching (`--warning-pattern`, `--critical-pattern`), regex matching (`--warning-regex`, `--critical-regex`), and numeric threshold checks (`--warning`, `--critical` with Nagios range support)
* Configurable severity levels for different failure modes (STDOUT, STDERR, return code, connection timeout)
* Supports `--skip-stdout` and `--skip-stderr` to ignore all or the first N lines of output

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/by-ssh> |
| Nagios/Icinga Check Name              | `check_by_ssh` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--command` and `--hostname` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: by-ssh [-h] [-V] [--always-ok] --command COMMAND
              [--configfile CONFIGFILE] [-c CRIT]
              [--critical-pattern CRIT_PATTERN] [--critical-regex CRIT_REGEX]
              [--disable-pseudo-terminal] -H HOSTNAME [--identity IDENTITY]
              [--ipv4] [--ipv6] [-p PASSWORD] [--port PORT] [--quiet]
              [--severity-retc {ok,warn,crit,unknown}]
              [--severity-stderr {ok,warn,crit,unknown}]
              [--severity-stdout {ok,warn,crit,unknown}]
              [--severity-timeout {ok,warn,crit,unknown}]
              [--skip-stderr SKIP_STDERR] [--skip-stdout SKIP_STDOUT]
              [--ssh-option SSH_OPTION] [--shell] [--test TEST] [-u USERNAME]
              [--verbose] [-w WARN] [--warning-pattern WARN_PATTERN]
              [--warning-regex WARN_REGEX]

Executes a command on a remote host via SSH and evaluates the result. Returns
STDOUT and, in case of failure, STDERR and the command's exit code. Supports
pattern matching on STDOUT to detect specific conditions, with configurable
alert severities per match. Can also alert on single numeric return values
against warning and critical thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --command COMMAND     SSH: Command that will be executed on the remote host.
  --configfile CONFIGFILE
                        SSH: Alternative per-user configuration file. If a
                        configuration file is given on the command line, the
                        system-wide configuration file (`/etc/ssh/ssh_config`)
                        will be ignored. The default for the per-user
                        configuration file is `~/.ssh/config`. If set to
                        `none`, no configuration files will be read.
  -c, --critical CRIT   CRIT threshold for single numeric return values.
                        Supports Nagios ranges. Example: `@10:20` alerts if
                        STDOUT is in range 10..20.
  --critical-pattern CRIT_PATTERN
                        Any line matching this pattern (case-insensitive) will
                        count as a critical. Can be specified multiple times.
  --critical-regex CRIT_REGEX
                        Any line matching this Python regex (case-insensitive)
                        will count as a critical. Can be specified multiple
                        times.
  --disable-pseudo-terminal
                        SSH: Disable pseudo-terminal allocation.
  -H, --hostname HOSTNAME
                        SSH: Hostname.
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
  --ipv4                SSH: Forces ssh to use IPv4 addresses only.
  --ipv6                SSH: Forces ssh to use IPv6 addresses only.
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
  --severity-retc {ok,warn,crit,unknown}
                        Severity for alerting if there is a return code != 0.
                        Default: warn
  --severity-stderr {ok,warn,crit,unknown}
                        Severity for alerting if there is an output on STDERR.
                        Default: warn
  --severity-stdout {ok,warn,crit,unknown}
                        Severity for alerting if there is an output on STDOUT.
                        Default: ok
  --severity-timeout {ok,warn,crit,unknown}
                        Severity on connection problems. Default: unknown
  --skip-stderr SKIP_STDERR
                        Ignore all (0) or first n lines on STDERR. Default: -1
                        (no ignore).
  --skip-stdout SKIP_STDOUT
                        Ignore all (0) or first n lines on STDOUT. Default: -1
                        (no ignore).
  --ssh-option SSH_OPTION
                        SSH: Can be used to give options in the format used in
                        the configuration file. This is useful for specifying
                        options for which there is no separate command-line
                        flag. For full details of the options, and their
                        possible values, see ssh_config(5). Can be specified
                        multiple times.
  --shell               Enable shell expansion for environment variables and
                        file globs. Can be a security hazard. Without this
                        option, only simple commands without globs or pipes
                        are supported.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  -u, --username USERNAME
                        SSH: Username. Default: root
  --verbose             Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Default: False
  -w, --warning WARN    WARN threshold for single numeric return values.
                        Supports Nagios ranges. Example: `@10:20` alerts if
                        STDOUT is in range 10..20.
  --warning-pattern WARN_PATTERN
                        Any line matching this pattern (case-insensitive) will
                        count as a warning. Can be specified multiple times.
  --warning-regex WARN_REGEX
                        Any line matching this Python regex (case-insensitive)
                        will count as a warning. Can be specified multiple
                        times.
```


## Usage Examples

Simple example - returns CRIT if `dmesg --level=emerg,alert,crit` reports critical events:

```bash
./by-ssh \
    --hostname appserver \
    --username linuxfabrik \
    --severity-stdout crit \
    --command 'sudo dmesg --level=emerg,alert,crit'
```

Output:

```text
[140369.507978] watchdog: BUG: soft lockup - CPU#0 stuck for 37858s! [swapper/0:0] [CRITICAL]
```

Now imagine a command `status interface` that prints to STDOUT like this:

```text
eth0      Link encap:Ethernet  HWaddr 00:01:4E:03:00:00
          and much more output
ETH0 (Speed|Duplex): 1000Mb/s|Full
Command Result : 0 (Success)
```

You want to get a CRIT if the command does not return `Command Result : 0`. A very comprehensive plugin call that shows most of the options:

```bash
./by-ssh \
    --configfile ~/.ssh/config \
    --disable-pseudo-terminal \
    --identity ~/.ssh/id_rsa1 \
    --identity ~/.ssh/id_rsa2 \
    --ipv6 \
    --port 22 \
    --quiet \
    --ssh-option 'ConnectTimeout=3' \
    --ssh-option 'MACs=hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com' \
     \
    --severity-retc crit \
    --severity-stderr ok \
    --severity-timeout unknown \
    --critical-regex 'command result : (?!0).*' \
     \
    --hostname appserver \
    --username linuxfabrik \
    --shell \
    --command 'status interface | tail -1'
```

Get a WARNING if the `/opt` directory does NOT have `rwxrwxrwx` permissions, using a negative lookahead in a Python regular expression:

```bash
./by-ssh \
    --hostname appserver \
    --username linuxfabrik \
    --warning-regex '^(?!drwxrwxrwx.*).*opt$' \
    --command 'ls -ld /opt'

# another more consistent way using `stat` and a more readable regex (but same logic)
./by-ssh \
    --hostname appserver \
    --username linuxfabrik \
    --warning-regex '^(?!777)\d{3}$' \
    --command 'stat /opt -c %a'
```

Output in case of an error will look like this:

```text
Command Result : 65535 (PSe2 Shell execution) [CRITICAL]
```

Calling an invalid command:

```bash
./by-ssh \
    --hostname appserver \
    --username linuxfabrik \
    --command 'sudo gobbledygook'
```

Output:

```text
retc: 1 [WARNING]; stderr: sudo: gobbledygook: command not found [WARNING]; stdout: None
```


## States

States are computed in this particular order. The worst state is returned (CRIT before WARN before UNKNOWN before OK).

Output on STDOUT?

* Depending on the given `--severity-stdout`, returns OK (default), WARN, CRIT or UNKNOWN.
* Returns WARN depending on the results of `--warning-pattern` or `--warning-regex`.
* Returns CRIT depending on the results of `--critical-pattern` or `--critical-regex`.
* Returns WARN or CRIT depending on single numeric return values and `--warning` / `--critical` (Nagios ranges).

Output on STDERR?

* Depending on the given `--severity-stderr`, returns OK, WARN (default), CRIT or UNKNOWN if there is output on STDERR.

Return code != 0?

* Depending on the given `--severity-timeout`, returns OK, WARN, CRIT or UNKNOWN (default) if SSH can't connect.
* Depending on the given `--severity-retc`, returns OK, WARN (default), CRIT or UNKNOWN if there is a return code != 0.

`--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| remote_runtime | Seconds | Time connecting, running the command on the remote host and disconnecting. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch); originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
