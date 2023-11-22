Check qts-version
=================

Overview
--------

This plugin lets you track if a QTS update is available. To check for updates, this plugin requests the in-built update check of the appliance.

Hints and Recommendations:

* Tested on `QuTScloud <https://www.qnap.com/en-us/download?model=qutscloud&category=firmware>`_ v4.5.6+
* Does not work on QTS 4.3 or less (see `#701 <https://github.com/Linuxfabrik/monitoring-plugins/issues/701>`_ for details).
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: qts-version [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                       --password PASSWORD [--timeout TIMEOUT] --url URL
                       [--username USERNAME]

    This plugin lets you track if server updates are available.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      --insecure           This option explicitly allows to perform "insecure" SSL
                           connections. Default: False
      --no-proxy           Do not use a proxy. Default: False
      --password PASSWORD  QTS Password.
      --timeout TIMEOUT    Network timeout in seconds. Default: 6 (seconds)
      --url URL            QTS-based Appliance URL, for example
                           https://192.168.1.1:8080.
      --username USERNAME  QTS User. Default: admin


Usage Examples
--------------

.. code-block:: bash

    ./qts-version --url http://qts:8080 --username admin --password linuxfabrik --insecure
    
Output:

.. code-block:: text

    QTS vc5.0.1.2374 Build 20230419 installed, QTS vc5.1.0.2498 Build 20230822 available


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
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
