Check wordpress-version
=======================

Overview
--------

This plugin lets you track if WordPress is End-of-Life (EOL). To compare against the current/installed version of WordPress, the check has to run on the WordPress server itself and needs access to the WordPress installation directory.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wordpress-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: wordpress-version [-h] [-V] [--always-ok] [--path PATH]

    Tracks if WordPress is EOL.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --path PATH    Local path to your WordPress installation, typically within
                     your Webserver's Document Root. Default:
                     /var/www/html/wordpress


Usage Examples
--------------

.. code-block:: bash

    ./wordpress-version --path /var/www/html/wordpress

Output:

.. code-block:: text

    WordPress v4.0.38 (EOL 2022-12-01) [WARNING]


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
    wordpress-version,                          Number,             Installed WordPress version as float. "4.0.38" becomes "4.038".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
