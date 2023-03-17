Check huawei-dorado-power
=========================

Overview
--------

Batch query basic status and performance data about a Huawei OceanStor Dorado storage system via the REST Interface, using the ``https://${ip}:${port}/deviceManager/rest/${deviceId}/power`` endpoint. Cookies and iBaseTokens are stored and re-used (the session timeout period is usually 20 minutes).

Hints:

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0.
* Create a read-only API user that can perform query only.
* Sometimes the API returns ``This operation fails to be performed because of the unauthorized REST. Before performing this operation, ensure that REST is authorized.``, although everything is fine. In this case, the check simply tries to retrieve the data again, a maximum of 9 times within 9 seconds.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-power"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: huawei-dorado-power [-h] [-V] [--always-ok]
                               [--cache-expire CACHE_EXPIRE] --device-id
                               DEVICE_ID [--no-proxy] --password PASSWORD
                               [--scope SCOPE] [--test TEST] [--timeout TIMEOUT]
                              -u URL --username USERNAME

    Batch query basic information about power modules on a Huawei OceanStor Dorado
    storage system via the REST Interface, using the ``/power`` endpoint.

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

    ./huawei-dorado-power --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass

Output:

.. code-block:: text

    There are warnings.

    UUID       ! Location    ! Manufacturer ! Model         ! SerialNumber         ! Produced   ! In (MV) ! Out (MV) ! Temp ! Health    ! Running   
    -----------+-------------+--------------+---------------+----------------------+------------+---------+----------+------+-----------+-----------
    23:23.0.0  ! CTE0.PSU0   ! HUAWEI       ! PAC2000S12-BG ! 12345678             ! 2020-08-20 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
    23:23.0.1  ! CTE0.PSU1   ! HUAWEI       ! PAC2000S12-BG ! 12345678             ! 2020-08-20 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
    23:23.0.2  ! CTE0.PSU2   ! HUAWEI       ! PAC2000S12-BG ! 12345678             ! 2020-08-21 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
    23:23.0.3  ! CTE0.PSU3   ! HUAWEI       ! PAC2000S12-BG ! 12345678             ! 2020-08-20 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
    23:23.64.0 ! DAE000.PSU0 ! Huawei       ! PAC2000S12-BG ! 12345678             ! 2020-12-02 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
    23:23.64.1 ! DAE000.PSU1 ! Huawei       ! PAC2000S12-BG ! 12345678             ! 2020-12-02 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
    23:23.65.0 ! DAE010.PSU0 ! Huawei       ! PAC2000S12-BG ! 12345678             ! 2020-12-02 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
    23:23.65.1 ! DAE010.PSU1 ! Huawei       ! PAC2000S12-BG ! 12345678             ! 2020-12-02 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
    23:23.66.0 ! DAE020.PSU0 ! Huawei       ! PAC2000S12-BG ! 12345678             ! 2020-12-02 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
    23:23.66.1 ! DAE020.PSU1 ! Huawei       ! PAC2000S12-BG ! 12345678             ! 2020-12-02 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
    23:0.0B.0  ! CTE0.PSU 0  ! VAPEL        ! HSP960-D1205D ! 21022701328NE5000004 ! 2014-05-03 ! 0       ! 0        ! 0    ! [WARNING] ! [WARNING]   

    Fetched API 2 times


States
------

* UNKNOWN on invalid responses or responses with error codes.
* WARN if power health status is not equal to "Normal".
* WARN if power running status is not equal to "Normal", "Running" or "Online".


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    <UUID>_HEALTHSTATUS,                        Number,             "0: unknown, 1: normal, 2: faulty, 9: inconsistent, 11: no input"
    <UUID>_INPUTVOLTAGE,                        Number,             "Output voltage. (MV)"
    <UUID>_OUTPUTVOLTAGE,                       Number,             "Input voltage. (MV)"
    <UUID>_RUNNINGSTATUS,                       Number,             "0: unknown, 1: normal, 2: running, 27: online, 28: offline"
    <UUID>_TEMPERATURE,                         Number,             "Temperature."

Have a look at the `API documentation <https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview>`_ for details.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
