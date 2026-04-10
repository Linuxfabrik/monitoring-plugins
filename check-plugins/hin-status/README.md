# Check hin-status


## Overview

Monitors the HIN (Health Info Net) status page for service disruptions. Parses the support website for outage announcements since no machine-readable API is available. Alerts when active incidents are detected.

**Important Notes:**

* Since no machine-readable API is available, the check relies on parsing WordPress-generated HTML content. Changes to the HIN website structure may break parsing.

**Data Collection:**

* Fetches the HIN status page (<https://support.hin.ch/de/> by default) and parses the HTML for outage announcements
* Looks for the `hin-status-block-status is-ok` CSS class to determine if all services are operational
* If not found, extracts individual incident descriptions from the status block


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/hin-status> |
| Nagios/Icinga Check Name              | `check_hin_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `beautifulsoup4` |


## Help

```text
usage: hin-status [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                  [--test TEST] [--timeout TIMEOUT] [--url URL]

Monitors the HIN (Health Info Net) status page for service disruptions. Parses
the support website for outage announcements since no machine-readable API is
available. Alerts when active incidents are detected.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                     stderr-file,expected-retc".
  --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
  --url URL          HIN Status Page URL. Default: https://support.hin.ch/de/
```


## Usage Examples

```bash
./hin-status
```

Output (all services operational):

```text
Everything is ok.
```

Output (incident detected):

```text
Incidents: Stoerung beim Einlesen von Krankenkassenkarten. See https://support.hin.ch/de/ for details.
```


## States

* OK if no outage announcements are found on the HIN status page.
* WARN if active incidents are detected.
* UNKNOWN if the HTML page cannot be parsed.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cnt_incidents | Number | 1 if incidents are found, 0 otherwise. |


## Troubleshooting

`Python module "BeautifulSoup4" is not installed.`  
Install `beautifulsoup4`: `pip install beautifulsoup4` or `dnf install python3-beautifulsoup4`.

`Cannot parse html at <url>`  
The structure of the HIN status page may have changed. Check the URL manually and report the issue.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
