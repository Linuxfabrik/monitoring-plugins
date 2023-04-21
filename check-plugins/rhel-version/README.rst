Check rhel-version
==================

Overview
--------

This plugin lets you track if RHEL (and compatible) is End-of-Life (EOL). To compare against the current/installed version of RHEL, the check has to run on the RHEL server itself.

Hints:

* Also works for Alma, CentOS, CentOS Stream, Oracle, Rocky, etc., but (currently) reports the EOL date for RHEL.
* On Fedora Workstation or Fedora Server, use https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fedora-version.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rhel-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: rhel-version [-h] [-V] [--always-ok]

    Tracks if RHEL is EOL.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.


Usage Examples
--------------

.. code-block:: bash

    ./rhel-version

Output:

.. code-block:: text

    Rocky Linux 8.7 (Green Obsidian) (EOL 2029-05-31)


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
    rhel-version,                               Number,             Installed RHEL version as float. "8.7" becomes "87".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
