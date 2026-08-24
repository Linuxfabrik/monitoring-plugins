# Check nextcloud-stats


## Overview

Monitors Nextcloud usage statistics via the server info API, including active user counts over time, file shares by category, and storage metrics. Also reports PHP, database, and web server configuration details. Optionally lists the accounts consuming the most storage via `--top`, to identify who fills up the data directory. The listing is informative only: it never changes the state of the check and produces no performance data.

**Important Notes:**

* Tested with Nextcloud 15+
* This plugin always returns OK and is purely informational
* To access the serverinfo API you need credentials of an admin user. It is recommended to create an app password (in "Devices & sessions" at `https://cloud.example.com/index.php/settings/user/security`) or a separate user.
* If you simply want to check the availability of the Nextcloud web frontend, you have to use other checks
* If a Nextcloud App leads to a "500 Internal Server Error", the Nextcloud API often still remains intact, so this check cannot report that
* Might take up to 30 seconds for the first time; after that, still takes a few seconds
* `--top` queries a second endpoint whose runtime grows with the number of accounts on the instance. On a test instance with 1206 accounts one run took about three seconds. Budget roughly three milliseconds per account, and raise `--top-timeout` together with the timeout the monitoring agent grants the check if your instance is larger
* The first run after a batch of accounts was created (a directory sync, a migration) is far slower, because Nextcloud materialises the home directory of every account that does not have one yet while answering. Budget about 110 milliseconds per such account for that one run: on a test instance, 1000 freshly created accounts took 85 seconds. Answering the request also creates those home directories on disk, so with `--top` enabled this check writes to the monitored system. Set `--top=0` if that is not acceptable
* The usage reported per account is the account's own home storage. Group folders and shares received from others are not counted towards it

**Data Collection:**

* Queries the Nextcloud serverinfo API endpoint (`/ocs/v2.php/apps/serverinfo/api/v1/info`) using HTTP Basic authentication
* Reports active users (last 5 minutes, 1 hour, 24 hours), total files, apps, shares (by type), storage distribution, PHP settings, database type/size, and web server/memcache configuration
* Optional top-N accounts by storage usage (`--top`, default: 5), read from the account listing endpoint (`/ocs/v2.php/cloud/users/details`) below the same installation root as `--url`. The endpoint cannot sort or filter, so the plugin reads all accounts and ranks them itself. Accounts with a quota limit are shown with the share of it they use; accounts without a limit are shown with their usage alone


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-stats> |
| Nagios/Icinga Check Name              | `check_nextcloud_stats` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No (`--password` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | Nextcloud App 'serverinfo' |


## Help

```text
usage: nextcloud-stats [-h] [-V] [--always-ok] [--insecure] [--no-perfdata]
                       [--no-proxy] --password PASSWORD [--timeout TIMEOUT]
                       [--top TOP] [--top-timeout TOP_TIMEOUT] [--url URL]
                       [--username USERNAME]

Monitors Nextcloud usage statistics via the server info API, including active
user counts over time, file shares by category, and storage metrics.
Optionally lists the accounts consuming the most storage via --top, to
identify who fills up the data directory. The listing is informative only: it
never changes the state of the check and produces no performance data.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Password for authenticating against the Nextcloud API.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --top TOP             Number of top storage-consuming accounts to list. Use
                        `--top=0` to disable. Default: 5
  --top-timeout TOP_TIMEOUT
                        Network timeout in seconds for fetching the account
                        list used by `--top`. Runs much longer than the
                        timeout of the other requests, because the endpoint
                        answers slower the more accounts the instance has.
                        Keep it below the timeout the monitoring agent grants
                        the check. Default: 240 (seconds)
  --url URL             Nextcloud server info API URL. Default: http://localho
                        st/nextcloud/ocs/v2.php/apps/serverinfo/api/v1/info
  --username USERNAME   Username for authenticating against the Nextcloud API.
                        Default: admin

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-stats/
```


## Usage Examples

```bash
./nextcloud-stats --username=nextcloud-stats --password=linuxfabrik --url=http://localhost/nextcloud/ocs/v2.php/apps/serverinfo/api/v1/info
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

Top 5 accounts by storage usage:
1. jdoe: 109.7MiB of 5.0GiB (2.1%)
2. asmith: 79.7MiB of 1.0GiB (7.8%)
3. mmueller: 64.7MiB of 500.0MiB (12.9%)
4. admin: 59.7MiB
5. jbrown: 0.0B
```

Without the account listing, which skips the second endpoint entirely:

```bash
./nextcloud-stats --username=nextcloud-stats --password=linuxfabrik --top=0
```


## States

* Always returns OK.
* An account listing that fails or names nobody does not change that. The check reports the server info numbers as usual and states in place of the listing why it is missing.


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

### Unknown error while fetching the API endpoint

`Unknown error while fetching http://localhost/nextcloud/ocs/v2.php/apps/serverinfo/api/v1/info?format=json, maybe timeout or error on webserver`

Check the Nextcloud API endpoint URL. Maybe change from http(s)://localhost to http(s)://127.0.0.1.

### HTTP 401 Unauthorized

`HTTP error "401 Unauthorized" while fetching http://...`

Password is correct? Maybe you enabled 2FA. Use an app password for your monitoring server.

### The account listing is reported as unavailable

`Top 5 accounts by storage usage: unavailable, URL error "timed out" for http://...`

The account listing did not answer within `--top-timeout`. The endpoint gets slower the more accounts the instance has, and it is slowest on the first run after a batch of accounts was created, because it materialises their home directories while answering. Let that run finish once with a raised `--top-timeout`, or set `--top=0` if the listing is not worth the runtime. Whatever value you pick has to stay below the timeout the monitoring agent grants the check, otherwise the agent kills the plugin before it can report anything.

### The account listing reports nobody

`Top 5 accounts by storage usage: none reported, check that nextcloud-stats may list accounts.`

The account listing answered, but named no account. It only returns accounts the user behind `--username` is allowed to see, which requires an administrator, a delegated administrator or a group administrator. Give the monitoring account one of those roles, or set `--top=0`.

### `Failed to execute script 'nextcloud-stats' due to unhandled exception!`

Use a newer version of this plugin.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: Inspired by: <https://github.com/BornToBeRoot/check_nextcloud>
