# Check ntp-chronyd

## Overview

Checks the clock offset of chronyd in milliseconds compared to the configured NTP servers. Alerts when the offset exceeds the configured thresholds.

**Data Collection:**

* Executes `chronyc tracking` to obtain the current synchronization status
* Reports Reference ID, Stratum, Ref time, System time, Last offset, RMS offset, Frequency, Residual freq, Skew, Root delay, Root dispersion, Update interval, and Leap status
* If no NTP server is reachable, additionally runs `chronyc sources` to display the configured NTP servers

**Compatibility:**

* Linux systems running chronyd

**Important Notes:**

* The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.


## 