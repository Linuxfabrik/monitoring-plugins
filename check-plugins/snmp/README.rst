Check "snmp"
============

Overview
--------

This check utilizes ``snmpget`` to query for information on a network entity, so it provides all that ``snmpget`` is capable of, for example SNMP v2c and SNMP v3.

.. note::

    Only use SNMP if there is no other way. SNMP puts much strain on the target system and the monitoring software.

    * If you can use an agent of your monitoring software for monitoring, for example the Icinga agent, do it.
    * If you can't install an agent, but there is a good (REST-)API available, use that.
    * If you can't install an agent on a device and there is no (good) API, then use SNMP.
    * Prefer SNMPv2. Although completely insecure, it is fast and keeps the load on your appliance low.


Installation
------------

Install ``snmpget``:

.. code-block:: bash

    # on CentOS:
    yum -y install net-snmp-utils

If needed, get any MIB files ready. Copy them to ``$HOME/.snmp/mibs`` or ``/usr/share/snmp/mibs``. If you prefer other locations, provide the paths using the ``--mibdir`` parameter (same syntax as the ``-M`` parameter of ``snmpget``). The checks comes with some predefined, device-dependend MIBs located at ``/usr/lib64/nagios/plugins/device-mibs/``.

Create an OID list in ``/usr/lib64/nagios/plugins/device-oids/...`` using CSV format. For details, have a look at "Defining a Device" within this document.


Usage
-----

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
        --mibdir +/usr/lib64/nagios/plugins/device-mibs/switch-fs-s3900 \
        --hide-ok \
        --hostname 10.80.32.109


Defining a Device
-----------------

You want to define a device-specific list of OIDs, including any calculations, warning and critical thresholds, create a CSV file located at ``device-oids``, using ``,`` as delimiter and ``"`` as quoting character. A minimal example for nearly any device:

========================= ============= ================== ============ ======================= ======================= ================== ==================
OID                       Name          Re-Calc            Unit Label   WARN                    CRIT                    Show in 1st Line   Report Change as
========================= ============= ================== ============ ======================= ======================= ================== ==================
SNMPv2-MIB::sysName.0     Name                                                                                                 
SNMPv2-MIB::sysLocation.0 Location                                                                                                         WARN
SNMPv2-MIB::sysUpTime.0   Uptime        int(value) / 100   s            value > 4*365*24*3600   value > 5*365*24*3600   True             
========================= ============= ================== ============ ======================= ======================= ================== ==================

The check divides the OID list automatically into blocks of 25 OIDs per SNMPGET request. 


The columns in detail:

* | OID
  | The Object-Identifier from any of your MIB files.
* | Name
  | If provided, the check prints this instead of the OID.
* | Re-Calc
  | Feel free to use any Python Code based on the variables ``value`` and ``values``, which contain the result of the SNMPGET operation on the given OID.
* | Unit
  | This is the "Unit of Measurement", case-insensitiv.

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

* | WARN
  | The warning threshold for the re-calculated or raw ``value``.
* | CRIT
  | The critical threshold for the re-calculated or raw ``value``.
* | Show in first line
  | Should ``value`` be printed in the first line of the check output?
* | Report Change as
  | Should a change of ``value`` be reported as ``WARN`` or ``CRIT``? The check stores the initial values on the first run in ``TMPDIR/linuxfabrik-plugin-cache.db``.

The output would be something like this::

    Uptime: 5m 1w

    Key         Value           State 
    ---         -----           ----- 
    Name        BRW38B1DB3B30F4 [OK]  
    Location    Office          [OK]  
    Contact     The Printer Man [OK]  
    Description Brother NC-350w [OK]  
    Uptime      5m 1w           [OK]|Uptime=13762718.93s;;;0;;



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
                          NIC.1 Traffic values['NIC.1 tx'] + values['NIC.1 rx']  b,c
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
``-M DIR[:...]``   ``--mibdir MIBDIR``
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

I get ``Too many object identifiers specified. Only 128 allowed in one request.``
    Probably your SNMP v3 parameters are incomplete or incorrect.

I get ``add_mibdir: strings scanned in from .snmp/mibs/.index are too large.  count = ...``
    There seems to be a malformed, a duplicated MIB file or one with spaces in its filename within one of your MIB directories.

I get ``Error in packet. Reason: (tooBig) Response message would have been too large.``
    A "tooBig" response simply means that the SNMP agent tried to generate a response with all requested OID's, but the response grew too big for its buffer, resulting in this error message. To avoid this, we divide your OID list and send a maximum of 25 oids per request each.

Within Icinga, if I acknowledge a value change in WARN or CRIT state, does the plugin returns OK?
    If you acknowledge a value change in Icinga, the desired WARN or CRIT state remains - due to the fact that SNMP is mostly run against hardware, and you have to check what triggered the change. If everything is fine, delete ``TMPDIR/linuxfabrik-plugin-cache.db``. On the next run of the plugin, it will recreate the inventory.


States
------

Depending on the OID definitions the check returns

* OK
* WARN
* CRIT
* UNKNOWN


Perfdata
--------

All numeric values are automatically returned.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
