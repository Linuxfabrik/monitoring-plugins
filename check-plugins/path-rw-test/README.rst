Check path-rw-test
==================

Overview
--------

Tests whether a file (``__LINUXFABRIK_PATH_RW_TEST__``) can be written to a specific path and then deleted - much like the "__DIRECT_IO_TEST__" in oVirt. Especially useful with mounted filesystems like NFS or SMB. The local temporary directory is always tested, no matter whether the check is called with or without parameters. May need sudo.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/path-rw-test"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``psutil``"


Help
----

.. code-block:: text

    usage: path-rw-test [-h] [-V] [--always-ok] [--path PATH]
                        [--severity {warn,crit}]

    Tests whether a file can be written to a specific path and then deleted.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --path PATH           Path to which the file is to be written and from which
                            it will be deleted (repeating). Default: ['/tmp']
      --severity {warn,crit}
                            Severity for alerting. One of "warn" or "crit".
                            Default: warn


Usage Examples
--------------

.. code-block:: bash

    ./path-rw-test --path /mnt/nfs --path /mnt/smb --path . --severity warn

Output:

.. code-block:: text

    /mnt/nfs: I/O error "Permission denied" while writing /mnt/nfs/__LINUXFABRIK_PATH_RW_TEST__ [WARNING]


States
------

* WARN if ``--severity`` is set to ``warn`` (default)
* CRIT if ``--severity`` is set to ``crit``


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
