# Check ipmi-sel


## Overview

Checks the IPMI System Event Log (SEL) for entries and alerts when events are found. Entries can be filtered by regex using `--ignore`. To clear the SEL after resolving issues, run `ipmitool sel clear`. Requires root or sudo.

**Important Notes:**

* Tested on Supermicro BMC and HPE iLO
* Requires hardware with an IPMI interface
* `Discrete` sensors support is not implemented.
* Requires the `ipmitool` command-line tool to be installed.

**Data Collection:**

* Executes `ipmitool sel elist` locally or against a remote BMC/iLO via IPMI over LAN
* For remote access, supports both IPMI v1.5 (`--interface=lan`) and IPMI v2.0 (`--interface=lanplus`)
* Output lines are displayed in reverse chronological order with pipe characters replaced by semicolons

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ipmi-sel> |
| Nagios/Icinga Check Name              | `check_ipmi_sel` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | `ipmitool` |


## Help

```text
usage: ipmi-sel [-h] [-V] [--authtype {NONE,PASSWORD,MD2,MD5,OEM}]
                [-H HOSTNAME] [--ignore IGNORE] [--interface {lan,lanplus}]
                [--password PASSWORD] [--port PORT]
                [--privlevel {CALLBACK,USER,OPERATOR,ADMINISTRATOR}]
                [--test TEST] [--username USERNAME]

Checks the IPMI System Event Log (SEL) for entries and alerts when events are
found. Entries can be filtered by regex using --ignore. To clear the SEL after
resolving issues, run "ipmitool sel clear". Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --authtype {NONE,PASSWORD,MD2,MD5,OEM}
                        Authentication type for IPMIv1.5 lan session
                        activation. Supported types are NONE, PASSWORD, MD2,
                        MD5, or OEM. Default: NONE
  -H, --hostname HOSTNAME
                        Remote server address, can be a hostname or IP
                        address. Required for lan and lanplus interfaces.
  --ignore IGNORE       Ignore SEL entries matching this Python regular
                        expression. Can be specified multiple times. Example:
                        `--ignore="Log area reset/cleared"`.
  --interface {lan,lanplus}
                        IPMI interface to use. Supported types are "lan" (IPMI
                        v1.5) or "lanplus" (IPMI v2.0). Default: lan
  --password PASSWORD   Remote server password.
  --port PORT           Remote server UDP port to connect to. Default: 623
  --privlevel {CALLBACK,USER,OPERATOR,ADMINISTRATOR}
                        Force session privilege level. Can be CALLBACK, USER,
                        OPERATOR, ADMINISTRATOR. Default: USER
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --username USERNAME   Remote server username. Default: NULL
```


## Usage Examples

```bash
./ipmi-sel --privlevel USER --interface lanplus --hostname 10.100.184.29 --username 'user' --password 'pa$$word'
```

Output:

```text
*   17 ; 09/10/2019 ; 21:11:27 ; OS Boot ; Installation completed () ; Asserted
*   16 ; 09/10/2019 ; 21:00:01 ; OS Boot ; Installation started () ; Asserted
*   15 ; 09/10/2019 ; 20:45:43 ; OS Boot ; Installation started () ; Asserted
*   14 ; 09/03/2019 ; 21:59:00 ; Unknown #0xff ;  ; Asserted
*    d ; 08/26/2019 ; 13:57:02 ; Physical Security Chassis Intru ; General Chassis intrusion () ; Deasserted
*    c ; 08/17/2019 ; 02:33:33 ; Power Supply PS1 Status ; Failure detected () ; Deasserted
*    b ; 08/17/2019 ; 02:33:24 ; Power Supply PS1 Status ; Failure detected () ; Asserted
```


## States

* OK if the SEL has no entries (or all entries are filtered by `--ignore`).
* WARN if the SEL contains entries.
* UNKNOWN if `ipmitool` is not found or returns an error.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
