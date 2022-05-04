Check needs-restarting
======================

Overview
--------

Checks for processes that started running before they or some component that they use were updated. Returns WARN if a full reboot is required or if services might need a restart, and in any other case OK. May take more than 10 seconds on Red Hat to execute.

Hints:

* Linux only
* ``needs-restarting3`` runs on Red Hat- and Debian-based OS's
* ``needs-restarting2`` runs on Red Hat-based OS's only


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/needs-restarting"
    "Check Interval Recommendation",        "Once a day (or after a system update only)"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Red Hat: ``needs-restarting``, Debian: None, optional ``needrestart``"


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
    
Output on Red Hat:

.. code-block:: text

    Found 17 running processes that have been updated and may need a restart:
    1595 : /usr/lib/systemd/systemd-udevd
    1483 : sshd: root@pts/1
    1223 : qmgr -l -t unix -u
    1222 : pickup -l -t unix -u
    ...

Output on Debian:

.. code-block:: text

    A system reboot may be required. Running Kernel 4.19.0-20-amd64 != Installed Kernel 5.10.0-13-amd64 (version upgrade pending). Found 3 running processes that have been updated and may need a restart:
    * dbus.service
    * getty@tty1.service
    * systemd-logind.service


States
------

* WARN on needed service or system restarts.
* Does not alert on other problems like ``Modular dependency problem`` (yum/dnf) etc.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
