# Check cometsystem

## Overview

Reads sensor data from Comet System Web Sensors via their JSON API endpoint. Monitors channels such as temperature, humidity, and other environmental values. Alarm states are mapped to configurable severity levels using a flexible pattern matching system (e.g. "temp:high:crit", "humi:low:warn").

**Data Collection:**

* Fetches sensor data from the JSON endpoint of a [COMET SYSTEM](https://www.cometsystem.com/) Web Sensor (e.g. `http://example.com/values.json`)
* Iterates over all channels (`ch1`, `ch2`, ...) and reads their name, value, unit, and alarm state
* Alarm mode per channel selects the direction: lower than limit (low alarm), higher than limit (high alarm), or disabled

**Compatibility:**

* Cross-platform


**