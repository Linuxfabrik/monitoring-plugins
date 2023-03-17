Check php-version
=================

Overview
--------

With this plugin you can check if the installed PHP version is EOL. Does not care about patch levels.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: php-version3 [-h] [-V] [--always-ok]

    With this plugin you can check if the installed PHP version is EOL. Does
    not care about patch levels.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.


Usage Examples
--------------

.. code-block:: bash

    ./php-version

Output:

.. code-block:: text

    PHP v7.4.33 (EOL 2022-11-28) [WARNING]


States
------

* If wanted, always returns OK,
* else returns WARN if installed PHP version is End-of-Life (EOL)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    php-version,                                Number,             Installed PHP version as a float. "7.4.16" gets "7.416".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
