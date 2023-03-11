Check postfix-version
=====================

Overview
--------

With this plugin you can check if the installed Postfix version is EOL. Does not care about patch levels.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/postfix-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: postfix-version3 [-h] [-V] [--always-ok]

    Tracks if Postfix is EOL.

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

    Postfix v3.5.8 (no EOL)


States
------

* WARN on EOL


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    postfix-version,                            Number,             Installed Postfix version as a float. "3.5.8" gets "3.58".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
