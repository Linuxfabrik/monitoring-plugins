Check hostname-fqdn
===================

Overview
--------

Checks if the local or a given hostname is a valid fully qualified domain name in full compliance with RFC 1035. The parameter ``--hostname`` checks the given string, not a remote host.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/hostname-fqdn"
    "Check Interval Recommendation",        "Once a week or even once in the lifetime of a machine"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: hostname-fqdn [-h] [-V] [-H HOSTNAME]

    Checks if the local or a given hostname is a valid fully qualified domain name
    in full compliance with RFC 1035.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -H HOSTNAME, --hostname HOSTNAME
                            Hostname to check. Defaults to the local hostname.

Usage Examples
--------------

.. code-block:: bash

    ./hostname-fqdn
    
Output:

.. code-block:: text

    "linuxfabrik" is an invalid fully qualified domain name (FQDN)


States
------

* WARN if hostname is not a valid fully qualified domain name in full compliance with RFC 1035.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
