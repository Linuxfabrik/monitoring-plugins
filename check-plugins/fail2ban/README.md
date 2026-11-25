# Check fail2ban


## Overview

Checks the number of currently banned IP addresses across all fail2ban jails. Reports the total ban count and a per-jail breakdown. Jails can be excluded from the check with a regular expression. Alerts when the number of banned IPs in any jail exceeds the configured thresholds. Alerts as well when fail2ban bans an address that must stay reachable, such as the reverse proxy in front of this host or the monitoring server, so a lockout of everybody behind a proxy shows up at once, and when the firewall does not hold a ban fail2ban lists, for example after a firewall reload removed the rules of fail2ban. Requires root or sudo.

fail2ban lists an address as banned as soon as it decides to ban it, whether or not the ban action succeeded, and keeps listing it after a firewall reload has dropped its rules. For every jail that bans anybody, the check therefore reads what its ban actions put into the firewall and compares it with the list: the nftables set (`nftables-*`), the iptables chain (`iptables-*`, and the direct rules of `firewallcmd-allports`, `firewallcmd-multiport` and `firewallcmd-new`), the ipset (`iptables-ipset*`, `firewallcmd-ipset` and `shorewall-ipset-proto6`) or the rich rules of the firewalld zone (`firewallcmd-rich-rules`, `firewallcmd-rich-logging`), for IPv4 and IPv6. A ban that is missing is read a second time two seconds later, so a ban on its way into the firewall does not alert. Jails whose actions put their bans elsewhere show `not verified`, without an alert: `iptables-xt_recent-echo`, `firewallcmd-ipset` with `ipsetbackend = firewalld`, `shorewall`, `ufw`, `route`, `hostsdeny`, the BSD and macOS firewalls, and the actions that report to a remote service or send mail, such as `cloudflare` or `abuseipdb`.

Whether the bans keep the banned clients out, and why a ban action failed, shows in the log of fail2ban, which [fail2ban-logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban-logfile/) reads.

**Data Collection:**

* Runs `fail2ban-client ping` to verify the fail2ban server is alive
* Runs `fail2ban-client status` to discover all configured jails
* Runs `fail2ban-client status <jail>` for each jail to get the current number of banned IPs and the list of banned addresses
* For each jail that bans anybody, runs `fail2ban-client get <jail> actions` and `fail2ban-client get <jail> action <action> actionban` (plus the properties the ban command refers to, such as `addr_set`) to learn where the bans go
* Reads the firewall once per run with what the actions use: `nft --json list table <family> <table>`, `iptables-save --table filter`, `ip6tables-save --table filter`, `ipset save`, `firewall-cmd --zone=<zone> --list-rich-rules`


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
usage: fail2ban [-h] [-V] [--always-ok] [-c CRIT] [--ignore IGNORE]
                [--no-match-severity {ok,warn,crit,unknown}] [--no-perfdata]
                [--socket SOCKET] [--timeout TIMEOUT]
                [--trusted-ip TRUSTED_IP] [-w WARN]

Checks the number of currently banned IP addresses across all fail2ban jails.
Reports the total ban count and a per-jail breakdown. Jails can be excluded
from the check with a regular expression. Alerts when the number of banned IPs
in any jail exceeds the configured thresholds. Alerts as well when fail2ban
bans an address that must stay reachable, such as the reverse proxy in front
of this host or the monitoring server, so a lockout of everybody behind a
proxy shows up at once, and when the firewall does not hold a ban fail2ban
lists, for example after a firewall reload removed the rules of fail2ban.
Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the number of banned IPs per jail.
                        Supports Nagios ranges. Default: 10000
  --ignore IGNORE       Exclude jails whose name matches this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. Example: `--ignore="^recidive$"`. Default: None
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --socket SOCKET       Path to the fail2ban server Unix socket. Passed to
                        `fail2ban-client --socket`. Must resolve within /run
                        or /var/run, and nobody but root may be able to
                        replace it. Default: None
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --trusted-ip TRUSTED_IP
                        IP address or network that fail2ban must never ban,
                        such as a reverse proxy in front of this host. Alerts
                        with CRIT if a jail bans it. IPv4 or IPv6, a single
                        address or a network in CIDR notation. Can be
                        specified multiple times. Example: `--trusted-
                        ip=192.0.2.10 --trusted-ip=2001:db8::/64`
  -w, --warning WARN    WARN threshold for the number of banned IPs per jail.
                        Supports Nagios ranges. Default: 2500

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fail2ban/
```


## Usage Examples

```bash
./fail2ban --warning=2500 --critical=10000 --ignore='^recidive$'
```

Output:

```text
7406 IPs banned

Jail     ! Banned ! Firewall ! Status
---------+--------+----------+----------
sshd     ! 5432   ! ok       ! [WARNING]
portscan ! 1974   ! ok       ! [OK]
```

After a firewall reload that flushed the whole ruleset:

```text
8 IPs banned, 8 bans missing in the firewall [WARNING]

Bans missing in the firewall:
* 192.0.2.77 in sshd (nftables-multiport, set inet f2b-table addr-set-sshd)
* 198.51.100.3 in sshd (nftables-multiport, set inet f2b-table addr-set-sshd)
* 2001:db8::91 in sshd (nftables-multiport, set inet f2b-table addr6-set-sshd)
* 203.0.113.12 in sshd (nftables-multiport, set inet f2b-table addr-set-sshd)
* 203.0.113.40 in sshd (nftables-multiport, set inet f2b-table addr-set-sshd)
* and 3 more in sshd

fail2ban lists these addresses as banned, but the firewall does not block them, typically because a firewall reload removed the rules of fail2ban, or because the ban action failed (see the fail2ban log). Restart fail2ban to set the bans again: `sudo systemctl restart fail2ban`.

Jail     ! Banned ! Firewall  ! Status
---------+--------+-----------+----------
sshd     ! 8      ! 8 missing ! [WARNING]
portscan ! 0      ! -         ! [OK]
```

Alert when fail2ban bans the reverse proxy in front of this host. Behind a proxy that Apache logs as the client, a jail that counts failed logins or missing files bans the proxy, and everybody behind it loses access:

```bash
./fail2ban --trusted-ip=192.0.2.10 --trusted-ip=2001:db8::/64
```

Output:

```text
3 IPs banned, 1 trusted address among them [CRITICAL]

Trusted addresses banned:
* 192.0.2.10 in apache-auth, lift the ban with `sudo fail2ban-client set apache-auth unbanip 192.0.2.10`

Add the trusted addresses to `ignoreip` in fail2ban so they are not banned again.

Jail        ! Banned ! Firewall ! Status
------------+--------+----------+-----------
apache-auth ! 3      ! ok       ! [CRITICAL]
sshd        ! 0      ! -        ! [OK]
```


## States

* OK if the number of banned IPs in every checked jail is within `--warning` (default: 2500).
* WARN if the number of banned IPs in any jail exceeds `--warning` (default: 2500).
* CRIT if the number of banned IPs in any jail exceeds `--critical` (default: 10000).
* CRIT if a jail bans an address or network given by `--trusted-ip`, whatever the number of banned IPs.
* WARN if the firewall does not hold a ban that fail2ban lists, on two looks two seconds apart.
* WARN if the firewall a ban action uses cannot be read, for example because firewalld is not running.
* WARN if a `fail2ban-client` call does not return within `--timeout` (default: 8 seconds), typically because the fail2ban server hangs.
* UNKNOWN if `fail2ban-client ping` fails or `fail2ban-client status` returns an error.
* UNKNOWN if a `--trusted-ip` value is neither an IP address nor a network in CIDR notation.
* UNKNOWN if `--socket` resolves outside `/run` or `/var/run`, or if anybody but root could replace the socket or a directory above it.
* `--warning` and `--critical` accept Nagios range expressions.
* Jails matching `--ignore` are excluded from both the output and the alerting.
* `--no-match-severity` sets the state reported when the filters match no jail and nothing is checked (default: `ok`); set it to `warn`, `crit`, or `unknown` to alert on an empty selection (for example a filter typo or a missing jail) instead of silently returning OK.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| `<jail>` | Number | Number of banned IP addresses per jail. |


## Troubleshooting

### `Permission denied to socket: /var/run/fail2ban/fail2ban.sock (you must be root)`

The fail2ban client works only with user `root` by default. Fail2ban does not have individual permission or a user privilege model. If you allow the fail2ban client accessing the fail2ban server for non-root, you could stop the server, change runtime config, ban, unban, etc.

There are two ways to let a non-root user like `nagios` or `icinga` run the check: change the socket permissions, or grant sudo access.

### Granting access by changing socket permissions

Tested on Debian 11.

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

### Granting access using sudo

Tested on RHEL 7+.

As an alternative you might add a sudoers rule, for example in `/etc/sudoers.d/fail2ban`:

```text
icinga    ALL = NOPASSWD: /usr/lib64/nagios/plugins/fail2ban
```

Click this link to find [a list of sudoers files for all main Linux distributions](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers) for Icinga.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
