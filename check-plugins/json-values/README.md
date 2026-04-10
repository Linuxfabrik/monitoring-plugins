# Check json-values


## Overview

Parses a JSON object from a local file, HTTP/HTTPS URL, or SMB share and extracts message, state, and perfdata values from configurable keys. This allows integrating custom applications or scripts that provide monitoring data in JSON format into Nagios/Icinga without writing a dedicated check plugin.

**Data Collection:**

* Reads JSON from one of three sources (mutually exclusive): a local file (`--filename`), an HTTP/HTTPS URL (`--url`), or an SMB share (`smb://` URL with optional `--username`/`--password`)
* Extracts the output message from the key specified by `--message-key` (default: `message`)
* Extracts the perfdata string from the key specified by `--perfdata-key` (default: `perfdata`)
* Extracts the return state from the key specified by `--state-key` (default: `state`)


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
usage: json-values [-h] [-V] [--always-ok] [--filename FILENAME] [--insecure]
                   [--message-key MESSAGE_KEY] [--no-proxy]
                   [--password PASSWORD] [--perfdata-key PERFDATA_KEY]
                   [--state-key STATE_KEY] [--timeout TIMEOUT] [-u URL]
                   [--username USERNAME]

Parses a JSON array from a file, URL, or SMB share and extracts message,
state, and perfdata values from specific keys. Useful for integrating custom
applications or APIs that provide monitoring data in JSON format. Alerts based
on the state value extracted from the JSON data.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --filename FILENAME   Path to a local JSON file. Mutually exclusive with -u
                        / --url.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --message-key MESSAGE_KEY
                        Name of the JSON array key containing the output
                        message. Default: message
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Password for SMB authentication.
  --perfdata-key PERFDATA_KEY
                        Name of the JSON array key containing the perfdata.
                        Default: perfdata
  --state-key STATE_KEY
                        Name of the JSON array key containing the state.
                        Default: state
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         URL of the JSON file, starting with "http://",
                        "https://", or "smb://". Mutually exclusive with
                        --filename.
  --username USERNAME   Username for SMB authentication.
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


## States

* Returns the state value from the JSON object (0=OK, 1=WARN, 2=CRIT, 3=UNKNOWN).
* UNKNOWN if `--filename` and `--url` are used together, if the URL protocol is unsupported, if JSON parsing fails, or if the state key is missing.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| (from JSON) | (from JSON) | Returns the perfdata string from the JSON object as-is (key specified by `--perfdata-key`). |


## Troubleshooting

`Python module "smbprotocol" is not installed.`
Install the required modules: `pip install PySmbClient smbprotocol`.

`The --filename and -u / --url parameter are mutually exclusive.`
Specify either `--filename` or `--url`, not both.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
