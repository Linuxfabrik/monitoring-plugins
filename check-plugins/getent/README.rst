Check getent
============

Overview
--------

The getent plugin checks entries from databases supported by the Name Service Switch libraries, which are configured in ``/etc/nsswitch.conf``, using the ``getent`` command, and warns if no match - so it helps for example to check the availability of a FreeIPA or an Active Directory (AD) connected via ``sssd``.

If one or more key arguments are provided, then only the entries that match the supplied keys will be checked.

For details have a look at ``man getent``.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/getent"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Python module ``psutil``, command-line tool ``getent``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"
    "Perfdata compatible with Prometheus",  "Yes"


Help
----

.. code-block:: text

    usage: example [-h] [-V]

    Example Check.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./getent --database group --key SysOps
    ./getent --database hosts --key localhost --key localhost.localdomain
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN if one or more supplied keys could not be found in the database.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
