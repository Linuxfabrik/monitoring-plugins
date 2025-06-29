# Check openstack-nova-list

## Overview

Nova is the OpenStack project that provides a way to provision compute instances (aka virtual servers). This monitoring plugin lists all virtual servers and checks their status.

You have to provide a path to an rc file to authenticate. A working rc file might look like this:

```text
export OS_AUTH_URL=https://linuxfabrik.cloud/identity/v3
export OS_IDENTITY_API_VERSION=3
export OS_INTERFACE=public
export OS_PROJECT_DOMAIN_NAME=default
export OS_PROJECT_ID=492a82d9-003a-4f52-8891-406eb19d0573
export OS_PROJECT_NAME=MYPROJECT
export OS_REGION_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_USERNAME=MYUSER
OS_PASSWORD='linuxfabrik'
export OS_PASSWORD
```


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openstack-nova-list> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `python-novaclient` |


## Help

```text
usage: openstack-nova-list [-h] [-V] [--always-ok] [--rc-file RC_FILE]

Nova is the OpenStack project that provides a way to provision compute
instances (aka virtual servers). This monitoring plugin lists all virtual
servers and checks their status.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --rc-file RC_FILE  Specifies a rc file to read connection parameters like
                     OS_USERNAME from (instead of specifying them on the
                     command line), for example
                     `/var/spool/icinga2/.openstack.cnf`. Default:
                     /var/spool/icinga2/.openstack.cnf
```


## Usage Examples

```bash
openstack-nova-list --rc-file /var/spool/icinga2/rc/.openstack-myproject.rc
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

* Alerts when a VM returns a status other than ACTIVE, MIGRATING, REBOOT, SHELVED, SHELVED_OFFLOADED, SHUTOFF, SUSPENDED.


## Perfdata / Metrics

| Name              | Type   | Description                 |
|-------------------|--------|-----------------------------|
| total             | Number | Number of total VMs         |
| ACTIVE            | Number | Number of VMs in this state |
| BUILD             | Number | Number of VMs in this state |
| DELETED           | Number | Number of VMs in this state |
| ERROR             | Number | Number of VMs in this state |
| HARD_REBOOT       | Number | Number of VMs in this state |
| MIGRATING         | Number | Number of VMs in this state |
| PASSWORD          | Number | Number of VMs in this state |
| PAUSED            | Number | Number of VMs in this state |
| REBOOT            | Number | Number of VMs in this state |
| REBUILD           | Number | Number of VMs in this state |
| RESCUE            | Number | Number of VMs in this state |
| RESIZE            | Number | Number of VMs in this state |
| REVERT_RESIZE     | Number | Number of VMs in this state |
| SHELVED           | Number | Number of VMs in this state |
| SHELVED_OFFLOADED | Number | Number of VMs in this state |
| SHUTOFF           | Number | Number of VMs in this state |
| SOFT_DELETED      | Number | Number of VMs in this state |
| SUSPENDED         | Number | Number of VMs in this state |
| UNKNOWN           | Number | Number of VMs in this state |
| VERIFY_RESIZE     | Number | Number of VMs in this state |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
