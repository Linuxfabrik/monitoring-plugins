# Check openstack-nova-list

## Overview

Lists all OpenStack Nova compute instances (virtual servers) and checks their status. Alerts when any instance is in an error state or has been shelved. Reports instance name, status, power state, and creation date.

**Important Notes:**

* You have to provide a path to an rc file to authenticate. The rc file should contain standard OpenStack environment variables such as `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_PROJECT_NAME`, etc.
* Requires the `python-novaclient` Python module.



**Data Collection:**

* Authenticates to the OpenStack Nova API using credentials from an rc file
* Lists all virtual servers and their current status
* Reports server name, ID, last update timestamp, and status for each instance
* Counts instances per state and tracks the last status change across all servers

**Compatibility:**

* Cross-platform



## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openstack-nova-list> |
| Nagios/Icinga Check Name              | `check_openstack_nova_list` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `python-novaclient` |


## Help

```text
usage: openstack-nova-list [-h] [-V] [--always-ok] [--rc-file RC_FILE]

Lists all OpenStack Nova compute instances (virtual servers) and checks their
status. Alerts when any instance is in an error state or has been shelved.
Reports instance name, status, power state, and creation date.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --rc-file RC_FILE  Path to a rc file containing OpenStack connection
                     parameters like OS_USERNAME (instead of specifying them
                     on the command line). Example:
                     `/var/spool/icinga2/.openstack.cnf`. Default:
                     /var/spool/icinga2/.openstack.cnf
```


## Usage Examples

```bash
./openstack-nova-list --rc-file /var/spool/icinga2/rc/.openstack-myproject.rc
```

Output:

```text
2 servers checked. 1 active, 0 migrating, 1 demand verify resize, 0 in error. Last status update 2023-06-13 12:34:00 UTC (3h 6m ago).

Name              ! ID                                   ! Updated (UTC)                      ! Status                   
------------------+--------------------------------------+----------------------------------+--------------------------
first_server      ! 48f44934-2bdf-4aed-84f8-df0960689620 ! 2023-06-08 16:39:51 (3D 18h ago) ! VERIFY_RESIZE [WARNING] 
second_server     ! 38654a93-435d-40ea-bd39-64d01b186830 ! 2023-06-12 09:11:09 (2h 45s ago) ! ACTIVE
```


## States

* OK for VM states: ACTIVE, MIGRATING, REBOOT, SHELVED, SHELVED_OFFLOADED, SHUTOFF, SUSPENDED.
* WARN for VM states: BUILD, HARD_REBOOT, PAUSED, REBUILD, RESIZE, REVERT_RESIZE, SOFT_DELETED, VERIFY_RESIZE.
* CRIT for VM states: DELETED, ERROR, PASSWORD, RESCUE, UNKNOWN (and any other).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| ACTIVE | Number | Number of VMs in this state. |
| BUILD | Number | Number of VMs in this state. |
| DELETED | Number | Number of VMs in this state. |
| ERROR | Number | Number of VMs in this state. |
| HARD_REBOOT | Number | Number of VMs in this state. |
| MIGRATING | Number | Number of VMs in this state. |
| PASSWORD | Number | Number of VMs in this state. |
| PAUSED | Number | Number of VMs in this state. |
| REBOOT | Number | Number of VMs in this state. |
| REBUILD | Number | Number of VMs in this state. |
| RESCUE | Number | Number of VMs in this state. |
| RESIZE | Number | Number of VMs in this state. |
| REVERT_RESIZE | Number | Number of VMs in this state. |
| SHELVED | Number | Number of VMs in this state. |
| SHELVED_OFFLOADED | Number | Number of VMs in this state. |
| SHUTOFF | Number | Number of VMs in this state. |
| SOFT_DELETED | Number | Number of VMs in this state. |
| SUSPENDED | Number | Number of VMs in this state. |
| total | Number | Total number of VMs. |
| UNKNOWN | Number | Number of VMs in this state. |
| VERIFY_RESIZE | Number | Number of VMs in this state. |


## Troubleshooting

`Python module "python-novaclient" is not installed.`  
Install `python-novaclient`: `pip install python-novaclient`.

`An error occurred while connecting to Nova`  
Check the credentials in your rc file and verify that the OpenStack API endpoint is reachable.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
