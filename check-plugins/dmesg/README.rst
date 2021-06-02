Check dmesg
===========

Overview
--------

Checks emerg, alert, crit and err messages in dmesg, and unless the ``--severity`` parameter is ommitted, always returns CRIT if something was found.

Some very common dmesg messages are ignored, for example ``Assuming drive cache: write through`` (should be a debug message) or ``ioctl error in smb2_get_dfs_refer rc=-5`` (a bug as stated in https://access.redhat.com/solutions/3496971).

Be aware that the reported timestamps could be inaccurate. The time source used for dmesg is not updated after system SUSPEND/RESUME. Timestamps are adjusted according to current delta between boottime and monotonic clocks, this works only for messages printed after last resume.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/dmesg"
    "Check Interval Recommendation",        "Once a minute"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Python module ``psutil``, command-line tool ``dmesg``"
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

    ./dmesg 
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* CRIT or state given by ``--severity`` if any of (filtered) emerg, alert, crit and err messages in dmesg are found.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
