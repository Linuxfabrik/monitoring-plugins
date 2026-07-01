# Check podman-image


## Overview

Lists the container images on a host and checks how old they are. Reports each image's repository tag, age and size, and alerts when an image is older than the configured thresholds, which is a sign that a rebuild or pull was missed. Images can be selected or excluded by name using regular expressions. For Docker, use the docker-image check instead. Requires root or sudo.

**Important Notes:**

* Alerts when an image is older than the `--warning` (default `90D`) or `--critical` (default `365D`) age threshold; raise or widen these for images you intentionally pin
* A dangling image (one that has lost its repository tag) is shown by its short image ID instead of a tag, and counted in the `images_dangling` perfdata
* Podman runs rootless by default, and every user keeps their images in their own storage. Running the check as root (via `sudo`) sees root's own images, not the rootless images of other users. To check a rootless user's images, pass `--user=<name>`: the check then runs podman as that user. Every line of output names the inspected user, so an empty result against root's storage is obvious
* On a host with a very large number of images, or with rootless Podman under `--user`, the check can take a while, since every image is inspected, and may exceed the short check timeout monitoring systems use by default (often 10 seconds); give the check more time if it times out

**Data Collection:**

* Executes `podman images --quiet --no-trunc` to list all image IDs
* Executes `podman image inspect` on those IDs to read each image's repository tag, creation date and size


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/podman-image> |
| Nagios/Icinga Check Name              | `check_podman_image` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | `podman` CLI |


## Help

```text
usage: podman-image [-h] [-V] [--always-ok] [-c CRIT] [--ignore IGNORE]
                    [--match MATCH]
                    [--no-match-severity {ok,warn,crit,unknown}] [--user USER]
                    [-w WARN]

Lists the container images on a host and checks how old they are. Reports each
image's repository tag, age and size, and alerts when an image is older than
the configured thresholds, which is a sign that a rebuild or pull was missed.
Images can be selected or excluded by name using regular expressions. For
Docker, use the docker-image check instead. Requires root or sudo.

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
  --user USER           Inspect the rootless images of this user instead of
                        those visible to the executing user. Podman keeps each
                        user's rootless images in that user's own storage, so
                        root (the monitoring user runs the check via sudo)
                        does not see them. With --user, the check runs podman
                        as that user. Requires the right to `sudo -u <user>`
                        (root has this by default). Example: `--user=webapp`.
                        Default: None
  -w, --warning WARN    WARN threshold for the image age in a human-readable
                        format (s = seconds, m = minutes, h = hours, D = days,
                        W = weeks, M = months, Y = years). Supports Nagios
                        ranges. Example: `90D` alerts on images older than 90
                        days. Default: 90D
```


## Usage Examples

Report all images and their age:

```bash
./podman-image
```

Alert on images older than 180 days, ignoring locally built ones:

```bash
./podman-image --ignore="^localhost/" --critical=180D
```

Check the rootless images of the `webapp` user (run the check as root, for example via the Icinga Director sudo wrapper):

```bash
./podman-image --user=webapp --warning=90D
```

Output:

```text
docker.io/library/postgres:16: age 1Y 6M [CRITICAL] (thresholds 90D/365D; user: `webapp`)

Image                         ! Age   ! Size     ! State
------------------------------+-------+----------+-----------
docker.io/library/nginx:1.27  ! 4W 1D ! 178.3MiB ! [OK]
docker.io/library/postgres:16 ! 1Y 6M ! 405.3MiB ! [CRITICAL]
```


## States

* WARN/CRIT if an image's age crosses `--warning` (default 90D) or `--critical` (default 365D).
* The state reported when no image matches the `--match` / `--ignore` filters (or no images exist) is configurable via `--no-match-severity` (default: ok).
* CRIT if `podman images` or `podman image inspect` returns a non-zero exit code.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| images_checked | Number | Number of images that passed the filters and were checked. |
| images_dangling | Number | Number of checked images that have lost their repository tag. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
