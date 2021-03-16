Check "snmp"
============

Overview
--------

This check utilizes ``snmpget`` to query for information on a network entity, so it provides all that ``snmpget`` is capable of, for example SNMP v2c and SNMP v3.

.. note::

    Only use SNMP if there is no other way. SNMP puts much strain on the target system and the monitoring software.

    * If you can use an agent of your monitoring software for monitoring, for example the Icinga agent, do it.
    * If you can't install an agent, but there is a good (REST-)API available, use that.
    * If you can't install an agent on a device and there is no good API, then use SNMP.
    * Prefer SNMPv2. Although completely insecure, it is fast and keeps the load on your appliance low.


Installation
------------

Install ``snmpget``. On CentOS:

.. code-block:: bash

    yum -y install net-snmp-utils

If needed, get any MIB files ready. Copy them to ``$HOME/.snmp/mibs``, ``/usr/share/snmp/mibs`` or ``/usr/lib64/nagios/plugins/snmp-mibs``. If you prefer other locations, provide the paths using the ``--mibdir`` parameter (same syntax as the ``-M`` parameter of ``snmpget``).

Create an OID list in ``/usr/lib64/nagios/plugins/snmp-devices`` using CSV format. For details, have a look at "Defining a Device" within this document.


Usage
-----

A minimal command call:

.. code-block:: bash

    ./snmp --hostname 10.80.32.109

This just parses some most common attributes like *Contact* or *Uptime*, defined in ``snmp-devices/any-any-any``.

.. code-block:: bash

    ./snmp --device switch-fs-s3900 --hostname 10.80.32.109 --mib +FS-MIB

With this, the check

#. calls ``snmpget -v 2c -c public -r 0 -t 7 -OSqtU -M $HOME/.snmp/mibs:/usr/share/snmp/mibs:./snmp-mibs -m +FS-MIB 10.80.32.109 OID1 OID2 ...``,
#. parses the output,
#. interprets the result and calculates the state.

Other examples:

.. code-block:: bash

    # snmp v2
    ./snmp --device switch-fs-s3900 --snmpversion 2c --community public --hostname 10.80.32.109 --mib +FS-MIB


Defining a Device
-----------------

You have to define a list of OIDs that has to be fetched, including any calculations, warning and critical thresholds in a CSV file located at ``snmp-devices``. An example for nearly any device:

.. csv-table:: 
    :caption: snmp-devices/devicetype-vendor-model

    OID,                                Name       ,Re-Calc         ,Unit Label,WARN                 ,CRIT                 ,Show in 1st Line,Report Change as
    SNMPv2-MIB::sysName.0,              Name       ,                ,          ,                     ,                     ,                ,
    SNMPv2-MIB::sysLocation.0,          Location   ,                ,          ,                     ,                     ,                ,WARN
    SNMPv2-MIB::sysContact.0,           Contact    ,                ,          ,                     ,                     ,                ,
    SNMPv2-MIB::sysDescr.0,             Description,                ,          ,                     ,                     ,                ,
    DISMAN-EVENT-MIB::sysUpTimeInstance,Uptime     ,int(value) / 100,s         ,value > 4*365*24*3600,value > 5*365*24*3600,True            ,

The columns in detail:

* | OID
  | The Object-Identifier from any of your MIB files.
* | Name
  | If provided, the check prints this instead of the OID.
* | Re-Calc
  | Feel free to use any Python Code based on the variable ``value``, which contains the result of the SNMPGET operation on the given OID.
* | Unit
  | The units ``s`` (seconds) and ``b`` (bytes) will be converted to a human-friendly format.
* | WARN
  | The warning threshold for the re-calculated or raw ``value``.
* | CRIT
  | The critical threshold for the re-calculated or raw ``value``.
* | Show in first line
  | Should ``value`` be printed in the first line of the check output?
* | Report Change as
  | Should a change of ``value`` be reported as WARN or CRIT? The check stores the initial values in ``TMPDIR/linuxfabrik-plugin-cache.db``.

The ``value`` returned by ``snmpget`` for a given *OID* is always a string. If you want to use it as an Integer, re-calculate it by specifying ``int(value)`` in column.

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


Get a list of OIDs
------------------

How to get a list of OIDs:

.. code-block:: bash

    snmpbulkwalk -v2c -c public -OSt -M $HOME/.snmp/mibs:/usr/share/snmp/mibs:./snmp-mibs 10.80.32.141 NETGEAR-SWITCHING-MIB::agentInfoGroup
    
    # load also the MIB "FS-MIB", and start walking
    snmpbulkwalk -v2c -c public -OSt -M $HOME/.snmp/mibs:/usr/share/snmp/mibs:./snmp-mibs -m +FS-MIB 10.80.32.109


Q & A
-----

I get ``Too many object identifiers specified. Only 128 allowed in one request.``
    Probably your SNMP v3 parameters are incomplete or incorrect.

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

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
