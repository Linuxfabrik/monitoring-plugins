# Check podman-info


## Overview

Displays system-wide Podman information including container counts, image count, storage driver, runtime version, available CPUs, and total memory. For Docker, use the [docker-info](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-info) check instead.

**Important Notes:**

* Podman runs rootless by default. Without `sudo`, the check only sees containers of the executing user. To monitor containers across all users, run the check via `sudo` (the Icinga Director basket and sudoers file are pre-configured for this).

**Data Collection:**

* Executes `podman info --format json` to collect system-wide Podman information
* Parses container counts (running, paused, stopped), image count, storage driver, logging driver, registries, Podman version, CPU count, and total memory

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/podman-info> |
| Nagios/Icinga Check Name              | `check_podman_info` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: podman-info [-h] [-V] [--always-ok] [--test TEST]

Displays system-wide Podman information including container counts, image
count, storage driver, runtime version, available CPUs, and total memory. For
Docker, use the docker-info check instead. Requires root or sudo.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
  --always-ok    Always returns OK.
  --test TEST    For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                 file,expected-retc".
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

| Name               | Type   | Description                  |
|--------------------|--------|------------------------------|
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
