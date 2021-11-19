Check huawei-dorado-disk
========================

Overview
--------

Batch query basic status and performance data about a Huawei OceanStor Dorado storage disk via the REST Interface, using the ``https://${ip}:${port}/deviceManager/rest/${deviceId}/disk`` endpoint. Cookies and iBaseTokens are stored and re-used (the session timeout period is usually 20 minutes).

Hints:

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0.
* Create a read-only API user that can perform query only.
* Sometimes the API returns ``This operation fails to be performed because of the unauthorized REST. Before performing this operation, ensure that REST is authorized.``, although everything is fine. In this case, the check simply tries to retrieve the data again, a maximum of 9 times within 9 seconds.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/huawei-dorado-disk"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: huawei-dorado-disk [-h] [-V] [--always-ok]
                             [--cache-expire CACHE_EXPIRE] --device-id DEVICE_ID
                             [--no-proxy] --password PASSWORD [--scope SCOPE]
                             [--test TEST] [--timeout TIMEOUT] -u URL --username
                             USERNAME

    Batch query basic information about disks on a Huawei OceanStor Dorado storage
    system via the REST Interface, using the ``/disk`` endpoint.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the credential cache
                            expires, in minutes. Default: 15
      --device-id DEVICE_ID
                            Huawei OceanStor Dorado API Device ID.
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   Huawei OceanStor Dorado API Password.
      --scope SCOPE         Huawei OceanStor Dorado API Scope.
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -u URL, --url URL     Huawei OceanStor Dorado API URL.
      --username USERNAME   Huawei OceanStor Dorado API Username.


Usage Examples
--------------

.. code-block:: bash

    ./huawei-dorado-disk --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass

Output:

.. code-block:: text

    Everything is ok.

    Manufacturer ! Model            ! SerialNumber         ! Location ! Abrasion% ! Progress% ! Runtime ! Temp ! Health ! Running 
    -------------+------------------+----------------------+----------+-----------+-----------+---------+------+--------+---------
    HUAWEI       ! HSSD-D7294DL7T6E ! 12345678             ! DAE000.0 ! 67        ! 0         ! 4M 2W   ! 36   ! [OK]   ! [OK]    
    HUAWEI       ! HSSD-D7294DL7T6E ! 12345679             ! DAE000.1 ! 70        ! 0         ! 4M 2W   ! 37   ! [OK]   ! [OK]    
    Seagate      ! ST2000NM0023     ! Z1X2F480000094381WYN ! CTE0.0   ! 0         ! 0         ! 1Y 4M   ! 37   ! [OK]   ! [OK]


States
------

* UNKNOWN on invalid responses or responses with error codes.
* CRIT if disk health status is not equal to "Normal".
* WARN if disk running status is not equal to "Normal" or "Online".


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    <Disk>_ABRASIONRATE,                        Percentage,         "Wear (Wear is the percentage of used service life to total service life.)."
    <Disk>_CAPACITYUSAGE,                       Percentage,         "Capacity usage."
    <Disk>_HEALTHMARK,                          Number,             "Health score of the disk."
    <Disk>_HEALTHSTATUS,                        Number,             "0: unknown, 1: normal, 2: faulty, 3: about to fail, 17: single link"
    <Disk>_PROGRESS,                            Percentage          "Progresses of reconstruction, copyback, pre-copy, and destruction."
    <Disk>_REMAINLIFE,                          Seconds,            "Remaining service life."
    <Disk>_RUNNINGSTATUS,                       Number,             "0: unknown, 1: normal, 14: pre-copy, 16: reconstruction, 27: online, 28: offline, 114: erasing, 115: verifying"
    <Disk>_RUNTIME,                             Seconds,            "Operating time."
    <Disk>_TEMPERATURE,                         Number,             "Temperature."

Have a look at the `API documentation <https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview>`_ for details.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
