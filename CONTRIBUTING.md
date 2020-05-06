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
* It is not needed to execute system (shell/bash) commands by specifying their full path.
* It is ok to use temp files if needed.
* Much better: use a local SQLite database if you want to use a temp file.
* Keep in mind: Plugins have a limited runtime - typically 10 seconds max. Therefore it is great if the plugin executes fast and uses less ressources (cpu time, memory etc.).
* Timeout gracefully on errors (for example `df` on a failed network drive) and return WARN.
* Return UNKNOWN on missing dependencies or wrong parameters.
* Mainly return WARN. Only return CRIT if the operators want to or have to wake up at night. CRIT means "react immediately".
* EAFP: Easier to ask for forgiveness than permission. This common Python coding style assumes the existence of valid keys or attributes and catches exceptions if the assumption proves false. This clean and fast style is characterized by the presence of many try and except statements. 


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

    --activestate
    --always-ok
    --cache-expire
    --channel
    --command
    --count
    --database
    --depth
    --filename
    --full
    --ignore
    --input
    --insecure
    --interface
    --interval
    --key
    --loadstate
    --metric
    --mode
    --mount
    --no-kthreads
    --no-proxy
    --no-summary
    --path
    --portname
    --prefix
    --severity
    --state
    --substate
    --test
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


## Threshold and Ranges

If a threshold has to be handled as a range parameter, this is how to interpret them. Pretty much the same as stated in the [Nagios Development Guidelines](http://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT).

* simple value: a range from 0 up to and including the value
* `:`: describes a range
* empty value before or after `:`: positive infinity
* `~`: negative infinity
* `@`: if range starts with "@", then alert if inside this range (including endpoints)

-w, -c    | OK if result is   | WARN/CRIT if      | lib.base.parse_range() returns
----------|-------------------|-------------------|----------------------------
10        | in (0..10)        | not in (0..10)    | (0, 10, False)
-10       | in (-10..0)       | not in (-10..0)   | (0, -10, False)
10:       | in (10..inf)      | not in (10..inf)  | (10, inf, False)
:         | in (0..inf)       | not in (0..inf)   | (0, inf, False)
~:10      | in (-inf..10)     | not in (-inf..10) | (-inf, 10, False)
10:20     | in (10..20)       | not in (10..20)   | (10, 20, False)
@10:20    | not in (10..20)   | in 10..20         | (10, 20, True)
@~:20     | not in (-inf..20) | in (-inf..20)     | (-inf, 20, True)
@         | not in (0..inf)   | in (0..inf)       | (0, inf, True)

So, a definition like `--warning 2:100 --critical 1:150` should return the states:

    val   0   1   2 .. 100 101 .. 150 151
    -w   WA  WA  OK     OK  WA     WA  WA
    -c   CR  OK  OK     OK  OK     OK  CR
    =>   CR  WA  OK     OK  WA     WA  CR

Another example: `--warning 190: --critical 200:`

    val 189 190 191 .. 199 200 201
    -w   WA  OK  OK     OK  OK  OK
    -c   CR  CR  CR     CR  OK  OK
    =>   CR  CR  CR     CR  OK  OK

Another example: `--warning ~:0 --critical 10`

    val  -2  -1   0   1 ..   9  10  11
    -w   OK  OK  OK  WA     WA  WA  WA
    -c   CR  CR  OK  OK     OK  OK  CR
    =>   CR  CR  OK  WA     WA  WA  CR

Have a look at `procs` on how to implement this.


## Caching temporary data, SQLite database

Use `cache` if you need a simple key-value store, for example as used in `nextcloud-version`. Otherwise, use `db_sqlite` as used in `cpu-usage`.


## Error Handling

* Catch exceptions using `try`/`except`, especially in functions.
* In functions, if you have to catch exceptions, on such an exception always return `(False, errormessage)`. Otherwise return `(True, result)` if the function succeeds in any way. For example, returning `(True, False)` means that the function has not raised an exception and its result is simply `False`.
* A function calling a function with such an extended error handling has to return a `(retc, result)` tuple itself.
* In `main()` you can use `lib.base.coe()` to simplify error handling.
* Have a look at `nextcloud-version` for details.


## Plugin Output

* Print a short concise message in the first line within the first 80 chars if possible.
* Use multi-line output for details (`msg_body`), with the most important output in the first line (`msg_header`).
* Don't print "OK".
* Print "(WARN)" or "(CRIT)" for clarification next to a specific item.
* If possible give a help text to solve the problem.
* Multiple items checked, and ...
  - ... everything ok? Print "Everything is ok." or the most important output in the first line, and optional the items and their data attached in multiple lines.
  - ... there are warnings or errors? Print "There are warnings." or "There are errors." or the most important output in the first line, and optional the items and their data attached in multiple lines.
* Use short "Units of Measurements" without white spaces:
  * Percentage: 93.2%
  * Bytes: 7B, 3.4K, M, G, T
  * Temperatures: 7.3C, 45F
  * Network: "Rx/s", "Tx/s", 17.4Mbps (Megabit per Second)
  * I/O and Throughput: 220.4MB/s (Megabyte per Second)
  * Read/Write: "R/s", "W/s", "IO/s"
* Use ISO format for date or datetime ("yyyy-mm-dd", "yyyy-mm-dd hh:mm:ss")
* Print human readable datetimes and time periods ("Up 3d 4h", "2019-12-31 23:59:59", "1.5s")


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


## PEP8 Sytle Guide for Python Code

We recently started to use [PEP 8 -- Style Guide for Python Code](https://www.python.org/dev/peps/pep-0008/).


## docstring, pydoc

Not long ago we started to document our [Check Plugin Libraries](https://git.linuxfabrik.ch/linuxfabrik-icinga-plugins/lib-linux) using docstrings, so that calling `pydoc lib/base.py` works, for example.


## Pylint

To further improve code quality, we recently started using [Pylint](https://www.pylint.org/) with pure `pylint` for the libraries, and with `pylint --disable=C0103,C0114,C0116` for the check plugins, on a more regular basis. The parameter disables warnings for

* non-conformance to snake_case naming style
* missing module docstring
* missing function or method docstring


## Unit Tests

Implementing tests:

* Use the `unittest` framework (https://docs.python.org/2.7/library/unittest.html). Within your `test` file, call the check as a bash command, capture stdout, stderr and its return code (retc), and run your assertions against stdout, stderr and retc.
* To test a check that needs to run some tools that aren't on your machine, provide an `examples` stdout file and a `--test` parameter to feed "example/stdout-file,expected-stderr,expected-retc" into your check. If you get the `--test` parameter, skip the execution of your bash/psutil/whatever function.

Running tests:

```bash
# cd into the check directory and run:
python2 test
```
