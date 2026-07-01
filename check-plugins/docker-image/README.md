# Check docker-image


## Overview

Lists the container images on a host and checks how old they are. Reports each image's repository tag, age and size, and alerts when an image is older than the configured thresholds, which is a sign that a rebuild or pull was missed. Images can be selected or excluded by name using regular expressions. For Podman, use the podman-image check instead. Requires root or sudo.

**Important Notes:**

* Alerts when an image is older than the `--warning` (default `90D`) or `--critical` (default `365D`) age threshold; raise or widen these for images you intentionally pin
* A dangling image (one that has lost its repository tag) is shown by its short image ID instead of a tag, and counted in the `images_dangling` perfdata
* On a host with a very large number of images the check can take a while, since every image is inspected, and may exceed the short check timeout monitoring systems use by default (often 10 seconds); give the check more time if it times out

**Data Collection:**

* Executes `docker images --quiet --no-trunc` to list all image IDs
* Executes `docker image inspect` on those IDs to read each image's repository tag, creation date and size


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-image> |
| Nagios/Icinga Check Name              | `check_docker_image` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | `docker` CLI |


## Help

```text
usage: docker-image [-h] [-V] [--always-ok] [-c CRIT] [--ignore IGNORE]
                    [--match MATCH]
                    [--no-match-severity {ok,warn,crit,unknown}] [-w WARN]

Lists the container images on a host and checks how old they are. Reports each
image's repository tag, age and size, and alerts when an image is older than
the configured thresholds, which is a sign that a rebuild or pull was missed.
Images can be selected or excluded by name using regular expressions. For
Podman, use the podman-image check instead. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the image age in a human-readable
                        format (s = seconds, m = minutes, h = hours, D = days,
                        W = weeks, M = months, Y = years). Supports Nagios
                        ranges. Example: `180D` alerts on images older than
                        180 days. Default: 365D
  --ignore IGNORE       Ignore images whose repository tag matches this Python
                        regular expression. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times. Example: `--ignore="^localhost/"` to
                        skip locally built images. Example:
                        `--ignore="(?i)test"` (case-insensitive) to skip any
                        image with "test" in its tag. Default: None
  --match MATCH         Only check images whose repository tag matches this
                        Python regular expression. Case-sensitive by default;
                        use `(?i)` for case-insensitive matching. Can be
                        specified multiple times. If both `--match` and
                        `--ignore` are given, an image must match `--match`
                        AND not match `--ignore` to be checked (include first,
                        exclude second). Example:
                        `--match="^docker.io/library/nginx"` to check only the
                        nginx images. Default: None
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  -w, --warning WARN    WARN threshold for the image age in a human-readable
                        format (s = seconds, m = minutes, h = hours, D = days,
                        W = weeks, M = months, Y = years). Supports Nagios
                        ranges. Example: `90D` alerts on images older than 90
                        days. Default: 90D
```


## Usage Examples

Report all images and their age:

```bash
./docker-image
```

Alert on images older than 180 days, ignoring locally built ones:

```bash
./docker-image --ignore="^localhost/" --critical=180D
```

Output:

```text
postgres:16: age 1Y 6M [CRITICAL] (thresholds 90D/180D)

Image       ! Age   ! Size     ! State
------------+-------+----------+-----------
nginx:1.27  ! 4W 1D ! 178.3MiB ! [OK]
postgres:16 ! 1Y 6M ! 405.3MiB ! [CRITICAL]
```


## States

* WARN/CRIT if an image's age crosses `--warning` (default 90D) or `--critical` (default 365D).
* The state reported when no image matches the `--match` / `--ignore` filters (or no images exist) is configurable via `--no-match-severity` (default: ok).
* CRIT if `docker images` or `docker image inspect` returns a non-zero exit code.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| images_checked | Number | Number of images that passed the filters and were checked. |
| images_dangling | Number | Number of checked images that have lost their repository tag. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
