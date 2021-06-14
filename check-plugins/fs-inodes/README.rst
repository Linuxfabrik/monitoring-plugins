Check fs-inodes
===============

Overview
--------

Checks the used inode space in percent, default on ``/``, ``/tmp`` and ``/boot``.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fs-inodes"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: fs-inodes [-h] [-V] [--always-ok] [-c CRIT] [--mount MOUNT] [-w WARN]

    Checks the used inode space in percent, default on "/", "/tmp" and "/boot".

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold inode usage percentage.
                            Default: 95
      --mount MOUNT         The mount point. Default: "/, /tmp, /boot"
      -w WARN, --warning WARN
                            Set the warning threshold inode usage percentage.
                            Default: 90


Usage Examples
--------------

.. code-block:: bash

    ./fs-inodes --mount '/, /boot, /tmp' --warning 90 --critical 95
    
Output:

.. code-block:: text

    / 1.7%, /tmp 3.2%, /boot 0.2%


States
------

* WARN or CRIT if inode usage is above a given threshold.


Perfdata / Metrics
------------------

For each mount:

* inode usage (%)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
