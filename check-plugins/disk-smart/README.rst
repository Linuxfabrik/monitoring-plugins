Check disk-smart
================

Overview
--------

Multi HDD/SSD scan. No need to provide any warning/critical thresholds, no need to maintain any
disk or property databases, no need for any additional libraries.

The check calls ``smartctl``, which itself *controls the Self-Monitoring, Analysis 
and Reporting Technology (SMART) system built into most ATA/SATA and SCSI/SAS 
hard drives and solid-state drives. The purpose of SMART is to monitor the 
reliability of the hard drive and predict drive failures.* (from the man page of ``smart``)

Hints:

* Needs ``sudo``.
* Running this check just makes sense on hardware using ATA/SATA and/or SCSI/SAS HDDs and SSDs.
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
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: disk-smart [-h] [-V] [--always-ok] [--full] [--ignore IGNORE]
                      [--test TEST]

    This check is some kind of user interface for smartctl, which is a tool for
    querying and controlling SMART (Self-Monitoring, Analysis, and Reporting
    Technology) data in hard disk and solid-state drives. It allows you to inspect
    the drive's SMART data to determine its health.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit
      --always-ok      Always returns OK.
      --full           If set, also warn on any assumptions (in GSmartControl
                       stated as "notice" messages), otherwise just warn on "real"
                       SMART issues. Default: check warnings and alerts only.
      --ignore IGNORE  A comma-separated list of disks which should be ignored, in
                       the format 'sda,sdb'.Default: []
      --test TEST      For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                       file,expected-retc".


Usage Examples
--------------

.. code-block:: bash
    
    ./disk-smart --ignore sdd,sdbx,mmcblk0 --full

Output:

.. code-block:: text


    Checked 6 disks. There are critical errors.
    * sda (Crucial/Micron Client SSDs, Crucial_CT525MX300SSD1, SerNo 1a2b3c4d)
    * sdb (Crucial/Micron Client SSDs, Crucial_CT525MX300SSD1, SerNo 1a2b3c4d)
    * [CRITICAL] sdc (Seagate IronWolf, ST12000VN0007-2GS116, SerNo 1a2b3c4d)
      - The device error log contains records of errors.
      - Error Log: Drive is reporting 2 internal errors. Usually this means uncorrectable data loss and similar severe errors. Check the actual errors for details.
      - Error Log: Error "Uncorrectable error in data".
      - Error Log: Error "Uncorrectable error in data".
      - Attributes: Drive has a non-zero Raw value ("5 Reallocated_Sector_Ct"), but there is no SMART warning yet. This could be an indication of future failures and/or potential data loss in bad sectors.
    * sdd (Seagate IronWolf, ST12000VN0007-2GS116, SerNo 1a2b3c4d)
      - The device error log contains records of errors.
    * sde (Seagate IronWolf, ST12000VN0007-2GS116, SerNo 1a2b3c4d)
      - The device error log contains records of errors.
    * sdf (Seagate IronWolf, ST12000VN0007-2GS116, SerNo 1a2b3c4d)
      - The device error log contains records of errors.


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

UNKNOWN on ``smartctl`` not found, errors running ``smartctl``, SMART not available or not supported.

If ``smartctl`` reports more than one issue, the worst issue state over all disks is returned.


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
* Credits: `GSmartControl <https://gsmartcontrol.sourceforge.io/home/>`_: We re-implemented parts of the logic in Python and used its excellent output.
