# Check dmesg


## Overview

Checks the kernel ring buffer (dmesg) for messages at severity levels emerg, alert, crit, and err. Known false positives and hardware-specific noise are filtered out by default. Optionally integrates with Icinga: when the service is acknowledged, the reported messages are suppressed on following runs so they don't re-alert, which makes a login and "dmesg --clear" on the host unnecessary. Requires root or sudo.

**Important Notes:**

* The reported timestamps may be inaccurate. The time source used for dmesg is not updated after system SUSPEND/RESUME. Timestamps are adjusted according to the current delta between boottime and monotonic clocks, which only works for messages printed after the last resume
* The kernel ring buffer is a fixed-size circular buffer. Over time, newer messages overwrite older ones, so errors that have been resolved and whose messages have been overwritten will no longer be reported
* Without `--icinga-callback`, a reported message keeps alerting until it is overwritten in the ring buffer or the buffer is cleared with `dmesg --clear`
* When using `--icinga-callback`, the parameters `--icinga-url`, `--icinga-password`, `--icinga-username`, and `--icinga-service-name` are all required. Create an Icinga API user like so:

```text
object ApiUser "linuxfabrik-check-dmesg" {
  password = "linuxfabrik"
  permissions = [
  {
    permission = "objects/query/service"
  }]
}
```

* An acknowledged message is recognized by its full text including the timestamp dmesg prints for it. After a SUSPEND/RESUME, dmesg renders those timestamps differently, so already acknowledged messages can show up once more and have to be acknowledged again

**Data Collection:**

* Executes `dmesg --level=emerg,alert,crit,err --ctime` to read the kernel ring buffer
* Known false positives are filtered out by default, including common harmless messages such as "Assuming drive cache: write through", "ioctl error in smb2_get_dfs_refer rc=-5", "shpchp pci_hp_register failed with error -16" on virtualized hosts, and various KVM/EFI/SMBus messages. The bundled default ignore list is annotated inline with the rationale and reference URLs for each entry, so it can be re-evaluated as the plugin matures
* Additional messages can be excluded using the `--ignore` parameter, which accepts Python regular expressions and may be specified multiple times. Once `--ignore` is given, the user-supplied list replaces the bundled default ignore list, so admins can curate their own catalogue without inheriting the defaults
* If more than 10 error lines are found, the output is shortened to the first 5 and last 5 lines
* With `--icinga-callback`: when the service is acknowledged in Icinga, the currently reported kernel messages are persisted to a SQLite state DB as "already handled". On following runs, these messages are filtered out of the dmesg output so they do not re-alert, and the plugin reports how many messages it suppressed. Each ignore list gets its own state DB, keyed by a short hash over it. Ack records older than 30 days are auto-pruned; by that age the message has been overwritten in the ring buffer anyway


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dmesg> |
| Nagios/Icinga Check Name              | `check_dmesg` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-dmesg-<hash>.db` (only with `--icinga-callback`; one DB per ignore list) |


## Help

```text
usage: dmesg [-h] [-V] [--always-ok] [--icinga-callback]
             [--icinga-password ICINGA_PASSWORD]
             [--icinga-service-name ICINGA_SERVICE_NAME]
             [--icinga-url ICINGA_URL] [--icinga-username ICINGA_USERNAME]
             [--ignore IGNORE] [--insecure] [--no-perfdata] [--no-proxy]
             [--timeout TIMEOUT]

Checks the kernel ring buffer (dmesg) for messages at severity levels emerg,
alert, crit, and err. Known false positives and hardware-specific noise are
filtered out by default; the filtered count is reported as the `errors`
perfdata so trends can be graphed. Optionally integrates with Icinga: when the
service is acknowledged, the reported messages are suppressed on following
runs so they don't re-alert, which makes a login and "dmesg --clear" on the
host unnecessary. Note: the kernel ring buffer is a fixed-size circular
buffer, so older messages are overwritten over time, and timestamps may drift
across SUSPEND/RESUME because the time source is not updated on resume.
Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --icinga-callback     Get the service acknowledgement from Icinga. When the
                        service is acknowledged, the currently reported kernel
                        messages are persisted as "already handled" so they no
                        longer trigger alerts on following runs. Default:
                        False
  --icinga-password ICINGA_PASSWORD
                        Icinga API password.
  --icinga-service-name ICINGA_SERVICE_NAME
                        Unique name of the service using this check within
                        Icinga. Take it from the `__name` service attribute.
                        Example: `icinga-server!my-service-name`.
  --icinga-url ICINGA_URL
                        Icinga API URL. Example: `https://icinga-server:5665`.
  --icinga-username ICINGA_USERNAME
                        Icinga API username.
  --ignore IGNORE       Ignore a kernel message matching this Python regular
                        expression. Can be specified multiple times.
                        Specifying this parameter replaces the bundled default
                        ignore list. Example: `--ignore="^.* unhandled
                        (rd|wr)msr: "`.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --timeout TIMEOUT     Network timeout in seconds. Default: 5 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/dmesg/
```


## Usage Examples

Run with the bundled defaults:

```bash
./dmesg
```

Add a regex to suppress noisy ACPI EC method-abort messages on top of the defaults:

```bash
./dmesg --ignore="ACPI Error: Aborting method"
```

Note: specifying `--ignore` replaces the bundled defaults. To keep the defaults plus an extra pattern, repeat the bundled patterns or wrap them in a single broader regex such as `--ignore="(unhandled (rd|wr)msr: |EFI MOKvar)"`.

Sample output on a host with real errors:

```text
5 errors in Kernel Ring Buffer.

[Mon May 31 18:27:14 2021] x86/cpu: SGX disabled by BIOS
[Sat Jun  5 18:49:50 2021] ACPI Error: Thread 2495397888 cannot release Mutex [ECMX] acquired by thread 1817575424 (20210105/exmutex-378)
[Sat Jun  5 18:49:50 2021] ACPI Error: Aborting method \_SB.PCI0.LPCB.ECDV._Q66 due to previous error (AE_AML_NOT_OWNER) (20210105/psparse-529)
[Tue Jun  8 18:54:41 2021] usb usb2-port1: Cannot enable. Maybe the USB cable is bad?
[Tue Jun  8 18:54:41 2021] usb usb2-port1: unable to enumerate USB device|'errors'=5;;;0
```

Report kernel messages with Icinga acknowledgement support. After the admin acknowledges the service in Icinga, the reported messages are persisted as "already handled" and no longer re-alert on following runs, so there is no need to log in and run `dmesg --clear`:

```bash
./dmesg --icinga-callback --icinga-url=https://icinga.example.com:5665 --icinga-username=linuxfabrik-check-dmesg --icinga-password=linuxfabrik --icinga-service-name='monitoring-host!dmesg'
```

Output once the previously reported messages have been acknowledged:

```text
Everything is ok. 5 acknowledged messages suppressed.|'errors'=0;;;0
```


## States

* OK if no emerg, alert, crit, or err messages are found in the kernel ring buffer (after filtering).
* OK if all messages found have already been acknowledged via `--icinga-callback` on a previous run.
* CRIT if any such messages are found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name     | Description                                                |
|----------|------------------------------------------------------------|
| `errors` | Number of reported error lines found in the ring buffer, after applying the ignore list and, with `--icinga-callback`, the acknowledged messages. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
