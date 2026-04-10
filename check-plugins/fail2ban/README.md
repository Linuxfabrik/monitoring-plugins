# Check fail2ban


## Overview

Checks the number of currently banned IP addresses across all fail2ban jails. Reports the total ban count and a per-jail breakdown. Alerts when the number of banned IPs in any jail exceeds the configured thresholds. Requires root or sudo.

**Data Collection:**

* Runs `fail2ban-client ping` to verify the fail2ban server is alive
* Runs `fail2ban-client status` to discover all configured jails
* Runs `fail2ban-client status <jail>` for each jail to get the current number of banned IPs


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fail2ban> |
| Nagios/Icinga Check Name              | `check_fail2ban` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: fail2ban [-h] [-V] [--always-ok] [-c CRIT] [--test TEST] [-w WARN]

Checks the number of currently banned IP addresses across all fail2ban jails.
Reports the total ban count and a per-jail breakdown. Alerts when the number
of banned IPs in any jail exceeds the configured thresholds. Requires root or
sudo.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the number of banned IPs per jail.
                       Default: 10000
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   WARN threshold for the number of banned IPs per jail.
                       Default: 2500
```


## Usage Examples

```bash
./fail2ban --warning 2500 --critical 10000
```

Output:

```text
7406 IPs banned
* 5432 in jail "sshd" [WARNING]
* 1974 in jail "portscan"
```


## States

* OK if the number of banned IPs in every jail is below `--warning` (default: 2500).
* WARN if the number of banned IPs in any jail is >= `--warning` (default: 2500).
* CRIT if the number of banned IPs in any jail is >= `--critical` (default: 10000).
* UNKNOWN if `fail2ban-client ping` fails or `fail2ban-client status` returns an error.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| `<jail>` | Number | Number of banned IP addresses per jail. |


## Troubleshooting

`Permission denied to socket: /var/run/fail2ban/fail2ban.sock (you must be root)`  
The fail2ban client works only with user `root` by default. Fail2ban does not have individual permission or a user privilege model. If you allow the fail2ban client accessing the fail2ban server for non-root, you could stop the server, change runtime config, ban, unban, etc.

Preparing fail2ban by changing permissions (tested on Debian 11):

The communication takes place via unix-socket `/var/run/fail2ban/fail2ban.sock` which has the following permissions:

```text
srwx------ 1 root root ... /var/run/fail2ban/fail2ban.sock
```

Grant access to `fail2ban.sock` for a user like `nagios` or `icinga`:

```bash
sudo groupadd fail2ban
sudo usermod --append --groups fail2ban nagios
sudo chown root:fail2ban /var/run/fail2ban/fail2ban.sock
sudo chmod g+w /var/run/fail2ban/fail2ban.sock
```

After that, this (and the check plugin) should work:

```bash
sudo -u nagios /usr/bin/fail2ban-client status
sudo -u nagios /usr/lib64/nagios/plugins/fail2ban
```

To persist on a system where fail2ban is managed by systemd, add the following to the fail2ban service override file:

```bash
sudo systemctl edit fail2ban
```

```text
[Service]
ExecStartPost=/usr/bin/sh -c "while ! [ -S /var/run/fail2ban/fail2ban.sock ]; do sleep 1; done"
ExecStartPost=/usr/bin/chgrp fail2ban /var/run/fail2ban/fail2ban.sock
ExecStartPost=/usr/bin/chmod g+w /var/run/fail2ban/fail2ban.sock
```

Preparing fail2ban by using sudo (tested on RHEL 7+):

As an alternative you might add a sudoers rule, for example in `/etc/sudoers.d/fail2ban`:

```text
Defaults:icinga !requiretty
icinga    ALL = NOPASSWD: /usr/lib64/nagios/plugins/fail2ban
```

Click this link to find [a list of sudoers files for all main Linux distributions](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers) for Icinga.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
