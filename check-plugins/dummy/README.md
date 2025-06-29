# Check dummy

## Overview

This check just returns the given message, state and perfdata. It comes in handy when trying to pass Icinga DSL to the dummy command via the Icinga Director, as this is not currently possible with the Icinga built-in dummy command.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dummy> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: dummy [-h] [-V] [--always-ok] [--message MESSAGE] [--perfdata PERFDATA]
             [--state {ok,warn,crit,unk}]

This check just returns the given message, state and perfdata.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --message MESSAGE     The message to return. Default: Everything is ok.
  --perfdata PERFDATA   The perfdata to return, formatted according to the
                        nagios guidelines. Default: None
  --state {ok,warn,crit,unk}
                        The state to return (ok, warn, crit, unk). Default: ok
```


## Usage Examples

```bash
./dummy2 --message='A warning message.' --state=warn --perfdata='85,"%",80,90,0,100'
```

Output:

```text
A warning message.|85,%,80,90,0,100
```


## States

* Given state, or UNKNOWN if none is given


## Perfdata / Metrics

* Given perfdata, or none


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
