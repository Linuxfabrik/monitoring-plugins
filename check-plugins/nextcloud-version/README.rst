Check nextcloud-version
=======================

Overview
--------

This plugin lets you track if Nextcloud is End-of-Life (EOL). To compare against the current/installed version of Nextcloud, the check has to run on the nextcloud server itself and needs access to the Nextcloud installation directory.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: nextcloud-version [-h] [-V] [--always-ok] [--path PATH]

    Tracks if Nextcloud is EOL.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --path PATH    Local path to your Nextcloud installation, typically within
                     your Webserver's Document Root. Default:
                     /var/www/html/nextcloud


Usage Examples
--------------

.. code-block:: bash

    ./nextcloud-version --path /var/www/html/nextcloud

Output:

.. code-block:: text

    Nextcloud v23.0.12 (EOL 2022-12-01) [WARNING]


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
    nextcloud-version,                          Number,             Installed Nextcloud version as float. "23.0.12" becomes "23.012".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
