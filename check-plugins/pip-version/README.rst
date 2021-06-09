Check pip-version
=================

Overview
--------

This plugin lets you track if an update for a python package installed via ``pip`` is available. May take more than 10 seconds to execute.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/pip-version"
    "Check Interval Recommendation",        "Once a week"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: pip-version [-h] [-V] [--package PACKAGE] [--virtualenv VIRTUALENV]
                       [--test TEST]

    Checks if there is an update for a python package installed via `pip`.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --package PACKAGE     Name of the python package.
      --virtualenv VIRTUALENV
                            Path of the virtualenv that will be activated before
                            checking for updates. For example:
                            "/opt/sphinx/bin/activate".
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./pip-version --package sphinx --virtualenv /opt/sphinx/bin/activate
    
Output:

.. code-block:: text

    sphinx 3.2.1 is up to date.


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
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
