# Check starface-java-memory-usage

## Overview

Monitors Java heap and non-heap memory usage of the Starface PBX. If the JVM reports unlimited memory for heap or non-heap, no percentage is calculated and no threshold check is performed for that memory area.

**Data Collection:**

* Connects via socket to the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) on port 6556
* Supports both IPv4 (default) and IPv6
* Fetched data is cached for up to one minute in a shared SQLite database, so that multiple Starface checks running in parallel do not overload the PBX

**Compatibility:**

* Cross-platform

**Important Notes:**

* Requires the [Starface Monitoring Module](https://wiki.fluxpunkt.de/display/FPW/Monitoring) to be installed on the PBX


## 