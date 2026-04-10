# Check nextcloud-enterprise


## Overview

Retrieves and displays information about an installed Nextcloud Enterprise subscription, including license status, expiration date, and supported user count. Requires root or sudo.

**Important Notes:**

* This plugin currently always returns OK and is purely informational
* The "Limit" value in the output refers to the user limit set via `occ config:app:set support user-limit --value=N`. If not set, it shows "not set".

**Data Collection:**

* Requires sudo permissions for the UID under which the Nextcloud application runs
* Runs Nextcloud `occ` commands via sudo to retrieve subscription key, last response data, and user limit configuration
* Displays subscription details including end date, level, account manager, and per-feature subscription status (groupware, talk, collabora, onlyoffice, outlook, sip_bridge)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-enterprise> |
| Nagios/Icinga Check Name              | `check_nextcloud_enterprise` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: nextcloud-enterprise [-h] [-V] [--path PATH]

Retrieves and displays information about an installed Nextcloud Enterprise
subscription, including license status, expiration date, and supported user
count. Alerts when the subscription is expired or about to expire. Requires
root or sudo.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
  --path PATH    Local path to the Nextcloud installation, typically the web
                 server document root. Default: /var/www/html/nextcloud
```


## Usage Examples

```bash
./nextcloud-enterprise --path=/var/www/html/nextcloud
```

Output:

```text
Subscr.: 300 users, Limit: 180 users, End date: 2025-11-30, Key: *****WCZA, Level: standard_1y
Subscr. Renewal: True, Count active users only: False, Hard User Limit: False, Extended Support: False, Branding: False, Branding Plus: False, Customization Service: False
Account Manager: Firstname Lastname, +49 711 252 123 45, firstname.lastname@nextcloud.com

           ! hasSubscription ! users ! endDate ! mcu   ! mcuUsers ! level
-----------+-----------------+-------+---------+-------+----------+------
groupware  ! False           !       ! None    !       !          !      
talk       ! False           ! 0     ! None    ! False ! 0        !      
collabora  ! False           ! 0     ! None    !       !          !      
onlyoffice ! False           ! 0     ! None    !       !          !      
outlook    ! False           ! 0     ! None    !       !          ! old  
sip_bridge ! False           ! 0     ! None    !       !          !
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| user_limit | Number | Number of users set by `config:app:set support user-limit`. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
