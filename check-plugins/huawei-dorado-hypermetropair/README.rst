Check huawei-dorado-hypermetropair
==================================

Overview
--------

Batch querying HyperMetro pairs of a Huawei OceanStor Dorado storage system via the REST Interface, using the ``https://${ip}:${port}/deviceManager/rest/${deviceId}/hypermetropair`` endpoint. Cookies and iBaseTokens are stored and re-used (the session timeout period is usually 20 minutes).

Hints:

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0.
* Create a read-only API user that can perform query only.
* Sometimes the API returns ``This operation fails to be performed because of the unauthorized REST. Before performing this operation, ensure that REST is authorized.``, although everything is fine. In this case, the check simply tries to retrieve the data again, a maximum of 9 times within 9 seconds.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-hypermetropair"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: huawei-dorado-hypermetropair [-h] [-V] [--always-ok]
                                        [--cache-expire CACHE_EXPIRE]
                                        --device-id DEVICE_ID [--insecure]
                                        [--no-proxy] --password PASSWORD
                                        [--scope SCOPE] [--test TEST]
                                        [--timeout TIMEOUT] -u URL
                                        --username USERNAME

    Batch query basic information about HyperMetroPairs of a Huawei OceanStor
    Dorado storage system via the REST Interface, using the ``/hypermetropair``
    endpoint.

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

    ./huawei-dorado-hypermetropair --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass

Output:

.. code-block:: text

    Everything is ok.

    UUID                                   ! Link ! Last Sync                       ! Duration ! Progr (%) ! LocalJob  ! DataState ! Access ! RemoteJob ! DataState ! Access ! Health ! Running 
    ---------------------------------------+------+---------------------------------+----------+-----------+-----------+-----------+--------+-----------+-----------+--------+--------+---------
    15361:2100f4b78d046ec60000000000000000 ! [OK] ! 2021-08-18 10:39:47 (3M 6D ago) ! 2m 1s    ! 100       ! LUN01-BLH ! [OK]      ! R/W    ! LUN01-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000001 ! [OK] ! 2021-08-18 10:39:50 (3M 6D ago) ! 2m 3s    ! 100       ! LUN02-BLH ! [OK]      ! R/W    ! LUN02-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000002 ! [OK] ! 2021-08-18 10:38:29 (3M 6D ago) ! 42s      ! 100       ! LUN03-BLH ! [OK]      ! R/W    ! LUN03-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000003 ! [OK] ! 2021-08-18 10:39:03 (3M 6D ago) ! 1m 16s   ! 100       ! LUN04-BLH ! [OK]      ! R/W    ! LUN04-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000004 ! [OK] ! 2021-08-18 10:39:38 (3M 6D ago) ! 1m 51s   ! 100       ! LUN05-BLH ! [OK]      ! R/W    ! LUN05-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000005 ! [OK] ! 2021-08-18 10:39:18 (3M 6D ago) ! 1m 32s   ! 100       ! LUN06-BLH ! [OK]      ! R/W    ! LUN06-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000006 ! [OK] ! 2021-08-18 10:39:30 (3M 6D ago) ! 1m 44s   ! 100       ! LUN07-BLH ! [OK]      ! R/W    ! LUN07-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000007 ! [OK] ! 2021-08-18 10:40:38 (3M 6D ago) ! 2m 51s   ! 100       ! LUN08-BLH ! [OK]      ! R/W    ! LUN08-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000008 ! [OK] ! 2021-08-18 10:39:00 (3M 6D ago) ! 1m 13s   ! 100       ! LUN09-BLH ! [OK]      ! R/W    ! LUN09-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000009 ! [OK] ! 2021-08-18 10:38:41 (3M 6D ago) ! 55s      ! 100       ! LUN10-BLH ! [OK]      ! R/W    ! LUN10-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec6000000000000000a ! [OK] ! 2021-08-18 11:00:44 (3M 6D ago) ! 22m 58s  ! 100       ! LUN11-BLH ! [OK]      ! R/W    ! LUN11-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec6000000000000000b ! [OK] ! 2021-08-18 10:38:13 (3M 6D ago) ! 27s      ! 100       ! LUN12-BLH ! [OK]      ! R/W    ! LUN12-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec6000000000000000c ! [OK] ! 2021-08-18 10:39:56 (3M 6D ago) ! 2m 10s   ! 100       ! LUN13-BLH ! [OK]      ! R/W    ! LUN13-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec6000000000000000d ! [OK] ! 2021-08-18 10:38:44 (3M 6D ago) ! 58s      ! 100       ! LUN14-BLH ! [OK]      ! R/W    ! LUN14-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec6000000000000000e ! [OK] ! 2021-08-18 10:39:28 (3M 6D ago) ! 1m 42s   ! 100       ! LUN15-BLH ! [OK]      ! R/W    ! LUN15-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec6000000000000000f ! [OK] ! 2021-08-18 10:39:01 (3M 6D ago) ! 1m 14s   ! 100       ! LUN16-BLH ! [OK]      ! R/W    ! LUN16-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000010 ! [OK] ! 2021-08-18 10:39:57 (3M 6D ago) ! 2m 10s   ! 100       ! LUN17-BLH ! [OK]      ! R/W    ! LUN17-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000011 ! [OK] ! 2021-08-18 10:39:21 (3M 6D ago) ! 1m 34s   ! 100       ! LUN18-BLH ! [OK]      ! R/W    ! LUN18-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000012 ! [OK] ! 2021-08-18 10:37:52 (3M 6D ago) ! 5s       ! 100       ! LUN19-BLH ! [OK]      ! R/W    ! LUN19-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000013 ! [OK] ! 2021-08-18 10:37:50 (3M 6D ago) ! 3s       ! 100       ! LUN20-BLH ! [OK]      ! R/W    ! LUN20-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000014 ! [OK] ! 2021-08-18 10:37:49 (3M 6D ago) ! 3s       ! 100       ! LUN21-BLH ! [OK]      ! R/W    ! LUN21-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
    15361:2100f4b78d046ec60000000000000015 ! [OK] ! 2021-08-18 10:37:49 (3M 6D ago) ! 2s       ! 100       ! LUN22-BLH ! [OK]      ! R/W    ! LUN22-COL ! [OK]      ! R/W    ! [OK]   ! [OK]

    Fetched API 2 times


States
------

* UNKNOWN on invalid responses or responses with error codes.
* WARN if HyperMetroPair health status is not equal to "Normal".
* WARN if HyperMetroPair running status is not equal to "Normal" or "Synchronizing.
* WARN if link status is not equal to "connected".
* WARN if local data status is not equal to "consistent".
* WARN if remote data status is not equal to "consistent".


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    <UUID>_HEALTHSTATUS,                        Number,             "0: unknown, 1: normal, 2: faulty"
    <UUID>_LINKSTATUS,                          Number,             "1: connected, 2: disconnected"
    <UUID>_LOCALDATASTATE,                      Number,             "1: consistent, 2: inconsistent"
    <UUID>_LOCALHOSTACCESSSTATE,                Number,             "1: access forbidden, 2: read-only, 3: read/write"
    <UUID>_REMOTEDATASTATE,                     Number,             "1: consistent, 2: inconsistent"
    <UUID>_REMOTEHOSTACCESSSTATE,               Number,             "1: access forbidden, 2: read-only, 3: read/write, 5: unknown"
    <UUID>_RUNNINGSTATUS,                       Number,             "1: Normal, 23: Synchronizing, 35: Invalid, 41: Paused, 93: Forcibly started, 100: To be synchronized"
    <UUID>_SYNCPROGRESS,                        Percentage,         "Synchronization progress."

Have a look at the `API documentation <https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview>`_ for details.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
