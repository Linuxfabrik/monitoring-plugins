# Check "nextcloud-security-scan" - Overview

Checks the security of your private cloud server using Nextcloud Security Scan from https://scan.nextcloud.com/, so the check itself does not need to run on the same host that serves Nextcloud. Triggers a rescan on https://scan.nextcloud.com/ if result is older than 14 days (default). Have a look at https://scan.nextcloud.com/ for further explanation. 

Works with ownCloud, too.

We recommend to run this check once a day or week.


# Installation and Usage

```bash
./nextcloud-security-scan --url cloud.linuxfabrik.io
./nextcloud-security-scan --url cloud.linuxfabrik.io --timeout 1 --trigger 10
./nextcloud-security-scan --help
```

# States

* CRIT if Nextcloud Rating is F, E.
* WARN if Nextcloud Rating is D, C.
* Otherwise OK.


# Perfdata

There is no perfdata.


# Known Issues and Limitations

* Run it once a day max. There is an API limit at the scan.nextcloud.com server at the /api/queue endpoint with less than 100 POST requests a day (you will then run into a "403 Forbidden").
* `--noproxy` not implemented
* `--insecure` not implemented


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.