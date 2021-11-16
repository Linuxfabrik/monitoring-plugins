Check dhcp-scope-usage
======================

Overview
--------

Checks the IPv4 scope usage for a Windows DHCP server service using the PowerShell command ``Get-DhcpServerv4ScopeStatistics -ComputerName "dhcpServer.contoso.com"``. Have a look at https://docs.microsoft.com/en-us/powershell/module/dhcpserver/get-dhcpserverv4scopestatistics for details.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/example"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "PowerShell"


Help
----

.. code-block:: text

    usage: dhcp-scope-usage [-h] [-V] [--always-ok] [-c CRIT] [-H HOSTNAME]
                            [--test TEST] [-w WARN]

    Windows: Checks the IPv4 scope usage for a DHCP server service.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold as a percentage. Default: >= 90
      -H HOSTNAME, --hostname HOSTNAME
                            Specifies the DNS name, or IPv4 or IPv6 address, of
                            the target computer that runs the DHCP server service.
                            Default: localhost
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w WARN, --warning WARN
                            Set the WARN threshold as a percentage. Default: >= 80


Usage Examples
--------------

.. code-block:: bash

    ./dhcp-scope-usage


Output:

.. code-block:: text

    There are one or more criticals.

    * 192.168.120.0: 0% used
    * 192.168.121.0: 83% used [WARNING]
    * 192.168.122.0: 91% used [CRITICAL]


States
------

* WARN is PowerShell cmdlet's return code is not equal to 0.
* WARN or CRIT if any DHCP scopy usage in percent is above a given threshold.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    scope_<ScopeID>,                            Percentage,         The IP address range usage for the DHCP scope.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
