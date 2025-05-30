Check fail2ban
==============

Overview
--------

Checks the amount of banned IP addresses for all jails in Fail2ban.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fail2ban"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"


Help
----

.. code-block:: text

    usage: fail2ban [-h] [-V] [--always-ok] [-c CRIT] [--test TEST] [-w WARN]

    In fail2ban, checks the amount of banned IP addresses per jail.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      -c, --critical CRIT  Set the critical threshold for banned IPs per jail.
                           Default: 10000
      --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                           stderr-file,expected-retc".
      -w, --warning WARN   Set the warning threshold for banned IPs per jail.
                           Default: 2500


Usage Examples
--------------

.. code-block:: bash

    ./fail2ban --warning 2500 --critical 10000

Output:

.. code-block:: text

    7406 IPs banned
    * 5432 in jail "sshd" [WARNING]
    * 1974 in jail "portscan"


States
------

* WARN or CRIT if the number of blocked IP addresses in any jail exceeds a specified threshold.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    <jail>,                                     Number,             Number of blocked IP addresses (per jail).


Troubleshooting
---------------

Permission denied to socket: /var/run/fail2ban/fail2ban.sock (you must be root)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Fail2ban client (used by this check plugin internally) works only with user ``root`` by default. The reasons:

* Fail2ban does not have individual permission or a user privilege model.
* If you would allow the Fail2ban client accessing the Fail2ban sever for non-root, you could stop the server, change runtime config, ban, unban, etc.


Preparing Fail2ban by changing permissions
    Tested on Debian 11.

    The communication takes place via unix-socket ``/var/run/fail2ban/fail2ban.sock`` which has the following permissions:

    .. code-block:: text

        srwx------ 1 root root ... /var/run/fail2ban/fail2ban.sock

    So you have to grant access to ``fail2ban.sock`` for a user like ``nagios`` or ``icinga``, for example like so:

    .. code-block:: bash

        sudo groupadd fail2ban
        sudo usermod --append --groups fail2ban nagios
        sudo chown root:fail2ban /var/run/fail2ban/fail2ban.sock
        sudo chmod g+w /var/run/fail2ban/fail2ban.sock

    After that, this (and so the check plugin) should work:

    .. code-block:: bash

        sudo -u nagios /usr/bin/fail2ban-client status
        sudo -u nagios /usr/lib64/nagios/plugins/fail2ban

    To persist on a system where Fail2ban is managed by Systemd, add the following to the Fail2ban service override file:

    .. code-block:: bash

        sudo systemctl edit fail2ban

    .. code-block:: text

        [Service]
        ExecStartPost=/usr/bin/sh -c "while ! [ -S /var/run/fail2ban/fail2ban.sock ]; do sleep 1; done"
        ExecStartPost=/usr/bin/chgrp fail2ban /var/run/fail2ban/fail2ban.sock
        ExecStartPost=/usr/bin/chmod g+w /var/run/fail2ban/fail2ban.sock


Preparing Fail2ban by using sudo
    Tested on RHEL 7+.

    As an alternative you might add a sudoers rule, for example in ``/etc/sudoers.d/fail2ban``:

    .. code-block:: text

        Defaults:icinga !requiretty
        icinga    ALL = NOPASSWD: /usr/lib64/nagios/plugins/fail2ban

    Click this link to find `a list of sudoers files for all main Linux distributions <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers>`_ for Icinga.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
