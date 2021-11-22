Check huawei-dorado-fan
=======================

Overview
--------

Batch query basic information about fans of a Huawei OceanStor Dorado storage system via the REST Interface, using the ``https://${ip}:${port}/deviceManager/rest/${deviceId}/fan`` endpoint. Cookies and iBaseTokens are stored and re-used (the session timeout period is usually 20 minutes).

Hints:

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0.
* Create a read-only API user that can perform query only.
* Sometimes the API returns ``This operation fails to be performed because of the unauthorized REST. Before performing this operation, ensure that REST is authorized.``, although everything is fine. In this case, the check simply tries to retrieve the data again, a maximum of 9 times within 9 seconds.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/huawei-dorado-fan"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: huawei-dorado-fan [-h] [-V] [--always-ok]
                            [--cache-expire CACHE_EXPIRE] --device-id DEVICE_ID
                            [--no-proxy] --password PASSWORD [--scope SCOPE]
                            [--test TEST] [--timeout TIMEOUT] -u URL --username
                            USERNAME

    Batch query basic information about fans on a Huawei OceanStor Dorado storage
    system via the REST Interface, using the ``/fan`` endpoint.

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

    ./huawei-dorado-fan --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass

Output:

.. code-block:: text

    Everything is ok.

    UUID            ! Location      ! Runlevel   ! Health ! Running 
    ----------------+---------------+------------+--------+---------
    211:211.0.0.00  ! CTE0.A.FAN0   ! normal (1) ! [OK]   ! [OK]    
    211:211.0.0.01  ! CTE0.A.FAN1   ! normal (1) ! [OK]   ! [OK]    
    211:211.64.0.00 ! DAE000.A.FAN0 ! low (0)    ! [OK]   ! [OK]    
    211:211.64.0.01 ! DAE000.A.FAN1 ! low (0)    ! [OK]   ! [OK]    
    211:0.0B.0      ! CTE0.PSU 0    ! low (0)    ! [OK]   ! [OK]    

    Fetched API 2 times


States
------

* UNKNOWN on invalid responses or responses with error codes.
* WARN if fan health status is not equal to "Normal".
* WARN if fan running status is not equal to "Normal", "Running" or "Online".


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    <UUID>_HEALTHSTATUS,                        Number,             "0: unknown, 1: normal, 2: faulty"
    <UUID>_RUNLEVEL,                            Numer,              "0: low, 1: normal, 2: high"
    <UUID>_RUNNINGSTATUS,                       Number,             "0: unknown, 1: normal, 2: running, 3: not running, 8: spin down, 27: online, 28: offline"

Have a look at the `API documentation <https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview>`_ for details.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
