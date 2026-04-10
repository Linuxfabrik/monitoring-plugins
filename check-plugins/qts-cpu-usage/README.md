# Check qts-cpu-usage

## Overview

Monitors CPU utilization on QNAP appliances running QTS via the HTTP API. Alerts only if the threshold has been exceeded for a configurable number of consecutive check runs (default: 5), suppressing short spikes.

**Data Collection:**

* Authenticates against the QTS API and fetches system information via `/cgi-bin/management/manaRequest.cgi`
* Uses a local SQLite database to store historical CPU measurements for trend tracking
* `--count=5` (the default) while checking every minute means the check reports a warning if the overall CPU usage is above a threshold in the last 5 minutes

**Important Notes:**

* 3rd party Python module `xmltodict` required
* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.

**Compatibility:**

* Linux only


## 