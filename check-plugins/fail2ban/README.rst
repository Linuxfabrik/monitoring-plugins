Check fail2ban
==============

Overview
--------

In fail2ban, checks the amount of banned IP addresses (for all jails).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fail2ban"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: fail2ban [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

    In fail2ban, checks the amount of banned IP addresses (for a list of jails).

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold for banned IPs. Default:
                            10000
      -w WARN, --warning WARN
                            Set the warning threshold for banned IPs. Default:
                            1000


Usage Examples
--------------

.. code-block:: bash

    ./fail2ban --warning 1000 --critical 10000 
    
Output:

.. code-block:: text

    787 IPs banned in jail "linuxfabrik-portscan" (acting on /var/log/messages), 0 IPs banned in jail "sshd"


States
------

* WARN or CRIT if number of blocked IP addresses is above a given threshold.


Perfdata / Metrics
------------------

Per jail:

* Number of blocked IP addresses.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
