Check huawei-dorado-interface
=============================

Overview
--------

Batch query basic information about interfaces on a Huawei OceanStor Dorado storage system via the REST Interface, using the ``https://${ip}:${port}/deviceManager/rest/${deviceId}/intf_module`` endpoint. Cookies and iBaseTokens are stored and re-used (the session timeout period is usually 20 minutes).

Hints:

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0.
* Create a read-only API user that can perform query only.
* Sometimes the API returns ``This operation fails to be performed because of the unauthorized REST. Before performing this operation, ensure that REST is authorized.``, although everything is fine. In this case, the check simply tries to retrieve the data again, a maximum of 9 times within 9 seconds.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-interface"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: huawei-dorado-interface [-h] [-V] [--always-ok]
                                   [--cache-expire CACHE_EXPIRE] --device-id
                                   DEVICE_ID [--no-proxy] --password PASSWORD
                                   [--scope SCOPE] [--test TEST]
                                   [--timeout TIMEOUT] -u URL --username USERNAME

    Batch query basic information about interfaces on a Huawei OceanStor Dorado
    storage system via the REST Interface, using the ``/intf_module`` endpoint.

    options:
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

    ./huawei-dorado-interface --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass

Output:

.. code-block:: text

    Everything is ok.

    UUID       ! Location     ! Model                                 ! RunMode  ! LED ! Health ! Running 
    -----------+--------------+---------------------------------------+----------+-----+--------+---------
    209:0A.1   ! CTE0.A.IOM1  ! Unknown                               ! FC       ! Off ! [OK]   ! [OK]    
    209:0.128  ! CTE0.IOM.H0  ! 2 ports FE 100 Gbit/s ETH I/O module  ! Ethernet ! Off ! [OK]   ! [OK]    
    209:0.129  ! CTE0.IOM.H1  ! 2 ports FE 100 Gbit/s ETH I/O module  ! Ethernet ! Off ! [OK]   ! [OK]    
    209:0.134  ! CTE0.IOM.H6  ! 2 ports BE 100 Gbit/s RDMA I/O module ! RoCE     ! Off ! [OK]   ! [OK]    
    209:0.135  ! CTE0.IOM.H7  ! 2 ports BE 100 Gbit/s RDMA I/O module ! RoCE     ! Off ! [OK]   ! [OK]    
    209:0.140  ! CTE0.IOM.H12 ! 2 ports FE 100 Gbit/s ETH I/O module  ! Ethernet ! Off ! [OK]   ! [OK]    
    209:0.141  ! CTE0.IOM.H13 ! 2 ports FE 100 Gbit/s ETH I/O module  ! Ethernet ! Off ! [OK]   ! [OK]    
    209:0.142  ! CTE0.IOM.L0  ! 2 ports FE 100 Gbit/s ETH I/O module  ! Ethernet ! Off ! [OK]   ! [OK]    
    209:0.143  ! CTE0.IOM.L1  ! 2 ports FE 100 Gbit/s ETH I/O module  ! Ethernet ! Off ! [OK]   ! [OK]    
    209:0.148  ! CTE0.IOM.L6  ! 2 ports BE 100 Gbit/s RDMA I/O module ! RoCE     ! Off ! [OK]   ! [OK]    
    209:0.149  ! CTE0.IOM.L7  ! 2 ports BE 100 Gbit/s RDMA I/O module ! RoCE     ! Off ! [OK]   ! [OK]    
    209:0.154  ! CTE0.IOM.L12 ! 2 ports FE 100 Gbit/s ETH I/O module  ! Ethernet ! Off ! [OK]   ! [OK]    
    209:0.155  ! CTE0.IOM.L13 ! 2 ports FE 100 Gbit/s ETH I/O module  ! Ethernet ! Off ! [OK]   ! [OK]    
    209:0.64   ! CTE0.SMM0    ! System Management Module              ! Unknown  ! Off ! [OK]   ! [OK]    
    209:0.65   ! CTE0.SMM1    ! System Management Module              ! Unknown  ! Off ! [OK]   ! [OK]    
    209:0A.130 ! CTE0.IOM.H2  ! AI Accelerator Card                   ! Unknown  ! Off ! [OK]   ! [OK]    
    209:0B.144 ! CTE0.IOM.L2  ! AI Accelerator Card                   ! Unknown  ! Off ! [OK]   ! [OK]    
    209:0C.139 ! CTE0.IOM.H11 ! AI Accelerator Card                   ! Unknown  ! Off ! [OK]   ! [OK]    
    209:0D.153 ! CTE0.IOM.L11 ! AI Accelerator Card                   ! Unknown  ! Off ! [OK]   ! [OK] 

    Fetched API 2 times


States
------

* UNKNOWN on invalid responses or responses with error codes.
* WARN if interface health status is not equal to "Normal".
* WARN if interface running status is not equal to "Normal", "Running" or "Powering on".


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    <UUID>_HEALTHSTATUS,                        Number,             "0: unknown, 1: normal, 2: faulty"
    <UUID>_RUNNINGSTATUS,                       Number,             "0: unknown, 1: normal, 2: running, 12: powering on, 13: powered off, 27: online, 28: offline, 103: power-on failed"

Have a look at the `API documentation <https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview>`_ for details.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
