# Check rpm-lastactivity


## Overview

Checks how long ago the last RPM package manager activity occurred (install, update, or remove via yum/dnf). Useful for detecting servers that have not been patched in a long time.

**Data Collection:**

* Executes `rpm --query --all --queryformat "%{INSTALLTIME} %{NAME}\n"` to determine the timestamp of the most recently installed or updated package


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rpm-lastactivity> |
| Nagios/Icinga Check Name              | `check_rpm_lastactivity` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
Traceback (most recent call last):
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/rpm-lastactivity/rpm-lastactivity", line 122, in 'module'
    main()
    ~~~~^^
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/rpm-lastactivity/rpm-lastactivity", line 80, in main
    args = parse_args()
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/rpm-lastactivity/rpm-lastactivity", line 45, in parse_args
    help=lib.args.help('--always-ok'),
         ^^^^^^^^
AttributeError: module 'lib' has no attribute 'args'
```


## Usage Examples

```bash
./rpm-lastactivity --warning 90 --critical 365
```

Output:

```text
Last package manager activity is 5M 2W ago [WARNING] (thresholds 90D/365D).
```


## States

* OK if last activity is within the warning threshold.
* WARN if last activity is older than `--warning` (default: 90 days).
* CRIT if last activity is older than `--critical` (default: 365 days).


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
