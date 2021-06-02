Check systemd-unit
==================

Overview
--------

Checks states of a service, job, mount etc., using ``systemctl show``.

Simple example: ``./systemd-unit --loadstate=loaded --activestate=active --substate=running --unitfilestate=enabled --unit=crond.service`` is checked against ``systemctl show -p LoadState,ActiveState,SubState,UnitFileState crond.service``.

How do you get an idea what to check for?

1. Show ALL possible unit files - services, mounts, timers etc.: ``systemctl list-unit-files --all``
2. Show units, and optionally compare them with another system: ``systemctl list-units`` (here you get the states)
3. If you know what to look for, get the state data for this check: ``systemctl show -p LoadState,ActiveState,SubState,UnitFileState firewalld``


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/systemd-unit"
    "Check Interval Recommendation",        "Once a minute"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, command-line tool ``systemctl``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"
    "Perfdata compatible with Prometheus",  "Yes"


Help
----

.. code-block:: text

    usage: example [-h] [-V]

    Example Check.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    Examples:

    * Does the service exist? (and nothing more!) `systemd-unit --unit=firewalld.service`
    * Is the service running? `systemd-unit --substate=running --unit=firewalld.service`
    * Is the service disabled? `systemd-unit --unitfilestate=disabled --unit=firewalld.service`
    * Is the service stopped and disabled? `systemd-unit --activestate=inactive --substate=dead --unitfilestate=disabled --unit=firewalld.service`
    * Is the service exited? `systemd-unit --substate=exited --unit=firewalld.service`
    * Is this service with instance name "server" running? `systemd-unit --substate=running --unit=openvpn-server@server.service`
    * Is this service absent/uninstalled? `systemd-unit --loadstate=not-found --unit=firewalld.service`
    * Is this path mounted? `systemd-unit --substate=mounted --unit=mnt-smb.mount`
    * Is this device plugged in? `systemd-unit --substate=plugged --unit=sys-devices-virtual-net-tun0.device`
    * The current state of a timer job? (has one activestate and two substates) `systemd-unit --activestate=active --substate=waiting --substate=running --unit=myjob.timer`
    * Check a service depending on a timer (has two activestates and two substates): `systemd-unit --activestate=active --activestate=inactive --substate=dead --substate=running --unit=myjob.service`
    
    Parameters:
        
    Attention:
    * If any of `--activestate`, `--substate` or `--unitfilestate` is ommited, the related unit state value will not be checked (so the check don't care, just prints).
    * Best practise is to specify `--activestate` and `--substate` at least.
    * The unit suffix `.service` is optional for service units only, but it is - as always - recommended to use it.

    `--unit`:
    * The unit name (service, timer, mount etc.).
    * Required.

    `--loadstate`:
    * Reflects whether the unit definition was properly loaded.
    * loadstate=loaded,not-found
    * Default: loaded

    `--activestate` (repeating):
    * The high-level unit activation state(s), i.e. generalization of SUB.
    * If ommited, the unit's active state will not be checked.
    * activestate=active,failed,inactive,activating,deactivating
    * Default: none

    `--substate` (repeating):
    * The low-level unit activation state(s); values depend on unit type.
    * If ommited, the unit's substate will not be checked.
    * substate=abandoned,activating,activating-done,active,auto-restart,cleaning,condition,deactivating,deactivating-sigkill,deactivating-sigterm,dead,elapsed,exited,failed,final-sigkill,final-sigterm,final-watchdog,listening,mounted,mounting,mounting-done,plugged,reload,remounting,remounting-sigkill,remounting-sigterm,running,start,start-chown,start-post,start-pre,stop,stop-post,stop-pre,stop-pre-sigkill,stop-pre-sigterm,stop-sigkill,stop-sigterm,stop-watchdog,tentative,unmounting,unmounting-sigkill,unmounting-sigterm,waiting
    * Default: none

    `--unitfilestate`:
    * If ommited, the unit's unit-file state will not be checked.
    * unitfilestate=bad,disabled,enabled,enabled-runtime,generated,indirect,static,transient
    * Default: none

    `--severity`:
    * If something was found, the check returns WARN unless set here.
    * severity=warn,crit
    * Default: warn
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN if result does not match parameter values.
* CRIT only if configured as such.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
