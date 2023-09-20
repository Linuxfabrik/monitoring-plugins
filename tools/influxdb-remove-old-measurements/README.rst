Tool influxdb-remove-old-measurements
=====================================

Overview
--------

This tool removes old measurements in InfluxDB, therefore to reducing InfluxDB disk usage.
Measurements where the latest entry is older than the given threshold will be deleted (per host).

It is especially useful when monitoring systems do not automatically remove measurements when hosts or services are deleted.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Tool Download",                        "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/tools/influxdb-remove-old-measurements"
    "Can be called without parameters",     "No"
    "3rd Party Python modules",             "``influxdb``"


Help
----

.. code-block:: text

    usage: influxdb-remove-old-measurements [-h] [-V] --database DATABASE
                                            [--dry-run] [--hostname HOSTNAME]
                                            [--password PASSWORD] [--port PORT]
                                            [--threshold THRESHOLD]
                                            [--username USERNAME]

    This tool removes old measurements in InfluxDB, therefore to reducing InfluxDB
    disk usage. Measurements where the latest entry is older than the given
    threshold will be deleted (per host).

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --database DATABASE   InfluxDB Database.
      --dry-run             Perform a trial run with no changes made.
      --hostname HOSTNAME   InfluxDB Hostname. Default: localhost.
      --password PASSWORD   InfluxDB Password.
      --port PORT           InfluxDB Port.
      --threshold THRESHOLD
                            Threshold in days.
      --username USERNAME   InfluxDB Username.


Usage Examples
--------------

.. code-block:: bash

    ./influxdb-remove-old-measurements --database icinga2 --username influxdb-user --password linuxfabrik

Output:

.. code-block:: text

    Deleting "cmd-check-ping" for host "mon01" (last entry 3M 1W ago)
    Deleting "cmd-check-postfix-version" for host "web01" (last entry 3M 1W ago)
    Deleting "cmd-check-procs" for host "web01" (last entry 3M 1W ago)
    Deleting "cmd-check-swap-usage" for host "cloud01" (last entry 3M 1W ago)
    Deleting "cmd-check-swap-usage" for host "web01" (last entry 3M 1W ago)
    Deleting "cmd-check-systemd-units-failed" for host "cloud01" (last entry 3M 1W ago)
    Deleting "cmd-check-systemd-units-failed" for host "web01" (last entry 3M 1W ago)
    Deleting "cmd-check-uptime" for host "cloud01" (last entry 3M 1W ago)
    Deleting "cmd-check-users" for host "cloud01" (last entry 3M 1W ago)
    Deleting "cmd-check-users" for host "web01" (last entry 3M 1W ago)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
