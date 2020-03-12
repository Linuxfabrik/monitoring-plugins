# Linuxfabrik's Icinga Check Plugin Developer Guidelines

## Deliverables

* The check itself.
* A nice 16x16 transparent PNG icon, for example based on font-awesome.
* README file explaining "How?" and Why?" 
* LICENSE file
* optional: Grafana panel
* optional: Icinga Director Basket Config
* optional: Icingaweb2 Grafana Module .ini file
* optional: sudoers file
* optional: `test` - the unittest file


## Rules of Thumb

* The check should be "self configuring" and/or using best practise defaults, so that it runs without parameters wherever possible.
* Develop with CentOS 7/8 Minimal in mind.
* Develop with Icinga2 in mind.
* Avoid complicated or fancy (and therefore unreadable) Python statements.
* Comments and output should be in English only.
* If possible avoid libraries that have to be installed.
* Validate user input.
* Check for system commands, libraries and their versions (`try` ... `except`).
* It is not needed to execute system (shell/bash) commands by specifying their full path.
* It is ok to use temp files if needed.
* Much better: use a local SQLite database if you want to use a temp file.
* Keep in mind: Plugins have a limited runtime - typically 10 seconds max. Therefore it is great if the plugin executes fast and uses less ressources (cpu time, memory etc.).
* Timeout gracefully on errors (for example `df` on a failed network drive) and return WARN.
* Return UNKNOWN on missing dependencies or wrong parameters.
* Mainly return WARN. Only return CRIT if the operators want to or have to wake up at night. CRIT means "react immediately".


## Names, Naming Conventions, Parameters, Option Processing

There are a few Nagios-compatible reserved options that should not be used for other purposes:

    -a, --authentication    authentication password
    -C, --community         SNMP community
    -c, --critical          critical threshold
    -h, --help              help
    -H, --hostname          hostname
    -l, --logname           login name
    -p, --password          password
    -p, --port              network port
    -t, --timeout           timeout
    -u, --url               URL
    -u, --username          username
    -V, --version           version
    -v, --verbose           verbose
    -w, --warning           warning threshold

For all other options, use long parameters only. We recommend using some of those:

    --always-ok
    --count
    --database
    --filename
    --ignore
    --ignore-...
    --input
    --insecure
    --interface
    --loadstate
    --mode
    --mount
    --no-proxy
    --no-update-check
    --no-summary
    --no-...
    --port
    --portname 
    --prefix
    --severity
    --state 
    --substate
    --test
    --timeout
    --timespan
    --trigger
    --type
    --unit
    --unitfilestate

* For complex parameter tupels, use the `csv` type. 
  `--input='Name, Value, Warn, Crit'` results in `[ 'Name', 'Value', 'Warn', 'Crit' ]`

* For repeating parameters, use the `append` action. A `default` variable has to be a list then. `--input=a --input=b` results in `[ 'a', 'b' ]`

* If you combine `csv` type and `append` action, you get a two-dimensional list: `--repeating-csv='1, 2, 3' --repeating-csv='a, b, c'` results in
  `[['1', '2', '3'], ['a', 'b', 'c']]`


## Plugin Output

* Print a short concise message in the first line within the first 80 chars if possible.
* Use multi-line output for details, with important output in the first line.
* Don't print "OK", "WARN", "CRIT".
* Give a help text to solve the problem.
* Multiple items checked, and ...
  - ... everything ok? Print "Everything is ok." in the first line, and optional the items and their data attached in multiple lines.
  - ... there are warnings or errors? Print "There are warnings." or "There are errors.", and optional the items and their data attached in multiple lines.
* Output short "Units of Measurements" without white spaces:
  * Percentage: 93.2%
  * Bytes: 7B, 3.4K, M, G, T
  * Temperatures: 7.3C, 45F
  * Network: "Rx/s", "Tx/s", 17.4Mbps (Megabit per Second)
  * I/O: 220.4MB/s (Megabyte per Second)
  * Read/Write: "R/s", "W/s"
* Use ISO format for datetime ("yyyy-mm-dd hh:mm:ss")
* Print human readable datetimes ("Up 3d 4h", "2019-12-31 23:59:59", "1.5s")


## Plugin Perfdata

UOM = Unit of Measurement

Sample: 

    'label'=value[UOM];[warn];[crit];[min];[max];  

Perfdata value-suffixes:

    no unit specified - assume a number (int or float) of things (eg, users, processes, load averages)
    s - seconds (also us, ms)
    % - percentage
    B - bytes (also KB, MB, TB)
    c - a continous counter (such as bytes transmitted on an interface)

Wherever possible, prefer percentages over absolute values to assist users in comparing different systems with different absolute sizes.


## Unit Tests

Implementing tests:

* Use the `unittest` framework (https://docs.python.org/2.7/library/unittest.html). Within your `test` file, call the check as a bash command, capture stdout, stderr and its return code (retc), and run your assertions against stdout, stderr and retc.
* To test a check that needs to run some tools that aren't on your machine, provide an `examples` stdout file and a `--test` parameter to feed "example/stdout-file,expected-stderr,expected-retc" into your check. If you get the `--test` parameter, skip the execution of your bash/psutil/whatever function.

Running tests: `python2 path/to/check-plugin/test`


