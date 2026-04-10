# Check infomaniak-swiss-backup-devices


## Overview

Checks each backup device (slot) across all Infomaniak Swiss Backup products via the Infomaniak API. Alerts when storage usage exceeds the configured thresholds or when a device reports an error state. Devices can be filtered by customer, name, tag, or user.

**Important Notes:**

* Works with the Infomaniak Swiss Backup API v1
* The check may take 10 seconds or more. Increasing the runtime timeout to 30 seconds is recommended.
* You may retrieve usage values while Infomaniak's API is still compiling the usage statistic. This can cause a temporary drop in reported usage that returns to normal on the next check run.

* Links:

    * Swiss Backup: <https://www.infomaniak.com/en/swiss-backup>
    * API Documentation: <https://developer.infomaniak.com/docs/api/get/1/swiss_backups>
    * API Tokens: <https://manager.infomaniak.com/v3/$ACCOUNT_ID/ng/accounts/token>


**Data Collection:**

* Queries the Infomaniak API for all Swiss Backup products and their device slots
* Requires a Bearer Token with scope "swiss-backup" from Infomaniak
* Output table is sorted by the "Tags" column


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/infomaniak-swiss-backup-devices> |
| Nagios/Icinga Check Name              | `check_infomaniak_swiss_backup_devices` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | No (`--account-id` and `--token` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: infomaniak-swiss-backup-devices [-h] [-V] --account-id ACCOUNT_ID
                                       [--always-ok] [-c CRIT] [--insecure]
                                       [--no-proxy]
                                       [--ignore-customer IGNORE_CUSTOMER]
                                       [--ignore-name IGNORE_NAME]
                                       [--ignore-tag IGNORE_TAG]
                                       [--ignore-user IGNORE_USER]
                                       [--severity {warn,crit}]
                                       [--timeout TIMEOUT] --token TOKEN
                                       [--test TEST] [-w WARN]

Checks each backup device (slot) across all Infomaniak Swiss Backup products
via the Infomaniak API. Alerts when storage usage exceeds the configured
thresholds or when a device reports an error state. Devices can be filtered by
customer, name, tag, or user.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --account-id ACCOUNT_ID
                        Infomaniak account ID.
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold in percent. Default: >= 95
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --ignore-customer IGNORE_CUSTOMER
                        Any device whose product customer name matches this
                        Python regex will be ignored. Can be specified
                        multiple times. Example: `--ignore-customer
                        "(?i)test"`.
  --ignore-name IGNORE_NAME
                        Any device whose name matches this Python regex will
                        be ignored. Can be specified multiple times. Example:
                        `--ignore-name "(?i)old-backup"`.
  --ignore-tag IGNORE_TAG
                        Any device whose product tag matches this Python regex
                        will be ignored. Can be specified multiple times.
                        Example: `--ignore-tag "(?i)deprecated"`.
  --ignore-user IGNORE_USER
                        Any device whose username matches this Python regex
                        will be ignored. Can be specified multiple times.
                        Example: `--ignore-user "(?i)testuser"`.
  --severity {warn,crit}
                        Severity for alerting on locked devices. Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --token TOKEN         Infomaniak API token.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  -w, --warning WARN    WARN threshold in percent. Default: >= 90
```


## Usage Examples

```bash
./infomaniak-swiss-backup-devices --token=TOKEN --account-id=200999 --warning=80 --severity=crit
```

Output:

```text
There are critical errors.

ID    ! Customer     ! Tag   ! User         ! Name   ! Type  ! Locked ! Usage Upd. ! Used                   ! Used %             
------+--------------+-------+--------------+--------+-------+--------+------------+------------------------+--------------------
99924 ! BK-200999-2  ! tag03 ! SBI-AB123456 ! prod   ! swift ! False  ! 2h 18m ago ! 13.2GiB / 139.7GiB    ! 9.4%               
99925 ! BK-200999-2  ! tag03 ! SBI-AB123456 ! test   ! swift ! False  ! 2h 18m ago ! 3.3GiB / 46.6GiB      ! 7.1%               
99946 ! BK-200999-9  ! tag90 ! SBI-AB123456 ! bucket ! swift ! False  ! 2h 18m ago ! 856.6GiB / 931.3GiB   ! 92.0% [WARNING]    
```


## States

* OK if all devices are within their usage thresholds, are not locked, and have data stored.
* WARN if a device's storage usage is >= `--warning` (default: 90%).
* WARN if a device has 0 bytes stored (no backups made).
* WARN if `--severity=warn` (default) and a device is locked.
* CRIT if a device's storage usage is >= `--critical` (default: 95%).
* CRIT if `--severity=crit` and a device is locked.
* UNKNOWN on invalid command-line arguments.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<ID\>-locked | Number | 0 = unlocked, 1 = locked. |
| \<ID\>-percent | Percentage | Storage usage in percent. |
| \<ID\>-total | Bytes | Total device size. |
| \<ID\>-usage | Bytes | Storage usage in bytes. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
