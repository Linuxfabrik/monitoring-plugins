# Overview

This check "allows a server administrator to find out how well their server is performing". For the check plugin to work you have to enable `mod_status` and set `ExtendedStatus` to `On`. Have a look at https://httpd.apache.org/docs/2.4/mod/mod_status.html

Busy workers (workers serving requests) are:
* `C`: Closing connection
* `D`: DNS Lookup
* `G`: Gracefully finishing
* `I`: Idle cleanup of worker
* `K`: Keepalive (read)
* `L`: Logging
* `R`: Reading Request
* `S`: Starting up
* `W`: Sending Reply

Idle workers are:
* `_`: Waiting for Connection

Free workers are:
* `.`: Open slot with no current process

We recommend to run this check every minute.


# Installation and Usage

```bash
./apache-httpd-status --url http://localhost/server-status
./apache-httpd-status --url http://localhost/server-status --warning 80 --critical 90
./apache-httpd-status --help
```

# States and Perfdata

* WARN or CRIT if more than 90% or 95% busy workers compared to the total possible number of workers are found.
* WARN if more than 25% gracefully finishing workers compared to free workers are found.


# Known Issues and Limitations

* Tested with Apache/2.4.6 (CentOS 7).


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.

