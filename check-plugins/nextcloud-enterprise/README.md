# Check nextcloud-enterprise

## Overview

This monitoring plugin provides information about an installed Nextcloud Enterprise subscription.

The line 'Subscr.: 300 users, Limit: 180 users' means that you have a subscription for a maximum of 300 users, but have set a limit of 180 users using the command `sudo -u apache /var/www/html/nextcloud/occ config:app:set support user-limit --value=180`. If you haven't set this kind of user limit, the line would be printed as 'Subscr.: 300 users, Limit: not set'.

Hints:

* This plugin does not currently raise any alerts.
* Passwordless or otherwise configured sudo permissions are required for the UID under which the Nextcloud application is running.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-enterprise> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: nextcloud-enterprise [-h] [-V] [--path PATH]

Provides information about an installed Nextcloud Enterprise subscription.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
  --path PATH    Local path to your Nextcloud installation, typically within
                 your Webserver's Document Root. Default:
                 /var/www/html/nextcloud
```


## Usage Examples

```bash
./nextcloud-version --path=/var/www/html/nextcloud
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
| user_limit | Number | Number of users set by `config:app:set support user-limit` |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
