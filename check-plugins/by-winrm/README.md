# Check by-winrm

## Overview

Execute commands on remote Windows hosts via WinRM (Windows Remote Management), including support for JEA (Just Enough Administration) and PowerShell Remoting (PSRP). It behaves similarly to [by-ssh](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/by-ssh), but - although running on Linux - is Windows-native, speaking Microsoft's remoting protocols instead of SSH.

This plugin securely executes PowerShell commands or scripts on remote Windows hosts via WinRM, supporting NTLM, Kerberos, CredSSP, Basic, and plaintext transports. It automatically prefers PSRP (PowerShell Remoting / JEA) for modern, least-privilege Windows remoting and falls back to classic WinRM when needed. Output can be evaluated using numeric thresholds, pattern and regex matching, and configurable severity levels based on stdout, stderr, return code, or connection issues. It also exports execution time as performance data (remote_runtime).

This makes the plugin ideal for retrieving Windows-specific metrics, running custom PowerShell-based health checks (such as inventory, backup status, or failover cluster queries), and accessing systems like Active Directory, Exchange, SQL Server, or Hyper-V. It is especially useful in environments where installing a monitoring agent is not possible or desired, offering a secure and flexible alternative for remote monitoring on Windows hosts.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/by-winrm> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Requirements                          | Enable WinRM on the remote host (`Enable-PSRemoting -Force`). For JEA usage, configure a JEA endpoint with a role allowing specific commands only (recommended for security-sensitive environments). |
| 3rd Party Python modules              | `pypsrp` (supports JEA). Alternative without JEA: `pywinrm`, `pywinrm[kerberos]`, `pywinrm[credssp]` |


## Prerequisites

### Windows (Remote Host)

Enable WinRM on the target Windows host:

```powershell
Enable-PSRemoting -Force
```

By default, WinRM listens on port **5985** (HTTP) and **5986** (HTTPS). Ensure the corresponding firewall port is open.

Depending on the chosen transport, additional configuration may be required:

| Transport | When to use | Extra Setup on Windows |
|----|----|----|
| `ntlm` (default) | Domain and workgroup environments. Works out of the box. | None - works with `Enable-PSRemoting`. |
| `kerberos` | Active Directory environments. Most secure; supports SSO via `kinit` on the monitoring host (no password needed). | Requires AD domain membership. |
| `basic` | Testing or HTTPS-only setups. Credentials are base64-encoded (not encrypted). | `winrm set winrm/config/service/auth @{Basic="true"}`. Use HTTPS in production. |
| `credssp` | Multi-hop scenarios where credentials must be delegated to a third system. | `Enable-WSManCredSSP -Role Server` on the target host. |
| `plaintext` | Same as `basic` but explicitly over HTTP. | Same as `basic`. Insecure - avoid in production. |

### Linux (Monitoring Host)

For **Kerberos** transport, configure `/etc/krb5.conf` for your Active Directory domain and obtain a ticket before running the plugin:

```bash
kinit user@EXAMPLE.COM
```

When Kerberos credentials are present in the cache, `--winrm-username` and `--winrm-password` can be omitted.

### `--winrm-domain`

When set, the username is sent as `user@DOMAIN` for NTLM authentication. Use the Active Directory domain name (e.g. `EXAMPLE.COM`). Not needed for Kerberos (the domain is part of the Kerberos principal) or local accounts.


## Help

```text
usage: by-winrm [-h] [-V] [--always-ok] --command COMMAND [-c CRIT]
                [--critical-pattern CRIT_PATTERN]
                [--critical-regex CRIT_REGEX]
                [--severity-retc {ok,warn,crit,unknown}]
                [--severity-stderr {ok,warn,crit,unknown}]
                [--severity-stdout {ok,warn,crit,unknown}]
                [--severity-timeout {ok,warn,crit,unknown}]
                [--skip-stderr SKIP_STDERR] [--skip-stdout SKIP_STDOUT]
                [--test TEST] [--verbose] [-w WARN]
                [--warning-pattern WARN_PATTERN] [--warning-regex WARN_REGEX]
                [--winrm-configuration-name WINRM_CONFIGURATION_NAME]
                [--winrm-domain WINRM_DOMAIN] --winrm-hostname WINRM_HOSTNAME
                [--winrm-password WINRM_PASSWORD]
                [--winrm-transport {basic,ntlm,kerberos,credssp,plaintext}]
                [--winrm-username WINRM_USERNAME]

This plugin executes PowerShell commands or scripts on remote Windows hosts
via WinRM, supporting JEA. It returns standard output (STDOUT) and, in case of
failure, standard error (STDERR) along with the command's exit code. By
evaluating these results - through threshold checks or pattern matching on
STDOUT - the plugin can generate alerts with configurable severity levels.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --command COMMAND     PowerShell command or script to execute on the remote
                        host. Supports pipelines and complex expressions.
  -c, --critical CRIT   CRIT threshold for single numeric return values.
                        Supports Nagios ranges. Example: `@10:20` alerts if
                        STDOUT is in range 10..20.
  --critical-pattern CRIT_PATTERN
                        Any line matching this pattern (case-insensitive) will
                        count as a critical. Can be specified multiple times.
  --critical-regex CRIT_REGEX
                        Any line matching this python regex (case-insensitive)
                        will count as a critical. Can be specified multiple
                        times.
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
                        (no ignore)
  --skip-stdout SKIP_STDOUT
                        Ignore all (0) or first n lines on STDOUT. Default: -1
                        (no ignore)
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --verbose             Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what's going on under the
                        hood. Default: False
  -w, --warning WARN    WARN threshold for single numeric return values.
                        Supports Nagios ranges. Example: `@10:20` alerts if
                        STDOUT is in range 10..20.
  --warning-pattern WARN_PATTERN
                        Any line matching this pattern (case-insensitive) will
                        count as a warning. Can be specified multiple times.
  --warning-regex WARN_REGEX
                        Any line matching this python regex (case-insensitive)
                        will count as a warning. Can be specified multiple
                        times.
  --winrm-configuration-name WINRM_CONFIGURATION_NAME
                        PowerShell session configuration name (JEA endpoint).
                        Only supported with pypsrp.
  --winrm-domain WINRM_DOMAIN
                        AD domain name for NTLM authentication. When set,
                        username is sent as user@DOMAIN. Not needed for
                        Kerberos or local accounts. Default: None
  --winrm-hostname WINRM_HOSTNAME
                        Target Windows computer on which the command will be
                        executed.
  --winrm-password WINRM_PASSWORD
                        WinRM account password. Optional for Kerberos (uses
                        credential cache from kinit).
  --winrm-transport {basic,ntlm,kerberos,credssp,plaintext}
                        WinRM transport type. Default: ntlm
  --winrm-username WINRM_USERNAME
                        WinRM account name. Optional for Kerberos (uses
                        credential cache from kinit).
```


## Usage Examples

Simple example - returns CRIT if the PowerShell Command `1+1` is not in the range `3..infinity`:

```bash
./by-winrm \
    --winrm-hostname=winsrv.example.com \
    --winrm-username=Administrator \
    --winrm-password=linuxfabrik \
    --winrm-domain=EXAMPLE.COM \
    --winrm-transport=ntlm \
    --command='1+1' \
    --critical='3:'
```

Output:

```text
2 [CRITICAL]
```

Get a warning if CPU usage is >= 2.1%:

```bash
./by-winrm \
    --winrm-hostname=winsrv.example.com \
    --winrm-username=Administrator \
    --winrm-password=linuxfabrik \
    --winrm-domain=EXAMPLE.COM \
    --winrm-transport=ntlm \
    --command='(Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 1).CounterSamples[0].CookedValue' \
    --warning=2.1
```

Output:

```text
2.78062697768402 [WARNING]
```

Check if the Windows Update service is running - alert with CRIT if it is stopped (uses a pipeline and pattern matching):

```bash
./by-winrm \
    --winrm-hostname=winsrv.example.com \
    --winrm-username=Administrator \
    --winrm-password=linuxfabrik \
    --winrm-domain=EXAMPLE.COM \
    --command='(Get-Service -Name wuauserv).Status' \
    --critical-pattern='Stopped'
```

Output if the service is stopped:

```text
Stopped [CRITICAL]
```

Use regex matching - alert with WARNING if any of the last 50 system event log messages contain "disk", or CRIT if they contain "error" or "fail":

```bash
./by-winrm \
    --winrm-hostname=winsrv.example.com \
    --winrm-username=Administrator \
    --winrm-password=linuxfabrik \
    --winrm-domain=EXAMPLE.COM \
    --command='Get-EventLog -LogName System -Newest 50 | Select-Object -ExpandProperty Message' \
    --warning-pattern='disk' \
    --critical-regex='error|fail'
```

Use Kerberos authentication (no password needed when a valid ticket exists):

```bash
kinit -V linus@EXAMPLE.COM
klist

./by-winrm \
    --winrm-hostname=winsrv.example.com \
    --winrm-transport=kerberos \
    --command='Get-CpuPercent'
```

Use a JEA (Just Enough Administration) endpoint - requires `pypsrp`:

```bash
./by-winrm \
    --winrm-hostname=winsrv.example.com \
    --winrm-username=jea-operator \
    --winrm-password=linuxfabrik \
    --winrm-domain=EXAMPLE.COM \
    --winrm-configuration-name=MyJEAEndpoint \
    --command='Get-DiskSpace'
```

The `--winrm-configuration-name` specifies the PowerShell session configuration (JEA endpoint) on the target host. Only the cmdlets allowed by the JEA role capability will be available.

What error output looks like - for example when authentication fails:

```bash
./by-winrm \
    --winrm-hostname=winsrv.example.com \
    --winrm-username=Administrator \
    --winrm-password=wrong-password \
    --winrm-domain=EXAMPLE.COM \
    --command='Get-Service'
```

Output:

```text
the server did not respond with one of the following authentication methods - Negotiate [UNKNOWN]
```


## States

States are computed in this particular order. The worst state is returned (CRIT before WARN before UNKNOWN before OK).

Output on STDOUT?

* Depending on the given `--severity-stdout`, returns OK (default), WARN, CRIT or UNKNOWN.
* Returns WARN depending on the return value and `--warning`.
* Returns CRIT depending on the return value and `--critical`.
* Returns WARN depending on the results of `--warning-pattern` or `--warning-regex`.
* Returns CRIT depending on the results of `--critical-pattern` or `--critical-regex`.

Output on STDERR?

* Depending on the given `--severity-stderr`, returns OK, WARN (default), CRIT or UNKNOWN if there is output on STDERR.

Return code != 0?

* Depending on the given `--severity-timeout`, returns OK, WARN, CRIT or UNKNOWN (default) if WinRM can't connect (no command output but error present).
* Depending on the given `--severity-retc`, returns OK, WARN (default), CRIT or UNKNOWN if there is a return code != 0.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| remote_runtime | Seconds | Time connecting, running the command on the remote host and disconnecting. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch); originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
