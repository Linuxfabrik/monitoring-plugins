Check postfix-version
=====================

Overview
--------

This plugin lets you track if Postfix is End-of-Life (EOL). To compare against the current/installed version of Postfix, the check has to run on the Postfix server itself.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/postfix-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: postfix-version [-h] [-V] [--always-ok]

    Tracks if postfix is EOL.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.


Usage Examples
--------------

.. code-block:: bash

    ./postfix-version

Output:

.. code-block:: text

    Postfix v3.3.22 (EOL 2022-02-05) [WARNING]


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
    postfix-version,                            Number,             Installed Postfix version as float. "3.3.22" becomes "3.322".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
