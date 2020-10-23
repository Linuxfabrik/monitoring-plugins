# Check "mailq" - Overview

Checks the mail queue. Tested with Postfix and Exim.

Regarding Exim: _By default, `exim -bq` (`mailq`) can be used only by an admin user. However, the `queue_list_requires_admin` option can be set false to allow any user to see the queue._ Alternatively, add the icinga user to the exim group.

We recommend to run this check every 5 minutes.


# Installation and Usage

Requirements:
* `mailq`

```bash
./mailq
./mailq --warning 2 --critical 250
./mailq --help
```


# States

* WARN on error messages from mailq.
* WARN or CRIT if number of messages is greater than or equal to the thresholds.


# Perfdata

* mailq: Mails in mail queue


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.