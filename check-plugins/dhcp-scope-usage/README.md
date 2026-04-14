# Check dhcp-scope-usage


## Overview

Monitors IPv4 DHCP scope usage on a Windows DHCP server. Connects via WinRM and queries scope statistics using PowerShell. Alerts when the address pool usage of any scope exceeds the configured thresholds (default: WARN at 80%, CRIT at 90%).

**Important Notes:**

* Set the plugin timeout to 30 seconds, as WinRM connections can be slow
* The `--hostname` parameter specifies which DHCP server to query (can differ from the WinRM target)
* Running directly on Linux without `--winrm-hostname` is not supported

**Data Collection:**

* Executes the PowerShell cmdlet `Get-DhcpServerv4ScopeStatistics -ComputerName "<hostname>"` via WinRM on the target Windows server
* Parses the `PercentageInUse` field for each scope (handles locale-dependent decimal separators by truncating the fraction)
* Reports each scope individually with its usage percentage


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dhcp-scope-usage> |
| Nagios/Icinga Check Name              | `check_dhcp_scope_usage` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No (`--winrm-hostname` and `--winrm-password` are required) |
| Runs on                               | Windows |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `winrm` (for remote execution via WinRM) |


## Help

```text
usage: dhcp-scope-usage [-h] [-V] [--always-ok] [--brief] [-c CRIT]
                        [-H HOSTNAME] [--test TEST] [-w WARN]
                        [--winrm-domain WINRM_DOMAIN]
                        --winrm-hostname WINRM_HOSTNAME
                        --winrm-password WINRM_PASSWORD
                        [--winrm-transport {basic,ntlm,kerberos,credssp,plaintext}]
                        [--winrm-username WINRM_USERNAME]

Monitors IPv4 DHCP scope usage on a Windows DHCP server. Connects via WinRM
and queries scope statistics using PowerShell. On servers with thousands of
scopes, --brief hides rows within the thresholds so the output only lists
scopes in WARN/CRIT state. Alerts when the address pool usage of any scope
exceeds the configured thresholds (default: WARN at 80%, CRIT at 90%).

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide scopes within the thresholds and show only those
                        in WARN/CRIT state. Inverse of `--lengthy` (which adds
                        columns); `--brief` filters rows. The two are
                        orthogonal and can be combined. Perfdata and alerting
                        are unaffected: all scopes still emit perfdata and
                        still drive the overall check state. Default: False
  -c, --critical CRIT   CRIT threshold in percent. Default: >= 90
  -H, --hostname HOSTNAME
                        DNS name, IPv4, or IPv6 address of the DHCP server.
                        Default: localhost
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  -w, --warning WARN    WARN threshold in percent. Default: >= 80
  --winrm-domain WINRM_DOMAIN
                        WinRM Domain Name. Default: None
  --winrm-hostname WINRM_HOSTNAME
                        Target Windows computer on which the command will be
                        executed.
  --winrm-password WINRM_PASSWORD
                        WinRM account password.
  --winrm-transport {basic,ntlm,kerberos,credssp,plaintext}
                        WinRM transport type. Default: ntlm
  --winrm-username WINRM_USERNAME
                        WinRM account name. Default: Administrator
```


## Usage Examples

Remote usage, for example from a Linux server:

```bash
./dhcp-scope-usage \
    --hostname=dhcp01.example.com \
    --winrm-hostname=10.80.32.246 \
    --winrm-username=Administrator \
    --winrm-password=linuxfabrik \
    --winrm-domain=EXAMPLE.COM \
    --winrm-transport=ntlm
```

Output:

```text
There are one or more criticals.

* 192.168.120.0: 0% used
* 192.168.121.0: 83% used [WARNING]
* 192.168.122.0: 91% used [CRITICAL]
```


## States

* OK if all DHCP scope usage percentages are below the thresholds.
* WARN if the PowerShell cmdlet returns a non-zero exit code.
* WARN if any DHCP scope usage is >= `--warning` (default: 80%).
* CRIT if any DHCP scope usage is >= `--critical` (default: 90%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| scope_SCOPEID | Percentage | The address pool usage for the DHCP scope identified by SCOPEID (for example `scope_192.168.122.0`). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
