Check qts-disk-smart
====================

Overview
--------

Checks the disk SMART values returned by a QNAP Appliance running QTS. This check does not run SMART itself. In order to get the latest values, schedule the in-built SMART check in the QTS webinterface.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/qts-disk-smart"
    "Check Interval Recommendation",        "Every 8 hours"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: qts-disk-smart [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                          --password PASSWORD [--timeout TIMEOUT] --url URL
                          [--username USERNAME]

    Checks the disk SMART values returned by QTS.

    optional arguments:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      --insecure           This option explicitly allows to perform "insecure" SSL
                           connections. Default: False
      --no-proxy           Do not use a proxy. Default: False
      --password PASSWORD  QTS Password.
      --timeout TIMEOUT    Network timeout in seconds. Default: 3 (seconds)
      --url URL            QTS-based Appliance URL, for example
                           https://192.168.1.1:8080.
      --username USERNAME  QTS User. Default: admin


Usage Examples
--------------

.. code-block:: bash

    ./qts-disk-smart --url http://qts:8080 --username admin --password my-password
    
Output:

.. code-block:: text

    Checked 12 disks. All are healthy.

    * Disk 1 (ST16000NE000-2RW103, SerNo 382jdh237, Temp 46°C)
    * Disk 2 (ST16000NE000-2RW103, SerNo 382jdh237, Temp 48°C)
    * Disk 3 (ST16000NE000-2RW103, SerNo 382jdh237, Temp 47°C)
    * Disk 4 (ST16000NE000-2RW103, SerNo 382jdh237, Temp 44°C)
    * Disk 5 (ST12000VN0007-2GS116, SerNo 382jdh237, Temp 43°C)
    * Disk 6 (ST12000VN0007-2GS116, SerNo 382jdh237, Temp 43°C)
    * Disk 7 (ST12000VN0007-2GS116, SerNo 382jdh237, Temp 42°C)
    * Disk 8 (ST12000VN0007-2GS116, SerNo 382jdh237, Temp 40°C)
    * PCIe 2 M.2 SSD 1 (FireCuda 520 SSD ZP2000GM30002, SerNo 382jdh237, Temp 48°C)
    * PCIe 2 M.2 SSD 2 (FireCuda 520 SSD ZP2000GM30002, SerNo 382jdh237, Temp 49°C)
    * PCIe 4 M.2 SSD 1 (FireCuda 520 SSD ZP2000GM30002, SerNo 382jdh237, Temp 47°C)
    * PCIe 4 M.2 SSD 2 (FireCuda 520 SSD ZP2000GM30002, SerNo 382jdh237, Temp 48°C)


States
------

* OK if all disks are ok.
* Otherwise WARN.


Perfdata / Metrics
------------------

* <name>_<model_<serno>_temperature: Temperature in °C


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
