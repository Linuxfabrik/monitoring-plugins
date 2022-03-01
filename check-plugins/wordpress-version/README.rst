Check wordpress-version
=======================

Overview
--------

This plugin lets you track if a WordPress update is available. To check for updates, this plugin uses the Git Repo at https://github.com/WordPress/WordPress/releases. To compare against the current/installed version of WordPress, the check has to run on the WordPress server itself and needs access to the WordPress installation directory.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wordpress-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: wordpress-version2 [-h] [-V] [--always-ok]
                              [--cache-expire CACHE_EXPIRE] [--path PATH]

    This plugin lets you track if server updates are available.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the update check cache
                            expires, in hours. Default: 24
      --path PATH           Local path to your WordPress installation. Default:
                            /var/www/html/wordpress


Usage Examples
--------------

.. code-block:: bash

    ./wordpress-version --path /var/www/html/wordpress
    
Output:

.. code-block:: text

    WordPress v5.7.2 is up to date


States
------

* If wanted, always returns OK,
* else returns WARN if update is available.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
