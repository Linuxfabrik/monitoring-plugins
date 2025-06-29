# Check mailq

## Overview

Checks the mail queue. Tested with Postfix and Exim.

Hints:

* Exim: By default, `exim -bq` (alias `mailq`) can be used only by an admin user. However, the `queue_list_requires_admin` option can be set false to allow any user to see the queue. Alternatively, add the icinga user to the exim group (sometimes the group is also called `Debian-exim`).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mailq> |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `mailq` |


## Help

```text
usage: mailq [-h] [-V] [--always-ok] [-c CRIT] [--test TEST] [-w WARN]

Checks the mail queue.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  Set the critical threshold for mails in the queue.
                       Default: 250
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   Set the warning threshold for mails in the queue.
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

* WARN on error messages from mailq.
* WARN or CRIT if number of messages is greater than or equal to the thresholds.


## Perfdata / Metrics

* mailq: Mails in mail queue


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
