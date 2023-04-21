Check safenet-hsm
=============

Overview
--------

This checks the health of a Gemalto SafeNet HSM via SSH and PSESH commands.

Currently only the `hsm state` command is implemented. The other commands only report the output and UNKNOWN if not `Command Result : 0 (Success)`.

The other commands are:
* cpu
* date
* disk
* interface
* mac
* mem
* netstat
* ps
* time
* zone


Hints:

* https://thalesdocs.com/gphsm/ptk/5.2/docs/Network_HSM_Installation_Guide.pdf
* Only run on *trusted* host as this isn't secure - `ps` will expose the SSH password!


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/safenet-hsm"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3"
    "Requirements",                         "command-line tool ``sshpass``"


Help
----

.. code-block:: text

    usage: safenet-hsm [-h] [-V] [--always-ok] [-C COMMAND] [-c CRIT] -H HOSTNAME -p PASSWORD [--test TEST] [-u USER]
                    [-w WARN]

    This checks the health of a Gemalto SafeNet SHM via SSH and PSESH commands.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --command COMMAND
                            Command to use for the check. Default: hsm state
      -c CRIT, --critical CRIT
                            Set the CRIT threshold as a percentage. Default: >= 90
      -H HOSTNAME, --hostname HOSTNAME
                            SafeNet HSM Hostname
      -p PASSWORD, --password PASSWORD
                            Password
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-stderr-file,expected-retc".
      -u USER, --username USER
                            Username [admin|pseoperator]. Defautl: pseoperator
      -w WARN, --warning WARN
                            Set the WARN threshold as a percentage. Default: >= 80


Usage Examples
--------------

.. code-block:: bash

    ./safenet-hsm -H hsm.example.com -p 'Sup3r Secret P4$$wd'

Output:

.. code-block:: text

    [OK] HSM in NORMAL MODE. RESPONDING to requests. Usage Level=3%|'usage_percent'=3%;80;90;0;100

States
------

* Always returns OK.
* WARN or CRIT if any condition.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    usage_percent,                              Percentage,         Percentag of possible usage.

Troubleshooting
---------------

Output is: `sshpass: Host public key is unknown. sshpass exits without confirming the new key.`
    On the `check_source`, as the user icinga runs as, manually connect via SSH to the HSM. This will add the HSM to the list of known hosts.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_; originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
