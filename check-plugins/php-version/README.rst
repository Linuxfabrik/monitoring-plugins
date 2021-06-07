Check php-version
=================

Overview
--------

This plugin lets you track if a PHP update is available. To check for updates, this plugin uses https://www.php.net/releases/index.php. To compare against the current/installed version of PHP, the check calls ``php --version``.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/example"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: php-version [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]

    This plugin lets you track if php updates are available.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the update check cache
                            expires, in hours. Default: 24


Usage Examples
--------------

.. code-block:: bash

    ./php-version

Output:

.. code-block:: text

    PHP v7.4.20 is available (installed: v7.4.19)


States
------

* If wanted, always returns OK,
* else returns WARN if update is available.


Perfdata / Metrics
------------------

* php-version: as a float. "7.4.16" becomes "7.416".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
