# Check starface-channel-status

## Overview

Counts the number of active DAHDI, SIP, and other channels on a Starface PBX, and alerts on channel overusage when a maximum call limit is configured on the PBX.

**Data Collection:**

* Connects via socket to the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) on port 6556
* Supports both IPv4 (default) and IPv6
* Fetched data is cached for up to one minute in a shared SQLite database, so that multiple Starface checks running in parallel do not overload the PBX

**Compatibility:**

* Cross-platform

**Important Notes:**

* Requires the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) to be installed on the PBX


## 