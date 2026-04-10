# Check json-values

## Overview

This check parses a flat json array from a file or url and simply returns the message, state and perfdata from the json.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/json-values> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `PySmbClient`, `smbprotocol` |


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
                        connections. Default: False.
  --message-key MESSAGE_KEY
                        Name of the JSON array key containing the output
                        message. Default: message.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Password for SMB authentication.
  --perfdata-key PERFDATA_KEY
                        Name of the JSON array key containing the perfdata.
                        Default: perfdata.
  --state-key STATE_KEY
                        Name of the JSON array key containing the state.
                        Default: state.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         URL of the JSON file, starting with "http://",
                        "https://", or "smb://". Mutually exclusive with
                        --filename.
  --username USERNAME   Username for SMB authentication.
```


## Usage Examples

```bash
./json-values --url=http://example.com/example.json --message-key=message --state-key=state --perfdata-key=perfdata

cat > /tmp/example.json2 << 'EOF'
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

* Exits with the state from the json array.


## Perfdata / Metrics

Returns the perfdata from the json array.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
