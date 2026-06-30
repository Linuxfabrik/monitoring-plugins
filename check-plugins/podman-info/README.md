# Check podman-info


## Overview

Displays system-wide Podman information including container counts, image count, storage driver, runtime version, available CPUs, and total memory. For Docker, use the [docker-info](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-info) check instead.

**Important Notes:**

* Podman runs rootless by default, and every user keeps their containers and images in their own storage. Running the check as root (via `sudo`) reports on root's own Podman, not on the rootless containers of other users. To report on a rootless user's Podman, pass `--user=<name>`: the check then runs podman as that user. Every line of output names the inspected user, so an empty result against root's storage is obvious.

**Data Collection:**

* Executes `podman info --format json` to collect system-wide Podman information
* Parses container counts (running, paused, stopped), image count, storage driver, logging driver, registries, Podman version, CPU count, and total memory


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/podman-info> |
| Nagios/Icinga Check Name              | `check_podman_info` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: podman-info [-h] [-V] [--always-ok] [--ignore IGNORE] [--user USER]

Displays system-wide Podman information including container counts, image
count, storage driver, runtime version, available CPUs, and total memory. Also
monitors the Podman daemon stderr for warnings and errors. Individual stderr
lines can be filtered out with --ignore (e.g. benign cgroup warnings on
rootless hosts). For Docker, use the docker-info check instead. Requires root
or sudo.

options:
  -h, --help       show this help message and exit
  -V, --version    show program's version number and exit
  --always-ok      Always returns OK.
  --ignore IGNORE  Ignore stderr lines matching this Python regular
                   expression. Case-sensitive by default; use `(?i)` for case-
                   insensitive matching. Can be specified multiple times.
                   Example: `--ignore="cgroup v1"` to suppress a benign
                   cgroup-version warning on hosts that have not yet migrated
                   to cgroup v2. Example: `--ignore="(?i)rootless"` (case-
                   insensitive) to suppress any rootless-related informational
                   warning. Default: None
  --user USER      Report on the rootless Podman of this user instead of the
                   one visible to the executing user. Podman keeps each user's
                   rootless containers and images in that user's own storage,
                   so root (the monitoring user runs the check via sudo) does
                   not see them. With --user, the check runs podman as that
                   user. Requires the right to `sudo -u <user>` (root has this
                   by default). Example: `--user=rocketchat`. Default: None
```


## Usage Examples

```bash
./podman-info
```

Output:

```text
2 Containers (1 running, 0 paused, 1 stopped), 1055 Images, Storage Driver: overlay, Logging Driver: journald, 3 Registries, Podman v5.8.1, 8 CPUs, 30.9GiB Memory
```


## States

* OK if `podman info` completes without warnings or errors.
* WARN on `podman info` warnings in stderr.
* CRIT on `podman info` errors in stderr or return codes != 0.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| containers         | Number | Number of containers.         |
| containers_paused  | Number | Number of paused containers.  |
| containers_running | Number | Number of running containers. |
| containers_stopped | Number | Number of stopped containers. |
| cpu                | Number | Number of host CPUs.          |
| images             | Number | Number of images.             |
| ram                | Bytes  | Total host memory.            |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
