Check mydumper-version
======================

Overview
--------

This plugin lets you track whether a mydumper update is available. To check for updates, this plugin uses the Git Repo at https://github.com/maxbube/mydumper/releases. In order to compare with the current/installed version of mydumper/myloader, the check must run ``mydumper``.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mydumper-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: mydumper-version [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]

    This plugin lets you track if mydumper updates are available.

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

    ./mydumper-version --cache-expire 8 --always-ok

Output:

.. code-block:: text

    mydumper/myloader v0.10.5 is up to date


States
------

* If wanted, always returns OK,
* else returns WARN if update is available.


Perfdata / Metrics
------------------

* mydumper-version: Float


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
