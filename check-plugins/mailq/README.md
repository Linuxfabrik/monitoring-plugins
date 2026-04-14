# Check mailq


## Overview

Checks the number of messages in the mail queue using the `mailq` command. Alerts when the queue length exceeds the configured thresholds. Tested with Postfix and Exim.

**Important Notes:**

* Exim: By default, `exim -bq` (alias `mailq`) can be used only by an admin user. Set `queue_list_requires_admin` to false to allow any user to see the queue, or add the icinga user to the exim group (sometimes called `Debian-exim`)

**Data Collection:**

* Executes the `mailq` command and parses its output to count queued messages
* Supports different output formats: Postfix-style ("-- 2 Kbytes in 3 Requests."), Exim-style (line counting), and generic ("17 mails to deliver")
* Also reports any error messages from `mailq` on stderr


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mailq> |
| Nagios/Icinga Check Name              | `check_mailq` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: mailq [-h] [-V] [--always-ok] [-c CRIT]
             [--mta {auto,postfix,exim,sendmail}] [--test TEST] [-w WARN]

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
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  -w, --warning WARN    WARN threshold for the age of the oldest mail in the
                        queue. Accepts a duration with a unit suffix (`Ns`,
                        `Nm`, `Nh`, `ND`, `NW`, `NM`, `NY`, case-sensitive
                        units). Example: `--warning=1h` to alert when the
                        oldest mail has been in the queue for an hour or more.
                        Default: 1h
```


## Usage Examples

```bash
./mailq --warning 2 --critical 250
```

Output:

```text
4 mails to deliver.
```


## States

* OK if the mail queue is empty or the number of messages is below `--warning` (default: 2).
* WARN if `mailq` reports an error message on stderr.
* WARN if the number of messages is >= `--warning` (default: 2).
* CRIT if the number of messages is >= `--critical` (default: 250).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mailq | Number | Number of messages currently in the mail queue. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
