Check pip-updates
=================

Overview
--------

This plugin lets you track if updates for python packages installed via ``pip`` are available. May take more than 10 seconds to execute.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/pip-updates"
    "Check Interval Recommendation",        "Once a week"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: pip-updates [-h] [-V] [--always-ok] [-c CRIT] [--test TEST] [-w WARN]
                       [--virtualenv VIRTUALENV]

    Checks if there are updates for python packages installed via `pip`.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --updates         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold for the number of pending
                            updates. Default: 100
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w WARN, --warning WARN
                            Set the warning threshold for the number of pending
                            updates. Default: 10
      --virtualenv VIRTUALENV
                            Path of the virtualenv that will be activated before
                            checking for updates. For example: "/opt/sphinx-
                            venv/bin/activate".


Usage Examples
--------------

.. code-block:: bash

    ./pip-updates --virtualenv /opt/sphinx-venv/bin/activate
    
Output:

.. code-block:: text

    131 outdated packages [CRITICAL]

    ablog                         0.10.12    0.10.19      wheel
    ansible                       2.9.21     4.0.0        sdist
    argcomplete                   1.12.0     1.12.3       wheel
    astroid                       2.4.2      2.5.8        wheel
    ...


States
------

* If wanted, always returns OK,
* else returns WARN or CRIT if updates are available.


Perfdata / Metrics
------------------

* pip_outdated_packages: Number of pending updates.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
