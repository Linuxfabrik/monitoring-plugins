# Check pip-updates

## Overview

Checks for outdated Python packages installed via pip. Reports the number of packages with available updates and lists them with current and latest versions.

**Important Notes:**

* Requires `pip` v20.3+



**Data Collection:**

* Executes `python3 -m pip list --outdated --format=json` to get the list of outdated packages
* Optionally sources a virtualenv activate script before checking
* Supports all standard pip options for index URLs, exclusions, and package filtering
* May take more than 10 seconds to execute depending on the number of installed packages and network latency

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/pip-updates> |
| Nagios/Icinga Check Name              | `check_pip_updates` |
| Check Interval Recommendation         | Once a week |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | `pip` v20.3+ |


## Help

```text
usage: pip-updates [-h] [-V] [--always-ok] [-c CRIT] [--exclude EXCLUDE]
                   [--extra-index-url EXTRA_INDEX_URL]
                   [--find-links FIND_LINKS] [--index-url INDEX_URL] [--local]
                   [--no-index] [--not-required] [--pre] [--test TEST]
                   [--user] [--virtualenv VIRTUALENV] [-w WARN]

Checks for outdated Python packages installed via pip. Reports the number of
packages with available updates and lists them. Alerts when the count exceeds
the configured threshold.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the number of outdated packages.
                        Default: 100
  --exclude EXCLUDE     Package name to exclude from the output. Can be
                        specified multiple times.
  --extra-index-url EXTRA_INDEX_URL
                        Extra URL of a package index to use in addition to
                        --index-url. Should follow the same rules as --index-
                        url. Can be specified multiple times.
  --find-links FIND_LINKS
                        URL or path to an HTML file to parse for links to
                        archives (.tar.gz, .whl). If a local path or file://
                        URL pointing to a directory, look for archives in the
                        directory listing. VCS project URLs are not supported.
                        Can be specified multiple times.
  --index-url INDEX_URL
                        Base URL of the Python Package Index (PEP 503
                        compliant repository or local directory in the same
                        format).
  --local               If in a virtualenv that has global access, do not list
                        globally-installed packages.
  --no-index            Ignore the package index and only look at --find-links
                        URLs.
  --not-required        Only list packages that are not dependencies of other
                        installed packages.
  --pre                 Include pre-release and development versions. By
                        default, pip only finds stable versions.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --user                Only check packages installed in the user-site
                        directory.
  --virtualenv VIRTUALENV
                        Path to a virtualenv activate script to source before
                        checking for updates. Example: `/opt/sphinx-
                        venv/bin/activate`
  -w, --warning WARN    WARN threshold for the number of outdated packages.
                        Default: 10
```


## Usage Examples

```bash
./pip-updates --virtualenv /path/to/my/venv/bin/activate --local --exclude boto3 --exclude pip
```

Output:

```text
venv /path/to/my/venv/bin/activate. pip is complaining about something or about itself, but most of the packages are up to date. 2 outdated packages. Executed command: `source /path/to/my/venv/bin/activate && python3 -m pip list --outdated --exclude=boto3 --exclude=pip --local`

Package  ! Version ! Latest  ! Type  
---------+---------+---------+-------
botocore ! 1.29.41 ! 1.29.78 ! wheel 
pyspnego ! 0.7.0   ! 0.8.0   ! wheel
```


## States

* OK if the number of outdated packages is below the warning threshold.
* WARN if the number of outdated packages is >= `--warning` (default: 10).
* CRIT if the number of outdated packages is >= `--critical` (default: 100).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name                  | Type   | Description                |
|-----------------------|--------|----------------------------|
| pip_outdated_packages | Number | Number of outdated packages. |


## Troubleshooting

`TypeError: '>' not supported between instances of 'Version' and 'Version'`
This indicates that your version of `pip` is below 20.3. Upgrade by running `python3 -m pip install --upgrade pip`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
