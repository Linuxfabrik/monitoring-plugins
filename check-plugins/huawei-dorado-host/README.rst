Check huawei-dorado-host
=============================

Overview
--------

Batch querying basic information about hosts attached to a Huawei OceanStor Dorado storage system via the REST Interface, using the ``https://${ip}:${port}/deviceManager/rest/${deviceId}/host`` endpoint. Cookies and iBaseTokens are stored and re-used (the session timeout period is usually 20 minutes).

Hints:

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0.
* Create a read-only API user that can perform query only.
* Sometimes the API returns ``This operation fails to be performed because of the unauthorized REST. Before performing this operation, ensure that REST is authorized.``, although everything is fine. In this case, the check simply tries to retrieve the data again, a maximum of 9 times within 9 seconds.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-host"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: huawei-dorado-host [-h] [-V] [--always-ok]
                              [--cache-expire CACHE_EXPIRE] --device-id DEVICE_ID
                              [--no-proxy] --password PASSWORD [--scope SCOPE]
                              [--test TEST] [--timeout TIMEOUT] -u URL --username
                              USERNAME

    Batch query basic information about hosts attached to a Huawei OceanStor
    Dorado storage system via the REST Interface, using the ``/host`` endpoint.

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

    ./huawei-dorado-host --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass

Output:

.. code-block:: text

    There are warnings.

    UUID  ! Location ! Name      ! OS         ! Health    ! Running 
    ------+----------+-----------+------------+-----------+---------
    21:1  !          ! host1     ! Solaris    ! [OK]      ! [OK]    
    21:2  !          ! host2     ! Linux      ! [WARNING] ! [OK]    
    21:0  !          ! site01-01 ! VMware ESX ! [OK]      ! [OK]    
    21:1  !          ! site01-02 ! VMware ESX ! [OK]      ! [OK]    
    21:2  !          ! site01-03 ! VMware ESX ! [OK]      ! [OK]    
    21:3  !          ! site01-04 ! VMware ESX ! [OK]      ! [OK]    
    21:4  !          ! site01-05 ! VMware ESX ! [OK]      ! [OK]    
    21:5  !          ! site01-06 ! VMware ESX ! [OK]      ! [OK]    
    21:6  !          ! site02-01 ! VMware ESX ! [OK]      ! [OK]    
    21:7  !          ! site02-02 ! VMware ESX ! [OK]      ! [OK]    
    21:8  !          ! site02-03 ! VMware ESX ! [OK]      ! [OK]    
    21:9  !          ! site02-04 ! VMware ESX ! [OK]      ! [OK]    
    21:10 !          ! site02-05 ! VMware ESX ! [OK]      ! [OK]    
    21:11 !          ! site02-06 ! VMware ESX ! [OK]      ! [OK] 

    Fetched API 2 times


States
------

* UNKNOWN on invalid responses or responses with error codes.
* WARN if host health status is not equal to "Normal".
* WARN if host running status is not equal to "Normal".


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    <UUID>_HEALTHSTATUS,                        Number,             "1: Normal, 17: No redundant link, 18: Offline"
    <UUID>_RUNNINGSTATUS,                       Number,             "1: normal"
    <UUID>_allocatedCapacity,                   Number,             "Used capacity."

Have a look at the `API documentation <https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview>`_ for details.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
