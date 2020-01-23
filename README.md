# Python-based Checks for Icinga

This git repo provides various Python2-based check plugins for Nagios compatible monitoring systems like Nagios and Icinga. All checks are written and tested on CentOS 7 Minimal and Fedora >= 30.

If you
* are disappointed by `nagios-plugins-all` (who needs `check_games`?)
* search for checks that are written in Python2 only (your system language on CentOS)
* want to have a look into the source code of the checks
* want to use checks that are fast, reliable and focused on CentOS and Icinga2
* want to use checks that all behave uniform and report the same (for example "used") in a short and precise manner
* want to use checks out of the box with some kind of auto-discovery, that use useful defaults and only throw CRITs where it is absolutely necessary
* are happy about checks that provide some additional information to help you troubleshoot your system
* want to use plugins that try to avoid 3rd party dependencies wherever possible

...then these checks might be for you.


## Python2

All checks are written in Python 2, because...

* in a datacenter environment (where these checks are mainly used) the `python == python2` side is still more popular.
* in CentOS 7, Python 2.7 is the default.
* in CentOS 8, there is no default. You just need to specify whether you want Python 3 or 2.
* support for Python 2 will end, but not in CentOS 8 (Python 2 remains available in CentOS 8 until at least 2029 - for further details have a look at https://developers.redhat.com/blog/2018/11/14/python-in-rhel-8/).

Our checks call Python 2 by using `#! /usr/bin/env python2`.

We try to avoid dependencies on libraries wherever possible. If we have to use additional libraries for various reasons, we stick on official versions.


## Hints

To run a check make sure that the symbolic link `lib` points to `lib-linux`, which you have to clone from [lib-linux](https://gitlab.com/linuxfabrik-icinga-plugins/lib-linux).


# Icinga Check Plugin Developer Guidelines

## Deliverables

* The check itself.
* A nice 16x16 transparent PNG icon, for example based on font-awesome.
* README.md
* LICENSE file
* optional: Grafana panel
* optional: Icinga Director Basket Config
* optional: Icingaweb2 Grafana Module .ini file
* optional: sudoers file
* optional: `test` - the unittest file


## Rules of Thumb

* The check should be "self configuring" and/or using best practise defaults, so that it runs without parameters.
* Develop with CentOS 7/8 Minimal in mind.
* Develop with Icinga2 in mind.
* Avoid complicated or fancy (and therefore unreadable) Python statements.
* Comments and output should be in English only.
* If possible avoid libraries that have to be installed.
* Validate input.
* Check for system commands, libraries and their versions.
* It is not needed to execute system commands by specifying their full path.
* Use temp files if needed.
* Or better: use a local SQLite database if you want to use a temp file.
* Great, if the plugin executes fast and uses less ressources (cpu time, memory etc.).
* Keep in mind: Plugins have a limited runtime - typically 10 seconds max.
* Timeout gracefully on errors (for example `df` on a failed network drive) and return WARN.
* Return UNKNOWN on missing dependencies or wrong parameters.
* Mainly return WARN. Only return CRIT if the operators have to wake up at night.


## Unit Tests

Use the `unittest` framework (https://docs.python.org/2.7/library/unittest.html), run the check as a bash command, capture stdout, stderr and its return code, and run your assertions.

To test a check that need to run some tools that aren't on your machine, provide an `examples` stdout file and a `--test` parameter to feed "example/stdout-file,expected-stderr,expected-retc" into your check. If you get the `--test` parameter, skip the execution of your bash/psutil/whatever function.


## Names, Naming Conventions

define_args     > get_options
parsed          > options
unpack_perfdata > format_perfdata
filter_input    > filter_values (gehört auch nicht in parse_input, sondern ist eine array-funktion)

set_thresholds
get_status
stats (instead of "statistics")
msgs (abbreviation for "messages")
get_greater_state > get_most_significant_state

Auslagern:
* is_sw_update_available (nextcloud, rocket)
* get_latest_sw_version (nextcloud, rocket)



Parameters:

* ignore-...
* disable-...
* noproxy
* insecure

Libraries:

* utils.py


## Parameters, Option Processing

There are a few reserved options that should not be used for other purposes:

    -a, --authentication    authentication password
    -C, --community         SNMP community
    -c, --critical          critical threshold
    -f, --filename          file or directory name
        --count             count intervals, the same as "for" in prometheus ("for 5 minutes")
    -h, --help              help
    -H, --hostname          hostname
    -i, --input
    -i, --interface
    -l, --logname           login name
    -m, --mode 
    -p, --password          password
    -p, --port              network port
        --state             warn,crit
    -t, --timeout           timeout
        --type
    -u, --url               URL
    -u, --username          username
    -V, --version           version
    -v, --verbose           verbose
    -w, --warning           warning threshold

* For complex parameter tupels, use the `csv` type. 
  `--input='Name, Value, Warn, Crit'` results in
  `[ 'Name', 'Value', 'Warn', 'Crit' ]`

* For repeating parameter tupels, use the `append` action. A `default` variable has to be a list then.
  `--input=a --input=b` results in
  `[ 'a', 'b' ]`

* If you combine `csv` type and `append` action, you get a two-dimensional list:
  `--repeating-csv='1, 2, 3' --repeating-csv='a, b, c'` results in
  `[['1', '2', '3'], ['a', 'b', 'c']]`


## Help

README.md
gute Hilfetexte im Check (das "warum" erklären)


## Plugin Output

Sample Output:

```
There are warnings.
* WARN Item 1: 123M (100/200)
* Item 2: 37M
```

* Print a short concise message in the first line within the first 80 chars.
* Use multi-line output for details
* Don't print OK, WARN, CRIT
* Give a help text to solve the problem
* Multiple items checked, and ...
  - everything ok? Print "Everything is ok." in the first line, and optional the items and their data attached in multiple lines.
  - 
  - 

* bei der Ausgabe am aktuellsten `glances` unter Fedora orientieren
* Angaben von Einheiten so "schmal" wie möglich (ohne Leerzeichen und Ballast)
  * Percent: %
  * Bytes: B, K, M, G, T
  * Temperatures: C, F
  * Network: "Rx/s", "Tx/s", Mbps (Megabit per Second)
  * I/O: MB/s (Megabyte per Second)
  * Read/Write: R/s, W/s
* Used, Total
* File Sys: "/boot (sda2)"
* Tendenz-Anzeige mit "\ / -", Beispiel: "CPU / 5.0%" 
* Use ISO format for datetimestamps ("yyyy-mm-dd hh:mm:ss")
* Human readable datetimes ("Up 3d 4h", "2019-12-31 23:59:59", "1.5s")


## Perfdata

    'label'=value[UOM];[warn];[crit];[min];[max]

UOM = Unit of Measurement


Perfdata value-suffix:

    no unit specified - assume a number (int or float) of things (eg, users, processes, load averages)
    s - seconds (also us, ms)
    % - percentage
    B - bytes (also KB, MB, TB)
    c - a continous counter (such as bytes transmitted on an interface)

