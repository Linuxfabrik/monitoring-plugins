# Check deb-updates

## Overview

This plugin checks for software updates on systems that use package management systems based on the apt-get(8) command found in Debian GNU/Linux and compatible. This plugin only lists updates and upgrades, and provides the relevant alerts. It never actually runs an update. Tested on Debian 11+ and Ubuntu 20+.

The plugin stores all relevant information in a local SQLite database. For the `--query` parameter, the following database columns can be used:

* package (TEXT)

As the output interface of the `apt` tool is not stable, the database table has been kept deliberately simple and consists of only one column.

Example content of the `package` column:

```text
base-files/stable 12.4+deb12u11 amd64 [upgradable from: 12.4+deb12u5]
bash/stable 5.2.15-2+b8 amd64 [upgradable from: 5.2.15-2+b2]
bind9-dnsutils/stable,stable-security 1:9.18.33-1~deb12u2 amd64 [upgradable from: 1:9.18.19-1~deb12u1]
```


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/deb-updates> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | Command-line tool `sudo`; the user running this plugin must have sudo permissions, and the NOPASSWD tag must be set |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-deb-updates.db` |


## Help

```text
usage: deb-updates [-h] [-V] [--always-ok] [--only-critical] [--query QUERY]
                   [--timeout TIMEOUT] [-w WARN]

This plugin checks for software updates on systems that use package management
systems based on the apt-get(8) command found in Debian GNU/Linux and
compatible. This plugin only lists updates and upgrades, and provides the
relevant alerts. It never actually runs an update.

options:
  -h, --help          show this help message and exit
  -V, --version       show program's version number and exit
  --always-ok         Always returns OK.
  --only-critical     Only collect critical updates and upgrades.
  --query QUERY       The list of available updates and upgrades is stored in
                      a SQL table. Provide the SQL `WHEN` statement part to
                      narrow down results. Example: `--query='package like
                      "bind9-%"'`. Also supports regular expressions via a
                      REGEXP statement. Have a look at the README for a list
                      of available columns. If this parameter is used, a list
                      of matching updates is printed. Default: 1
  --timeout TIMEOUT   Plugin timeout in seconds. Default: 60 (seconds)
  -w, --warning WARN  Minimum number of packages to return WARNING. Default:
                      1.
```


## Usage Examples

```bash
./deb-updates --only-critical --query='package like "bind9-%"'
```

Output:

```text
3 critical updates available [WARNING]:
* bind9-dnsutils/stable,stable-security 1:9.18.33-1~deb12u2 amd64 [upgradable from: 1:9.18.19-1~deb12u1]
* bind9-host/stable,stable-security 1:9.18.33-1~deb12u2 amd64 [upgradable from: 1:9.18.19-1~deb12u1]
* bind9-libs/stable,stable-security 1:9.18.33-1~deb12u2 amd64 [upgradable from: 1:9.18.19-1~deb12u1]
```


## States

* WARN if the number of updatable packages exceeds the specified threshold value


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| updates | Number | Number of updatable packages matching the current `--query`. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
