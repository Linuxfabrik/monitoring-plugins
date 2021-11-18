Check huawei-dorado-system
==========================

Overview
--------

Query basic status and performance data about a Huawei OceanStor Dorado storage system via the REST Interface, using the ``https://${ip}:${port}/deviceManager/rest/${deviceId}/system/`` endpoint. Cookies and iBaseTokens are stored and re-used (the session timeout period is usually 20 minutes).

Hints:

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0.
* Create a read-only API user that can perform query only.
* Sometimes the API returns ``This operation fails to be performed because of the unauthorized REST. Before performing this operation, ensure that REST is authorized.``, although everything is fine. In this case, the check simply tries to retrieve the data again, a maximum of 9 times within 9 seconds.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/huawei-dorado-system"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: huawei-dorado-system [-h] [-V] [--always-ok]
                                [--cache-expire CACHE_EXPIRE] [-c CRIT]
                                --device-id DEVICE_ID [--no-proxy] --password
                                PASSWORD [--scope SCOPE] [--test TEST]
                                [--timeout TIMEOUT] -u URL --username USERNAME
                                [-w WARN]

    Query basic status and performance data about a Huawei OceanStor Dorado
    storage system via the REST Interface, using the ``/system/`` endpoint.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the credential cache
                            expires, in minutes. Default: 15
      -c CRIT, --critical CRIT
                            Set the CRIT threshold as a percentage. Default: >= 95
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
      -w WARN, --warning WARN
                            Set the WARN threshold as a percentage. Default: >= 90


Usage Examples
--------------

.. code-block:: bash

    ./huawei-dorado-system --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass

Output:

.. code-block:: text

    OceanStor Dorado 8000 V6 6.1.0.SPH12, Name: myname, ID: 123456789, Location: mylocation, Health Status: Normal, Running Status: Normal
    Sectors: Total 1.0% used (19.0G/1.6T), Storage Pool 1.0% used (19.0G/1.3T)
    Fetched API 2 times


States
------

* UNKNOWN on invalid responses or responses with error codes.
* CRIT if system health status is not equal to "Normal".
* WARN if system running status is not equal to "Normal".
* WARN or CRIT if STORAGEPOOLUSEDCAPACITY in percent is above a given threshold.
* WARN or CRIT if USEDCAPACITY in percent is above a given threshold.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    FREEDISKSCAPACITY,                          Sectors,            "Total raw capacity of all free disks (If no free disks exist in the system, the value is 0.).""
    HEALTHSTATUS,                               Number,             "1: Normal, 2: Faulty"
    HOTSPAREDISKSCAPACITY,                      Sectors,            "Total raw capacity of all hot spare disks (If no hot spare disks exist in the system, the value is 0. The value is fixed to 0 for systems built based on the XVE architecture.)."
    mappedLunsCountCapacity,                    Sectors,            "Total capacity of mapped LUNs."
    RUNNINGSTATUS,                              Number,             "1: Normal, 3: Not running, 12: Powering on, 47: Powering off, 51: Upgrading"
    sectors-capacity-percent,                   Percentage,         
    sectors-storagepool-percent,                Percentage,         
    STORAGEPOOLFREECAPACITY,                    Sectors,            "Total free capacity of all storage pools (after RAID groups are created)."
    STORAGEPOOLHOSTSPARECAPACITY,               Sectors,            "Total hot spare capacity reserved of all storage pools (after RAID groups are created)."
    STORAGEPOOLRAWCAPACITY,                     Sectors,            "Total raw capacity of disks in all storage pools."
    STORAGEPOOLUSEDCAPACITY,                    Sectors,            "Total used capacity of all storage pools (after RAID groups are created)."
    THICKLUNSALLOCATECAPACITY,                  Sectors,            "Total capacity allocated to all thick LUNs."
    THICKLUNSUSEDCAPACITY,                      Sectors,            "Total used capacity of all thick LUNs."
    THINLUNSALLOCATECAPACITY,                   Sectors,            "Total capacity allocated to all thin LUNs."
    THINLUNSUSEDCAPACITY,                       Sectors,            "Total used capacity of all thin LUNs."
    UNAVAILABLEDISKSCAPACITY,                   Sectors,            "Total raw capacity of all unavailable disks (If no unavailable disks exist in the system, the value is 0. An unavailable disk is a malfunctioning member disk or free disk.)."
    unMappedLunsCountCapacity,                  Sectors,            "Total capacity of unmapped LUNs."
    USEDCAPACITY,                               Sectors,            "Used system capacity."
    userFreeCapacity,                           Sectors,            "Available system capacity."

Have a look at the `API documentation <https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview>`_ for details.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
