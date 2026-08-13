# Check docker-info


## Overview

Displays system-wide Docker information including container counts (running, paused, stopped), image count, storage and logging driver, Docker version, available CPUs, and total memory. Alerts when the daemon reports a warning about itself or its host, and when the daemon answers with an error at all. Individual warnings can be filtered out with --ignore (e.g. the "No swap limit support" message on hosts where the kernel does not expose swap accounting). For Podman, use the podman-info check instead. Requires root or sudo.

**Important Notes:**

* Every `docker` command starts a daemon that is only socket-activated, which is how most distributions ship it. A daemon someone stopped with `systemctl stop docker` is therefore started again by the next run of this check, or of any other Docker check. A service watching `docker.service` reports the stopped unit, while the container checks next to it are green again, and both are right

**Data Collection:**

* Executes `docker info --format '{{json .}}'` and reads container counts, image count, storage driver, logging driver, Docker version, CPUs and total memory from the answer
* Reads the warnings and errors the daemon states about itself in the same answer, so nothing depends on how the command formats its output for a terminal


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-info> |
| Nagios/Icinga Check Name              | `check_docker_info` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: docker-info [-h] [-V] [--always-ok] [--ignore IGNORE] [--no-perfdata]

Displays system-wide Docker information including container counts (running,
paused, stopped), image count, storage and logging driver, Docker version,
available CPUs, and total memory. Alerts when the daemon reports a warning
about itself or its host, and when the daemon answers with an error at all.
Individual warnings can be filtered out with --ignore (e.g. the "No swap limit
support" message on hosts where the kernel does not expose swap accounting).
For Podman, use the podman-info check instead. Requires root or sudo.

options:
  -h, --help       show this help message and exit
  -V, --version    show program's version number and exit
  --always-ok      Always returns OK.
  --ignore IGNORE  Ignore daemon warnings and errors matching this Python
                   regular expression. Case-sensitive by default; use `(?i)`
                   for case-insensitive matching. Can be specified multiple
                   times. Example: `--ignore="No swap limit support"` to
                   suppress the Docker warning on kernels without swap
                   accounting. Example: `--ignore="(?i)bridge-nf-call"` (case-
                   insensitive) to suppress both `bridge-nf-call-iptables` and
                   `bridge-nf-call-ip6tables` warnings on Debian hosts.
                   Default: None
  --no-perfdata    Suppress the performance data section from the output. The
                   status message and the exit code are unaffected, so
                   alerting keeps working while trending data is dropped.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-info/
```


## Usage Examples

```bash
./docker-info
```

Output:

```text
WARNING: No cpuset support, 37 Containers (2 running, 0 paused, 35 stopped), 103 Images, Storage Driver: overlay2, Logging Driver: json-file, Docker v28.5.2, 8 CPUs, 30.7GiB Memory
```


## States

* OK if the daemon reports no warnings and no errors.
* WARN for every warning the daemon reports about itself or its host.
* CRIT for every error the daemon answers with.
* CRIT if `docker info` returns a non-zero exit code.
* UNKNOWN if the check may not talk to the container engine. The engine is answering, this check is only not allowed to ask, so it says nothing about it and names the sudoers file instead.
* UNKNOWN if the answer cannot be read, or comes from Podman rather than Docker.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| containers | Number | Total number of containers. |
| containers_paused | Number | Number of paused containers. |
| containers_running | Number | Number of running containers. |
| containers_stopped | Number | Number of stopped containers. |
| cpu | Number | Number of host CPUs. |
| images | Number | Number of images. |
| ram | Bytes | Total host memory. |


## Troubleshooting

### `WARNING: bridge-nf-call-iptables is disabled, WARNING: bridge-nf-call-ip6tables is disabled`

These settings control whether packets traversing a network bridge are processed by iptables rules on the host system. Typically, enabling these options is not desirable as this can cause guest container traffic to be blocked by iptables rules that are intended for the host. This could cause unpredictable behavior for containers that do not expect traffic to be firewalled at the host level.

If you accept and understand the implications of enabling these options or you have no iptables rules set on the host, you can enable these options to remove the warning messages.

To enable:

```bash
sysctl -p net.bridge.bridge-nf-call-iptables=1
sysctl -p net.bridge.bridge-nf-call-ip6tables=1
```

### `The daemon did not report a server version. If you are using Podman, use the podman-info check instead.`

The answer to `docker info` carries no server version. On a host with `podman-docker` installed, `docker` is a wrapper around Podman and answers with Podman's own information; use the `podman-info` check plugin there.

### `Unable to read the docker info output. If you are using Podman, use the podman-info check instead.`

The command answered with something other than the expected document, which usually means a wrapper or a proxy sits between the check and the daemon. Run `docker info --format '{{json .}}'` by hand to see what actually comes back.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
