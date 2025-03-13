Check getent
============

Overview
--------

The getent plugin checks entries from databases supported by the Name Service Switch libraries, which are configured in ``/etc/nsswitch.conf``, using the ``getent`` command, and warns if no match.

If one or more key arguments are provided, then only the entries that match the supplied keys will be checked.

Note: Calling the plugin with ``getent --database=passwd`` lists only local users, not users on an Directory server. To check the availability of a FreeIPA or an Active Directory (AD) connected via ``sssd``, add the name of a known network account to test if network users are resolved correctly. For example, ``getent --database=passwd --key=<ldapuser>``.

For details have a look at ``man getent``.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/getent"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: getent [-h] [-V] [--database DATABASE] [--key KEY]

    Attempts to obtain entries from Name Service Switch (NSS) libraries and warns
    of errors or missing matches.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --database DATABASE  May be any of those supported by "getent", for example
                           "group", "hosts" etc. Default: group
      --key KEY            If one or more key arguments are provided, then only
                           the entries that match the supplied keys will be
                           fetched. Otherwise, if no key is provided, all entries
                           will be fetched (unless the database does not support
                           enumeration). (repeating)


Usage Examples
--------------

.. code-block:: bash

    ./getent --database group --key SysOps
    ./getent --database hosts --key localhost --key localhost.localdomain
    
Output:

.. code-block:: text

    Everything is ok. Executed `/usr/bin/getent group`, got 7153 results.


States
------

* WARN if one or more supplied keys could not be found in the database.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
