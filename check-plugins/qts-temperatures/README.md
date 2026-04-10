# Check qts-temperatures

## Overview

Checks system and CPU temperatures on QNAP appliances running QTS via the HTTP API. All temperatures are expressed in Celsius. Temperature thresholds are determined automatically from the QTS system configuration.

**Data Collection:**

* Authenticates against the QTS API and fetches system information via `/cgi-bin/management/manaRequest.cgi`
* Reads system temperature (`sys_tempc`), CPU temperature (`cpu_tempc`), and the corresponding warning/error thresholds from the QTS configuration

**Important Notes:**

* 3rd party Python module `xmltodict` required
* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.

**Compatibility:**

* Linux only


## 