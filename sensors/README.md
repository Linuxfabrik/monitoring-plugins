# Check "sensors" - Overview

Checks the status of some hardware sensors using the lm_sensors package.

If `sensors` returns information which is not useful because devices do not exist or are not connected, like for example fan sensors, disable these in `/etc/sensors.conf` with the `ignore` directive:

```
ignore fan1
ignore fan3
```

If `sensors` returns alarms, check if sensors' min and max limits are configured correctly, they're probably defaults or from some other boards. Voltages are rarely reported by drivers correctly, because a scaling factor needs to be applied to the limited range of the internal sensors. (https://serverfault.com/questions/379756/is-it-safe-to-ignore-the-lm-sensors-voltage-alarms)

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* `sensors` from `lm_sensors`

```bash
./sensors
./sensors --help
```


# States

* WARN if sensor reports an alarm.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.