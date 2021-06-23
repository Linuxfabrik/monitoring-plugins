Check file-ownership
====================

Overview
--------

Checks the ownership (owner and group, both have to be names) of a list of files, and also (and always) most of the files defined in the CIS Security Benchmarks. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.

Default files checked, sorted by path:

* root:root,/boot/grub/grub.conf
* root:root,/boot/grub2/grub.cfg
* root:root,/boot/grub2/grubenv
* root:root,/boot/grub2/user.cfg
* root:root,/etc/anacrontab
* root:root,/etc/at.allow
* root:root,/etc/cron.allow
* root:root,/etc/cron.d
* root:root,/etc/cron.daily
* root:root,/etc/cron.hourly
* root:root,/etc/cron.monthly
* root:root,/etc/cron.weekly
* root:root,/etc/crontab
* graylog:graylog,/etc/graylog/certs
* root:root,/etc/group
* root:root,/etc/group-
* root:root,/etc/gshadow-
* root:root,/etc/hosts.allow
* root:root,/etc/hosts.deny
* root:root,/etc/issue
* root:root,/etc/issue.net
* lool:lool,/etc/loolwsd/loolwsd.xml
* root:root,/etc/motd
* root:named,/etc/named.conf
* root:root,/etc/passwd
* root:root,/etc/passwd-
* root:root,/etc/shadow-
* root:root,/etc/ssh/sshd_config
* vdsm:kvm,/home/ovirt
* root:root,/tmp
* hnet:hnet,/var/hnet
* unbound:unbound,/var/lib/unbound/root.key
* ldap:ldap,/var/run/openldap


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

    usage: file-ownership [-h] [-V] [--filename FILES]

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

    ./file-ownership --filename root:root,/tmp --filename root:root,/etc/motd
    
Output:

.. code-block:: text

    One or more problems with owners or groups.

    Path                      Expected        Found                      
    ----                      --------        -----                      
    /etc/anacrontab           root:root       root:root                  
    /etc/cron.d               root:root       root:root                  
    /etc/cron.daily           root:root       root:root                  
    /etc/cron.hourly          root:root       root:root                  
    /etc/cron.monthly         root:root       root:root                  
    /etc/cron.weekly          root:root       root:root                  
    /etc/crontab              root:root       root:root                  
    /etc/group                root:root       root:root                  
    /etc/group-               root:root       root:root                  
    /etc/gshadow-             root:root       root:root                  
    /etc/issue                root:root       root:root                  
    /etc/issue.net            root:root       root:root                  
    /etc/motd                 root:root       markus.frei:root [WARNING] 
    /etc/passwd               root:root       root:root                  
    /etc/passwd-              root:root       root:root                  
    /etc/shadow-              root:root       root:root                  
    /etc/ssh/sshd_config      root:root       root:root                  
    /tmp                      root:root       root:root                  
    /var/lib/unbound/root.key unbound:unbound unbound:unbound


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
