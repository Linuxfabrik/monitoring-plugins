Check infomaniak-swiss-backup-devices
=====================================

Overview
--------

Checks each device / slot of all your Infomaniak Swiss backup products via the Infomaniak API. To use this check, you have to create a Bearer Token at Infomaniak first.

The output table is sorted by the "Tags" column.

Hints:

* The check takes 10 seconds or more. Increasing runtime timout to 30 seconds is recommended.
* Be aware of the fact that you may retrieve values while Infomaniak's API is still compiling the usage statistic. This may cause you to think that you have lost a certain amount of data without doing anything. The next time you run the check, usage statistic will be back to normal.

Links:

* Swiss Backup: https://www.infomaniak.com/en/swiss-backup
* API Documentation: https://developer.infomaniak.com/, https://api.infomaniak.com/doc
* API Tokens: https://manager.infomaniak.com/v3/$ACCOUNT_ID/ng/accounts/token


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/infomaniak-swiss-backup-devices"
    "Check Interval Recommendation",        "Every hour"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: infomaniak-swiss-backup-devices [-h] [-V] --account-id ACCOUNT_ID
                                           [--always-ok] [-c CRIT]
                                           [--severity {warn,crit}] --token TOKEN
                                           [--test TEST] [-w WARN]

    Checks each device / slot of all your Infomaniak Swiss backup products via the
    Infomaniak API.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --account-id ACCOUNT_ID
                            Infomaniak Account-ID
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold as a percentage. Default: >= 95
      --severity {warn,crit}
                            Severity for alerting other values. Default: warn
      --token TOKEN         Infomaniak API token
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w WARN, --warning WARN
                            Set the WARN threshold as a percentage. Default: >= 90


Usage Examples
--------------

.. code-block:: bash

    ./infomaniak-swiss-backup-devices --token=TOKEN --account-id=200999 --warning=80 --severity=crit

Output:

.. code-block:: text

    There are critical errors.

    ID    ! Customer     ! Tags  ! User         ! Name   ! Type  ! Usage                                 ! Usage Upd. ! Locked
    ------+--------------+-------+--------------+--------+-------+---------------------------------------+------------+--------
    99924 ! BK-200999-2  ! tag03 ! SBI-AB123456 ! prod   ! swift ! 9.4% (13.2GiB / 139.7GiB)             ! 2h 18m ago ! False  
    99925 ! BK-200999-2  ! tag03 ! SBI-AB123456 ! test   ! swift ! 7.1% (3.3GiB / 46.6GiB)               ! 2h 18m ago ! False  
    99946 ! BK-200999-9  ! tag90 ! SBI-AB123456 ! bucket ! swift ! 92.0% (856.6GiB / 931.3GiB) [WARNING] ! 2h 18m ago ! False


States
------

* CRIT if ``--severity=crit`` and "Locked" is ``True``.
* WARN if ``--severity=warn`` (default) and "Locked" is ``True``.
* WARN or CRIT if a device / slot is above a given threshold.
* WARN if a device is not used at all (0 bytes), which means that no backups are made and you waste money.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    <ID>-percent,                               Percentage,         Usage in percent
    <ID>-total,                                 Bytes,              Total device size
    <ID>-usage,                                 Bytes,              Usage in Bytes
    <ID>-locked,                                Number,             "0 = unlocked, 1 = locked"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
