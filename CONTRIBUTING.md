# Contributing


## Linuxfabrik Standards

The following standards apply to all Linuxfabrik repositories.


### Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).


### Issue Tracking

Open issues are tracked on GitHub Issues in the respective repository.


### Pre-commit

Some repositories use [pre-commit](https://pre-commit.com/) for automated linting and formatting checks. If the repository contains a `.pre-commit-config.yaml`, install [pre-commit](https://pre-commit.com/#install) and configure the hooks after cloning:

```bash
pre-commit install
```


### Commit Messages

Commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification:

```
<type>(<scope>): <subject>
```

If there is a related issue, append `(fix #N)`:

```
<type>(<scope>): <subject> (fix #N)
```

`<type>` must be one of:

- `chore`: Changes to the build process or auxiliary tools and libraries
- `docs`: Documentation only changes
- `feat`: A new feature
- `fix`: A bug fix
- `perf`: A code change that improves performance
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `style`: Changes that do not affect the meaning of the code (whitespace, formatting, etc.)
- `test`: Adding missing tests


### Changelog

Document all changes in `CHANGELOG.md` following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Sort entries within sections alphabetically.


### Language

Code, comments, commit messages, and documentation must be written in English.


### Coding Conventions

- Sort variables, parameters, lists, and similar items alphabetically where possible.
- Always use long parameters when using shell commands.
- Use RFC [5737](https://datatracker.ietf.org/doc/html/rfc5737), [3849](https://datatracker.ietf.org/doc/html/rfc3849), [7042](https://datatracker.ietf.org/doc/html/rfc7042#section-2.1.1), and [2606](https://datatracker.ietf.org/doc/html/rfc2606) in examples and documentation:
    - IPv4: `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`
    - IPv6: `2001:DB8::/32`
    - MAC: `00-00-5E-00-53-00` through `00-00-5E-00-53-FF` (unicast), `01-00-5E-90-10-00` through `01-00-5E-90-10-FF` (multicast)
    - Domains: `*.example`, `example.com`


---


## Check Plugin Developer Guidelines

Use the [example](check-plugins/example/example) plugin as a skeleton for new plugins. It demonstrates all standard patterns, library functions, and coding conventions described below.


### Monitoring of an Application

Monitoring an application can be complex and produce a wide variety of data. In order to standardize the handling of threshold values on the command line, to reduce the number of command line parameters and their interdependencies and to enable independent and thus extended designs of the Grafana panels, each topic should be dealt with in a separate check (following the Linux mantra: "one tool, one task").

Avoid an extensive check that covers a wide variety of aspects:

* `myapp --action threading --warning 1500 --critical 2000`
* `myapp --action memory-usage --warning 80 --critical 90`
* `myapp --action deployment-status` (warning and critical command line options not supported)

Better write three separate checks:

* `myapp-threading --warning 1500 --critical 2000`
* `myapp-memory-usage --warning 80 --critical 90`
* `myapp-deployment-status`

All plugins are written in Python and will be licensed under the [UNLICENSE](https://unlicense.org/), which is a license with no conditions whatsoever that dedicates works to the public domain.


### Setting up your Development Environment

All plugins are coded using Python 3.9. Simply clone the libraries and monitoring plugins and start working:

```bash
git clone git@github.com:Linuxfabrik/lib.git
git clone git@github.com:Linuxfabrik/monitoring-plugins.git
```


### Deliverables

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


### Rules of Thumb

* Be brief by default. Report what needs to be reported to fix a problem. If there is more information that might help the admin, support a `--lengthy` parameter.
* The plugin should be "self configuring" and/or using best practise defaults, so that it runs without parameters wherever possible.
* Develop with a minimal Linux in mind.
* Develop with Icinga2 in mind.
* Avoid complicated or fancy (and therefore unreadable) Python statements.
* If possible avoid libraries that have to be installed.
* Validate user input.
* It is ok to use temp files if needed.
* Much better: use a local SQLite database if you want to use a temp file.
* Keep in mind: Plugins have a limited runtime - typically 10 seconds max. Therefore it is ideal if the plugin executes fast and uses minimal resources (CPU time, memory etc.).
* Timeout gracefully on errors (for example `df` on a failed network drive) and return WARN.
* Return UNKNOWN on missing dependencies or wrong parameters.
* Mainly return WARN. Only return CRIT if the operators want to or have to wake up at night. CRIT means "react immediately".
* EAFP: Easier to ask for forgiveness than permission. This common Python coding style assumes the existence of valid keys or attributes and catches exceptions if the assumption proves false. This clean and fast style is characterized by the presence of many try and except statements.


### Return Codes

Plugins must return one of the following POSIX-compliant exit codes. Use the constants from `lib.base`:

| Exit Code | Status | Constant | Meaning |
|---|---|---|---|
| 0 | OK | `STATE_OK` | Service functioning properly |
| 1 | Warning | `STATE_WARN` | Service above warning threshold or not working properly |
| 2 | Critical | `STATE_CRIT` | Service not running or above critical threshold |
| 3 | Unknown | `STATE_UNKNOWN` | Invalid arguments, missing dependencies, or internal plugin failures |

Guidelines:

* Return `STATE_UNKNOWN` on missing dependencies, wrong parameters, or when `--help`/`--version` is requested.
* Return `STATE_WARN` for most alert conditions. Only return `STATE_CRIT` if the situation requires immediate human intervention ("wake up at night").
* Never return any exit code other than 0, 1, 2, or 3.
* Use `lib.base.oao()` (output and out) to print the result and exit with the appropriate state in a single call.


### Bytes vs. Unicode

Short:

* Use `txt.to_text()` and `txt.to_bytes()`.

The theory:

* Data coming into your plugins must be bytes, encoded with `UTF-8`.
* Decode incoming bytes as soon as possible (best by using the `txt` library), producing unicode.
* **Use unicode throughout your plugin.**
* When outputting data, use library functions, they should do output conversions for you. Library functions like `base.oao` or `url.fetch_json` will take care of the conversion to and from bytes.

See <https://nedbatchelder.com/text/unipain.html> for details.


### Names, Naming Conventions

The plugin name should match the following regex: `^[a-zA-Z0-9\-\_]*$`. This allows the plugin name to be used as the grafana dashboard uid (according to [here](https://github.com/grafana/grafana/blob/552ecfeda320a422bfc7ca9978c94ffea887134a/pkg/util/shortid_generator.go#L11)).


### Parameters, Option Processing

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

Every plugin must support at least `--help` and `--version`:

* `--help` (`-h`): Print a short usage statement followed by a detailed description of all options with their defaults. Keep the output within 80 characters width. Exit with `STATE_UNKNOWN` (3).
* `--version` (`-V`): Print the plugin name and version (`__version__`). Exit with `STATE_UNKNOWN` (3).

Positional arguments are not allowed. All parameters must be named options.

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

**Threshold parameters** (`--warning`, `--critical`) in new plugins must use `type=str` (not `int` or `float`) to support [Nagios range expressions](https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT) like `80`, `10:`, `~:50`, `@10:20`. In `main()`, use `lib.base.get_state(value, args.WARN, args.CRIT, _operator='range')`. See the [example](check-plugins/example/example) plugin and the [Threshold and Ranges](#threshold-and-ranges) section for details.

Hints:

* For complex parameter tupels, use the `csv` type. `--input='Name, Value, Warn, Crit'` results in `[ 'Name', 'Value', 'Warn', 'Crit' ]`
* For repeating parameters, use the `append` action. A `default` variable has to be a list then. `--input=a --input=b` results in `[ 'a', 'b' ]`
* If you combine `csv` type and `append` action, you get a two-dimensional list: `--repeating-csv='1, 2, 3' --repeating-csv='a, b, c'` results in `[['1', '2', '3'], ['a', 'b', 'c']]`
* If you want to provide default values together with `append`, in `parser.add_argument()`, leave the `default` as `None`. If after `main:parse_args()` the value is still `None`, put the desired default list (or any other object) there. The primary purpose of the parser is to parse the commandline - to figure out what the user wants to tell you. There's nothing wrong with tweaking (and checking) the `args` Namespace after parsing. (According to <https://bugs.python.org/issue16399>)
* When it comes to parameters, stay backwards compatible. If you have to rename or drop parameters, keep the old ones, but silently ignore them. This helps admins deploy the monitoring plugins to thousands of servers, while the monitoring server is updated later for various reasons. To be as tolerant as possible, replace the parameter's help text with `help=argparse.SUPPRESS`:

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

* A plugin should tolerate unknown parameters. Imagine an monitoring system that checks thousand hosts. You want to update a plugin offering a new parameter that is essential for you, so you adjust the service definition, add the new parameter and update the plugin on one host. The non-updated plugin on the other 999 hosts will throw an 'UNKNOWN' error when argparse is used with `parser.parse_args()`. This would significantly disrupt operations and cause stress. Therefore, it makes more sense to be tolerant and use `parser.parse_known_args()`.


#### Parameter Help Text Format

Help texts must be consistent across all plugins. Each property of a parameter goes on its own line (using Python implicit string concatenation). This makes it easy to scan, compare, and maintain. The order is:

1. Purpose (what the parameter does)
2. Data type or format (if not obvious)
3. Regex or case-sensitivity note (if applicable)
4. Repeating note (if applicable)
5. Nagios range support (if applicable)
6. Example (if helpful)
7. Default value (always last, always present if there is one)

Standard help texts for common parameters are defined centrally in `lib.args.HELP_TEXTS`. Use `lib.args.help('--parameter-name')` wherever possible instead of writing help text inline:

```python
# standard parameter - use lib.args.help()
parser.add_argument(
    '--timeout',
    help=lib.args.help('--timeout'),
    dest='TIMEOUT',
    type=int,
    default=DEFAULT_TIMEOUT,
)

# plugin-specific parameter - write help text inline, same format
parser.add_argument(
    '--token',
    help='Software API token.',
    dest='TOKEN',
    required=True,
)

# plugin-specific prefix + global help text
parser.add_argument(
    '--url',
    help='GitLab health URL endpoint. ' + lib.args.help('--url'),
    dest='URL',
    default=DEFAULT_URL,
)
```

Rules:

* Use `%(default)s` for defaults, never hardcode the value. Omit the default for `store_true`/`store_false` switches (e.g. `--always-ok`, `--insecure`, `--no-proxy`, `--lengthy`) since they are always False when not specified.
* Defaults and examples go on their own lines.
* Say "Can be specified multiple times." for `action='append'` parameters (not "(repeating)").
* Say "Supports Nagios ranges." when `lib.base.get_state()` is used with the value.
* Always state case-sensitivity explicitly: "Case-insensitive." or "Case-sensitive."
* Say "Uses Python regular expressions." when the parameter accepts a regex.
* End every help text with a period.
* Parameters that are identical across plugins must use identical help texts.


### Commit Scopes

Use the plugin name as commit scope:

```
fix(about-me): cryptography deprecation warning (fix #341)
```

For the first commit, use the message `Add <plugin-name>`.


### Threshold and Ranges

If a threshold has to be handled as a range parameter, this is how to interpret them. Compatible with the [Monitoring Plugins Development Guidelines](https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT) and the [Nagios Plugin Development Guidelines](https://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT).

The generalized range format is `[@]start:end`:

* `start` must be less than or equal to `end`.
* `start` and `:` are not required if `start` is 0.
* simple value: a range from 0 up to and including the value
* empty value after `:`: positive infinity
* `~`: negative infinity
* `@`: if range starts with "@", then alert if inside this range (including endpoints)
* An alert is raised if the metric is **outside** the range (inclusive of endpoints). The `@` prefix inverts this logic.

Examples:

| `-w, -c` | OK if result is | WARN/CRIT if |
|---|---|---|
| 10 | in (0..10) | not in (0..10) |
| -10:0 | in (-10..0) | not in (-10..0) |
| 10: | in (10..inf) | not in (10..inf) |
| : | in (0..inf) | not in (0..inf) |
| ~:10 | in (-inf..10) | not in (-inf..10) |
| 10:20 | in (10..20) | not in (10..20) |
| @10:20 | not in (10..20) | in 10..20 |
| @~:20 | not in (-inf..20) | in (-inf..20) |
| @ | not in (0..inf) | in (0..inf) |

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


### Caching temporary data, SQLite database

Use `cache` if you need a simple key-value store, for example as used in `nextcloud-version`. Otherwise, use `db_sqlite` as used in `cpu-usage`.


### Error Handling

* Catch exceptions using `try`/`except`, especially in functions. Never use bare `except:` without specifying the exception type. Use `except Exception:` as the broadest acceptable catch-all.
* In functions, if you have to catch exceptions, on such an exception always return `(False, errormessage)`. Otherwise return `(True, result)` if the function succeeds in any way. For example, returning `(True, False)` means that the function has not raised an exception and its result is simply `False`.
* A function calling a function with such an extended error handling has to return a `(retc, result)` tuple itself.
* In `main()` you can use `lib.base.coe()` to simplify error handling.
* Have a look at `nextcloud-version` for details.

By the way, when running the compiled variants, this gives the nice and intended error if the module is missing:

```python
try:
    import psutil
except ImportError:
    print('Python module "psutil" is not installed.')
    sys.exit(STATE_UNKNOWN)
```

while this leads to an ugly multi-exception stacktrace:

```python
try:
    import psutil
except ImportError:
    lib.base.cu('Python module "psutil" is not installed.')
```


### Timeout Handling

Plugins have a limited runtime - typically 10 seconds max. Every plugin must handle timeouts gracefully to prevent hanging processes (e.g. `df` on a failed network drive, unresponsive API endpoints, stuck database connections).

* Always support a `--timeout` parameter (default: 8 seconds, leaving headroom for Icinga's own 10s timeout).
* Use `lib.base.coe(lib.url.fetch(..., timeout=args.TIMEOUT))` for HTTP requests - the library handles timeouts.
* For shell commands, pass a timeout to `lib.shell.shell_exec()`.
* If a timeout occurs, return `STATE_WARN` with a meaningful message (e.g. "Timeout after 8s while connecting to ...").


### Security

* **External commands**: When executing system commands, use `lib.shell.shell_exec()`. Avoid `os.system()` or `subprocess` with `shell=True`, as these are vulnerable to shell injection. The official Monitoring Plugins guidelines require full paths for all external commands to prevent PATH-based trojan hijacking. Our `lib.shell.shell_exec()` uses `subprocess` with `shell=False`, which eliminates shell injection. We accept PATH-based command resolution for cross-platform compatibility (paths differ across distributions), but be aware that a compromised PATH could still redirect commands.
* **Input validation**: Validate all user-supplied input. Use `argparse` type converters (`type=int`, `type=float`, `type=lib.args.csv`) to enforce expected types.
* **Temporary files**: Avoid temporary files where possible. Prefer a local SQLite database via `lib.db_sqlite` or `lib.cache`. If temp files are unavoidable, fail cleanly if the file cannot be created, and delete it when done.
* **Symlinks**: If a plugin opens or reads files, ensure it does not follow symlinks to unintended locations.
* **Credentials**: Never log or print passwords, tokens, or other secrets in plugin output - not even in verbose mode.
* **Network communication**: Use HTTPS by default. Support `--insecure` to allow self-signed certificates where needed, but never make insecure the default.


### Plugin Output

Plugins must only print to STDOUT. Never print to STDERR, as Icinga/Nagios does not capture it.

The output structure follows the Monitoring Plugins standard:

```text
STATUS_TEXT - summary message | perfdata
detailed line 1
detailed line 2 | more_perfdata
```

The first line is the most important - Icinga/Nagios uses it for notifications, web interface display, and SMS alerts. Everything after the first newline is considered "long output" and only shown in detail views.

Rules:

* Print a short concise message in the first line within the first 80 chars if possible.
* Use multi-line output for details (`msg_body`), with the most important output in the first line (`msg_header`).
* Performance data is separated from text output by a pipe (`|`) character. Additional perfdata can follow on subsequent lines after a pipe.
* Do not use the pipe character (`|`) in the text output itself, as Icinga/Nagios uses it as a delimiter to separate text from performance data. `lib.base.oao()` automatically replaces stray pipes in the message.
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


### Verbose Output

If a plugin supports `-v`/`--verbose`, it should implement up to three verbosity levels (stackable `-v -v -v` or `--verbose --verbose --verbose`):

| Level | Output |
|---|---|
| 0 (default) | Single-line summary, minimal output |
| 1 (`-v`) | Single-line with additional detail (e.g. list of affected items) |
| 2 (`-v -v`) | Multi-line with configuration debug info (e.g. commands executed, API endpoints queried) |
| 3 (`-v -v -v`) | Extensive diagnostic detail for troubleshooting |

Note: Most of our plugins use `--lengthy` instead of `-v` for extended output. The verbosity levels above apply if the plugin explicitly supports `--verbose`.


### Plugin Performance Data, Perfdata

"UOM" means "Unit of Measurement".

Format (space-separated label/value pairs):

```text
'label'=value[UOM];[warn];[crit];[min];[max]
```

Rules:

* Labels may contain any characters except `=` (equals) and `'` (single quote).
* Single quotes around the label are optional but required if the label contains spaces.
* The first 19 characters of a label should be unique (RRD data source limitation).
* `value`, `min`, and `max` must match the character class `[-0-9.]` and share the same UOM.
* `warn` and `crit` use the range format (see [Threshold and Ranges](#threshold-and-ranges)).
* `min` and `max` are not required for percentage (`%`) UOM.
* Trailing unfilled semicolons may be dropped.
* `label` doesn't need to be machine friendly, so `Pages scanned=100;;;;;` is as valuable as `pages-scanned=100;;;;;`.

UOM suffixes:

```text
no unit specified - assume a number (int or float) of things (eg, users, processes, load averages)
s - seconds (also us, ms etc.)
% - percentage
B - bytes (also KB, MB, TB etc.). Bytes preferred, they are exact.
c - a continuous counter (such as bytes transmitted on an interface [so instead of 'B']) - do not use
```

**Do not use continuous counters** (`c`). Instead, calculate the delta between two measurements in the plugin itself and emit the result as an absolute value with a real unit ([#320](https://github.com/Linuxfabrik/monitoring-plugins/issues/320)). Store the previous measurement in a local SQLite database using `lib.db_sqlite`. This approach:

* Avoids forcing Grafana to compute `non_negative_difference()` over millions of data points on every panel refresh.
* Enables correct aggregation in Grafana (`mean()`, `min()`, `max()` work as expected on absolute values, but produce wrong results on cumulative counters).
* Allows meaningful legend tables (first, min, mean, max, last) in Grafana panels.
* Preserves the actual unit of measurement (`B`, `%`, `s`, etc.) in perfdata.
* Saves resources on the monitoring server by doing the calculation once per check run instead of repeatedly in Grafana.

See the [example](check-plugins/example/example) plugin for a complete implementation of this pattern.

Wherever possible, prefer percentages over absolute values to assist users in comparing different systems with different absolute sizes.

Be aware of already-aggregated values returned by systems and applications. Apache for example returns a value "137.5 kB/request". Sounds good, but this is not a value at the current time of measurement. Instead, it is the average of all requests during the lifetime of the Apache worker process. If you use this in some sort of Grafana panel, you just get a boring line which converges towards a constant value very fast. Not useful at all.

A monitoring plugin has to calculate such values always on its own. If this is not possible because of missing data, discard them.


### PEP 8

We use [PEP 8 -- Style Guide for Python Code](https://www.python.org/dev/peps/pep-0008/) where it makes sense.

**String quoting:** Use single quotes as the default. Use double quotes only inside f-string expressions (e.g. `f'{lib.base.state2str(state, prefix=" ")}'`) or when the string itself contains single quotes (e.g. `'Python module "psutil" is not installed.'`). Use `"""` for all triple-quoted strings (docstrings, `DESCRIPTION`, SQL, etc.). This is enforced by `ruff format`.


### DESCRIPTION Variable

Every plugin must define a `DESCRIPTION` variable that is passed to `argparse.ArgumentParser(description=DESCRIPTION)`. Rules:

* At least 2-3 sentences that explain what the plugin does, from the perspective of the admin deploying it.
* Written in fluent English, no implementation details (no mention of library functions, class names, or internal patterns).
* The first sentence must describe the purpose: what the plugin monitors or collects (e.g. "Monitors CPU utilization on ...", "Checks the installed ... version against ...").
* Must include at least one "Alerts when ..." or "Alerts if ..." clause that tells the admin under which conditions the plugin raises a warning or critical state.
* Use `"""` triple quotes.
* Keep line length around 90 characters.
* Plugins of the same type (e.g. all `-version` checks, all `huawei-dorado-*` checks) must use identical or near-identical DESCRIPTION text, with only the product name swapped. Consistency across plugin families is mandatory.
* If the plugin has a sudoers file in `assets/sudoers/`, the DESCRIPTION must end with "Requires root or sudo."
* If the plugin uses `lib.smb`, the DESCRIPTION must mention SMB share support.
* If the plugin uses `--count` for consecutive threshold violations (Handles Periods), the DESCRIPTION must mention this behavior, e.g. "Alerts only if the threshold has been exceeded for a configurable number of consecutive check runs (default: 5), suppressing short spikes."
* If the plugin supports `--lengthy`, the DESCRIPTION must mention "Supports extended reporting via --lengthy."
* The README Overview must include at least the text from the `DESCRIPTION`.


### Docstrings

We document our [Libraries](https://git.linuxfabrik.ch/linuxfabrik/lib) using [numpydoc docstrings](https://numpydoc.readthedocs.io/en/latest/format.html#docstring-standard), so that calling `pydoc lib/base.py` works, for example.


### Ruff

We use [ruff](https://docs.astral.sh/ruff/) as the primary linter and formatter. It covers PEP 8 enforcement, import sorting (replaces isort), and common bug patterns. Configuration is in `pyproject.toml`. Both `ruff-check` and `ruff-format` run automatically as pre-commit hooks.

```bash
# check a single plugin
ruff check check-plugins/my-check/my-check

# format a single plugin
ruff format check-plugins/my-check/my-check
```


### PyLint

PyLint runs as a second linter after ruff in the pre-commit hooks. It catches additional issues that ruff does not cover (e.g. undefined variables across module boundaries).

```bash
# lint a single plugin
pylint check-plugins/my-check/my-check
```


### Unit Tests

Unit tests are implemented using the `unittest` framework (<https://docs.python.org/3/library/unittest.html>) with a declarative, data-driven approach. Test definitions are a list of dicts, executed via `lib.lftest.run()` and `unittest.subTest()`. See the [example](check-plugins/example/unit-test/run) plugin for the reference implementation.


#### Test directory structure

```text
check-plugins/my-check/unit-test/
├── run                     # the test file
└── stdout/                 # test data files (fixtures)
    ├── empty-response      # scenario-based names, not EXAMPLE01
    ├── three-nodes-healthy
    └── three-nodes-one-down
```

Only create `stderr/` if a test actually needs to inject stderr data. Do not create empty `retc/` or `stderr/` directories.


#### Test data file naming

Fixture files in `stdout/` are named after the **scenario** they represent, not after an expected plugin state. The expected state depends on the combination of fixture content and plugin parameters (thresholds, filters, switches) and therefore cannot be encoded in the fixture filename alone.

Use descriptive, lowercase, hyphenated names that describe the shape of the data:

* `empty-response`, `single-node`, `three-nodes-healthy`
* `cpu-80-percent`, `disk-nearly-full`, `memory-400mb-used`
* `three-nodes-one-down`, `malformed-json`, `service-unreachable`

The same fixture may (and should) be reused by multiple testcases that vary the plugin parameters to reach different states. For example, a single `cpu-80-percent` fixture can drive an `ok-below-warn` test with `--warning 90 --critical 95`, a `warn-above-warn` test with `--warning 70 --critical 95`, and a `crit-above-crit` test with `--warning 50 --critical 75`.

The expected state is encoded in the testcase `id` instead (see below).


#### Writing tests

Define a `TESTS` list and use `lib.lftest.run()` to execute each testcase. The testcase `id` should lead with the expected state (`ok-`, `warn-`, `crit-`, `unknown-`), followed by a short description of what is being verified. This is what appears in the subtest output and documents the intent of each case.

```python
#!/usr/bin/env python3
import sys
sys.path.append('..')

import unittest

from lib.globals import STATE_CRIT, STATE_OK, STATE_UNKNOWN, STATE_WARN
import lib.lftest


TESTS = [
    # Same fixture, three different threshold combinations.
    {
        'id': 'ok-below-warn',
        'test': 'stdout/cpu-80-percent,,0',
        'params': '--warning 90 --critical 95',
        'assert-retc': STATE_OK,
        'assert-in': ['80%'],
    },
    {
        'id': 'warn-above-warn',
        'test': 'stdout/cpu-80-percent,,0',
        'params': '--warning 70 --critical 95',
        'assert-retc': STATE_WARN,
        'assert-regex': r'80%.*\[WARNING\]',
    },
    {
        'id': 'crit-above-crit',
        'test': 'stdout/cpu-80-percent,,0',
        'params': '--warning 50 --critical 75',
        'assert-retc': STATE_CRIT,
        'assert-regex': r'80%.*\[CRITICAL\]',
    },
    # Different fixture, different scenario.
    {
        'id': 'unknown-malformed-json',
        'test': 'stdout/malformed-json,,0',
        'params': '--warning 80 --critical 90',
        'assert-retc': STATE_UNKNOWN,
    },
]


class TestCheck(unittest.TestCase):

    check = '../my-check'

    def test(self):
        for t in TESTS:
            with self.subTest(id=t['id']):
                lib.lftest.run(self, self.check, t)


if __name__ == '__main__':
    unittest.main()
```

Naming rules for the testcase `id`:

* Lead with the expected state: `ok-`, `warn-`, `crit-`, `unknown-`.
* Follow with a short description of what the test verifies (not the fixture name): `ok-below-warn`, `warn-above-warn`, `crit-disk-full`, `unknown-missing-dependency`.
* `id` must be unique within the `TESTS` list.

Available assertion keys in each testcase dict:

* `assert-retc` (`int`, required): Expected return code (`STATE_OK`, `STATE_WARN`, `STATE_CRIT`, `STATE_UNKNOWN`).
* `assert-in` (`list` of `str`, optional): Strings that must appear in stdout.
* `assert-not-in` (`list` of `str`, optional): Strings that must not appear in stdout.
* `assert-regex` (`str`, optional): Regex pattern that must match stdout.
* `assert-stderr` (`str`, optional): Expected stderr content. Default: `''`.


#### Running tests

Unit tests come in two flavors:

* **Fast tests** use `--test` to inject fixture data and run in a fraction of a second. They are safe for CI and for the multi-Python-version `tox` matrix.
* **Container tests** build a podman image per target OS, inject the plugin and `lib/`, and exercise the check against a live service. They need podman on the host and take minutes per plugin. A plugin counts as a container test when its `unit-test/` directory has a `containerfiles/` subdirectory.

Everyday commands:

```bash
# single plugin (from its unit-test directory)
cd check-plugins/my-check/unit-test
./run

# single plugin (from the repo root)
python tools/run-unit-tests my-check

# all plugins (fast + container)
python tools/run-unit-tests

# only the fast tests (used by tox)
python tools/run-unit-tests --no-container

# only the container tests (also available as a thin wrapper)
python tools/run-unit-tests --only-container
python tools/run-container-tests
```

Multi-Python coverage via `tox`:

```bash
tox                      # all supported Python versions, fast tests only
tox -e py39              # single environment
```

`tox` invokes `tools/run-unit-tests --no-container` so the multi-Python matrix skips the container suite. Run `tools/run-container-tests` separately before a release for full integration coverage.

`tox` builds each Python environment from sdist, and `linuxfabrik-lib` pulls in `netifaces` which has no binary wheels on PyPI. For every Python version in the `tox` matrix you want to run locally, the matching development headers must be installed on the host, otherwise pip falls back to building `netifaces` from source and aborts with `fatal error: Python.h: No such file or directory`:

```bash
# Fedora
sudo dnf install python3.9-devel python3.10-devel python3.11-devel \
                 python3.12-devel python3.13-devel python3.14-devel

# Debian / Ubuntu
sudo apt install python3.9-dev python3.10-dev python3.11-dev \
                 python3.12-dev python3.13-dev python3.14-dev
```

`skip_missing_interpreters = true` already skips environments for Python versions that are not installed at all.


#### Container-based tests

If you want to implement unit tests based on containers, the following rules apply:

* Each container file does everything necessary to set up a running environment for the check plugin (e.g. install Python if you want to run the plugin inside the container).
* The `./run` unit test simply calls podman and, for each containerfile found, builds the container, injects the libs and the check plugin, and runs the tests - but does not modify the container in any other way.
* See the `keycloak-version` plugin for how to do this.
* `tools/run-unit-tests` auto-detects container tests by looking for a `containerfiles/` subdirectory, so `--no-container` / `--only-container` filter correctly without any per-plugin annotation.


### sudoers File

If the plugin requires `sudo`-permissions to run, please add the plugin to the `sudoers`-files for all supported operating systems in `assets/sudoers/`. The OS name should match the ansible variables `ansible_facts['distribution'] + ansible_facts['distribution_major_version']` (eg `CentOS7`). Use symbolic links to prevent duplicate files.

> **Attention:** The newline at the end is required!


### Icinga Director Basket Config

Each plugin should provide its required Director config in form of a Director basket. The basket usually contains at least one Command, one Service Template and some associated Datafields. The rest of the Icinga Director configuration (Host Templates, Service Sets, Notification Templates, Tag Lists, etc) can be placed in the `assets/icingaweb2-module-director/all-the-rest.json` file.

The Icinga Director Basket for one or all plugins can be created using the `check2basket` tool.

> **Always review the basket before committing.**


#### Create a Basket File from Scratch

After writing a new check called `new-check`, generate a basket file using:

```bash
./tools/check2basket --plugin-file check-plugins/new-check/new-check
```

The basket will be saved as `check-plugins/new-check/icingaweb2-module-director/new-check.json`. Inspect the basket, paying special attention to:

* Command: `timeout`
* ServiceTemplate: `check_interval`
* ServiceTemplate: `criticality`
* ServiceTemplate: `enable_perfdata`
* ServiceTemplate: `max_check_attempts`
* ServiceTemplate: `retry_interval`


#### Fine-tune a Basket File

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

```bash
./tools/check2basket --plugin-file check-plugins/new-check/new-check
```

If a parameter was added, changed or deleted in the plugin, simply re-run the `check2basket` to update the basket file.


#### Basket File for different OS

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


#### Create Basket Files for all Check Plugins

To run `check2basket` against all checks, for example due to a change in the `check2basket` script itself, use:

```bash
./tools/check2basket --auto
```


#### Service Sets

If you want to create a Service Set, edit `assets/icingaweb2-module-director/all-the-rest.json` and append the definition using JSON. Provide new unique UUIDs. Do a syntax check using `cat assets/icingaweb2-module-director/all-the-rest.json | jq` afterwards.

If you want to move a service from one Service Set to another, you have to create a new UUID for the new service (this isn't even possible in the Icinga Director GUI).


### README Structure

Each plugin README follows a fixed structure. See [check-plugins/example/README.md](check-plugins/example/README.md) for the reference template. The sections are:

1. **Overview**: Describes *what* the plugin does. A leading sentence stating the main purpose. This must include at least the text from the plugin's `DESCRIPTION` variable. Followed by subsections:

    * **Important Notes** (optional, but comes first if present): Operational edge cases the admin must know before deploying, for example: "Requires sudo", "Only works with Redis 3.0+", "First run returns OK with 'Waiting for more data.'", "After a reboot, counters reset and the check waits for a new baseline". No implementation details - only things that affect deployment and daily operations.
    * **Data Collection**: How data is gathered (shell command, API, psutil, etc.), filtering options, SQLite usage, non-blocking measurement.

2. **Fact Sheet**: Key properties as a table (download link, check name, check interval, parameters required, Windows support, 3rd party modules, state file path, etc.). Only list applicable rows.

    | Fact | Value |
    |----|----|
    | Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/example> |
    | Nagios/Icinga Check Name              | `check_example` (for SEO: helps admins find the plugin when searching for the traditional Nagios-style name). Always use underscores, never dashes. |
    | Check Interval Recommendation         | Every minute, Every 5/15/30 minutes, Every hour, Every 4/8/12 hours, Every day, Every week |
    | Can be called without parameters      | Yes/No |
    | Runs on                               | Cross-platform / Linux / Windows. Use "Cross-platform" by default since Python runs everywhere. Only use "Linux" if the plugin uses Linux-specific APIs (`/proc`, `systemd`, `dmesg`, `dnf`/`apt`/`yum`, `journalctl`, etc.). The absence of a `.windows` file does not mean the plugin is Linux-only. |
    | Compiled for Windows                  | Yes (when `.windows` file exists)/No (runs with Python interpreter) |
    | Requirements                          | command-line tool `foo`; User with higher permissions |
    | 3rd Party Python modules              | `module-name` |
    | Handles Periods                       | Yes (alerts only after `--count` consecutive threshold violations) |
    | Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-<plugin-name>.db` |

3. **Help**: The full `--help` output in a code block. Regenerate via `tools/update-readmes`.

4. **Usage Examples**: One or more realistic invocations with their output. Show at least one OK case. If the plugin has `--lengthy`, show both variants.

5. **States**: Describes *when* the plugin returns which state. Be precise about OK, WARN, CRIT, UNKNOWN conditions (e.g. "WARN if the percentage value is >= `--warning`"). Include `--always-ok` behavior, consecutive-run requirements, and first-run/reboot edge cases.

6. **Perfdata / Metrics**: Table with columns Name, Type, Description. Types: `Bytes`, `Number`, `Percentage`, `Seconds`. Where possible, use the metric descriptions from the vendor's official documentation (e.g. Redis INFO, psutil docs, API references).

7. **Troubleshooting** (optional): Known error messages with their solutions. Format: error message in backticks on its own line, followed by two trailing spaces for a Markdown line break, solution on the next line. Separate entries with a blank line.

8. **Credits, License**: Always present.


### Grafana Dashboards

The title of the dashboard should be capitalized, the name has to match the folder/plugin name (spaces will be replaced with `-`, `/` will be ignored. eg `Network I/O` will become `network-io`). Each Grafana panel should be meaningful, especially when comparing it to other related panels (eg memory usage and CPU usage).

Dashboard definitions are stored as YAML files in `check-plugins/<plugin-name>/grafana/`. Only define properties that differ from Grafana defaults to keep files minimal and maintainable.

Dashboards are currently managed using [Grizzly](https://github.com/grafana/grizzly) (`apiVersion: grizzly.grafana.com/v1alpha1`). Grizzly is being phased out in favor of [grafanactl](https://github.com/grafana/grafanactl) (`apiVersion: dashboard.grafana.app/v1`), which requires Grafana 12+. Continue using the Grizzly format for now. A migration to grafanactl is planned ([#1062](https://github.com/Linuxfabrik/monitoring-plugins/issues/1062)).


### Plugins and Capabilities

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

Unit tests use Docker/Podman to test against a range of versions or a range of operating systems:

* [cpu-usage](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cpu-usage)
* [keycloak-version](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/keycloak-version) (checking the filesystem in the container as well as the API)

Read ini files (example use case: password file parsing):

* [icinga-topflap-services](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/icinga-topflap-services)
