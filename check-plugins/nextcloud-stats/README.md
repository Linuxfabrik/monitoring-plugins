# Check nextcloud-stats

## Overview

Monitors Nextcloud usage statistics via the server info API, including active user counts over time, file shares by category, and storage metrics. Also reports PHP, database, and web server configuration details.

**Important Notes:**

* Tested with Nextcloud 15+
* This plugin always returns OK and is purely informational
* To access the serverinfo API you need credentials of an admin user. It is recommended to create an app password (in "Devices & sessions" at `https://cloud.example.com/index.php/settings/user/security`) or a separate user.
* If you simply want to check the availability of the Nextcloud web frontend, you have to use other checks
* If a Nextcloud App leads to a "500 Internal Server Error", the Nextcloud API often still remains intact, so this check cannot report that
* Might take up to 30 seconds for the first time; after that, still takes a few seconds


**Data Collection:**

* Queries the Nextcloud serverinfo API endpoint (`/ocs/v2.php/apps/serverinfo/api/v1/info`) using HTTP Basic authentication
* Reports active users (last 5 minutes, 1 hour, 24 hours), total files, apps, shares (by type), storage distribution, PHP settings, database type/size, and web server/memcache configuration

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-stats> |
| Nagios/Icinga Check Name              | `check_nextcloud_stats` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No (`--password` is required) |
| Compiled for Windows                  | No |
| Requirements                          | Nextcloud App 'serverinfo' |


## Help

```text
usage: nextcloud-stats [-h] [-V] [--insecure] [--no-proxy] --password PASSWORD
                       [--timeout TIMEOUT] [--url URL] [--username USERNAME]

Monitors Nextcloud usage statistics via the server info API, including active
user counts over time, file shares by category, and storage metrics.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --password PASSWORD  Password for authenticating against the Nextcloud API.
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  --url URL            Nextcloud server info API URL. Default: http://localhos
                       t/nextcloud/ocs/v2.php/apps/serverinfo/api/v1/info
  --username USERNAME  Username for authenticating against the Nextcloud API.
                       Default: admin
```


## Usage Examples

```bash
./nextcloud-stats --username nextcloud-stats --password mypassword --url http://localhost/nextcloud/ocs/v2.php/apps/serverinfo/api/v1/info
```

Output:

```text
77 users (22/30/53 in the last 5min/1h/24h), 4.4M files, 75 apps (0 updates available), v27.1.3.2
* Shares: 557 (0 groups, 488 links [478 w/o password], 25 mails, 0 rooms, 23 users, 0 federated sent)
* Federated Shares: 1 received
* Storages: 144 (23 home, 120 other, 1 local)
* PHP: v8.2.13, upload_max_filesize=9.8GiB, max_execution_time=3600s, memory_limit=1.0GiB
* DB: mysql v10.6.16, size=2.9GiB
* Web: Apache, local memcache: Memcache\Redis, locking memcache: Memcache\Redis
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| nc_active_users_last1h | Number | Active users in the last hour. |
| nc_active_users_last24h | Number | Active users in the last 24 hours. |
| nc_active_users_last5min | Number | Active users in the last 5 minutes. |
| nc_server_database_size | Bytes | Database size. |
| nc_shares_num_fed_shares_received | Number | Number of received federated shares. |
| nc_shares_num_fed_shares_sent | Number | Number of sent federated shares. |
| nc_shares_num_shares | Number | Total number of shares. |
| nc_shares_num_shares_groups | Number | Number of group shares. |
| nc_shares_num_shares_link | Number | Number of link shares. |
| nc_shares_num_shares_link_no_password | Number | Number of link shares without password. |
| nc_shares_num_shares_mail | Number | Number of mail shares. |
| nc_shares_num_shares_room | Number | Number of room shares. |
| nc_shares_num_shares_user | Number | Number of user shares. |
| nc_storage_num_files | Number | Total number of files. |
| nc_storage_num_storages | Number | Total number of storages. |
| nc_storage_num_storages_home | Number | Number of home storages. |
| nc_storage_num_storages_local | Number | Number of local storages. |
| nc_storage_num_storages_other | Number | Number of other storages. |
| nc_storage_num_users | Number | Total number of users (note: this is the number of users that have ever existed, not those currently enabled). |
| nc_system_apps_num_installed | Number | Number of installed apps. |


## Troubleshooting

`Unknown error while fetching http://localhost/nextcloud/ocs/v2.php/apps/serverinfo/api/v1/info?format=json, maybe timeout or error on webserver`
Check the Nextcloud API endpoint URL. Maybe change from http(s)://localhost to http(s)://127.0.0.1.

`HTTP error "401 Unauthorized" while fetching http://...`
Password is correct? Maybe you enabled 2FA. Use an app password for your monitoring server.

`Failed to execute script 'nextcloud-stats' due to unhandled exception!`
Use a newer version of this plugin.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: Inspired by: <https://github.com/BornToBeRoot/check_nextcloud>
