Check needs-restarting
======================

Overview
--------

Checks for processes that started running before they or some component that they use were updated. Returns WARN if a full reboot is required or if services might need a restart, and in any other case OK. May take more than 10 seconds to execute.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/needs-restarting"
    "Check Interval Recommendation",        "Once a day (or after a ``yum update`` only)"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: needs-restarting [-h] [-V]

    Checks for processes that started running before they or some component that
    they use were updated. Returns WARN if a full reboot is required or if
    services might need a restart, and in any other case OK. Should be called once
    a day or after applying updates only.

    optional arguments:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./needs-restarting
    
Output:

.. code-block:: text

    No system or service restart needed, but Invalid configuration value: failovermethod=priority in /etc/yum.repos.d/teamviewer.repo; Configuration: OptionBinding with id "failovermethod" does not exist


States
------

* WARN on needed service or system restarts.
* Does not WARN or CRIT on other problems like ``Modular dependency problem`` etc.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
