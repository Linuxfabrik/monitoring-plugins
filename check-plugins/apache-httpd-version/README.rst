Check apache-httpd-version
==========================

Overview
--------

This plugin lets you track if Apache httpd is End-of-Life (EOL). To compare against the current/installed version of Apache httpd, the check has to run on the Apache httpd server itself.

Hints:

* Runs on all systems where the Apache is named either "httpd" or "apache2".


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/apache-httpd-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: apache-httpd-version [-h] [-V] [--always-ok]

    Tracks if apache-httpd is EOL.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.


Usage Examples
--------------

.. code-block:: bash

    ./apache-httpd-version

Output:

.. code-block:: text

    Apache httpd v2.2.34 (EOL 2017-07-11 [WARNING])


States
------

* If wanted, always returns OK,
* else returns WARN if Software is EOL


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    apache-httpd-version,                       Number,             Installed Apache httpd version as float. "2.2.34" becomes "2.234".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
