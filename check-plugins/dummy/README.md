# Check dummy


## Overview

Returns a freely configurable message, state, and perfdata. Useful for testing monitoring configurations, simulating alerts, or generating placeholder data. It comes in handy when trying to pass Icinga DSL to the dummy command via the Icinga Director, as this is not currently possible with the Icinga built-in dummy command.


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dummy> |
| Nagios/Icinga Check Name              | `check_dummy` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |


## Help

```text
usage: dummy [-h] [-V] [--always-ok] [--message MESSAGE] [--perfdata PERFDATA]
             [--state {ok,warn,crit,unk}]

Returns a freely configurable message, state, and perfdata. Useful for testing
monitoring configurations, simulating alerts, or generating placeholder data.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --message MESSAGE     Message to return. Default: Everything is ok.
  --perfdata PERFDATA   Perfdata to return, formatted according to the Nagios
                        guidelines. Default: None
  --state {ok,warn,crit,unk}
                        State to return (ok, warn, crit, unk). Default: ok
```


## Usage Examples

```bash
./dummy --message='A warning message.' --state=warn --perfdata='85,"%",80,90,0,100'
```

Output:

```text
A warning message.|85,%,80,90,0,100
```


## States

* Returns the state given by `--state` (default: OK).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<user-defined> | \<user-defined> | Returns the perfdata given by `--perfdata`, or none if not specified. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
