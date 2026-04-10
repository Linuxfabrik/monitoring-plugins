# Check openstack-swift-stat

## Overview

Checks OpenStack Swift object storage account statistics, including total container count, object count, and bytes used. Alerts when storage usage exceeds the configured thresholds.

**Data Collection:**

* Authenticates to the OpenStack Swift API using credentials from an rc file
* Reports account-level statistics: container count, object count, total bytes used, and account quota
* Reports per-container statistics: item count, quota, usage, and remaining free space

**Alerting Logic:**

* If a quota is set on a container, alerts when the remaining free space drops below the configured thresholds (default: 50 GiB for WARN, 10 GiB for CRIT)

**Important Notes:**

* You have to provide a path to an rc file to authenticate. The rc file should contain standard OpenStack environment variables such as `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_PROJECT_NAME`, etc.
* Requires the `python-swiftclient` and `python-keystoneclient` Python modules.
* Might take more than 10 seconds to execute depending on the number of containers.


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openstack-swift-stat> |
| Nagios/Icinga Check Name              | `check_openstack_swift_stat` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `python-swiftclient`, `python-keystoneclient` |


## Help

```text
usage: openstack-swift-stat [-h] [-V] [--always-ok] [-c CRIT]
                            [--rc-file RC_FILE] [--test TEST] [-w WARN]

Checks OpenStack Swift object storage account statistics, including total
container count, object count, and bytes used. Alerts when storage usage
exceeds the configured thresholds.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for remaining free space, in GiB.
                       Default: <= 10
  --rc-file RC_FILE    Path to a rc file containing OpenStack connection
                       parameters like OS_USERNAME (instead of specifying them
                       on the command line). Example:
                       `/var/spool/icinga2/.openstack.cnf`. Default:
                       /var/spool/icinga2/.openstack.cnf
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   WARN threshold for remaining free space, in GiB.
                       Default: <= 50
```


## Usage Examples

```bash
./openstack-swift-stat --rc-file /var/spool/icinga2/rc/.openstack-myproject.rc
```

Output:

```text
Account: 4 containers, 2.8M objects, 5.4TiB used, 90.9TiB quota

Container ! Items  ! Quota    ! Used           ! Free              
----------+--------+----------+----------------+-------------------
01        ! 2.4M   ! 0.0B     ! 2.2TiB         !                   
02        ! 324.4K ! 3.1TiB   ! 3.1TiB (99.5%) ! 17.2GiB [WARNING] 
03        ! 107.7K ! 0.0B     ! 111.8GiB       !                   
04        ! 2.0    ! 204.9GiB ! 2.0GiB (1.0%)  ! 202.9GiB          
```


## States

* OK if all containers have sufficient free space (or no quota is set).
* WARN if a container's remaining free space is <= `--warning` (default: 50 GiB).
* CRIT if a container's remaining free space is <= `--critical` (default: 10 GiB).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<container-name\>\_items | Number | Number of items in the Swift container. |
| \<container-name\>\_used | Bytes | Bytes used in the Swift container. |


## Troubleshooting

`Python module "python-swiftclient" is not installed.`  
Install `python-swiftclient`: `pip install python-swiftclient python-keystoneclient`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
