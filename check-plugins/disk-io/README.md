# Check "disk-io" - Overview

Checks the disk throughput over a certain amount of time. Warns only if any of your disks is above a certain throughput threshold within the last n checks (default: 5).

Hints and Recommendations:
* `--count=5` (the default) while checking every minute means that the check reports a warning if any of your disks was above a threshold in the last 5 minutes.
* Check uses a SQLite database in `/tmp` to store its historica data.
* If you are wondering about `dm-0`, `dm-1` etc.: It's part of the "device mapper" in the kernel, used by LVM. Use `dmsetup ls` to see what is behind it.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* Python2 module `psutil`

```bash
./disk-io
./disk-io --ignore sr0 --ignore dm-1 --warning 100 --critical 200 --count 15
./disk-io --help
```


# States

* OK if disk throughput of all disks is below the thresholds within the last `--count` checks.
* Otherwise CRIT or WARN.


# Perfdata

Per disk:

* read_bytes_per_second: number of bytes read
* read_count_per_second: number of reads
* write_bytes_per_second: number of bytes written
* write_count_per_second: number of writes


# Known Issues and Limitations

There is no latency measurement due to the fact that the current `psutil` version (5.2) does not expose latency stats.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.