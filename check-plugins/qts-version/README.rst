Check qts-version
=================

Overview
--------

This plugin lets you track if a QTS update is available. To check for updates, this plugin requests the in-built update check of the appliance.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/qts-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: qts-version [-h] [-V] [--always-ok] [--insecure] [--no-proxy] --password PASSWORD [--timeout TIMEOUT] --url URL
                       [--username USERNAME]

    This plugin lets you track if server updates are available.

    optional arguments:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      --insecure           This option explicitly allows to perform "insecure" SSL connections. Default: False
      --no-proxy           Do not use a proxy. Default: False
      --password PASSWORD  QTS Password.
      --timeout TIMEOUT    Network timeout in seconds. Default: 3 (seconds)
      --url URL            QTS-based Appliance URL, for example https://192.168.1.1:8080.
      --username USERNAME  QTS User. Default: admin


Usage Examples
--------------

.. code-block:: bash

    ./qts-version --url http://qts:8080 --username admin --password my-password
    
Output:

.. code-block:: text

    QTS 4.5.3.1670 Build 20210515 is up to date


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
