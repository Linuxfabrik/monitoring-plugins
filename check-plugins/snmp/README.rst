Check snmp
==========

Overview
--------

This check utilizes ``snmpget`` to query for information on a network entity, so it provides all that ``snmpget`` is capable of, for example SNMP v2c and SNMP v3.

.. note::

    Only use SNMP if there is no other way. SNMP puts much strain on the target system and the monitoring software.

    * If you can use an agent of your monitoring software for monitoring, for example Icinga, and one of our plugins, do it.
    * If you can't install an agent, but there is a good (REST-)API available (and maybe one of our plugins), use that.
    * If you can't install an agent on a device and there is no (good) API, then use SNMP.
    * If possible, use a SNMP specialized solution like `LibreNMS <https://www.librenms.org/>`_ instead of this check.
    * Prefer SNMPv2. Although completely insecure, it is fast and keeps the load on your appliance low.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/snmp"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux"
    "Requirements",                         "``snmpget`` from ``net-snmp-utils``"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-monitoring-plugins-snmp.db``"


Help
----

.. code-block:: text

    usage: snmp [-h] [-V] [--community COMMUNITY] [--device DEVICE] [--hide-ok] -H
                HOSTNAME [--mib MIB] [--mib-dir MIB_DIR] [--snmp-version {1,2c,3}]
                [--test TEST] [-t TIMEOUT]
                [--v3-auth-prot {MD5,SHA,SHA-224,SHA-256,SHA-384,SHA-512}]
                [--v3-auth-prot-password V3_AUTH_PROT_PASSWORD]
                [--v3-boots-time V3_BOOTS_TIME] [--v3-context V3_CONTEXT]
                [--v3-context-engine-id V3_CONTEXT_ENGINE_ID]
                [--v3-level {noAuthNoPriv,authNoPriv,authPriv}]
                [--v3-priv-prot {DES,AES,AES-192,AES-256}]
                [--v3-priv-prot-password V3_PRIV_PROT_PASSWORD]
                [--v3-security-engine-id V3_SECURITY_ENGINE_ID]
                [--v3-username V3_USERNAME]

    This check is a SNMP application that uses the SNMP GET request to query for
    information on a network entity. The object identifiers (OIDs) of interest
    have to be defined in a CSV file, including optional WARN and CRIT parameters.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --community COMMUNITY
                            SNMP Version 1 or 2c specific. Set the community
                            string. Default: public.
      --device DEVICE       The name of a device file containing the SNMP-OIDs,
                            located under `./device-oids`, for example `switch-
                            fs-s3900.csv` or `printer-brother-mfcj5720dw.csv`.
                            `any-any-any.csv` is a good starting point showing
                            some features.Default: any-any-any.csv.
      --hide-ok             Don't print OIDs with OK state. Default: False.
      -H HOSTNAME, --hostname HOSTNAME
                            SNMP Appliance address.
      --mib MIB             Load given list of MIBs, for example `+FS-MIB` or `FS-
                            MIB:BROTHER-MIB`. Behaves like the `-m` option of
                            `snmpget`.
      --mib-dir MIB_DIR     Look in given list of directories for MIBs. Behaves
                            like the `-M` option of `snmpget`. Default:
                            $HOME/.snmp/mibs:/usr/share/snmp/mibs.
      --snmp-version {1,2c,3}
                            Specifies SNMP version to use. Default: 2c.
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -t TIMEOUT, --timeout TIMEOUT
                            Network timeout in seconds. Default: 7 (seconds).
      --v3-auth-prot {MD5,SHA,SHA-224,SHA-256,SHA-384,SHA-512}
                            SNMP Version 3 specific. Set authentication protocol.
      --v3-auth-prot-password V3_AUTH_PROT_PASSWORD
                            SNMP Version 3 specific. Set authentication protocol
                            pass phrase.
      --v3-boots-time V3_BOOTS_TIME
                            SNMP Version 3 specific. Set destination engine
                            boots/time.
      --v3-context V3_CONTEXT
                            SNMP Version 3 specific. Set context name (e.g.
                            bridge1).
      --v3-context-engine-id V3_CONTEXT_ENGINE_ID
                            SNMP Version 3 specific. Set context engine ID (e.g.
                            800000020109840301).
      --v3-level {noAuthNoPriv,authNoPriv,authPriv}
                            SNMP Version 3 specific. Set security level.
      --v3-priv-prot {DES,AES,AES-192,AES-256}
                            SNMP Version 3 specific. Set privacy protocol.
      --v3-priv-prot-password V3_PRIV_PROT_PASSWORD
                            SNMP Version 3 specific. Set privacy protocol pass
                            phrase.
      --v3-security-engine-id V3_SECURITY_ENGINE_ID
                            SNMP Version 3 specific. Set security engine ID (e.g.
                            800000020109840301).
      --v3-username V3_USERNAME
                            SNMP Version 3 specific. Set security name (e.g.
                            bert).


Usage Examples
--------------

A minimal command call:

.. code-block:: bash

    ./snmp --hostname 10.80.32.109

Calling this the check...

#. fetches a set of most common SNMP OIDs like *Contact* or *Uptime*, defined in ``device-oids/any-any-any.csv``,
#. calls ``snmpget -v 2c -c public -r 0 -t 7 -OSqtU -M $HOME/.snmp/mibs:/usr/share/snmp/mibs 10.80.32.109 OID1 OID2 ...``,
#. parses the output,
#. interprets the result and calculates the return state.

Other example using a more specific OID list and an additional MIB directory:

.. code-block:: bash

    /usr/lib64/nagios/plugins/snmp \
        --device switch-fs-s3900.csv \
        --mib-dir +/usr/lib64/nagios/plugins/device-mibs/switch-fs-s3900 \
        --hide-ok \
        --hostname 10.80.32.109


Installation
------------

Install ``snmpget``:

.. code-block:: bash

    # on RHEL:
    yum -y install net-snmp-utils

    # on Debian:
    apt -y install snmp snmp-mibs-downloader


Plugin Directory Strcuture
--------------------------

.. code-block:: text

    /usr/lib64/nagios/plugins/
    ├── device-mibs
    │   ├── printer-...
    │   ├── ...
    │   └── switch-...
    └── device-oids


Handling MIBs
-------------

If needed, get any MIB files ready. Copy them to ``$HOME/.snmp/mibs`` or ``/usr/share/snmp/mibs``. If you prefer other locations, provide the paths using the ``--mib-dir`` parameter (same syntax as the ``-M`` parameter of ``snmpget``). The checks comes with some predefined, device-dependend MIBs located at ``/usr/lib64/nagios/plugins/device-mibs/``.

Create an OID list in ``/usr/lib64/nagios/plugins/device-oids/...`` using CSV format. For details, have a look at "Defining a Device" within this document.


Defining a Device
-----------------

If you want to define a device-specific list of OIDs, including any calculations, warning and critical thresholds, create a CSV file located at ``device-oids``, using ``,`` as delimiter and ``"`` as quoting character. A minimal example for nearly any device:

========================= ============= ========================== ============ ======================= ======================= ================== ================== ================== ==========================
OID                       Name          Re-Calc                    Unit Label   WARN                    CRIT                    Show in 1st Line   Report Change as   Ignore in Perfdata Perfdata Alert Thresholds
========================= ============= ========================== ============ ======================= ======================= ================== ================== ================== ==========================
SNMPv2-MIB::sysName.0     Name                                                                                                 
SNMPv2-MIB::sysLocation.0 Location                                                                                                                 WARN
SNMPv2-MIB::sysUpTime.0   Uptime        int(value) / 100 * 24*3600 s            value > 6*30            value > 2*365           True                                                     "3*30,None"
========================= ============= ========================== ============ ======================= ======================= ================== ================== ================== ==========================

The columns in detail:

* | Column 1: OID (String)
  | The Object-Identifier from any of your MIB files.
* | Column 2: Name (String)
  | If provided, the check prints this instead of the OID.
* | Column 3: Re-Calc (Python code, or empty)
  | Feel free to use any Python Code based on the variables ``value`` and ``values``, which contain the result (always a string) of the SNMPGET operation on the given OID.
* | Column 4: Unit (String, or empty)
  | This is the "Unit of Measurement", case-insensitiv. One of:

     * s - seconds (also us, ms)
     * % - percentage
     * B - bytes (also KB, MB, TB, ...)
     * bps - bits per second (also Kbps, Mbps, ...)
     * c - a continous counter (such as bytes transmitted on an interface)  

  | If you provide two comma-separated units, for example "b,c", the first one will be used to display a human-readable format ("Bytes"), and the second one is used to suffix the perfdata ("continous counter").
  | For output, the following units will always be converted to a human-friendly format:

    * s - seconds
    * b - bytes
    * bps - bits per second

* | Column 5: WARN (Python condition, or empty)
  | The warning condition for the re-calculated or raw ``value``.
* | Column 6: CRIT (Python condition, or empty)
  | The critical condition for the re-calculated or raw ``value``.
* | Column 7: Show in first line (Bool, either "False", "True", or empty)
  | Should ``value`` be printed in the first line of the check output?
* | Column 8: Report Change as (String, either "WARN", "CRIT", or empty)
  | Should a change of ``value`` be reported as ``WARN`` or ``CRIT``? The check stores the initial values on the first run in ``$TEMP/linuxfabrik-monitoring-plugins-snmp.db``.
* | Column 9: Ignore in Perfdata (Bool, either "False", "True", or empty)
  | By default, all numeric values are automatically returned as perfdata objects. Set to ``True`` to exclude this item from the perfdata list.
* | Column 10: Perfdata Alert Thresholds (Python tuple)
  | Add warning and critical thresholds to performance data by defining a valid Python tuple - first element for warning, second one for critical. Use double quotes around the tuple because the comma is the separator between the fields. Normally, the values of WARN and CRIT should be repeated here so that the actual thresholds used are written to the performance data.

The output would be something like this

.. code-block:: text

    Uptime: 5M 1W

    Key         Value           State 
    ---         -----           ----- 
    Name        BRW38B1DB3B30F4 [OK]  
    Location    Office          [OK]  
    Contact     The Printer Guy [OK]  
    Description Brother NC-350w [OK]  
    Uptime      5M 1W           [WARNING]

If you get a ``Traceback (most recent call last)`` when running the check plugin with your CSV file, there is something wrong with your CSV file format. Try editing it in LibreOffice Calc, for example, to get the correct amount of commas, quotes, etc.

The check divides the OID list automatically into blocks of 25 OIDs per SNMPGET request.


Calculating and Comparing using ``value`` and ``values``
--------------------------------------------------------

``value`` contains the value of the *current* OID, simply and always as a Python string. ``values`` is a Python dictionary containing all *re-calculated* (or raw) values, up to this point. The dictionary keys are based on the "Name". If "Name" is not set, the dictionary keys are based on the "OID".

The ``value`` returned by ``snmpget`` for a given *OID* is always a string. If you want to use it for calculations or integer-based comparisons, re-calculate it by specifying ``int(value)`` in column (SNMP knows nothing about floats).

Both variables are allowed to be used in Python code in the columns "Re-Calc", "WARN" and "CRIT". This enables you to even warn in the current OID depending on previous values, for example.

In the last three lines of this example we simply calculate "NIC.1 Traffic" as a sum of "NIC.1 rx" and "NIC.1 tx", for which there is no SNMP OID:

========================= ============= ======================================== ============ ===================== ===
OID                       Name          Re-Calc                                  Unit Label   WARN                  ...
========================= ============= ======================================== ============ ===================== ===
SNMPv2-MIB::sysUpTime.0   Uptime        int(value) / 100                         s            value > 4*365*24*3600
IF-MIB::ifSpeed.1         NIC.1 Speed   int(value)                               bps
IF-MIB::ifOperStatus.1    NIC.1 Status
IF-MIB::ifOutOctets.1     NIC.1 tx      int(value)                               b,c
IF-MIB::ifInOctets.1      NIC.1 rx      int(value)                               b,c
<leave this empty>        NIC.1 Traffic values['NIC.1 tx'] + values['NIC.1 rx']  b,c
========================= ============= ======================================== ============ ===================== ===



Parameter Mapping
-----------------

=================  ========================================================
``snmpget``        This check
=================  ========================================================
``-v 1|2c|3``      ``--snmpversion {1,2c,3}``
``-c COMMUNITY``   ``--community COMMUNITY``
``-a PROTOCOL``    ``--v3authprot {MD5,SHA,SHA-224,SHA-256,SHA-384,SHA-512}``
``-A PASSPHRASE``  ``--v3authprotpassword V3AUTHPROTPASSWORD``
``-e ENGINE-ID``   ``--v3securityengineid V3SECURITYENGINEID``
``-E ENGINE-ID``   ``--v3contextengineid V3CONTEXTENGINEID``
``-l LEVEL``       ``--v3level {noAuthNoPriv,authNoPriv,authPriv}``
``-n CONTEXT``     ``--v3context V3CONTEXT``
``-u USER-NAME``   ``--v3username V3USERNAME``
``-x PROTOCOL``    ``--v3privprot {DES,AES,AES-192,AES-256}``
``-X PASSPHRASE``  ``--v3privprotpassword V3PRIVPROTPASSWORD``
``-Z BOOTS,TIME``  ``--v3bootstime V3BOOTSTIME``
``-r RETRIES``     hard-coded to ``0``
``-t TIMEOUT``     ``-t TIMEOUT``, ``--timeout TIMEOUT``
``-m MIB[:...]``   ``--mib MIB``
``-M DIR[:...]``   ``--mib-dir MIBDIR``
=================  ========================================================


How to fetch a list of OIDs
---------------------------

Example:

.. code-block:: bash

    snmpbulkwalk -v2c \
        -c public \
        -OSt \
        -M +/usr/lib64/nagios/plugins/device-mibs/switch-netgear-xs716t \
        10.80.32.141 NETGEAR-SWITCHING-MIB::agentInfoGroup


Q & A
-----

Q: **I get ``Too many object identifiers specified. Only 128 allowed in one request.``**

A: Probably your SNMP v3 parameters are incomplete or incorrect.

Q: **I get ``add_mibdir: strings scanned in from .snmp/mibs/.index are too large.  count = ...``**

A: There seems to be a malformed, a duplicated MIB file or one with spaces in its filename within one of your MIB directories.

Q: **I get ``Error in packet. Reason: (tooBig) Response message would have been too large.``**

A: A "tooBig" response simply means that the SNMP agent tried to generate a response with all requested OID's, but the response grew too big for its buffer, resulting in this error message. To avoid this, we divide your OID list and send a maximum of 25 oids per request each.

Q: **Within Icinga, if I acknowledge a value change in WARN or CRIT state, does the plugin returns OK?**

A: If you acknowledge a value change in Icinga, the desired WARN or CRIT state remains - due to the fact that SNMP is mostly run against hardware, and you have to check what triggered the change. If everything is fine, delete ``$TEMP/linuxfabrik-monitoring-plugins-snmp.db``. On the next run of the plugin, it will recreate the inventory.


States
------

Depending on the OID definitions the check returns

* OK
* WARN
* CRIT
* UNKNOWN


Perfdata / Metrics
------------------

By default, all numeric values are automatically returned as perfdata objects.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
