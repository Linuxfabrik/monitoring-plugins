Check systemd-units-failed
==========================

Overview
--------

This plugin warns on any ``systemd`` unit file which is in a failed state (whether active state or sub state).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/systemd-units-failed"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: systemd-units-failed [-h] [-V] [--always-ok] [--ignore IGNORE]
                                [--test TEST]

    Warns on any failed systemd units.

    options:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit
      --always-ok      Always returns OK.
      --ignore IGNORE  Ignore a unit, for example "dhcpd.service" (repeating).
                       Supports glob according to
                       https://docs.python.org/3/library/fnmatch.html. Default: []
      --test TEST      For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                       file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./systemd-units-failed --ignore=openipmi.service --ignore=dhcpd.service
    ./systemd-units-failed --ignore=sshd@*.service

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
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
