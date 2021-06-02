Check edisk-smart
==================

Overview
--------

The check calls ``smartctl``, which itself _controls the Self-Monitoring, Analysis 
and Reporting Technology (SMART) system built into most ATA/SATA and SCSI/SAS 
hard drives and solid-state drives. The purpose of SMART is to monitor the 
reliability of the hard drive and predict drive failures._ 
(from the man page of ``smart``)

Multi HDD/SSD scan. No need to provide any warning/critical thresholds, no need to maintain any
disk or property databases, no need for any additional libraries.

Hints:

* Needs ``sudo``.
* Running this check just makes sense on hardware using ATA/SATA and/or SCSI/SAS
  HDDs and SSDs.
* The check tries to identify all disks automatically. Disks without SMART
  capability can be ignored using the ``--ignore`` parameter manually.
* Keep in mind that a ``smartctl`` run can take up to one or two seconds per disk,
  depending on its health and (interface/bus) speed.
* Don't forget to run ``/usr/sbin/update-smart-drivedb`` from time to time to get the newest drive
  database (sometimes there are improvements on how to interpret some attributes).
* Use ``--full`` to get also a warning for notices.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/disk-smart"
    "Check Interval Recommendation",        "Every 8 hours"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, `smartctl`` >= 6.5 from ``smartmontools``, command-line tool ``foo``"
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
    
    ./disk-smart
    ./disk-smart --ignore sdd,sdbx,mmcblk0 --full

Output:

.. code-block:: text

    TODOVM Output


States
------

CRIT, if SMART reports

* any messages in subsection "health"
* drive has a failing pre-fail attribute
* "Address mark not found" in subsection "error_log"
* "Identity not found" in subsection "error_log"
* "Track 0 not found" in subsection "error_log"
* "Uncorrectable error in data" in subsection "error_log"
* SMART status check returned DISK FAILING

WARN, if SMART reports

* failing old-age attribute
* failing pre-fail attribute in the past
* "Command completion timed out" in subsection "error_log"
* "End of media" in subsection "error_log"
* "Interface CRC error" in subsection "error_log"
* Drive is past its estimated lifespan
* Drive is reporting surface errors

UNKNOWN on ``smartctl`` not found, errors running ``smartctl``, SMART not
available or not supported.

If ``smartctl`` reports more than one issue, the worst issue state over all disks
is returned.


Perfdata / Metrics
------------------

* Temperatures
* Remaining or used Lifetimes
* Power On Hours
* Power Cycle Counts


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
* Credits: GSmartControl (https://gsmartcontrol.sourceforge.io/home/): We re-implemented parts of the logic in Python and used its excellent output.
