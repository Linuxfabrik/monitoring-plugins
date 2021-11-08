Check redfish-sensor
====================

Overview
--------

Checks the state of the Chassis collection containing resources that represent the physical aspects of the infrastructure. A Chassis is roughly defined as a physical view of a computer system as seen by a human. A single Chassis resource can house sensors, fans, and other components. 

Hints:

* A check takes up to 10 seconds. Increasing runtime timout to 30 seconds is recommended.
* This check runs with both http and https. It just uses GET requests.
* No additional Python Redfish modules need to be installed.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/redfish-sensor"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: redfish-sensor [-h] [-V] [--always-ok] [--password PASSWORD]
                         [--url URL] [--username USERNAME]

    Checks the state of the Chassis collection containing resources that represent
    the physical aspects of the infrastructure. A Chassis is roughly defined as a
    physical view of a computer system as seen by a human. A single Chassis
    resource can house sensors, fans, and other components.

    optional arguments:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      --password PASSWORD  Redfish API password.
      --url URL            Redfish API URL. Default: https://localhost:5000
      --username USERNAME  Redfish API username.


Usage Examples
--------------

.. code-block:: bash

    ./redfish-sensor --url https://bmc --username redfish-monitoring --password 'mypassword'

Output:

.. code-block:: text

    Contoso 3500RX, Power: On, LED: Lit, SKU: 8675309, SerNo: 437XR1138R2, PartNumber: 224071-J23

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


States
------

* CRIT if an enabled sensor health rollup state is equal to "Critical".
* CRIT if an enabled sensor health state is equal to "Critical".
* CRIT if sensor value is above/below critical threshold given by Redfish (``Thresholds_UpperCritical`` and ``Thresholds_LowerCritical``).
* WARN if an enabled sensor health rollup state is equal to "Warning".
* WARN if an enabled sensor health state is equal to "Warning".
* WARN if sensor value is above/below Redfish non-critical threshold (``Thresholds_UpperCaution`` and ``Thresholds_LowerCaution``).


Perfdata / Metrics
------------------

Depends on your hardware - as an example:

* Chassis_Chassis_Fan_#1
* Chassis_Chassis_Fan_#2
* Chassis_Power_reading_for_the_Chassis
* Chassis_Power_Supply_#1_12V_Output_Current
* Chassis_Total_Energy
* CPU_CPU_#1_Fan_Speed
* CPU_CPU_#1_Temperature
* CPU_CPU_#2_Fan_Speed
* Exhaust_Fan_Bay_#1_Exhaust_Temperature
* Intake_Front_Panel_Intake_Temperature
* Memory_DIMM_#1_Temperature
* Memory_DIMM_#2_Temperature
* Memory_DIMM_#3_Temperature
* PowerSupply_Power_Supply_#1_12V_Output_Voltage
* PowerSupply_Power_Supply_#1_3V_Output_Current
* PowerSupply_Power_Supply_#1_3V_Output_Voltage
* PowerSupply_Power_Supply_#1_5V_Output_Current
* PowerSupply_Power_Supply_#1_5V_Output_Voltage
* PowerSupply_Power_Supply_#1_Energy
* PowerSupply_Power_Supply_#1_Frequency
* PowerSupply_Power_Supply_#1_Input_Current
* PowerSupply_Power_Supply_#1_Input_Power
* PowerSupply_Power_Supply_#1_Input_Voltage
* Room_Ambient_Temperature


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
