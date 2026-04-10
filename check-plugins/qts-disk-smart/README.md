# Check qts-disk-smart

## Overview

Checks disk SMART values on QNAP appliances running QTS via the API. Reports drive health, temperature, and SMART attribute status for all installed HDDs and SSDs. Disk temperature thresholds are determined automatically from the QTS system configuration.

**Data Collection:**

* Authenticates against the QTS API and fetches disk SMART data via `/cgi-bin/disk/qsmart.cgi`
* Fetches system information via `/cgi-bin/management/manaRequest.cgi` to retrieve temperature thresholds
* This check does not run SMART itself. To get the latest values, schedule the built-in SMART check in the QTS web interface.

**Important Notes:**

* 3rd party Python module `xmltodict` required
* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.

**Compatibility:**

* Linux only


## 