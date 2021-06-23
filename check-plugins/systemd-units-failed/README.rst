Check systemd-units-failed
==========================

Overview
--------

This plugin warns on any ``systemd`` unit file which is in a failed state (whether active state or sub state).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/systemd-units-failed"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: systemd-units-failed [-h] [-V] [--always-ok] [--test TEST]

    Warns on any failed systemd units.

    optional arguments:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --test TEST    For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                     file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./systemd-units-failed
    
Output:

.. code-block:: text

    There is 1 failed unit.

    unit            load   active sub    description    
    ----            ----   ------ ---    -----------    
    ipmievd.service loaded failed failed Ipmievd Daemon


States
------

* WARN if at least one unit has a failed active state or failed sub state.


Perfdata / Metrics
------------------

* systemd-units-failed: Number of failed units


Troubleshooting
---------------

If you can't do anything and simply want to reset the status of a failed unit, do this:

.. code-block:: bash

    systemctl reset-failed ipmievd.service


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
