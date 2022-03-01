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
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-version"
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


Troubleshooting
---------------

PHP.net does not know anything about PHP v8.0.
    The message comes even though the latest php version is installed? php.net should know about that version, but it has simply not been updated in this case. Wait and see if ``https://www.php.net/releases/index.php?json&version={}`` is updated.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
