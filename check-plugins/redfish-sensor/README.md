# Check redfish-sensor


## Overview

Checks hardware sensor readings (temperature, voltage, fan speed, power) from the Redfish Chassis collection via the Redfish API. Also evaluates fan redundancy status. A Chassis is roughly defined as a physical view of a computer system as seen by a human. A single Chassis resource can house sensors, fans, and other components.

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Data Collection:**

* Queries `/redfish/v1/Chassis` to enumerate chassis members
* For each member, queries the Sensors collection to read individual sensor values, thresholds, and health status
* Also queries the Thermal endpoint for fan redundancy information
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Only evaluates sensors and chassis in "Enabled" or "Quiesced" state


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-sensor> |
| Nagios/Icinga Check Name              | `check_redfish_sensor` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-sensor [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                      [--password PASSWORD] [--test TEST] [--timeout TIMEOUT]
                      [--url URL] [--username USERNAME]

Checks hardware sensor readings (temperature, voltage, fan speed, power) from
the Redfish Chassis collection via the Redfish API. Alerts when any sensor
reports a non-ok state.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --password PASSWORD  Redfish API password.
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  --url URL            Redfish API URL. Default: https://localhost:5000
  --username USERNAME  Redfish API username.
```


## Usage Examples

```bash
./redfish-sensor --url https://bmc --username redfish-monitoring --password 'mypassword'
```

Output:

```text
Everything is ok, checked sensors on 1 member.

Member: Contoso 3500RX, Power: On, LED: Lit, SKU: 8675309, SerNo: 437XR1138R2, PartNumber: 224071-J23

Sensor                             ! Location    ! Reading ! Unit ! Value ! State 
-----------------------------------+-------------+---------+------+-------+-------
Ambient Temperature                ! Room        ! 22.5    ! Cel  ! [OK]  ! [OK]  
CPU #1 Fan Speed                   ! CPU         ! 80      ! %    ! [OK]  ! [OK]  
CPU #2 Fan Speed                   ! CPU         ! 60      ! %    ! [OK]  ! [OK]  
CPU #1 Temperature                 ! CPU         ! 37      ! Cel  ! [OK]  ! [OK]  
DIMM #1 Temperature                ! Memory      ! 44      ! Cel  ! [OK]  ! [OK]  
DIMM #2 Temperature                ! Memory      ! 44      ! Cel  ! [OK]  ! [OK]  
DIMM #3 Temperature                ! Memory      ! 44      ! Cel  ! [OK]  ! [OK]  
Fan Bay #1 Exhaust Temperature     ! Exhaust     ! 40.5    ! Cel  ! [OK]  ! [OK]  
Chassis Fan #1                     ! Chassis     ! 45      ! %    ! [OK]  ! [OK]  
Chassis Fan #2                     ! Chassis     ! 45      ! %    ! [OK]  ! [OK]  
Front Panel Intake Temperature     ! Intake      ! 24.8    ! Cel  ! [OK]  ! [OK]  
Power Supply #1 Energy             ! PowerSupply ! 7855    ! kW.h ! [OK]  ! [OK]  
Power Supply #1 Frequency          ! PowerSupply ! 60.1    ! Hz   ! [OK]  ! [OK]  
Power Supply #1 Input Current      ! PowerSupply ! 8.92    ! A    ! [OK]  ! [OK]  
Power Supply #1 Input Power        ! PowerSupply ! 374     ! W    ! [OK]  ! [OK]  
Power Supply #1 Input Voltage      ! PowerSupply ! 119.27  ! V    ! [OK]  ! [OK]  
Power Supply #1 12V Output Voltage ! PowerSupply ! 12.08   ! V    ! [OK]  ! [OK]  
Power Supply #1 12V Output Current ! Chassis     ! 2.79    ! A    ! [OK]  ! [OK]  
Power Supply #1 3V Output Voltage  ! PowerSupply ! 3.32    ! V    ! [OK]  ! [OK]  
Power Supply #1 3V Output Current  ! PowerSupply ! 8.92    ! A    ! [OK]  ! [OK]  
Power Supply #1 5V Output Voltage  ! PowerSupply ! 5.04    ! V    ! [OK]  ! [OK]  
Power Supply #1 5V Output Current  ! PowerSupply ! 3.41    ! A    ! [OK]  ! [OK]  
Total Energy                       ! Chassis     ! 325675  ! kW.h ! [OK]  ! [OK]  
Power reading for the Chassis      ! Chassis     ! 374     ! W    ! [OK]  ! [OK]

Redundancy            ! Mode ! State 
----------------------+------+-------
BaseBoard System Fans ! N+m  ! [OK]
```


## States

* OK if all sensors are healthy and within their thresholds.
* WARN if an enabled sensor health or health rollup state is "Warning".
* WARN if a sensor value exceeds the Redfish non-critical threshold (`Thresholds_UpperCaution`, `Thresholds_LowerCaution`).
* CRIT if an enabled sensor health or health rollup state is "Critical".
* CRIT if a sensor value exceeds the Redfish critical threshold (`Thresholds_UpperCritical`, `Thresholds_LowerCritical`).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Depends on your hardware. Each sensor from the Redfish Chassis collection is reported as a separate metric.

| Name | Type | Description |
|----|----|----|
| \<chassis\>_\<sensor-name\> | Number | Sensor reading. Examples: `Chassis_Chassis_Fan_1`, `CPU_CPU_1_Temperature`, `Memory_DIMM_1_Temperature`


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
