Check dhcp-scope-usage
======================

Overview
--------

Checks the IPv4 scope usage for a Windows DHCP server service using the PowerShell command ``Get-DhcpServerv4ScopeStatistics -ComputerName "dhcpServer.contoso.com"``. Have a look at https://docs.microsoft.com/en-us/powershell/module/dhcpserver/get-dhcpserverv4scopestatistics for details.

If you provide ``--winrm-hostname``, the check plugin will execute all Powershell commands via WinRM, otherwise it will run locally. This allows the plugin to run on Linux servers as well. By using the `winrm Python module <https://github.com/diyan/pywinrm>`_, this plugin supports various transport methods in order to authenticate with the WinRM server. The options that are supported in the transport parameter are:

* ``basic``: Basic auth only works for local Windows accounts, not domain accounts. Credentials are base64 encoded when sending to the server.
* ``kerberos``: Will use Kerberos authentication for domain accounts which only works when the client is in the same domain as the server and the required dependencies are installed. Currently a Kerberos ticket needs to be initialized outside of the plugin using the ``kinit`` command.
* ``ntlm``: Will use NTLM authentication for both domain and local accounts (default).

Hints:

* Set the plugin timeout to 30 seconds.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/example"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "PowerShell"
    "3rd Party Python modules",             "optionally Python module ``winrm`` if you want to execute it via WinRM"


Help
----

.. code-block:: text

    usage: dhcp-scope-usage [-h] [-V] [--always-ok] [-c CRIT] [-H HOSTNAME]
                            [--test TEST] [-w WARN] [--winrm-domain WINRM_DOMAIN]
                            [--winrm-hostname WINRM_HOSTNAME]
                            [--winrm-password WINRM_PASSWORD]
                            [--winrm-transport {basic,ntlm,kerberos}]
                            [--winrm-username WINRM_USERNAME]

    Checks the IPv4 scope usage for a Windows DHCP server service.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c, --critical CRIT   Set the CRIT threshold as a percentage. Default: >= 90
      -H, --hostname HOSTNAME
                            Specifies the DNS name, or IPv4 or IPv6 address, of
                            the target computer that runs the DHCP server service.
                            Default: localhost
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w, --warning WARN    Set the WARN threshold as a percentage. Default: >= 80
      --winrm-domain WINRM_DOMAIN
                            WinRM Domain Name. Default: None
      --winrm-hostname WINRM_HOSTNAME
                            Target Windows computer on which the Windows commands
                            are to be executed. Default: None
      --winrm-password WINRM_PASSWORD
                            WinRM Account Password. Default: None
      --winrm-transport {basic,ntlm,kerberos}
                            WinRM transport type. Default: ntlm
      --winrm-username WINRM_USERNAME
                            WinRM Account Name. Default: None


Usage Examples
--------------

Local usage:

.. code-block:: bash

    ./dhcp-scope-usage

Remote usage, for example on a Linux server:

.. code-block:: bash

    ./dhcp-scope-usage3 \
        --hostname=dhcp01.example.com \
        --winrm-hostname=10.80.32.246 \
        --winrm-username=Administrator \
        --winrm-password=linuxfabrik \
        --winrm-domain=EXAMPLE.COM \
        --winrm-transport=ntlm

Output:

.. code-block:: text

    There are one or more criticals.

    * 192.168.120.0: 0% used
    * 192.168.121.0: 83% used [WARNING]
    * 192.168.122.0: 91% used [CRITICAL]


States
------

* WARN if PowerShell cmdlet's return code is not equal to 0.
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
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
