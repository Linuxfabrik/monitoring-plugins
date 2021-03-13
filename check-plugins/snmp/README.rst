snmp
====

This check utilizes ``snmpget`` to query for information on a network entity.

.. note::

    Only use SNMP if there is no other way. SNMP puts much strain on the target system and the monitoring software.

    * If you can use an agent of your monitoring software for monitoring, for example the Icinga agent, do it.
    * If you can't install an agent, but there is a good (REST-)API available, use that.
    * If you can't install an agent on a device and there is no good API, then use SNMP.

    Prefer SNMPv2. Although completely insecure, it is fast and keeps the load on your appliance low.


Preparation
-----------

Install ``snmpget``.

.. code-block:: bash

    yum -y install net-snmp-utils

If needed, get any MIB files ready. Copy them to ``$HOME/.snmp/mibs``, ``/usr/share/snmp/mibs`` or ``/usr/lib64/nagios/plugins/snmp-mibs``. If you prefer other locations, provide the paths using the ``--mibdir`` parameter (same syntax as the ``-M`` parameter of ``snmpget``).

If not already done, create an OID list in ``/usr/lib64/nagios/plugins/snmp-devices`` using CSV format. For details, have a look at "Building an OID list (CSV)" within this document.


Running this plugin
-------------------

.. code-block:: bash

    ./snmp --device switch_fs_s3900 --hostname 10.80.32.109 --mib +FS-MIB

With this, the check

#. calls ``snmpget -v 2c -c public -r 0 -t 7 -OSqtU -M $HOME/.snmp/mibs:/usr/share/snmp/mibs:./snmp-mibs -m +FS-MIB 10.80.32.109 OID1 OID2 ...``,
#. parses the output,
#. interprets the result and calculates the state.

Other examples:

.. code-block:: bash

    # snmp v2
    ./snmp --device switch_fs_s3900 --hostname 10.80.32.109 --snmpversion 2c --community public --mib +FS-MIB

    # snmp v3
    ./snmp --snmpversion 3 --v3bootstime bootstime --v3context context --v3contextengineid contextengineid --v3securityengineid securityengineid --v3level authPriv --v3authprotpassword authprotpassword --v3privprotpassword privprotpassword --v3authprot SHA-512 --v3privprot AES-256 --v3username username --mib +FS-MIB --hostname 10.80.32.109 --device switch_fs_s3900


Building an OID list (CSV)
--------------------------

The ``value`` returned by parsing the output of ``snmpget`` for a given *OID* is always a string. If you want to use it as an Integer, re-calculate it by specifying ``int(value)`` in column *Re-Calc* - this is Python Code.

Good to know: If more than 128 OIDs are used, the check automatically splits them into chunks of 128 OIDs per SNMPGET request max.


Get a list of OIDs
------------------

Then get a list with all OIDs:

.. code-block:: bash

    # load also the MIB "FS-MIB", and start walking
    rm -rf /var/lib/net-snmp/mib_indexes/*
    snmpbulkwalk -v2c -c public -OS -M $HOME/.snmp/mibs:/usr/share/snmp/mibs:./mibs -m +FS-MIB 10.80.32.109

    snmpbulkwalk -v2c -c public -OSt -M $HOME/.snmp/mibs:/usr/share/snmp/mibs:./snmp-mibs 10.80.32.141 NETGEAR-SWITCHING-MIB::agentInfoGroup



Q & A
-----

I get ``Too many object identifiers specified. Only 128 allowed in one request.``
    Probably your SNMP v3 parameters are incomplete or incorrect.

Within Icinga, if I acknowledge a value change in WARN or CRIT state, does the plugin returns OK?
    If you acknowledge a value change in Icinga, the desired WARN or CRIT state remains - due to the fact that SNMP is mostly run against hardware, and you have to check what triggered the change. If everything is fine, delete ``TMPDIR/linuxfabrik-plugin-cache.db``. On the next run of the plugin, it will recreate the inventory.
