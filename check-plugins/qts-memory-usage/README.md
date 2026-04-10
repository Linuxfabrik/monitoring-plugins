# Check qts-memory-usage

## Overview

Monitors system memory utilization on QNAP appliances running QTS via the HTTP API. Reports total, used, and free memory along with the usage percentage.

**Data Collection:**

* Authenticates against the QTS API and fetches system information via `/cgi-bin/management/manaRequest.cgi`
* Calculates memory usage from the total and free memory values reported by QTS

**Important Notes:**

* 3rd party Python module `xmltodict` required
* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.

**Compatibility:**

* Linux only


## 