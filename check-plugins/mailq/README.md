# Check mailq

## Overview

Checks the number of messages in the mail queue using the `mailq` command. Alerts when the queue length exceeds the configured thresholds. Tested with Postfix and Exim.

**Important Notes:**

* Exim: By default, `exim -bq` (alias `mailq`) can be used only by an admin user. Set `queue_list_requires_admin` to false to allow any user to see the queue, or add the icinga user to the exim group (sometimes called `Debian-exim`)


**Data Collection:**

* Executes the `mailq` command and parses its output to count queued messages
* Supports different output formats: Postfix-style ("-- 2 Kbytes in 3 Requests."), Exim-style (line counting), and generic ("17 mails to deliver")
* Also reports any error messages from `mailq` on stderr

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mailq> |
| Nagios/Icinga Check Name              | `check_mailq` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: mailq [-h] [-V] [--always-ok] [-c CRIT] [--test TEST] [-w WARN]

Checks the number of messages in the mail queue using the "mailq" command.
Alerts when the queue length exceeds the configured thresholds.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the number of mails in the queue.
                       Default: 250
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   WARN threshold for the number of mails in the queue.
                       Default: 2
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
