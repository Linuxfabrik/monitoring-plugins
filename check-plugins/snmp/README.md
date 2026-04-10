# Check snmp

## Overview

Queries SNMP OIDs defined in a CSV file and checks the returned values against optional warning and critical thresholds. Supports SNMP v1, v2c, and v3 with authentication and privacy protocols.

**Data Collection:**

* Reads OID definitions from a CSV file in the `device-oids` directory (default: `any-any-any.csv`)
* Calls `snmpget` in blocks of 25 OIDs per request to avoid "tooBig" errors
* Supports re-calculation of values, custom units, human-readable formatting (bytes, seconds, bps), and computed values using Python expressions
* Values can be shown in the first output line, filtered from the table, or excluded from perfdata

**Important Notes:**

* Only use SNMP if there is no other way. SNMP puts much strain on the target system and the monitoring software:
    * If you can use an agent of your monitoring software (e.g. Icinga) and one of our plugins, do it
    * If you can't install an agent but there is a good (REST-)API available, use that
    * If you can't install an agent and there is no good API, then use SNMP
    * If possible, use a specialized SNMP solution like [LibreNMS](https://www.librenms.org/) instead of this check
    * Prefer SNMPv2. Although completely insecure, it is fast and keeps the load on your appliance low
* The check divides the OID list automatically into blocks of 25 OIDs per SNMPGET request
* If you acknowledge a value change in Icinga, the desired WARN or CRIT state remains. Delete `$TEMP/linuxfabrik-monitoring-plugins-snmp.db` to reset the inventory.

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/snmp> |
| Nagios/Icinga Check Name              | `check_snmp` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--hostname` is required) |
| Compiled for Windows                  | No |
| Requirements                          | `snmpget` from `net-snmp-utils` |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-snmp.db` |


## Help

```text
usage: snmp [-h] [-V] [--community COMMUNITY] [--device DEVICE] [--hide-ok]
            [--hide-table] -H HOSTNAME [--mib MIB] [--mib-dir MIB_DIR]
            [--snmp-version {1,2c,3}] [--test TEST] [-t TIMEOUT]
            [--v3-auth-prot {MD5,SHA,SHA-224,SHA-256,SHA-384,SHA-512}]
            [--v3-auth-prot-password V3_AUTH_PROT_PASSWORD]
            [--v3-boots-time V3_BOOTS_TIME] [--v3-context V3_CONTEXT]
            [--v3-context-engine-id V3_CONTEXT_ENGINE_ID]
            [--v3-level {noAuthNoPriv,authNoPriv,authPriv}]
            [--v3-priv-prot {DES,AES,AES-192,AES-256}]
            [--v3-priv-prot-password V3_PRIV_PROT_PASSWORD]
            [--v3-security-engine-id V3_SECURITY_ENGINE_ID]
            [--v3-username V3_USERNAME]

Queries SNMP OIDs defined in a CSV file and checks the returned values against
optional warning and critical thresholds. Supports SNMP v1, v2c, and v3 with
authentication and privacy protocols.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --community COMMUNITY
                        SNMP v1/v2c community string. Default: public
  --device DEVICE       Name of a CSV file containing the SNMP OIDs, located
                        under `./device-oids`. The recommended naming
                        convention is `class-vendor-model.csv`. `any-any-
                        any.csv` is a good starting point showing some
                        features. Example: `--device switch-fs-s3900.csv`.
                        Default: any-any-any.csv
  --hide-ok             Suppress OIDs with OK state from output. Default:
                        False
  --hide-table          Suppress the table from output. Default: False
  -H, --hostname HOSTNAME
                        SNMP appliance hostname or IP address.
  --mib MIB             MIB(s) to load, behaves like the `-m` option of
                        `snmpget`. Example: `--mib "+FS-MIB"` or `--mib "FS-
                        MIB:BROTHER-MIB"`.
  --mib-dir MIB_DIR     Colon-separated list of directories to search for
                        MIBs, behaves like the `-M` option of `snmpget`.
                        Default: $HOME/.snmp/mibs:/usr/share/snmp/mibs
  --snmp-version {1,2c,3}
                        SNMP version to use. Default: 2c
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  -t, --timeout TIMEOUT
                        Network timeout in seconds. Default: 7 (seconds)
  --v3-auth-prot {MD5,SHA,SHA-224,SHA-256,SHA-384,SHA-512}
                        SNMPv3 authentication protocol.
  --v3-auth-prot-password V3_AUTH_PROT_PASSWORD
                        SNMPv3 authentication protocol passphrase.
  --v3-boots-time V3_BOOTS_TIME
                        SNMPv3 destination engine boots/time.
  --v3-context V3_CONTEXT
                        SNMPv3 context name. Example: `--v3-context bridge1`.
  --v3-context-engine-id V3_CONTEXT_ENGINE_ID
                        SNMPv3 context engine ID. Example: `--v3-context-
                        engine-id 800000020109840301`.
  --v3-level {noAuthNoPriv,authNoPriv,authPriv}
                        SNMPv3 security level.
  --v3-priv-prot {DES,AES,AES-192,AES-256}
                        SNMPv3 privacy protocol.
  --v3-priv-prot-password V3_PRIV_PROT_PASSWORD
                        SNMPv3 privacy protocol passphrase.
  --v3-security-engine-id V3_SECURITY_ENGINE_ID
                        SNMPv3 security engine ID. Example: `--v3-security-
                        engine-id 800000020109840301`.
  --v3-username V3_USERNAME
                        SNMPv3 security name (username). Example:
                        `--v3-username bert`.
```


## Usage Examples

A minimal command call:

```bash
./snmp --hostname 10.80.32.109
```

Calling this the check...

1.  fetches a set of most common SNMP OIDs like *Contact* or *Uptime*, defined in `device-oids/any-any-any.csv`,
2.  calls `snmpget -v 2c -c public -r 0 -t 7 -OSqtU -M $HOME/.snmp/mibs:/usr/share/snmp/mibs 10.80.32.109 OID1 OID2 ...`,
3.  parses the output,
4.  interprets the result and calculates the return state.

Other example using a more specific OID list and an additional MIB directory:

```bash
/usr/lib64/nagios/plugins/snmp \
    --device switch-fs-s3900.csv \
    --mib-dir +/usr/lib64/nagios/plugins/device-mibs/switch-fs-s3900 \
    --hide-ok \
    --hostname 10.80.32.109
```

Checking a Radware Alteon load balancer appliance - CSV file and result:

```text
OID,Name,Re-Calc,Unit Label,WARN,CRIT,Show in 1st Line,Report Change as
SNMPv2-SMI::enterprises.1872.2.5.1.2.8.1.0,TotalMem,int(value),,,,,
SNMPv2-SMI::enterprises.1872.2.5.1.2.8.3.0,FreeMem,int(value),,,,,
,warnPercent,70,%,,,,
,critPercent,90,%,,,,
,UsedMem,"values['TotalMem'] - values['FreeMem']",,,,,
,Memory Usage,"round( 100.0 * values['UsedMem'] / values['TotalMem'],2)",%,value > values['warnPercent'],value > values['critPercent'],True,
```

```text
lb-alteon-any.csv: Memory Usage: 40.06%

Key          ! Value    ! State
-------------+----------+-------
TotalMem     ! 65835992 ! [OK]
FreeMem      ! 39465220 ! [OK]
warnPercent  ! 70%      ! [OK]
critPercent  ! 90%      ! [OK]
UsedMem      ! 26370772 ! [OK]
Memory Usage ! 40.06%   ! [OK]
```


## Installation

Install `snmpget`:

```bash
# on RHEL:
yum -y install net-snmp-utils

# on Debian:
apt -y install snmp snmp-mibs-downloader
```


## Plugin Directory Structure

```text
/usr/lib64/nagios/plugins/
├── device-mibs
│   ├── printer-...
│   ├── ...
│   └── switch-...
└── device-oids
```


## Handling MIBs

If needed, get any MIB files ready. Copy them to `$HOME/.snmp/mibs` or `/usr/share/snmp/mibs`. If you prefer other locations, provide the paths using the `--mib-dir` parameter (same syntax as the `-M` parameter of `snmpget`). The check comes with some predefined, device-dependent MIBs located at `/usr/lib64/nagios/plugins/device-mibs/`.

Create an OID list in `/usr/lib64/nagios/plugins/device-oids/...` using CSV format. For details, have a look at "Defining a Device" within this document.


## Defining a Device via CSV file

If you want to define a device-specific list of OIDs, including any calculations, warning and critical thresholds, create a CSV file located at `device-oids`, using `,` as delimiter and `"` as quoting character. A minimal example for nearly any device:

| OID | Name | Re-Calc | Unit Label | WARN | CRIT | Show in 1st Line | Report Change as | Ignore in Perfdata | Perfdata Alert Thresholds | Skip Output |
|----|----|----|----|----|----|----|----|----|----|----|
| SNMPv2-MIB::sysName.0 | Name |  |  |  |  |  |  |  |  |  |
| SNMPv2-MIB::sysLocation.0 | Location |  |  |  |  |  | WARN |  |  | True |
| SNMPv2-MIB::sysUpTime.0 | Uptime | int(value) / 100 \* 24\*3600 | s | value \> 6\*30 | value \> 2\*365 | True |  |  | "3\*30,None" |  |

The columns in detail:

* **OID:**
   String. The Object-Identifier from any of your MIB files.

* **Name:**
   String. If provided, the check prints this instead of the OID.

* **Re-Calc:**
   Python code, or empty. Feel free to use any Python code based on the variables `value` and `values`, which contain the result (always a string) of the SNMPGET operation on the given OID.

* **Unit:**
   String, or empty. This is the "Unit of Measurement", case-insensitive. One of:

    * s - seconds (also us, ms)
    * % - percentage
    * B - bytes (also KB, MB, TB, ...)
    * bps - bits per second (also Kbps, Mbps, ...)
    * c - a continuous counter (such as bytes transmitted on an interface)

  If you provide two comma-separated units, for example "b,c", the first one will be used to display a human-readable format ("Bytes"), and the second one is used to suffix the perfdata ("continuous counter").
  For output, the following units will always be converted to a human-friendly format:

    * s - seconds
    * b - bytes
    * bps - bits per second

* **WARN:**
   Python condition, or empty. The warning condition for the re-calculated or raw `value`.

* **CRIT:**
   Python condition, or empty. The critical condition for the re-calculated or raw `value`.

* **Show in first line:**
   Bool, either "False", "True", or empty. Should `value` be printed in the first line of the check output?

* **Report Change as:**
   String, either "WARN", "CRIT", or empty. Should a change of `value` be reported as `WARN` or `CRIT`? The check stores the initial values on the first run in `$TEMP/linuxfabrik-monitoring-plugins-snmp.db`.

* **Ignore in Perfdata:**
   Bool, either "False", "True", or empty. By default, all numeric values are automatically returned as perfdata objects. Set to `True` to exclude this item from the perfdata list.

* **Perfdata Alert Thresholds:**
   Python tuple. Add warning and critical thresholds to performance data by defining a valid Python tuple - first element for warning, second one for critical. Use double quotes around the tuple because the comma is the separator between the fields. Normally, the values of WARN and CRIT should be repeated here so that the actual thresholds used are written to the performance data.

* **Skip Output:**
   Bool, either "False", "True", or empty. Should this row be included in the resulting table output? Set this to "True" if you only need the row for calculations.


## Calculating and Comparing using `value` and `values`

`value` contains the value of the *current* OID, simply and always as a Python string. `values` is a Python dictionary containing all *re-calculated* (or raw) values, up to this point. The dictionary keys are based on the "Name". If "Name" is not set, the dictionary keys are based on the "OID".

The `value` returned by `snmpget` for a given *OID* is always a string. If you want to use it for calculations or integer-based comparisons, re-calculate it by specifying `int(value)` in the column (SNMP knows nothing about floats).

Both variables are allowed to be used in Python code in the columns "Re-Calc", "WARN" and "CRIT". This enables you to even warn in the current OID depending on previous values, for example.

In the last three lines of this example we simply calculate "NIC.1 Traffic" as a sum of "NIC.1 rx" and "NIC.1 tx", for which there is no SNMP OID:

| OID | Name | Re-Calc | Unit Label | WARN | ... |
|----|----|----|----|----|----|
| SNMPv2-MIB::sysUpTime.0 | Uptime | int(value) / 100 | s | value \> 4\*365\*24\*3600 |  |
| IF-MIB::ifSpeed.1 | NIC.1 Speed | int(value) | bps |  |  |
| IF-MIB::ifOperStatus.1 | NIC.1 Status |  |  |  |  |
| IF-MIB::ifOutOctets.1 | NIC.1 tx | int(value) | b,c |  |  |
| IF-MIB::ifInOctets.1 | NIC.1 rx | int(value) | b,c |  |  |
| \<leave this empty\> | NIC.1 Traffic | values\['NIC.1 tx'\] + values\['NIC.1 rx'\] | b,c |  |  |


## Parameter Mapping `snmpget` vs. this Plugin

| `snmpget`       | This check                                               |
|-----------------|----------------------------------------------------------|
| `-v 1|2c|3`     | `--snmp-version {1,2c,3}`                                 |
| `-c COMMUNITY`  | `--community COMMUNITY`                                  |
| `-a PROTOCOL`   | `--v3-auth-prot {MD5,SHA,SHA-224,SHA-256,SHA-384,SHA-512}` |
| `-A PASSPHRASE` | `--v3-auth-prot-password V3AUTHPROTPASSWORD`                |
| `-e ENGINE-ID`  | `--v3-security-engine-id V3SECURITYENGINEID`                |
| `-E ENGINE-ID`  | `--v3-context-engine-id V3CONTEXTENGINEID`                  |
| `-l LEVEL`      | `--v3-level {noAuthNoPriv,authNoPriv,authPriv}`           |
| `-n CONTEXT`    | `--v3-context V3CONTEXT`                                  |
| `-u USER-NAME`  | `--v3-username V3USERNAME`                                |
| `-x PROTOCOL`   | `--v3-priv-prot {DES,AES,AES-192,AES-256}`                 |
| `-X PASSPHRASE` | `--v3-priv-prot-password V3PRIVPROTPASSWORD`                |
| `-Z BOOTS,TIME` | `--v3-boots-time V3BOOTSTIME`                              |
| `-r RETRIES`    | hard-coded to `0`                                        |
| `-t TIMEOUT`    | `-t TIMEOUT`, `--timeout TIMEOUT`                        |
| `-m MIB[:...]`  | `--mib MIB`                                              |
| `-M DIR[:...]`  | `--mib-dir MIBDIR`                                       |


## How to fetch a list of OIDs

Example:

```bash
snmpbulkwalk -v2c \
    -c public \
    -OSt \
    -M +/usr/lib64/nagios/plugins/device-mibs/switch-netgear-xs716t \
    10.80.32.141 NETGEAR-SWITCHING-MIB::agentInfoGroup
```


## States

* OK, WARN, CRIT, or UNKNOWN depending on the OID definitions in the CSV file.
* UNKNOWN if an OID returns "No Such Instance" or "No Such Object".
* UNKNOWN if a Re-Calc expression fails.


## Perfdata / Metrics

By default, all numeric values are automatically returned as perfdata objects. Use the "Ignore in Perfdata" CSV column to exclude specific items.


## Troubleshooting

`IndexError: list index out of range`  
Something is wrong with your CSV file format. Try editing it in LibreOffice Calc, for example, to get the right amount of commas, quotes, etc.

`Too many object identifiers specified. Only 128 allowed in one request.`  
Probably your SNMP v3 parameters are incomplete or incorrect.

`add_mibdir: strings scanned in from .snmp/mibs/.index are too large. count = ...`  
There seems to be a malformed, a duplicated MIB file or one with spaces in its filename within one of your MIB directories.

`Error in packet. Reason: (tooBig) Response message would have been too large.`  
A "tooBig" response simply means that the SNMP agent tried to generate a response with all requested OIDs, but the response grew too big for its buffer, resulting in this error message. The check already limits requests to a maximum of 25 OIDs each.

`Within Icinga, if I acknowledge a value change in WARN or CRIT state, does the plugin return OK?`  
If you acknowledge a value change in Icinga, the desired WARN or CRIT state remains, because SNMP is mostly run against hardware and you have to check what triggered the change. If everything is fine, delete `$TEMP/linuxfabrik-monitoring-plugins-snmp.db`. On the next run, the plugin will recreate the inventory.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
