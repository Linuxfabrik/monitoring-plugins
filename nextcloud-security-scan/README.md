# Overview

Checks the security of your private cloud server using Nextcloud Security Scan from https://scan.nextcloud.com/, so the check itself does not need to run on the same host that serves Nextcloud. Have a look at https://scan.nextcloud.com/ for further explanation. Works with ownCloud, too.


# Installation and Usage

```bash
./nextcloud-security-scan --url cloud.linuxfabrik.io
./nextcloud-security-scan --url cloud.linuxfabrik.io --timeout=1 --trigger=10
./nextcloud-security-scan --help
```

# States and Perfdata

* UNKNOWN if there are network issues fetching scan.nextcloud.com (timeouts etc.)
* CRIT if Nextcloud Rating is F, E
* WARN if Nextcloud Rating is D, C
* otherwise OK


# Known Issues and Limitations

* Run it once a day. There is an API limit at the scan.nextcloud.com server at the /api/queue endpoint with around 100 POST requests a day (you will then run into a "403 Forbidden").
* `--noproxy` not implemented


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
