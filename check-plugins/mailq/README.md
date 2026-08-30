# Check mailq


## Overview

Checks how long the oldest mail in the local mail queue has been waiting and alerts when it exceeds the configured duration thresholds. On hosts with Postfix, reads the queue via `postqueue -j` (JSON, with `arrival_time` as Unix epoch) for maximum accuracy. On Exim hosts, reads `mailq` (which is aliased to `exim -bp` by exim) and parses the age literal that exim prints next to each queued message. On other hosts, falls back to running `mailq` and parsing `Date:` lines from the output. A non-empty queue with 100 mails that are all a few minutes old is still OK, while a single mail stuck for more than an hour triggers a WARN, which matches how most admins actually want to be alerted on a mail queue.

**Important Notes:**

* The queue length itself never raises a state. It is reported in the message and as perfdata, so a queue that is draining normally stays quiet no matter how many mails pass through it
* Exim: By default, `exim -bp` (alias `mailq`) can be used only by an admin user. Set `queue_list_requires_admin` to false to allow any user to see the queue, or add the monitoring user to the exim group (sometimes called `Debian-exim`)
* Postfix writes a warning to stderr when the queue is read while the mail system is down. The check prepends that warning to its message and raises WARN, because a queue read that way may be incomplete

**Data Collection:**

* Probes for the mail transfer agent in this order: `postqueue` (Postfix), `exim` / `exim4` (Exim), `mailq` (Sendmail-style). `--mta` overrides the detection
* Postfix: runs `postqueue -j` and takes the age of each mail from its `arrival_time` epoch
* Exim: runs `mailq` and reads the age literal exim prints in front of each entry (`17m`, `2h`, `1d12h`)
* Sendmail and compatible: runs `mailq` and parses the `Date:` field of each entry
* Also reports any error message the queue command writes to stderr


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mailq> |
| Nagios/Icinga Check Name              | `check_mailq` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `postqueue` (Postfix), `exim` / `exim4` (Exim) or `mailq` (Sendmail-style) |


## Help

```text
usage: mailq [-h] [-V] [--always-ok] [-c CRIT]
             [--mta {auto,postfix,exim,sendmail}] [--no-perfdata] [-w WARN]

Checks how long the oldest mail in the local mail queue has been waiting and
alerts when it exceeds the configured duration thresholds. On hosts with
Postfix, reads the queue via `postqueue -j` (JSON, with `arrival_time` as Unix
epoch) for maximum accuracy. On Exim hosts, reads `mailq` (which is aliased to
`exim -bp` by exim) and parses the age literal that exim prints next to each
queued message. On other hosts, falls back to running `mailq` and parsing
`Date:` lines from the output. A non-empty queue with 100 mails that are all a
few minutes old is still OK, while a single mail stuck for more than an hour
triggers a WARN, which matches how most admins actually want to be alerted on
a mail queue.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the age of the oldest mail in the
                        queue. Accepts a duration with a unit suffix (`Ns`,
                        `Nm`, `Nh`, `ND`, `NW`, `NM`, `NY`, case-sensitive
                        units). Example: `--critical=3D` to alert when the
                        oldest mail has been in the queue for 3 days or more.
                        Default: 3D
  --mta {auto,postfix,exim,sendmail}
                        Which mail transfer agent to query. The default `auto`
                        probes for `postqueue` (Postfix), then `exim`/`exim4`
                        (Exim), and falls back to `mailq` (Sendmail-style)
                        otherwise. Override this if the detection picks the
                        wrong MTA. Default: auto
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  -w, --warning WARN    WARN threshold for the age of the oldest mail in the
                        queue. Accepts a duration with a unit suffix (`Ns`,
                        `Nm`, `Nh`, `ND`, `NW`, `NM`, `NY`, case-sensitive
                        units). Example: `--warning=1h` to alert when the
                        oldest mail has been in the queue for an hour or more.
                        Default: 1h

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mailq/
```


## Usage Examples

```bash
./mailq --warning=1h --critical=3D
```

Output:

```text
Oldest mail has been in the queue for 17m, 3 mails queued in total.
```

A mail that has been stuck for four days:

```text
Oldest mail has been in the queue for 4D [CRITICAL], 2 mails queued in total.
```

An empty queue:

```text
Mail queue is empty.
```


## States

* OK if the mail queue is empty, or if the oldest mail has been waiting less than `--warning`.
* WARN if the age of the oldest mail is >= `--warning` (default: 1h).
* WARN if the queue command reports an error message on stderr.
* CRIT if the age of the oldest mail is >= `--critical` (default: 3D).
* UNKNOWN if `--warning` or `--critical` is not a valid duration, or if no known MTA binary was found and `--mta` was not given.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mailq | Number | Number of messages currently in the mail queue. |
| oldest_mail_age | Seconds | How long the oldest mail in the queue has been waiting. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
