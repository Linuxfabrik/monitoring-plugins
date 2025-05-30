Check safenet-hsm-state
=======================

Overview
--------

The SafeNet SafeNet Network HSM is an Ethernet-attached HSM (Hardware Security Module) Server designed to protect critical cryptographic keys and to accelerate sensitive cryptographic operations across a wide range of security applications. This monitoring plugin checks the current state of a Gemalto SafeNet ProtectServer Network HSM via SSH and a PSESH command, and displays the current state of the HSM adapter.

Hints:

* Although it is not possible to log in as root when accessing the SafeNet ProtectServer Network HSM over an SSH connection, **only run this plugin on trusted hosts** as the HSM only offers password-based SSH logins - so ``ps`` will expose the SSH password.
* SafeNet ProtectServer Network HSM Installation and Configuration Guide: https://thalesdocs.com/gphsm/ptk/5.2/docs/Network_HSM_Installation_Guide.pdf


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/safenet-hsm-state"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for Windows",                 "No"
    "Requirements",                         "command-line tool ``sshpass``"


Help
----

.. code-block:: text

    usage: safenet-hsm-state [-h] [-V] [--always-ok] [-c CRIT] -H HOSTNAME
                             -p PASSWORD [--severity {warn,crit}] [--test TEST]
                             [--timeout TIMEOUT] [-u {admin,pseoperator}]
                             [-w WARN]

    This monitoring plugin checks the current state of a Gemalto SafeNet
    ProtectServer Network HSM via SSH and a PSESH command, and displays the
    current state of the HSM adapter.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c, --critical CRIT   Set the CRIT threshold as a percentage. Default: >= 90
      -H, --hostname HOSTNAME
                            SafeNet HSM hostname
      -p, --password PASSWORD
                            SafeNet HSM password
      --severity {warn,crit}
                            Severity for alerting. Default: crit
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -u, --username {admin,pseoperator}
                            SafeNet HSM Username, for example "admin" or
                            "pseoperator". Default: pseoperator
      -w, --warning WARN    Set the WARN threshold as a percentage. Default: >= 80


Usage Examples
--------------

.. code-block:: bash

    ./safenet-hsm-state --hostname hsm.example.com --password linuxfabrik

Output:

.. code-block:: text

    HSM device 0: HSM in NORMAL MODE. RESPONDING to requests. Usage Level=95% [CRITICAL]


States
------

* WARN or CRIT if usage level is above certain thresholds (default 80/90%).
* Depending on the given ``--severity``, returns WARN or CRIT (default) if HSM is not in normal mode.
* Depending on the given ``--severity``, returns WARN or CRIT (default) if command result is not equal to 0.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    usage_percent,                              Percentage,         HSM Usage Level


Troubleshooting
---------------

``sshpass: Host public key is unknown. sshpass exits without confirming the new key.``
    On the host running this check, manually connect to the HSM via SSH as the user running this check command. This will add the HSM to the list of known hosts.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_; originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
