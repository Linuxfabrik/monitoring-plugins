# Check docker-info


## Overview

Displays system-wide Docker information including container counts (running, paused, stopped), image count, storage and logging driver, Docker version, available CPUs, and total memory. Also monitors the Docker daemon for warnings or errors. For Podman, use the podman-info check instead. Requires root or sudo.

**Data Collection:**

* Executes `docker info` and parses the text output for container counts, image count, storage driver, logging driver, registry, Docker version, CPUs, and total memory
* Monitors `docker info` stderr output for warning and error messages from the Docker daemon

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-info> |
| Nagios/Icinga Check Name              | `check_docker_info` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: docker-info [-h] [-V] [--always-ok] [--test TEST]

Displays system-wide Docker information including container counts (running,
paused, stopped), image count, storage and logging driver, Docker version,
available CPUs, and total memory. Also monitors the Docker daemon for warnings
or errors. For Podman, use the podman-info check instead. Requires root or
sudo.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
  --always-ok    Always returns OK.
  --test TEST    For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                 file,expected-retc".
```


## Usage Examples

```bash
./docker-info
```

Output:

```text
WARNING: the devicemapper storage-driver is deprecated, and will be removed in a future release., 37 Containers (2 running, 0 paused, 35 stopped), 103 Images, Storage Driver: devicemapper, Logging Driver: json-file, Registry: https://index.docker.io/v1/, Docker v20.10.6, 6 CPUs, 15.51GiB Memory
```


## States

* OK if `docker info` returns no warnings or errors.
* WARN if `docker info` stderr contains warnings.
* CRIT if `docker info` stderr contains errors.
* CRIT if `docker info` returns a non-zero exit code.
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

`WARNING: bridge-nf-call-iptables is disabled, WARNING: bridge-nf-call-ip6tables is disabled`  
These settings control whether packets traversing a network bridge are processed by iptables rules on the host system. Typically, enabling these options is not desirable as this can cause guest container traffic to be blocked by iptables rules that are intended for the host. This could cause unpredictable behavior for containers that do not expect traffic to be firewalled at the host level.

If you accept and understand the implications of enabling these options or you have no iptables rules set on the host, you can enable these options to remove the warning messages.

To enable:

```bash
sysctl -p net.bridge.bridge-nf-call-iptables=1
sysctl -p net.bridge.bridge-nf-call-ip6tables=1
```

`Unable to parse docker info output. If you are using Podman, use the podman-info check instead.`  
The output of `docker info` does not contain the expected "Server Version" field. If you are running Podman instead of Docker, use the `podman-info` check plugin.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
