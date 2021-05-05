Check "path-rw-test"
====================

Overview
--------

Tests whether a file (``__LINUXFABRIK_PATH_RW_TEST__``) can be written to a specific path and then deleted - much like the "__DIRECT_IO_TEST__" in oVirt. Especially useful with mounted filesystems like NFS or SMB. The local temporary directory is always tested, no matter whether the check is called with or without parameters.


Installation and Usage
----------------------

.. code-block:: bash

    ./path-rw-test
    ./path-rw-test --path /mnt/nfs --path /mnt/smb --path . --severity warn
    ./path-rw-test --help

Output::

    Everything is ok.

Output::

    /mnt/smb: I/O error "No such file or directory" while writing /mnt/smb/__LINUXFABRIK_PATH_RW_TEST__ [WARNING], /mnt/nfs: I/O error "Permission denied" while writing /mnt/nfs/__LINUXFABRIK_PATH_RW_TEST__ [WARNING]


States
------

* WARN if ``--severity`` is set to ``warn`` (default)
* CRIT if ``--severity`` is set to ``crit``


Perfdata
--------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
