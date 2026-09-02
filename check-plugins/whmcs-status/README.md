# Check whmcs-status


## Overview

Monitors the health status of a WHMCS (Web Host Manager Complete Solution) installation via its system status API, the [GetHealthStatus API endpoint](https://developers.whmcs.com/api-reference/gethealthstatus/), which reports on the WHMCS version, the PHP and database environment, cron runs, file permissions and TLS. Alerts when WHMCS reports a check as more than a notice, and when it answers without any health checks at all. Messages are sorted by severity, worst first.

**Important Notes:**

WHMCS grants an API role only the actions it is configured for. A role without the `GetHealthStatus` action still authenticates, and WHMCS answers `success` with no health checks in it. The plugin reports that as UNKNOWN rather than as a healthy installation, because it has not seen a single check.

The message bodies are HTML in WHMCS, including the links inside them. The plugin renders them as plain text, so a phrase such as "see our documentation" loses the address it pointed at. Look the check up on the System Health Status page of the WHMCS admin area to get the link.

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


**Data Collection:**

* Queries the WHMCS API at `<url>/includes/api.php` using the `GetHealthStatus` action
* Authenticates via WHMCS API identifier and secret (`--identifier`, `--secret`)
* Supports optional HTTP Basic Authentication (`--username`, `--password`)
* Reports every check WHMCS grades above a notice, so an installation with nothing to report prints a single line


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/whmcs-status> |
| Nagios/Icinga Check Name              | `check_whmcs_status` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No (`--identifier`, `--secret` and `--url` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |


## Help

```text
usage: whmcs-status [-h] [-V] [--always-ok] --identifier IDENTIFIER
                    [--insecure] [--no-perfdata] [--no-proxy] [-p PASSWORD]
                    [--proxy PROXY] --secret SECRET [--timeout TIMEOUT]
                    --url URL [--username USERNAME]

Monitors the health status of a WHMCS installation via its system status API,
which reports on the WHMCS version, the PHP and database environment, cron
runs, file permissions and TLS. Alerts when WHMCS reports a check as more than
a notice, and when it answers without any health checks at all.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --identifier IDENTIFIER
                        WHMCS API identifier.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  -p, --password PASSWORD
                        HTTP Basic Auth password.
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --secret SECRET       WHMCS API secret.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Base URL of the WHMCS installation, without the
                        trailing `/includes/api.php`. Example:
                        `--url=https://whmcs.example.com`
  --username USERNAME   HTTP Basic Auth username.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/whmcs-status/
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
* WHMCS: We have detected that your WHMCS installation is currently using the default template names for one or more of the active templates. If you have made any customisations, we strongly recommend creating a custom template directory to avoid losing your customisations the next time you upgrade. You are currently using a default template in the following locations: *Cart*. Please review our documentation on making a custom theme for help doing this. (warning) [WARNING]
* PHP: Your PHP version *8.1.31* is supported by WHMCS. Your PHP version does not receive regular updates but is the latest supported by WHMCS. (info)
```

An installation with nothing above a notice:

```bash
./whmcs-status --identifier=myidentifier --secret=linuxfabrik --url=https://whmcs.example.com
```

Output:

```text
Everything is ok.
```


## States

* OK if WHMCS graded every one of its health checks as a notice, or as an "info" message.
* WARN if any health check carries a severity other than "notice" and "info". WHMCS uses "warning" and "error" for those. A severity WHMCS introduces later is treated the same way and listed above the known ones, because the plugin cannot judge how bad it is.
* UNKNOWN if the API refuses the request, if it answers with something other than JSON, or if it answers successfully but with no health check in it. The last case is what an API role without the `GetHealthStatus` action produces, and it is reported rather than passed off as a healthy installation.
* `--always-ok` turns the WARN above into OK. It does not cover the UNKNOWN cases, which leave before a state is evaluated.


## Perfdata / Metrics

There is no perfdata.


## Troubleshooting

### `The WHMCS API refused the request`

WHMCS states the reason itself and the plugin passes it on. Three things produce this: the identifier and secret do not match an API credential, the admin user behind that credential lost its `API Access` permission, or the calling host is missing from *Setup > General Settings > Security > API IP Access Restriction*. The Overview above sets up all three.

### `WHMCS answered, but the answer holds no health check`

The credential authenticated, but the API role behind it does not allow the `GetHealthStatus` action, so WHMCS returns a successful but empty answer. Open `configapicredentials.php` in the admin area, edit the API role the credential uses, and grant `Servers > GetHealthStatus` as described in the Overview above.

### The same message keeps the check at WARNING forever

WHMCS reports things an operator can legitimately decide to live with, for example the use of default template names. The plugin has no filter for individual checks, so the way to silence one is to resolve it in WHMCS or to acknowledge the service.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
