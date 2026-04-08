# Check podman-info

## Overview

Displays system-wide Podman information. For Docker, use the [docker-info](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-info) check instead.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/podman-info> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: podman-info [-h] [-V] [--always-ok] [--test TEST]

Displays system-wide Podman information. For Docker, use the docker-info check
instead.

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

* CRIT on `podman info` return codes != 0


## Perfdata / Metrics

| Name               | Type   | Description                  |
|--------------------|--------|------------------------------|
| containers         | Number | Number of containers         |
| containers_paused  | Number | Number of paused containers  |
| containers_running | Number | Number of running containers |
| containers_stopped | Number | Number of stopped containers |
| cpu                | Number | Number of Host CPUs          |
| images             | Number | Number of images             |
| ram                | Number | Total Host Memory            |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
