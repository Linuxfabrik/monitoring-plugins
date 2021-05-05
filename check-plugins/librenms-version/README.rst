Check "librenms-version"
========================

Overview
--------

Displays LibreNMS instance information. This is not a "is there a new version out there" check as LibreNMS is capable of updating itself (if running the Git version).

We recommend to run this check once a day.


Installation and Usage
----------------------

.. code-block:: bash

    ./librenms-version --help
    ./librenms-version --url http://librenms --token 03xyza61e74a9876f3dc7ab11234229d

Output::

    LibreNMS 21.4.0 (HEAD), DB-Schema 2021_04_08_151101_add_foreign_keys_to_port_group_port_table (208), MariaDB 10.6.0-MariaDB, NET-SNMP 5.8, PHP 8.0.5, Python 3.6.8, RRD-Tool 1.7.0|'librenms-version'=21.4;;;0;


States
------

Always returns OK.


Perfdata
--------

* librenms-version: Float


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.

