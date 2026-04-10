# Check diacos


## Overview

Checks availability and response time of an [ID DIACOS](https://www.id-suisse-ag.ch/loesungen/abrechnung/id-diacos/) installation by performing a full login, diagnosis search, and logout cycle. Alerts if the total response time exceeds the configured thresholds. Useful for monitoring the health of DIACOS medical billing systems.

ID DIACOS is a coding software for accurate and fast invoicing in hospitals, allowing clinical services to be documented quickly and reliably within fee-payment systems such as G-DRG, SWISS-DRG, and EBM.

**Important Notes:**

* Runs on any platform with network access to the ID DIACOS REST API
* Plugin execution may take more than 10 seconds depending on network latency and server load
* `--login-name` and `--login-licence` are required parameters
* The session ID is validated for minimum expected length before proceeding with the search

**Data Collection:**

* Performs three sequential API calls against the ID DIACOS REST API (`/axis2/idlogikrest`):
  1. `user.Login` - authenticates with the provided licence and user name, returns a session ID
  2. `classification.SearchDiagnoses` - performs a diagnosis search using configurable parameters
  3. `user.Logoff` - terminates the session
* Measures the total runtime across all three calls
* Each API call reports its own `totalTimeMillis` from the server response


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/diacos> |
| Nagios/Icinga Check Name              | `check_diacos` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--login-name` and `--login-licence` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: diacos [-h] [-V] [--always-ok] [-c CRITICAL] [--insecure]
              [--login-computer COMPUTER] [--login-ip IP]
              --login-licence LICENCE --login-name NAME [--no-proxy]
              [--search-concept-filter CONCEPT_FILTER]
              [--search-country COUNTRY] [--search-format FORMAT]
              [--search-searchtext SEARCHTEXT] [--search-sort-mode SORT_MODE]
              [--search-year YEAR] [--test TEST] [--timeout TIMEOUT]
              [--url URL] [-w WARNING]

Checks availability and response time of an ID DIACOS installation by
performing a full login, diagnosis search, and logout cycle. Alerts if the
total response time exceeds the configured thresholds. Useful for monitoring
the health of DIACOS medical billing systems.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        CRIT threshold for the total duration of login,
                        search, and logout, in milliseconds. Default: 6000
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --login-computer COMPUTER
                        COMPUTER argument for the user.Login API call.
                        Default: Brower_APP
  --login-ip IP         IP argument for the user.Login API call. Default:
                        127.0.0.1
  --login-licence LICENCE
                        LICENCE argument for the user.Login API call
                        (required).
  --login-name NAME     NAME argument for the user.Login API call (required).
  --no-proxy            Do not use a proxy.
  --search-concept-filter CONCEPT_FILTER
                        CONCEPT_FILTER argument for the
                        classification.SearchDiagnoses API call. Default:
                        %25R239%3BC%3BD99.99
  --search-country COUNTRY
                        COUNTRY argument for the
                        classification.SearchDiagnoses API call. Default: CH
  --search-format FORMAT
                        FORMAT argument for the classification.SearchDiagnoses
                        API call. Default: %25T0%25C%3F%25I%25R
  --search-searchtext SEARCHTEXT
                        SEARCHTEXT argument for the
                        classification.SearchDiagnoses API call. Default: Haut
  --search-sort-mode SORT_MODE
                        SORT_MODE argument for the
                        classification.SearchDiagnoses API call. Default: %25T
  --search-year YEAR    YEAR argument for the classification.SearchDiagnoses
                        API call. Default: 2020
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 7 (seconds)
  --url URL             ID DIACOS base URL. Default: http://localhost:9999
  -w, --warning WARNING
                        WARN threshold for the total duration of login,
                        search, and logout, in milliseconds. Default: 3000
```


## Usage Examples

```bash
./diacos \
    --critical 6000 \
    --login-computer Brower_APP \
    --login-ip 127.0.0.1 \
    --login-licence 4b903485-1def-4f1b-a4d5-dd5464176954 \
    --login-name supervisor \
    --search-concept-filter '%25R239%3BC%3BD99.99' \
    --search-country 'CH' \
    --search-format '%25T0%25C%3F%25I%25R' \
    --search-searchtext Haut \
    --search-sort-mode '%25T' \
    --search-year 2020 \
    --timeout 7 \
    --url http://localhost:9999 \
    --warning 3000
```

Output:

```text
7368ms for login, search and logout [CRITICAL]
```


## States

* OK if the total runtime is below `--warning` (default: 3000ms).
* WARN if the total runtime is >= `--warning` (default: 3000ms).
* CRIT if the total runtime is >= `--critical` (default: 6000ms).
* UNKNOWN if the login fails, the session ID is too short, or API calls return errors.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| login_duration | Milliseconds | Duration of the login API call as reported by the server. |
| logout_duration | Milliseconds | Duration of the logout API call as reported by the server. |
| runtime | Milliseconds | Total wall-clock time for login, search, and logout combined. |
| search_duration | Milliseconds | Duration of the diagnosis search API call as reported by the server. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch); originally written by Dominik Riva, Universitaetsspital Basel/Switzerland
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
