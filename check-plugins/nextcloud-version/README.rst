Check nextcloud-version
=======================

Overview
--------

With this plugin you can check if the installed Nextcloud version is EOL. Does not care about patch levels.

The check has to run on the Nextcloud server itself. It uses ``sudo -u $OWNER /path/to/nextcloud/occ config:list`` to get the installed version and therefore requires access to the Nextcloud installation directory.


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

    With this plugin you can check if the installed Nextcloud version is EOL. Does
    not care about patch levels.

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

    Nextcloud v16.0.2 (EOL 2020-06-01) [WARNING]


States
------

* If wanted, always returns OK,
* else returns WARN if installed Nextcloud version is End-of-Life (EOL)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    nextcloud-version,                          Number,             Installed Nextcloud version as a float. "25.0.4.2" gets "25.042".


Troubleshooting
---------------

sudo: unknown user: #-1, sudo: error initializing audit plugin sudoers_audit
    Nextcloud installation was not found.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
