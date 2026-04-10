# Check whmcs-status

## Overview

Monitors the health status of a WHMCS (Web Host Manager Complete Solution) installation via the [GetHealthStatus API endpoint](https://developers.whmcs.com/api-reference/gethealthstatus/). Reports messages about module versions, license status, and system health indicators. Messages are sorted by severity.

**Data Collection:**

* Queries the WHMCS API at `<url>/includes/api.php` using the `GetHealthStatus` action
* Authenticates via WHMCS API identifier and secret (`--identifier`, `--secret`)
* Supports optional HTTP Basic Authentication (`--username`, `--password`)

**Important Notes:**

Configuring API access and creating an API user in WHMCS is a bit tedious. First, allow IP Addresses to connect to WHMCS:

* Open <https://whmcs.example.com/path/to/whmcs-admin/configgeneral.php#tab=10>), Tab Security
* API IP Access Restriction > Add IP of the hosts accessing the API

Then create an administrator role with "API Access":

* Open <https://whmcs.example.com/path/to/whmcs-admin/configadminroles.php>
* Add New Role Group: "API Role Group"
* Grant "API Acccess" and save changes

Create an Administrator User with Role "API Access":

* Open <https://whmcs.example.com/path/to/whmcs-admin/configadmins.php>
* Add New Administrator
* Administrator Role: API Role Group
* First Name: WHMCS
* Last Name: Monitoring
* Username: whmcs-monitoring
* Password: set a password

Create API Credentials:

* Open <https://whmcs.example.com/path/to/whmcs-admin/configapicredentials.php>

* API Roles > Create API Role:

    * Role Name: GetHealthStatus
    * Allowed API Actions: Servers > GetHealthStatus

* API Credentials > Generate New API Credential

    * Admin User: WHMCS Monitoring
    * API Role(s): GetHealthStatus

Note the api_identifier and the api_secret. You will need both to configure this plugin.



**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/whmcs-status> |
| Nagios/Icinga Check Name              | `check_whmcs_status` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No (`--identifier` and `--secret` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: whmcs-status [-h] [-V] --identifier IDENTIFIER [--insecure]
                    [--no-proxy] [-p PASSWORD] --secret SECRET [--test TEST]
                    [--timeout TIMEOUT] [--url URL] [--username USERNAME]

Monitors the health status of a WHMCS installation via its system status API.
Reports module versions, license status, and system health indicators. Alerts
when the server reports an unhealthy state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --identifier IDENTIFIER
                        WHMCS API identifier.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  -p, --password PASSWORD
                        HTTP Basic Auth password.
  --secret SECRET       WHMCS API secret.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             WHMCS API URL. Default: http://127.0.0.1:8080
  --username USERNAME   HTTP Basic Auth username.
```


## Usage Examples

```bash
./whmcs-status --identifier=myidentifier --secret=linuxfabrik --url=https://whmcs.example.com
```

Output:

```text
There are 4 messages, ordered by severity.

* WHMCS: Please upgrade to the latest version: 8.12.0 You can learn about performing an upgrade in our documentation. (error) [WARNING]
* WHMCS: Module debugging is currently enabled. We recommend that you disable this when you finish debugging. Continuous use may degrade performance. For more information, see our documentation. (warning) [WARNING]
* WHMCS: We have detected that your WHMCS installation is currently using the default template names for one or more of the active templates. If you have made any customisations, we strongly recommend creating a custom template directory to avoid losing your customisations the next time you upgrade.You are currently using a default template in the following locations: *Cart*. Please review our documentation on making a custom theme for help doing this. (warning) [WARNING]
* PHP: Your PHP version *8.1.31* is supported by WHMCS. Your PHP version does not receive regular updates but is the latest supported by WHMCS. (info)
```


## States

* OK if no health check messages with severity greater than "info" are returned.
* WARN if any health check message has severity "warning" or "error".


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
