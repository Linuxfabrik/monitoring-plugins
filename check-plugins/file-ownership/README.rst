Check file-ownership
====================

Overview
--------

Checks the ownership (owner and group, both have to be names) of a list of files, and also (and always) the files defined in the CIS Security Benchmarks. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/file-ownership"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: file-ownership2 [-h] [-V] [--filename FILES]

    Checks the ownership (owner and group, both have to be names) of a list of
    files.

    optional arguments:
      -h, --help        show this help message and exit
      -V, --version     show program's version number and exit
      --filename FILES  File to be checked, in the format `owner:group,path`
                        (repeatable).


Usage Examples
--------------

.. code-block:: bash

    ./file-ownership --filename root:root,/tmp
    
Output:

.. code-block:: text

    Everything is ok.

    Path                      Owner   Group   State 
    ----                      -----   -----   ----- 
    /etc/anacrontab           root    root    [OK]  
    /etc/cron.d               root    root    [OK]  
    /etc/cron.daily           root    root    [OK]  
    /etc/cron.hourly          root    root    [OK]  
    /etc/cron.monthly         root    root    [OK]  
    /etc/cron.weekly          root    root    [OK]  
    /etc/crontab              root    root    [OK]  
    /etc/group                root    root    [OK]  
    /etc/group-               root    root    [OK]  
    /etc/gshadow              root    root    [OK]  
    /etc/gshadow-             root    root    [OK]  
    /etc/issue                root    root    [OK]  
    /etc/issue.net            root    root    [OK]  
    /etc/motd                 root    root    [OK]  
    /etc/passwd               root    root    [OK]  
    /etc/passwd-              root    root    [OK]  
    /etc/shadow               root    root    [OK]  
    /etc/shadow-              root    root    [OK]  
    /etc/ssh/sshd_config      root    root    [OK]  
    /tmp                      root    root    [OK]  
    /var/lib/unbound/root.key unbound unbound [OK]  
    /tmp                      root    root    [OK]


States
------

* WARN if ownership does not match expected values.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
