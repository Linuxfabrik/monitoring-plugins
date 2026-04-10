# Check ntp-systemd-timesyncd

## Overview

Checks the state of systemd-timesyncd, including synchronization status, server reachability, and stratum level. Alerts if time synchronization is inactive or if the stratum exceeds the configured limit.

**Data Collection:**

* Executes `timedatectl show-timesync --all` to obtain the current synchronization status
* Parses the NTP message to extract the stratum value
* Displays the full timedatectl output including configured NTP servers, server name and address, root distance, poll intervals, NTP message details, and frequency

**Compatibility:**

* Linux systems using systemd-timesyncd for time synchronization

**Important Notes:**

* The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.


## 