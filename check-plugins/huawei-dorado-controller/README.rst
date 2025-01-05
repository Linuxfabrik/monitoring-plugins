Check huawei-dorado-controller
==============================

Overview
--------

Batch querying controllers of a Huawei OceanStor Dorado storage system via the REST Interface, using the ``https://${ip}:${port}/deviceManager/rest/${deviceId}/controller`` endpoint. Cookies and iBaseTokens are stored and re-used (the session timeout period is usually 20 minutes).

Hints:

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0.
* Create a read-only API user that can perform query only.
* Sometimes the API returns ``This operation fails to be performed because of the unauthorized REST. Before performing this operation, ensure that REST is authorized.``, although everything is fine. In this case, the check simply tries to retrieve the data again, a maximum of 9 times within 9 seconds.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-controller"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: huawei-dorado-controller [-h] [-V] [--always-ok]
                                    [--cache-expire CACHE_EXPIRE]
                                    --device-id DEVICE_ID [--insecure]
                                    [--no-proxy] --password PASSWORD
                                    [--scope SCOPE] [--test TEST]
                                    [--timeout TIMEOUT] -u URL --username USERNAME

    Batch querying controllers of a Huawei OceanStor Dorado storage system via the
    REST Interface, using the ``/controller`` endpoint.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the credential cache
                            expires, in minutes. Default: 15
      --device-id DEVICE_ID
                            Huawei OceanStor Dorado API Device ID.
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: True
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   Huawei OceanStor Dorado API Password.
      --scope SCOPE         Huawei OceanStor Dorado API Scope.
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -u, --url URL         Huawei OceanStor Dorado API URL.
      --username USERNAME   Huawei OceanStor Dorado API Username.


Usage Examples
--------------

.. code-block:: bash

    ./huawei-dorado-controller --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass

Output:

.. code-block:: text

    There are critical errors.

    UUID   ! Location ! Model                               ! Role      ! Master ! CPU (%) ! Mem (%) ! Volt ! Health     ! Running 
    -------+----------+-------------------------------------+-----------+--------+---------+---------+------+------------+---------
    207:0A ! CTE0.A   ! Unknown                             ! Primary   ! -      ! 3       ! 75      ! 120  ! [CRITICAL] ! [OK]    
    207:0A ! CTE0.A   ! V6R1C00 4U4C high-end control board ! Secondary ! -      ! 33      ! 87      ! 120  ! [OK]       ! [OK]    
    207:0B ! CTE0.B   ! V6R1C00 4U4C high-end control board ! Primary   ! x      ! 17      ! 87      ! 120  ! [OK]       ! [OK]    
    207:0C ! CTE0.C   ! V6R1C00 4U4C high-end control board ! Secondary ! -      ! 33      ! 86      ! 120  ! [OK]       ! [OK]    
    207:0D ! CTE0.D   ! V6R1C00 4U4C high-end control board ! Secondary ! -      ! 32      ! 92      ! 120  ! [OK]       ! [OK]

    Fetched API 2 times


States
------

* UNKNOWN on invalid responses or responses with error codes.
* CRIT if controller health status is not equal to "Normal".
* WARN if controller running status is not equal to "Normal", "Running" or "Online".


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    <UUID>_CPUUSAGE,                            Percentage,         CPU utilization.
    <UUID>_DIRTYDATARATE,                       Percentage,         Dirty page usage.
    <UUID>_HEALTHSTATUS,                        Number,             "0: unknown, 1: normal, 2: faulty"
    <UUID>_LIGHT_STATUS,                        Number,             "1: off, 2: on"
    <UUID>_MEMORYUSAGE,                         Percentage,         Memory utilization.
    <UUID>_RUNNINGSTATUS,                       Number,             "0: unknown, 1: normal, 2: running, 5: sleep in high temperature, 27: online, 28: offline, 105: abnormal"
    <UUID>_TEMPERATURE,                         Number,             Temperature.
    <UUID>_VOLTAGE,                             Number,             Voltage.

Have a look at the `API documentation <https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview>`_ for details.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
