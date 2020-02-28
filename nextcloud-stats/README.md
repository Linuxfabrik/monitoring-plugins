# Check "nextcloud-stats" - Overview

This plugin lets you track if server or app updates are available, the number of active users over time, the number of shares in various categories and some storage statistics against a Nextcloud server. Might take up to 30 seconds for the first time; after that, takes approx. 1 to 2 seconds.

Hints:
* If you want to check the availability of the Nextcloud web frontend, you have to use other checks.
* If a Nextcloud App leads to a "500 Internal Server Error", the Nextcloud API often still remains intact. 
* Check uses a SQLite database in `/tmp` to store its historic data.

Tested with Nextcloud >= 15.0.4

We recommend to run this check every 15 minutes.


# Installation and Usage

```bash
./nextcloud-stats --username nextcloud-stats --password mypassword --url http://localhost/nextcloud/ocs/v2.php/apps/serverinfo/api/v1/info
./nextcloud-stats --help
```


# States

* WARN if Nextcloud or App updates are available.


# Perfdata

* nc_active_users_last5min
* nc_active_users_last1h
* nc_active_users_last24h
* nc_server_database_size
* nc_shares_num_fed_shares_received
* nc_shares_num_fed_shares_sent
* nc_shares_num_shares
* nc_shares_num_shares_groups
* nc_shares_num_shares_link
* nc_shares_num_shares_link_no_password
* nc_shares_num_shares_mail
* nc_shares_num_shares_room
* nc_shares_num_shares_user
* nc_storage_num_files
* nc_storage_num_storages
* nc_storage_num_storages_home
* nc_storage_num_storages_local
* nc_storage_num_storages_other
* nc_storage_num_users
* nc_system_apps_num_installed


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Credits:
  - Inspired by: https://github.com/BornToBeRoot/check_nextcloud