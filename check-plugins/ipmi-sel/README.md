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


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ipmi-sel> |
| Nagios/Icinga Check Name              | `check_ipmi_sel` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
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


## Troubleshooting

### What "Asserted" and "Deasserted" mean

The last field of every SEL line is the event direction, which IPMI records for every discrete sensor event:

* `Asserted`: the sensor entered the reported state, meaning the event condition became true.
* `Deasserted`: the sensor left that state again, meaning the condition cleared.

It is a direction flag, not a severity. A matching `Asserted` / `Deasserted` pair for the same sensor therefore describes a condition that has already cleared by itself.

### Reading a Power Supply event

The text between the sensor name and the direction (for example `Failure detected`) is the sensor-specific event offset defined by the IPMI specification. For a Power Supply sensor the common offsets are:

* `Presence detected`: the power supply is installed.
* `Failure detected`: generic power supply failure. A pulled cord or a lost input feed is commonly reported here.
* `Predictive failure`: the supply predicts an upcoming failure.
* `Power Supply AC lost`: input AC was lost. Some BMCs use this dedicated offset instead of the generic `Failure detected` for the same root cause.
* `AC lost or out-of-range`, `AC out-of-range, but present`: input voltage problems.

A redundant supply that briefly lost its feed (for example one of two cords, each fed from a separate UPS, being unplugged, or its UPS or PDU rail dropping out) and recovered about 90 seconds later looks like this:

```text
*    2 ; 06/11/2026 ; 08:11:35 ; Power Supply PS2 Status ; Failure detected () ; Deasserted
*    1 ; 06/11/2026 ; 08:10:07 ; Power Supply PS2 Status ; Failure detected () ; Asserted
```

The empty `()` is normal: it holds optional extra event data, which discrete status sensors usually do not provide.

The SEL records *that* the feed was lost, not *why*. It cannot tell a manually unplugged cord apart from a UPS or PDU rail dropping out. If several hosts log the same sensor (for example always `PS2`) at the same timestamp, a shared power path is a more likely cause than several individual cables.

### The check stays WARN after the hardware recovered

The plugin reports WARN whenever the SEL contains any non-ignored entry. It does not weigh `Asserted` against `Deasserted`, so a recovered transient like the example above keeps the service on WARN until the log is cleared. After confirming the cause and that no hardware is actually faulty, clear the SEL:

```bash
ipmitool sel clear
```

### Recurring entries keep raising WARN

To suppress known, harmless entries, filter them with `--ignore` (Python regex, repeatable). Keep the pattern as narrow as possible so real failures still alert. For example, ignore only log resets:

```bash
--ignore="Log area reset/cleared"
```

Avoid broad patterns such as `--ignore="Power Supply.*Status"`, which would also hide genuine power supply failures.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
