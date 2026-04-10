# Check infomaniak-swiss-backup-products

## Overview

Checks Infomaniak Swiss Backup product details via the Infomaniak API. Alerts when products are locked, maintenance window is active, or storage quota is exceeded. Products can be filtered by customer or tag.

**Alerting Logic:**

* Alerts WARN or CRIT when a product's expiration date is within the configured threshold (in days)
* Alerts WARN (default) or CRIT (if `--severity=crit`) when a product is locked, in maintenance, or has an operation in progress
* Both `--ignore-*` filters accept Python regular expressions and can be specified multiple times

**Data Collection:**

* Queries the Infomaniak API for all Swiss Backup product details
* Requires a Bearer Token from Infomaniak
* Output table is sorted by the "Tags" column
* In the table output, the column header "Dev" means the number of devices created, "Maint." stands for "Maintenance", and "Busy" corresponds to the API field `has_operation_in_progress`

**Compatibility:**

* Works with the Infomaniak Swiss Backup API v1

**Important Notes:**

* Links:

    * Swiss Backup: <https://www.infomaniak.com/en/swiss-backup>
    * API Documentation: <https://developer.infomaniak.com/docs/api/get/1/swiss_backups>
    * API Tokens: <https://manager.infomaniak.com/v3/$ACCOUNT_ID/ng/accounts/token>


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/infomaniak-swiss-backup-products> |
| Nagios/Icinga Check Name              | `check_infomaniak_swiss_backup_products` |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | No (`--account-id` and `--token` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: infomaniak-swiss-backup-products [-h] [-V] --account-id ACCOUNT_ID
                                        [--always-ok] [-c CRIT]
                                        [--ignore-customer IGNORE_CUSTOMER]
                                        [--ignore-tag IGNORE_TAG] [--insecure]
                                        [--no-proxy] [--severity {warn,crit}]
                                        [--timeout TIMEOUT] --token TOKEN
                                        [--test TEST] [-w WARN]

Checks Infomaniak Swiss Backup product details via the Infomaniak API. Alerts
when products are locked, maintenance window is active, or storage quota is
exceeded. Products can be filtered by customer or tag.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --account-id ACCOUNT_ID
                        Infomaniak Account-ID.
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the expiration date, in days.
                        Default: 3
  --ignore-customer IGNORE_CUSTOMER
                        Any product whose customer name matches this Python
                        regex will be ignored. Can be specified multiple
                        times. Example: `--ignore-customer='(?i)test'`.
  --ignore-tag IGNORE_TAG
                        Any product whose tag matches this Python regex will
                        be ignored. Can be specified multiple times. Example:
                        `--ignore-tag='(?i)deprecated'`.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --severity {warn,crit}
                        Severity for alerting on locked, maintenance, or busy
                        products. Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --token TOKEN         Infomaniak API token.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  -w, --warning WARN    WARN threshold for the expiration date, in days.
                        Default: 5
```


## Usage Examples

```bash
./infomaniak-swiss-backup-products --token=TOKEN --account-id=200999 --warning=21 --severity=crit
```

Output:

```text
Everything is ok.

ID    ! Customer     ! Tag  ! Size (alloc/avail)  ! Dev ! Maint. ! Locked ! Busy  ! Expires in 
------+--------------+------+---------------------+-----+--------+--------+-------+------------
55577 ! BK-200999-1  ! prod ! 9.1TiB / 9.1TiB     ! 1   ! False  ! False  ! False ! 11M 2W     
55556 ! BK-200999-2  ! test ! 186.3GiB / 186.3GiB ! 2   ! False  ! False  ! False ! 10M 5D     
55558 ! BK-200999-3  ! prod ! 4.5TiB / 4.5TiB     ! 2   ! False  ! False  ! False ! 9M 4D      
55560 ! BK-200999-4  ! test ! 1.8TiB / 1.8TiB     ! 1   ! False  ! False  ! False ! 8M 3D      
```


## States

* OK if all products are within their expiration thresholds and none are locked, in maintenance, or busy.
* WARN if `--severity=warn` (default) and a product is locked, in maintenance, or has an operation in progress.
* WARN if a product expires within `--warning` (default: 5) days.
* CRIT if `--severity=crit` and a product is locked, in maintenance, or has an operation in progress.
* CRIT if a product expires within `--critical` (default: 3) days.
* UNKNOWN on invalid command-line arguments.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<ID\>-busy | Number | 0 = not busy, 1 = operation in progress. |
| \<ID\>-locked | Number | 0 = unlocked, 1 = locked. |
| \<ID\>-maintenance | Number | 0 = not in maintenance, 1 = in maintenance. |
| \<ID\>-size | Bytes | Available storage space. |
| \<ID\>-storage_reserved | Bytes | Allocated storage space. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
