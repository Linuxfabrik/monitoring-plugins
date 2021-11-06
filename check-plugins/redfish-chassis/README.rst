Check redfish-chassis
=====================

Overview
--------

Checks the state of the Chassis collection containing resources that represent the physical aspects of the infrastructure. A Chassis is roughly defined as a physical view of a computer system as seen by a human. A single Chassis resource can house sensors, fans, and other components. 

This check runs with both http and https. No additional Python Redfish modules need to be installed.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/redfish-chassis"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: redfish-chassis [-h] [-V] [--always-ok] [--password PASSWORD]
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
      --username USERNAME  Redfish API username. Default: redfish-monitoring



Usage Examples
--------------

.. code-block:: bash

    ./redfish-chassis --url https://bmc --username redfish-monitoring --password 'mypassword'

Output:

.. code-block:: text

    Dell Inc. Precision 7920 Rack, Power: On, LED: Lit, SKU: ABCDEFG, SerNo: ABCDE12345678C, PartNumber: ABCDEFGH

    Fan               ! Location    ! Reading ! Unit ! Value ! State 
    ------------------+-------------+---------+------+-------+-------
    System Board Fan1 ! SystemBoard ! 7560    ! RPM  ! [OK]  ! [OK]  
    System Board Fan2 ! SystemBoard ! 7560    ! RPM  ! [OK]  ! [OK]  
    System Board Fan3 ! SystemBoard ! 7680    ! RPM  ! [OK]  ! [OK]  
    System Board Fan4 ! SystemBoard ! 7440    ! RPM  ! [OK]  ! [OK]  
    System Board Fan5 ! SystemBoard ! 7560    ! RPM  ! [OK]  ! [OK]  
    System Board Fan6 ! SystemBoard ! 7560    ! RPM  ! [OK]  ! [OK]  


    Temperature               ! Location    ! Reading ! Value ! State 
    --------------------------+-------------+---------+-------+-------
    CPU1 Temp                 ! CPU         ! 32      ! [OK]  ! [OK]  
    CPU2 Temp                 ! CPU         ! 33      ! [OK]  ! [OK]  
    System Board Inlet Temp   ! SystemBoard ! 24      ! [OK]  ! [OK]  
    System Board Exhaust Temp ! SystemBoard ! 27      ! [OK]  ! [OK]  


    Redundancy                  ! Mode ! State 
    ----------------------------+------+-------
    System Board Fan Redundancy ! N+m  ! [OK]


States
------

* CRIT if an enabled sensor health rollup state is equal to "Critical".
* CRIT if an enabled sensor health state is equal to "Critical".
* CRIT if sensor value is above/below critical threshold given by Redfish (``UpperThresholdCritical`` and ``LowerThresholdCritical``).
* WARN if an enabled sensor health rollup state is equal to "Warning".
* WARN if an enabled sensor health state is equal to "Warning".
* WARN if sensor value is above/below Redfish non-critical threshold (``UpperThresholdNonCritical`` and ``LowerThresholdNonCritical``).


Perfdata / Metrics
------------------

Depends on your hardware - as an example:

* System Board Fan1
* System Board Fan2
* System Board Fan3
* System Board Fan4
* System Board Fan5
* System Board Fan6
* CPU1 Temp
* CPU2 Temp
* System Board Inlet Temp
* System Board Exhaust Temp


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
