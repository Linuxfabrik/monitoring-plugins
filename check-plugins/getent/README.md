# Check getent

## Overview

The getent plugin checks entries from databases supported by the Name Service Switch libraries, which are configured in `/etc/nsswitch.conf`, using the `getent` command, and warns if no match.

If one or more key arguments are provided, then only the entries that match the supplied keys will be checked.

Note: Calling the plugin with `getent --database=passwd` lists only local users, not users on an Directory server. To check the availability of a FreeIPA or an Active Directory (AD) connected via `sssd`, add the name of a known network account to test if network users are resolved correctly. For example, `getent --database=passwd --key=<ldapuser>`.

For details have a look at `man getent`.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/getent> |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: getent [-h] [-V] [--database DATABASE] [--key KEY]

Queries the Name Service Switch (NSS) for entries in system databases such as
group, hosts, networks, passwd, protocols, or services. Alerts if the lookup
fails or if a specific key is not found.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --database DATABASE  NSS database to query. May be any database supported by
                       "getent". Example: `--database passwd`. Default: group
  --key KEY            Lookup key to search for in the database. If not
                       specified, all entries are fetched (unless the database
                       does not support enumeration). Can be specified
                       multiple times. Example: `--key root --key nobody`.
```


## Usage Examples

```bash
./getent --database group --key SysOps
./getent --database hosts --key localhost --key localhost.localdomain
```

Output:

```text
Everything is ok. Executed `/usr/bin/getent group`, got 7153 results.
```


## States

* WARN if one or more supplied keys could not be found in the database.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
