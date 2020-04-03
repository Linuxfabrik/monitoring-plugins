# Check "getent" - Overview

The getent plugin checks entries from databases supported by the Name Service Switch libraries, which are configured in `/etc/nsswitch.conf`, using the `getent` command, and warns if no match - so it helps for example to check the availability of a FreeIPA or an Active Directory (AD) connected via `sssd`.

If one or more key arguments are provided, then only the entries that match the supplied keys will be checked.

For details have a look at `man getent`.

We recommend to run this check every 15 minutes.


# Installation and Usage

```bash
./getent --database group --key SysOps
./getent --database hosts --key localhost --key localhost.localdomain
./getent --help
```


# States

* WARN if one or more supplied keys could not be found in the database.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.