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

If needed, get any MIB files ready. Copy them to ``$HOME/.snmp/mibs``, ``/usr/share/snmp/mibs`` or ``/usr/lib64/nagios/plugins/device-mibs/...``. If you prefer other locations, provide the paths using the ``--mibdir`` parameter (same syntax as the ``-M`` parameter of ``snmpget``), and reference special ones using the ``--mib`` parameter (same syntax as the ``-M`` parameter of ``snmpget``).

Create an OID list in ``/usr/lib64/nagios/plugins/device-oids`` using CSV format. For details, have a look at "Defining a Device" within this document.


Usage
-----

A minimal command call:

.. code-block:: bash

    ./snmp --hostname 10.80.32.109

The check then

#. calls ``snmpget -v 2c -c public -r 0 -t 7 -OSqtU -M $HOME/.snmp/mibs:/usr/share/snmp/mibs 10.80.32.109 OID1 OID2 ...``,
#. parses the output,
#. interprets the result and calculates the state.

Without further arguments, the check just parses some most common OIDs like *Contact* or *Uptime*, defined in ``device-oids/any-any-any.csv``.

Other example using an additional MIB directory:

.. code-block:: bash

    /usr/lib64/nagios/plugins/snmp3 \
        --device switch-fs-s3900.csv \
        --mibdir +/usr/lib64/nagios/plugins/device-mibs/switch-fs-s3900 \
        --hide-ok \
        --hostname 10.80.32.109


Defining a Device
-----------------

You have to define a list of OIDs that should be fetched, including any calculations, warning and critical thresholds, in a CSV file located at ``device-oids``, using ``,`` as delimiter and ``"`` as quoting character. An minimal example for nearly any device:

========================= ============= ================== ============ ======================= ======================= ================== ==================
OID                       Name          Re-Calc            Unit Label   WARN                    CRIT                    Show in 1st Line   Report Change as
========================= ============= ================== ============ ======================= ======================= ================== ==================
SNMPv2-MIB::sysName.0     Name                                                                                                 
SNMPv2-MIB::sysLocation.0 Location                                                                                                         WARN
SNMPv2-MIB::sysContact.0  Contact                                                                                              
SNMPv2-MIB::sysDescr.0    Description                                                                                          
SNMPv2-MIB::sysUpTime.0   Uptime        int(value) / 100   s            value > 4*365*24*3600   value > 5*365*24*3600   True             
========================= ============= ================== ============ ======================= ======================= ================== ==================


The columns in detail:

* | OID
  | The Object-Identifier from any of your MIB files.
* | Name
  | If provided, the check prints this instead of the OID.
* | Re-Calc
  | Feel free to use any Python Code based on the variable ``value``, which contains the result of the SNMPGET operation on the given OID.
* | Unit
  | This is the "Unit of Measurement", case-insensitiv.
  |  * s - seconds (also us, ms)
  |  * % - percentage
  |  * B - bytes (also KB, MB, TB, ...)
  |  * bps - bits per second (also Kbps, Mbps, ...)
  |  * c - a continous counter (such as bytes transmitted on an interface)  
  | If you provide two comma-separated units, for example "b,c", the first one will be used to display a human-readable format ("Bytes"), and the second one is used to suffix the perfdata ("continous counter").
  | For output, the following units will always be converted to a human-friendly format:
  | * s - seconds
  | * b - bytes
  | * bps - bits per second
* | WARN
  | The warning threshold for the re-calculated or raw ``value``.
* | CRIT
  | The critical threshold for the re-calculated or raw ``value``.
* | Show in first line
  | Should ``value`` be printed in the first line of the check output?
* | Report Change as
  | Should a change of ``value`` be reported as ``WARN`` or ``CRIT``? The check stores the initial values on the first run in ``TMPDIR/linuxfabrik-plugin-cache.db``.

The ``value`` returned by ``snmpget`` for a given *OID* is always a string. If you want to use it as an Integer, re-calculate it by specifying ``int(value)`` in column (SNMP knows nothing about floats).

The output would be something like this::

    Uptime: 5m 1w

    Key         Value           State 
    ---         -----           ----- 
    Name        BRW38B1DB3B30F4 [OK]  
    Location    Office          [OK]  
    Contact     The Printer Man [OK]  
    Description Brother NC-350w [OK]  
    Uptime      5m 1w           [OK]|Uptime=13762718.93s;;;0;;

Good to know: If more than 128 OIDs are used, the check automatically splits them into chunks of 128 OIDs per SNMPGET request max.


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
    There seems to be a malformed or duplicated MIB file in one of your MIB directories.

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
