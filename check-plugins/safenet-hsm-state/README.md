# Check safenet-hsm-state

## Overview

Checks the current state of a Gemalto SafeNet ProtectServer Network HSM via SSH by running a PSESH command on the appliance. Alerts when the HSM adapter reports a non-operational state or when the usage level exceeds the configured thresholds.

**Important Notes:**

* Although it is not possible to log in as root when accessing the SafeNet ProtectServer Network HSM over SSH, **only run this plugin on trusted hosts** as the HSM only offers password-based SSH logins, so `ps` will expose the SSH password
* Requires the `sshpass` command-line tool
* SafeNet ProtectServer Network HSM Installation and Configuration Guide: <https://thalesdocs.com/gphsm/ptk/5.2/docs/Network_HSM_Installation_Guide.pdf>

**Data Collection:**

* Connects to the HSM appliance via SSH using `sshpass` and executes the `hsm state` command
* Parses the HSM state output and extracts the usage level percentage

**Compatibility:**

* Cross-platform



## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/safenet-hsm-state> |
| Nagios/Icinga Check Name              | `check_safenet_hsm_state` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--hostname` and `--password` are required) |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `sshpass` |


## Help

```text
usage: safenet-hsm-state [-h] [-V] [--always-ok] [-c CRIT] -H HOSTNAME
                         -p PASSWORD [--severity {warn,crit}] [--test TEST]
                         [--timeout TIMEOUT] [-u {admin,pseoperator}]
                         [-w WARN]

Checks the current state of a Gemalto SafeNet ProtectServer Network HSM via
SSH by running a PSESH command on the appliance. Alerts when the HSM adapter
reports a non-operational state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold in percent. Default: >= 90
  -H, --hostname HOSTNAME
                        SafeNet HSM hostname or IP address.
  -p, --password PASSWORD
                        SafeNet HSM password.
  --severity {warn,crit}
                        Severity for alerting. Default: crit
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --username {admin,pseoperator}
                        SafeNet HSM username. Example: `--username admin`.
                        Default: pseoperator
  -w, --warning WARN    WARN threshold in percent. Default: >= 80
```


## Usage Examples

```bash
./safenet-hsm-state --hostname hsm.example.com --password linuxfabrik
```

Output:

```text
HSM device 0: HSM in NORMAL MODE. RESPONDING to requests. Usage Level=95% [CRITICAL]
```


## States

* OK if the HSM is in normal mode and usage level is below the warning threshold.
* WARN or CRIT if usage level is above the configured thresholds (default: WARN >= 80%, CRIT >= 90%).
* WARN or CRIT (depending on `--severity`, default: CRIT) if the HSM is not in normal mode.
* WARN or CRIT (depending on `--severity`, default: CRIT) if command result is not equal to 0.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| usage_percent | Percentage | HSM Usage Level |


## Troubleshooting

`sshpass: Host public key is unknown. sshpass exits without confirming the new key.`  
On the host running this check, manually connect to the HSM via SSH as the user running this check command. This will add the HSM to the list of known hosts.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch); originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
