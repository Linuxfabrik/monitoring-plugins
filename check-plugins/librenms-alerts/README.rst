Check librenms-alerts
=====================

Overview
--------

LibreNMS includes a highly customizable alerting system. The system requires a set of user-defined rules to evaluate the situation of each device, port, service or any other entity. This check warns about unacknowledged alerts in LibreNMS and reports the latest of the most critical alerts of each device (only for those who do not have "Disabled alerting" in their LibreNMS device settings). When alerts have triggered in LibreNMS, you will see these in the *Alerts > Notifications* page within the Web UI. If you acknowledge an alert in LibreNMS, this check will change its state to OK.

You need to create an API token for a user with "Global Read" level (login with an admin account, then go to LibreNMS > Gear Icon > API > API Settings, choose this user and create the API token).

Note: When defining device groups in LibreNMS for the use with ``--device--group``, refrain from using slashes in the name, as that will not work. See `this issue for example <https://github.com/laravel/framework/issues/22125>`_.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/librenms-alerts"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "LibreNMS API Token"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-lib-librenms-*.db``"


Help
----

.. code-block:: text

    usage: librenms-alerts  [-h] [-V] [--always-ok] [--device-group DEVICE_GROUP]
                            [--device-hostname DEVICE_HOSTNAME]
                            [--device-type {appliance,collaboration,environment,firewall,loadbalancer,network,power,printer,server,storage,wireless,workstation}]
                            [--insecure] [--lengthy] [--no-proxy]
                            [--timeout TIMEOUT] --token TOKEN [--url URL]

    This check fetches unacknowledged alerts from a LibreNMS instance, using its
    API.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --device-group DEVICE_GROUP
                            Filter by LibreNMS Device Group.
      --device-hostname DEVICE_HOSTNAME
                            Filter by LibreNMS Hostname (repeating).
      --device-type {appliance,collaboration,environment,firewall,loadbalancer,network,power,printer,server,storage,wireless,workstation}
                            Filter by LibreNMS Device Type (repeating).
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --lengthy             Extended reporting.
      --no-proxy            Do not use a proxy. Default: False
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --token TOKEN         LibreNMS API token
      --url URL             LibreNMS API URL. Default: http://localhost


Usage Examples
--------------

.. code-block:: bash

    ./librenms-alerts --url http://librenms --token 03xyza61e711234229d

Output:

.. code-block:: text

    There are one or more criticals.

    Hostname     SysName         Alerts Worst State Latest & Worst Msg
    --------     -------         ------ ----------- ------------------
    10.80.32.109 S3900-48T4S     1      [CRITICAL]  Device Down! Due to no ICMP response.
    10.80.32.141 switch99        3      [CRITICAL]  Port status up/down
    10.80.32.12  brw38b1db3b30f4 0      [OK]
    10.80.32.1   router01        0      [OK]
    10.80.32.50                  0      [OK]
    10.80.32.58                  0      [OK]


States
------

* CRIT on criticals in LibreNMS
* WARN on warnings in LibreNMS
* OK on OK in LibreNMS


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description
    device_count,                               Number,             Number of devices found
    alert_count,                                Number,             Number of alerts


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
