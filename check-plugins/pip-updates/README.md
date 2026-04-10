# Check pip-updates

## Overview

This plugin lets you track if updates for python packages installed via `pip` are available. May take more than 10 seconds to execute. For a detailed help on all parameters, have a look at `man pip3-list`.

Hints:

* Requires `pip` v20.3+.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/pip-updates> |
| Check Interval Recommendation         | Once a week |
| Can be called without parameters      | No |
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
venv /path/to/my/venv/bin/activate. pip is complaining about something or about itself, but most of the packages are up to date. 2 outdated packages. Executed command: `source /path/to/my/venv/bin/activate && python3 -m pip list --outdated --format=json --exclude=boto3 --exclude=pip --local`

Package  ! Version ! Latest  ! Type  
---------+---------+---------+-------
botocore ! 1.29.41 ! 1.29.78 ! wheel 
pyspnego ! 0.7.0   ! 0.8.0   ! wheel
```


## States

* If wanted, always returns OK,
* else returns WARN or CRIT if updates are available.


## Perfdata / Metrics

| Name                  | Type   | Description                |
|-----------------------|--------|----------------------------|
| pip_outdated_packages | Number | Number of pending updates. |


## Troubleshooting

This indicates that your version of `pip` is below 20.3:

```text
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/pip/_internal/cli/base_command.py", line 143, in main
    status = self.run(options, args)
  File "/usr/lib/python3/dist-packages/pip/_internal/commands/list.py", line 138, in run
    packages = self.get_outdated(packages, options)
  File "/usr/lib/python3/dist-packages/pip/_internal/commands/list.py", line 149, in get_outdated
    dist for dist in self.iter_packages_latest_infos(packages, options)
  File "/usr/lib/python3/dist-packages/pip/_internal/commands/list.py", line 150, in <listcomp>
    if dist.latest_version > dist.parsed_version
TypeError: '>' not supported between instances of 'Version' and 'Version'
```

So simply upgrade by using `python3 -m pip install --upgrade pip`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
