# Check qts-version

## Overview

Checks if firmware updates are available for a QNAP appliance running QTS by querying the QNAP update API. Reports the currently installed version and alerts when a newer firmware version is available.

**Data Collection:**

* Authenticates against the QTS API and fetches system information via `/cgi-bin/management/manaRequest.cgi`
* Checks for updates via `/cgi-bin/sys/sysRequest.cgi?subfunc=firm_update`
* Compares the installed version against the latest available version

**Important Notes:**

* 3rd party Python module `xmltodict` required
* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* Does not work on QTS 4.3 or less (see [#701](https://github.com/Linuxfabrik/monitoring-plugins/issues/701) for details).
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.

**Compatibility:**

* Linux only


## 