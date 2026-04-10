# Check getent

## Overview

Queries the Name Service Switch (NSS) for entries in system databases such as group, hosts, networks, passwd, protocols, or services using the `getent` command. Alerts if the lookup fails or if a specific key is not found. This is particularly useful for verifying that directory services (FreeIPA, Active Directory via sssd) are resolving users and groups correctly.

**Data Collection:**

* Executes `/usr/bin/getent <database> [key ...]` and evaluates the exit code

**Compatibility:**

* Linux

**Important Notes:**

* Calling `getent --database=passwd` without `--key` lists only local users, not users on a directory server. To check the availability of a FreeIPA or Active Directory connected via sssd, add the name of a known network account via `--key` to test if network users are resolved correctly. For example: `getent --database=passwd --key=<ldapuser>`
* For details see `man getent`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/getent> |
| Nagios/Icinga Check Name              | `check_getent` |
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
```

```bash
./getent --database hosts --key localhost --key localhost.localdomain
```

```bash
./getent --database passwd --key ldapuser
```

Output:

```text
Everything is ok. Executed `/usr/bin/getent group SysOps`, got 1 results.
```


## States

* OK if the `getent` lookup succeeds and all requested keys are found.
* WARN if one or more supplied keys could not be found in the database (getent exit code 2).
* UNKNOWN if the database name is invalid or arguments are missing (getent exit code 1).
* UNKNOWN if enumeration is not supported for the given database (getent exit code 3).


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
