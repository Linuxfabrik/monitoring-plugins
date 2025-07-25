# Linuxfabrik's Check Plugin Developer Guidelines

## Monitoring of an Application

Monitoring an application can be complex and produce a wide variety of data. In order to standardize the handling of threshold values on the command line, to reduce the number of command line parameters and their interdependencies and to enable independent and thus extended designs of the Grafana panels, each topic should be dealt with in a separate check (following the Linux mantra: "one tool, one task").

Avoid an extensive check that covers a wide variety of aspects:

* `myapp --action threading --warning 1500 --critical 2000`
* `myapp --action memory-usage --warning 80 --critical 90`
* `myapp --action deployment-status` (warning and critical command line options not supported)

Better write three separate checks:

* `myapp-threading --warning 1500 --critical 2000`
* `myapp-memory-usage --warning 80 --critical 90`
* `myapp-deployment-status`

All plugins are written in Python and will be licensed under the \[UNLICENSE\](<https://unlicense.org/>), which is a license with no conditions whatsoever that dedicates works to the public domain.


## Setting up your development environment

All plugins are coded using Python 3.9. Simply clone the libraries and monitoring plugins and start working:

```bash
git clone git@github.com:Linuxfabrik/lib.git
git clone git@github.com:Linuxfabrik/monitoring-plugins.git
```


## Deliverables

Checklist:

* The plugin itself, tested on RHEL and Debian.
* README file explaining "How?" and "Why?"
* A free, monochrome, transparent SVG icon from <https://simpleicons.org> or <https://fontawesome.com/search?ic=free>, placed in the `icon` directory.
* Optional: `unit-test/run` - the unittest file (see [Unit Tests](#unit-tests))
* Optional: `requirements.txt`
* If providing performance data: Grafana dashboard (see [GRAFANA](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/GRAFANA.md)) and `.ini` file for the Icinga Web 2 Grafana Module
* Icinga Director Basket Config for the check plugin (`check2basket`)
* Icinga Service Set in `all-the-rest.json`
* Optional: sudoers file (see [sudoers File](#sudoers-file))
* Optional: A screenshot of the plugins' output from within Icinga, resized to 423x106, using background-color `#f5f9fa`, hosted on [download.linuxfabrik.ch](https://download.linuxfabrik.ch/monitoring-plugins/assets/screenshots/), and listed alphabetically in the projects [README](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/README.md).
* CHANGELOG

## Rules of Thumb

* Be brief by default. Report what needs to be reported to fix a problem. If there is more information that might help the admin, support a `--lengthy` parameter.

* The plugin should be "self configuring" and/or using best practise defaults, so that it runs without parameters wherever possible.

* Develop with a minimal Linux in mind.

* Develop with Icinga2 in mind.

* Avoid complicated or fancy (and therefore unreadable) Python statements.

* Comments and output should be in English only.

* If possible avoid libraries that have to be installed.

* Validate user input.

* It is not needed to execute system (shell/bash) commands by specifying their full path.

* It is ok to use temp files if needed.

* Much better: use a local SQLite database if you want to use a temp file.

* Keep in mind: Plugins have a limited runtime - typically 10 seconds max. Therefore it is ideal if the plugin executes fast and uses minimal resources (CPU time, memory etc.).

* Timeout gracefully on errors (for example `df` on a failed network drive) and return WARN.

* Return UNKNOWN on missing dependencies or wrong parameters.

* Mainly return WARN. Only return CRIT if the operators want to or have to wake up at night. CRIT means "react immediately".

* EAFP: Easier to ask for forgiveness than permission. This common Python coding style assumes the existence of valid keys or attributes and catches exceptions if the assumption proves false. This clean and fast style is characterized by the presence of many try and except statements.

* Use RFC [5737](https://datatracker.ietf.org/doc/html/rfc5737), [3849](https://datatracker.ietf.org/doc/html/rfc3849), [7042](https://datatracker.ietf.org/doc/html/rfc7042#section-2.1.1) and [2606](https://datatracker.ietf.org/doc/html/rfc2606) in examples / documentation:

    * IPv4 Addresses: `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`
    * IPv6 Addresses: `2001:DB8::/32`
    * MAC Addresses: `00-00-5E-00-53-00 through 00-00-5E-00-53-FF` (unicast), `01-00-5E-90-10-00 through 01-00-5E-90-10-FF` (multicast)
    * Domains: `*.example`, `example.com`


## Bytes vs. Unicode

Short:

* Use `txt.to_text()` and `txt.to_bytes()`.

The theory:

* Data coming into your plugins must be bytes, encoded with `UTF-8`.
* Decode incoming bytes as soon as possible (best by using the `txt` library), producing unicode.
* **Use unicode throughout your plugin.**
* When outputting data, use library functions, they should do output conversions for you. Library functions like `base.oao` or `url.fetch_json` will take care of the conversion to and from bytes.

See <https://nedbatchelder.com/text/unipain.html> for details.


## Names, Naming Conventions, Parameters, Option Processing

The plugin name should match the following regex: `^[a-zA-Z0-9\-\_]*$`. This allows the plugin name to be used as the grafana dashboard uid (according to [here](https://github.com/grafana/grafana/blob/552ecfeda320a422bfc7ca9978c94ffea887134a/pkg/util/shortid_generator.go#L11)).

There are a few Nagios-compatible reserved options that should not be used for other purposes:

```text
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
```

For all other options, use long parameters only. Separate words using a `-`. We recommend using some out of those:

```text
--activestate
--alarm-duration
--always-ok
--argument
--authtype
--cache-expire
--command
--community
--config
--count
--critical
--critical-count
--critical-cpu
--critical-maxchildren
--critical-mem
--critical-pattern
--critical-regex
--critical-slowreq
--database
--datasource
--date
--device
--donor
--filename
--filter
--full
--hide-ok
--hostname
--icinga-callback
--icinga-password
--icinga-service-name
--icinga-url
--icinga-username
--idsite
--ignore
--ignore-pattern
--ignore-regex
--input
--insecure
--instance
--interface
--interval
--ipv6
--key
--latest
--lengthy
--loadstate
--message
--message-key
--metric
--mib
--mibdir
--mode
--module
--mount
--no-kthreads
--no-proxy
--no-summary
--node
--only-dirs
--only-files
--password
--path
--pattern
--perfdata
--perfdata-key
--period
--port
--portname
--prefix
--privlevel
--response
--service
--severity
--snmp-version
--starttype
--state
--state-key
--status
--substate
--suppress-lines
--task
--team
--test
--timeout
--timerange
--token
--trigger
--type
--unit
--unitfilestate
--url
--username
--version
--virtualenv
--warning
--warning-count
--warning-cpu
--warning-maxchildren
--warning-mem
--warning-pattern
--warning-regex
--warning-slowreq
```

[Parameter types](https://docs.python.org/3/library/argparse.html) are usually:

* `type=float`
* `type=int`
* `type=lib.args.csv`
* `type=lib.args.float_or_none`
* `type=lib.args.int_or_none`
* `type=str` (the default)
* `choices=['udp', 'udp6', 'tcp', 'tcp6']`
* `action='store_true'`, `action='store_false'` for switches

Hints:

* For complex parameter tupels, use the `csv` type. `--input='Name, Value, Warn, Crit'` results in `[ 'Name', 'Value', 'Warn', 'Crit' ]`
* For repeating parameters, use the `append` action. A `default` variable has to be a list then. `--input=a --input=b` results in `[ 'a', 'b' ]`
* If you combine `csv` type and `append` action, you get a two-dimensional list: `--repeating-csv='1, 2, 3' --repeating-csv='a, b, c'` results in `[['1', '2', '3'], ['a', 'b', 'c']]`
* If you want to provide default values together with `append`, in `parser.add_argument()`, leave the `default` as `None`. If after `main:parse_args()` the value is still `None`, put the desired default list (or any other object) there. The primary purpose of the parser is to parse the commandline - to figure out what the user wants to tell you. There's nothing wrong with tweaking (and checking) the `args` Namespace after parsing. (According to <https://bugs.python.org/issue16399>)

Lessons learned: When it comes to parameters, stay backwards compatible. If you have to rename or drop parameters, keep the old ones, but silently ignore them. This helps admins deploy the monitoring plugins to thousands of servers, while the monitoring server is updated later for various reasons. To be as tolerant as possible, replace the parameter's help text with `help=argparse.SUPPRESS`:

```python
def parse_args():
    """Parse command line arguments using argparse.
    """
    parser = argparse.ArgumentParser(description=DESCRIPTION)

    parser.add_argument(
        '--my-old-and-deprecated-parameter',
        help=argparse.SUPPRESS,
        dest='MY_OLD_VAR',
    )
```


## Git Commits

* Since 2024-11-13, commit messages follow the [Conventional Commits specification](https://www.conventionalcommits.org/en/v1.0.0/) (`<type>(<scope>): <subject>`)  
  Example: `fix(about-me): cryptography deprecation warning`.

* If there is an issue, the commit message must consist of the issue title followed by "(fix \#issueno)", for example: `fix(about-me): cryptography deprecation warning (fix #341)`.

* For the first commit, use the message `Add <plugin-name>`.

`<type>` must be one of the following:

* chore: Changes to the build process or auxiliary tools and libraries such as documentation generation
* docs: Documentation only changes
* feat: A new feature
* fix: A bug fix
* perf: A code change that improves performance
* refactor: A code change that neither fixes a bug nor adds a feature
* style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
* test: Adding missing tests


## Threshold and Ranges

If a threshold has to be handled as a range parameter, this is how to interpret them. Pretty much the same as stated in the [Nagios Development Guidelines](http://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT).

* simple value: a range from 0 up to and including the value
* empty value after `:`: positive infinity
* `~`: negative infinity
* `@`: if range starts with "@", then alert if inside this range (including endpoints)

Examples:

<table>
<thead>
<tr>
<th><dl>
<dt><code>-w, -c</code></dt>
<dd>
&#10;</dd>
</dl></th>
<th>OK if result is</th>
<th>WARN/CRIT if</th>
</tr>
</thead>
<tbody>
<tr>
<td>10</td>
<td>in (0..10)</td>
<td>not in (0..10)</td>
</tr>
<tr>
<td>-10</td>
<td>in (-10..0)</td>
<td>not in (-10..0)</td>
</tr>
<tr>
<td>10:</td>
<td>in (10..inf)</td>
<td>not in (10..inf)</td>
</tr>
<tr>
<td>:</td>
<td>in (0..inf)</td>
<td>not in (0..inf)</td>
</tr>
<tr>
<td>~:10</td>
<td>in (-inf..10)</td>
<td>not in (-inf..10)</td>
</tr>
<tr>
<td>10:20</td>
<td>in (10..20)</td>
<td>not in (10..20)</td>
</tr>
<tr>
<td>@10:20</td>
<td>not in (10..20)</td>
<td>in 10..20</td>
</tr>
<tr>
<td>@~:20</td>
<td>not in (-inf..20)</td>
<td>in (-inf..20)</td>
</tr>
<tr>
<td>@</td>
<td>not in (0..inf)</td>
<td>in (0..inf)</td>
</tr>
</tbody>
</table>

So, a definition like `--warning 2:100 --critical 1:150` should return the states:

```text
val   0   1   2 .. 100 101 .. 150 151
-w   WA  WA  OK     OK  WA     WA  WA
-c   CR  OK  OK     OK  OK     OK  CR
=>   CR  WA  OK     OK  WA     WA  CR
```

Another example: `--warning 190: --critical 200:`

```text
val 189 190 191 .. 199 200 201
-w   WA  OK  OK     OK  OK  OK
-c   CR  CR  CR     CR  OK  OK
=>   CR  CR  CR     CR  OK  OK
```

Another example: `--warning ~:0 --critical 10`

```text
val  -2  -1   0   1 ..   9  10  11
-w   OK  OK  OK  WA     WA  WA  WA
-c   CR  CR  OK  OK     OK  OK  CR
=>   CR  CR  OK  WA     WA  WA  CR
```

Have a look at `procs` on how to implement this.


## Caching temporary data, SQLite database

Use `cache` if you need a simple key-value store, for example as used in `nextcloud-version`. Otherwise, use `db_sqlite` as used in `cpu-usage`.


## Error Handling

* Catch exceptions using `try`/`except`, especially in functions.
* In functions, if you have to catch exceptions, on such an exception always return `(False, errormessage)`. Otherwise return `(True, result)` if the function succeeds in any way. For example, returning `(True, False)` means that the function has not raised an exception and its result is simply `False`.
* A function calling a function with such an extended error handling has to return a `(retc, result)` tuple itself.
* In `main()` you can use `lib.base.coe()` to simplify error handling.
* Have a look at `nextcloud-version` for details.

By the way, when running the compiled variants, this gives the nice and intended error if the module is missing:

```python
try:
    import psutil  # pylint: disable=C0413
except ImportError:
    print('Python module "psutil" is not installed.')
    sys.exit(STATE_UNKNOWN)
```

while this leads to an ugly multi-exception stacktrace:

```python
try:
    import psutil  # pylint: disable=C0413
except ImportError:
    lib.base.cu('Python module "psutil" is not installed.')
```


## Plugin Output

* Print a short concise message in the first line within the first 80 chars if possible.

* Use multi-line output for details (`msg_body`), with the most important output in the first line (`msg_header`).

* Don't print "OK".

* Print "\[WARNING\]" or "\[CRITICAL\]" for clarification next to a specific item using `lib.base.state2str()`.

* If possible give a help text to solve the problem.

* Multiple items checked, and ...

    * ... everything ok? Print "Everything is ok." or the most important output in the first line, and optional the items and their data attached in multiple lines.
    * ... there are warnings or errors? Print "There are warnings." or "There are errors." or the most important output in the first line, and optional the items and their data attached in multiple lines.

* Based on parameters etc. nothing is checked at the end? Print "Nothing checked."

* Wrong username or password? Print "Failed to authenticate."

* Use short "Units of Measurements" without white spaces, including these terms:

    * Bits: use `human.bits2human()`
    * Bytes: use `human.bytes2human()`
    * I/O and Throughput: `human.bytes2human() + '/s'` (Byte per Second)
    * Network: "Rx/s", "Tx/s", use `human.bps2human()`
    * Numbers: use `human.number2human()`
    * Percentage: 93.2%
    * Read/Write: "R/s", "W/s", "IO/s"
    * Seconds, Minutes etc.: use `human.seconds2human()`
    * Temperatures: 7.3C, 45F.

* Use ISO format for date or datetime ("yyyy-mm-dd", "yyyy-mm-dd hh:mm:ss")

* Print human readable datetimes and time periods ("Up 3d 4h", "2019-12-31 23:59:59", "1.5s")


## Plugin Performance Data, Perfdata

"UOM" means "Unit of Measurement".

Sample:

```text
'label'=value[UOM];[warn];[crit];[min];[max];
```

`label` doesn't need to be machine friendly, so `Pages scanned=100;;;;;` is as valuable as `pages-scanned=100;;;;;`.

Suffixes:

```text
no unit specified - assume a number (int or float) of things (eg, users, processes, load averages)
s - seconds (also us, ms etc.)
% - percentage
B - bytes (also KB, MB, TB etc.). Bytes preferred, they are exact.
c - a continous counter (such as bytes transmitted on an interface [so instead of 'B'])
```

Wherever possible, prefer percentages over absolute values to assist users in comparing different systems with different absolute sizes.

Be aware of already-aggregated values returned by systems and applications. Apache for example returns a value "137.5 kB/request". Sounds good, but this is not a value at the current time of measurement. Instead, it is the average of all requests during the lifetime of the Apache worker process. If you use this in some sort of Grafana panel, you just get a boring line which converges towards a constant value very fast. Not useful at all.

A monitoring plugin has to calculate such values always on its own. If this is not possible because of missing data, discard them.


## PEP8 Style Guide for Python Code

We use [PEP 8 -- Style Guide for Python Code](https://www.python.org/dev/peps/pep-0008/) (where it makes sense).


## docstring, pydoc

We document our [Libraries](https://git.linuxfabrik.ch/linuxfabrik/lib) using [numpydoc docstrings](https://numpydoc.readthedocs.io/en/latest/format.html#docstring-standard), so that calling `pydoc lib/base.py` works, for example.


## PyLint

To further improve code quality, we use [PyLint](https://www.pylint.org/) like so:

* Libs: `pylint mylib.py`
* Monitoring Plugins: `pylint --disable='invalid-name, missing-function-docstring, missing-module-docstring' plugin-name`

Have a look at [PyLint's message codes](http://pylint-messages.wikidot.com/all-codes).


## isort

To help sort the `import`-statements we use `isort`:

```bash
# to sort all imports
isort --recursive .

# sort in a single plugin
isort plugin-name
```


## Unit Tests

Unit tests are implemented using the `unittest` framework (<https://docs.python.org/3/library/unittest.html>). Have a look at the `fs-ro` plugin on how to implement unit tests. Rules of thumb:

* Within your `unit-test/run` file, call the plugin as a bash command, capture stdout, stderr and its return code (retc), and run your assertions against stdout, stderr and retc.
* To test a plugin that needs to run some tools that aren't on your machine or that can't provide special output, provide stdout/stderr files in `unit-test/stdout`, `unit-test/stderr` and/or `unit-test/retc` and a `--test` parameter to feed `stdout/stdout-file,stderr/stderr-file,expected-retc` into your plugin. If you get the `--test` parameter, skip the execution of your bash/psutil/whatever function.

If you want to implement unit tests based on containers, the following rules apply:

* Each container file does everything necessary to set up a running environment for the check plugin (e.g. install Python if you want to run the plugin inside the container).
* The `./run` unit test simply calls podman and, for each containerfile found, builds the container, injects the libs and the check plugin, and runs the tests - but does not modify the container in any other way.
* See the `keycloak-version` plugin for how to do this.

Running a unit test:

```bash
# cd into the plugin directory, then:
cd unit-test
# run the Python based test:
./run
```


## sudoers File

If the plugin requires `sudo`-permissions to run, please add the plugin to the `sudoers`-files for all supported operating systems in `assets/sudoers/`. The OS name should match the ansible variables `ansible_facts['distribution'] + ansible_facts['distribution_major_version']` (eg `CentOS7`). Use symbolic links to prevent duplicate files.

<div class="attention">

<div class="title">

Attention

</div>

The newline at the end is required!

</div>


## Icinga Director Basket Config

Each plugin should provide its required Director config in form of a Director basket. The basket usually contains at least one Command, one Service Template and some associated Datafields. The rest of the Icinga Director configuration (Host Templates, Service Sets, Notification Templates, Tag Lists, etc) can be placed in the `assets/icingaweb2-module-director/all-the-rest.json` file.

The Icinga Director Basket for one or all plugins can be created using the `check2basket` tool.

> **Always review the basket before committing.**


### Create a Basket File from Scratch

After writing a new check called `new-check`, generate a basket file using:

```
./tools/check2basket --plugin-file check-plugins/new-check/new-check
```

The basket will be saved as `check-plugins/new-check/icingaweb2-module-director/new-check.json`. Inspect the basket, paying special attention to:

* Command: `timeout`
* ServiceTemplate: `check_interval`
* ServiceTemplate: `criticality`
* ServiceTemplate: `enable_perfdata`
* ServiceTemplate: `max_check_attempts`
* ServiceTemplate: `retry_interval`


### Fine-tune a Basket File

**Never directly edit a basket JSON file.** If adjustments must be made to the basket, create a YML/YAML config file for `check2basket`.

For example, to set the timeout to 30s, to enable notifications and some other options, the config in `check-plugins/new-check/icingaweb2-module-director/new-check.yml` should look as follows:

```yml
---
variants:
  - linux
  - windows

overwrites:
  '["Command"]["cmd-check-new-check"]["command"]': '/usr/bin/sudo /usr/lib64/nagios/plugins/new-check'
  '["Command"]["cmd-check-new-check"]["timeout"]': 30
  '["ServiceTemplate"]["tpl-service-new-check"]["check_command"]': 'cmd-check-new-check-sudo'
  '["ServiceTemplate"]["tpl-service-new-check"]["check_interval"]': 3600
  '["ServiceTemplate"]["tpl-service-new-check"]["enable_perfdata"]': true
  '["ServiceTemplate"]["tpl-service-new-check"]["max_check_attempts"]': 5
  '["ServiceTemplate"]["tpl-service-new-check"]["retry_interval"]': 30
  '["ServiceTemplate"]["tpl-service-new-check"]["use_agent"]': false
  '["ServiceTemplate"]["tpl-service-new-check"]["vars"]["criticality"]': 'C'
```

Then, re-run `check2basket` to apply the overwrites:

```
./tools/check2basket --plugin-file check-plugins/new-check/new-check
```

If a parameter was added, changed or deleted in the plugin, simply re-run the `check2basket` to update the basket file.


### Basket File for different OS

The `check2basket` tool also offers to generate so-called `variants` of the checks (different flavours of the check command call to run on different operating systems):

* `linux`: This is the default, and will be used if no other variant is defined. It generates a `cmd-check-...`, `tpl-service-...` and the associated datafields.
* `windows`: Generates a `cmd-check-...-windows`, `cmd-check-...-windows-python`, `tpl-service-...-windows` and the associated datafields.
* `sudo`: Generates a `cmd-check-...-sudo` importing the `cmd-check-...`, but with `/usr/bin/sudo` prepended to the command, and a `tpl-service...-sudo` importing the `tpl-service...`, but with the `cmd-check-...-sudo` as the check command.
* `no-agent`: Generates a `tpl-service...-no-agent` importing the `tpl-service...`, but with command endpoint set to the Icinga2 master.

Specify them in the `check-plugins/new-check/icingaweb2-module-director/new-check.yml` configuration as follows:

```yml
---
variants:
  - linux
  - sudo
  - windows
  - no-agent
```


### Create Basket Files for all Check Plugins

To run `check2basket` against all checks, for example due to a change in the `check2basket` script itself, use:

```bash
./tools/check2basket --auto
```


### Service Sets

If you want to create a Service Set, edit `assets/icingaweb2-module-director/all-the-rest.json` and append the definition using JSON. Provide new unique UUIDs. Do a syntax check using `cat assets/icingaweb2-module-director/all-the-rest.json | jq` afterwards.

If you want to move a service from one Service Set to another, you have to create a new UUID for the new service (this isn't even possible in the Icinga Director GUI).


## Grafana Dashboards

The title of the dashboard should be capitalized, the name has to match the folder/plugin name (spaces will be replaced with `-`, `/` will be ignored. eg `Network I/O` will become `network-io`). Each Grafana panel should be meaningful, especially when comparing it to other related panels (eg memory usage and CPU usage).


## Plugins and Capabilities

Incomplete list of special features in some check-plugins.

README explains Python regular expression negative lookaheads to exclude matches:

* [by-ssh](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/by-ssh)

Lists "Top X" values (search for `--top` parameter):

* [cpu-usage](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cpu-usage)
* [disk-io](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-io)
* [file-descriptors](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-descriptors)
* [memory-usage](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/memory-usage)
* [swap-usage](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/swap-usage)

Alerts only after a certain amount of calls (search for `--count` parameter):

* [cpu-usage](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cpu-usage)

Cuts (truncates) its SQLite database table:

* [cpu-usage](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cpu-usage)

Pure/raw network communication using byte-structs and sockets:

* [dhcp-relayed](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dhcp-relayed)

Checks for a minimum required 3rd party library version:

* [disk-io](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-io)

"Learns" thresholds on its own (implementing some kind of "threshold warm-up"):

* [disk-io](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-io)

Ports of applications:

* [disk-smart](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-smart): port of [GSmartControl](https://github.com/ashaduri/gsmartcontrol) to Python.
* All mysql-\* plugins: Port of [MySQLTuner](https://github.com/major/MySQLTuner-perl) to Python.

Makes use of `FREE` and `USED` wording in parameters:

* [disk-usage](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-usage)

`--perfdata-regex` parameter lets you filter for a subset of performance data:

* [disk-usage](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-usage)

Is aware of its acknowledgement status in Icinga, and will suppress further warnings if it has been ACKed:

* [feed](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/feed)
* [logfile](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/logfile)

Calculates mean and median perfdata over a set of individual items:

* [file-age](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-age)

Supports human-readable Nagios ranges for bytes:

* [file-size](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-size)

Sanitizes complex data before querying MySQL/MariaDB:

* [librenms-alerts](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/librenms-alerts)

Reads a file line-by-line, but backwards:

* [logfile](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/logfile)

Makes heavy use of patterns versus compiled regexes, matching any() of them:

* [logfile](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/logfile)

Using application's config file for authentication:

* All mysql-\* plugins

Optionally uses an asset:

* [php-status](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-status): relies on `monitoring.php` that can provide more PHP insight in the context of the web server

Provides useful feedback from Redis' Memory Doctor:

* [redis-status](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redis-status)

Work without the `jolokia.war` plugin and use the native API:

* All wildfly-\* checks

Supports human-readable Nagios ranges for durations:

* [uptime](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/uptime)

Differentiates between Windows and Linux (search for `lib.base.LINUX` or `lib.base.WINDOWS`):

* [users](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/users)

Unit tests use Docker/Podman to test against a range of versions or a reange of operating systems / OS's:

* [cpu-usage](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cpu-usage)
* [keycloak-version](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/keycloak-version) (checking the filesystem in the container as well as the API)

Read ini files (example use case: password file parsing):

* [icinga-topflap-services](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/icinga-topflap-services)
