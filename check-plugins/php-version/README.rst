Check php-version
=================

Overview
--------

With this plugin you can check whether a PHP minor *upgrade* is available or whether the installed PHP version is EOL. For example, if you installed PHP 7.3 while PHP 7.4 is available, you will get a warning. If you're running PHP 7.4 and PHP 8 is available (which is a major upgrade), you won't get a warning. 

To check for available upgrades, this plugin uses https://www.php.net/releases/index.php. To compare against the current/installed version of PHP, the check calls ``php --version``.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/php-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: php-version [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]

    With this plugin you can check whether a PHP minor *upgrade* is available or
    whether the installed PHP version is EOL. For example, if you installed PHP
    7.3 while PHP 7.4 is available, you will get a warning. If you're running PHP
    7.4 and PHP 8 is available (which is a major upgrade), you won't get a
    warning. To check for available upgrades, this plugin uses
    https://www.php.net/releases/index.php. To compare against the
    current/installed version of PHP, the check calls ``php --version``.

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

    PHP v7.4.20 installed, PHP v7.4.21 available at php.net


States
------

* If wanted, always returns OK,
* else returns WARN if a minor update is available
* or returns WARN if installed PHP version is End-of-Life (EOL)


Perfdata / Metrics
------------------

* php-version: Installed PHP version as a float. "7.4.16" becomes "7.416".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
