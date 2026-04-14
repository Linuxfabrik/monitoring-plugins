# Check json-values


## Overview

Parses a JSON object from a local file, HTTP/HTTPS URL, or SMB share and extracts message, state, and perfdata values from configurable keys. This allows integrating custom applications or scripts that provide monitoring data in JSON format into Nagios/Icinga without writing a dedicated check plugin.

**Data Collection:**

* Reads JSON from one of three sources (mutually exclusive): a local file (`--filename`), an HTTP/HTTPS URL (`--url`), or an SMB share (`smb://` URL with optional `--username`/`--password`)
* Extracts the output message from the key specified by `--message-key` (default: `message`)
* Extracts the perfdata string from the key specified by `--perfdata-key` (default: `perfdata`)
* Extracts the return state from the key specified by `--state-key` (default: `state`)
* All `--*-key` parameters support dot-notation for nested keys (e.g. `--state-key=meta.state`)
* HTTP endpoints can be authenticated with a bearer token (`--token`) and/or custom request headers (`--header`, curl-style `"Name: Value"`, can be specified multiple times)
* In addition to the state extracted from the JSON itself, the value at a specific JSON key can be alerted on via `--warning-key`/`--warning` and `--critical-key`/`--critical` (Nagios range syntax); the value at the referenced key must be numeric, otherwise the check returns UNKNOWN. The overall check state is the worst of the JSON state and the two key-level thresholds.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/json-values> |
| Nagios/Icinga Check Name              | `check_json_values` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `PySmbClient`, `smbprotocol` (only for SMB access) |


## Help

```text
usage: json-values [-h] [-V] [--always-ok] [-c CRIT]
                   [--critical-key CRITICAL_KEY] [--filename FILENAME]
                   [--header HEADER] [--insecure] [--message-key MESSAGE_KEY]
                   [--no-proxy] [--password PASSWORD]
                   [--perfdata-key PERFDATA_KEY] [--state-key STATE_KEY]
                   [--timeout TIMEOUT] [--token TOKEN] [-u URL]
                   [--username USERNAME] [-w WARN] [--warning-key WARNING_KEY]

Parses a JSON object from a file, URL, or SMB share and extracts message,
state, and perfdata values from configurable keys. Useful for integrating
custom applications or APIs that expose monitoring data as JSON. Supports HTTP
bearer-token and arbitrary header authentication, dot-notation for nested JSON
keys, and per-key Nagios-range thresholds in addition to the state value
extracted from the JSON itself.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   Nagios range expression evaluated for the CRIT state
                        against the value of the JSON key referenced by
                        --critical-key. Example: `--critical-key=days
                        --critical=1`. Example: `--critical-
                        key=detailedInfo.count1 --critical=@90:100`. Default:
                        None
  --critical-key CRITICAL_KEY
                        Name of the JSON key whose value should be evaluated
                        against --critical for the CRIT state. Supports dot-
                        notation for nested keys (e.g. `detailedInfo.count1`).
                        The value at the resolved key must be numeric in the
                        JSON, otherwise the check returns UNKNOWN. Example:
                        `--critical-key=days`. Example: `--critical-
                        key=detailedInfo.count1`. Default: None
  --filename FILENAME   Path to a local JSON file. Mutually exclusive with -u
                        / --url.
  --header HEADER       Custom HTTP request header to send when fetching the
                        URL. curl-style format `"Name: Value"`. Can be
                        specified multiple times. Example: `--header="X-API-
                        Key: linuxfabrik"`. Example: `--header="Accept:
                        application/json"`. Default: None
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --message-key MESSAGE_KEY
                        Name of the JSON key containing the output message.
                        Supports dot-notation for nested keys (e.g.
                        `meta.message`). Example: `--message-
                        key=meta.message`. Default: message
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Password for SMB authentication.
  --perfdata-key PERFDATA_KEY
                        Name of the JSON key containing the perfdata. Supports
                        dot-notation for nested keys (e.g. `meta.perfdata`).
                        Example: `--perfdata-key=meta.perfdata`. Default:
                        perfdata
  --state-key STATE_KEY
                        Name of the JSON key containing the state. Supports
                        dot-notation for nested keys (e.g. `meta.state`).
                        Example: `--state-key=meta.state`. Default: state
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --token TOKEN         HTTP bearer token. Adds an `Authorization: Bearer
                        <token>` header to the URL request. Can be combined
                        with --header to send additional custom headers (e.g.
                        `--token=linuxfabrik --header="Accept:
                        application/json"`); a manual
                        `--header="Authorization: ..."` is overridden by
                        --token if both are specified. Default: None
  -u, --url URL         URL of the JSON file, starting with "http://",
                        "https://", or "smb://". Mutually exclusive with
                        --filename.
  --username USERNAME   Username for SMB authentication.
  -w, --warning WARN    Nagios range expression evaluated for the WARN state
                        against the value of the JSON key referenced by
                        --warning-key. Example: `--warning-key=days
                        --warning=7`. Example: `--warning-
                        key=detailedInfo.count1 --warning=@80:90`. Default:
                        None
  --warning-key WARNING_KEY
                        Name of the JSON key whose value should be evaluated
                        against --warning for the WARN state. Supports dot-
                        notation for nested keys (e.g. `detailedInfo.count1`).
                        The value at the resolved key must be numeric in the
                        JSON, otherwise the check returns UNKNOWN. Example:
                        `--warning-key=days`. Example: `--warning-
                        key=detailedInfo.count1`. Default: None
```


## Usage Examples

```bash
./json-values --url=http://example.com/example.json --message-key=message --state-key=state --perfdata-key=perfdata
```

```bash
cat > /tmp/example.json << 'EOF'
{
    "state": 2,
    "message": "This is a test message",
    "perfdata": "'cpu-usage'=5.6%;80;90;0;100"
}
EOF
./json-values --filename=/tmp/example.json
```

Output:

```text
This is a test message|'cpu-usage'=5.6%;80;90;0;100
```

Fetching from a protected HTTP endpoint with a bearer token and an additional `Accept` header, and reading a nested state key:

```bash
./json-values \
    --url=https://api.example.com/monitoring \
    --token=linuxfabrik \
    --header='Accept: application/json' \
    --state-key=meta.state \
    --message-key=meta.message \
    --perfdata-key=meta.perfdata
```

Alerting on a numeric value inside a nested JSON key with Nagios range expressions (`@80:90` means alert when inside the range, inclusive):

```bash
./json-values \
    --filename=/tmp/example.json \
    --warning-key=detailedInfo.count1 --warning=@80:90 \
    --critical-key=detailedInfo.count1 --critical=@90:100
```


## States

* Returns the worst of three states: the state extracted from the JSON object (0=OK, 1=WARN, 2=CRIT, 3=UNKNOWN), the state computed from `--warning-key` / `--warning`, and the state computed from `--critical-key` / `--critical`.
* UNKNOWN if `--filename` and `--url` are used together, if the URL protocol is unsupported, if JSON parsing fails, if the state key is missing or does not resolve to an integer in the range `0..3`, or if a threshold key cannot be resolved or is not numeric.
* `--warning` / `--warning-key` and `--critical` / `--critical-key` must be specified together (range without a key has nothing to compare, key without a range would silently never alert).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<from JSON> | \<from JSON> | Returns the perfdata string from the JSON object as-is (key specified by `--perfdata-key`). |


## Troubleshooting

`Python module "smbprotocol" is not installed.`
Install the required modules: `pip install PySmbClient smbprotocol`.

`The --filename and -u / --url parameter are mutually exclusive.`
Specify either `--filename` or `--url`, not both.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
