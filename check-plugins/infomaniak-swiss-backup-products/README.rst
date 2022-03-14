Check infomaniak-swiss-backup-products
======================================

Overview
--------

Checks your Infomaniak Swiss Backup product details via the Infomaniak API. To use this check, you have to create a Bearer Token at Infomaniak first.

Hints:

* In the table output, the column header "Dev" means the number of devices created, "Maint." stands for "Maintenance" and "Busy" for the API result "operation_in_progress".

Links:

* Swiss Backup: https://www.infomaniak.com/en/swiss-backup
* API Documentation: https://developer.infomaniak.com/, https://api.infomaniak.com/doc
* API Tokens: https://manager.infomaniak.com/v3/$ACCOUNT_ID/ng/accounts/token


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/infomaniak-swiss-backup-products"
    "Check Interval Recommendation",        "Every hour"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: infomaniak-swiss-backup-products [-h] [-V] --account-id ACCOUNT_ID
                                            [--always-ok] [-c CRIT]
                                            [--severity {warn,crit}] --token
                                            TOKEN [--test TEST] [-w WARN]

    Checks your Infomaniak Swiss Backup product details via the Infomaniak API.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --account-id ACCOUNT_ID
                            Infomaniak Account-ID
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical for the expiration date in days.
                            Default: 5
      --severity {warn,crit}
                            Severity for alerting other values. Default: warn
      --token TOKEN         Infomaniak API token
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w WARN, --warning WARN
                            Set the warning for the expiration date in days.
                            Default: 14


Usage Examples
--------------

.. code-block:: bash

    ./infomaniak-swiss-backup-products --token=TOKEN --account-id=200999 --warning=21 --severity=rit

Output:

.. code-block:: text

    Everything is ok.

    ID    ! Customer     ! Tags ! Size                ! Dev ! Expires in ! Maint. ! Locked ! Busy  
    ------+--------------+------+---------------------+-----+------------+--------+--------+-------
    55577 ! BK-200999-1  ! prod ! 9.1TiB / 9.1TiB     ! 1   ! 11M 2W     ! False  ! False  ! False 
    55556 ! BK-200999-2  ! test ! 186.3GiB / 186.3GiB ! 2   ! 10M 5D     ! False  ! False  ! False 
    55558 ! BK-200999-3  ! prod ! 4.5TiB / 4.5TiB     ! 2   ! 9M 4D      ! False  ! False  ! False 
    55560 ! BK-200999-4  ! test ! 1.8TiB / 1.8TiB     ! 1   ! 8M 3D      ! False  ! False  ! False 


States
------

* CRIT if ``--severity=crit`` and one of "Maint.", "Locked" or "Busy" is ``True``.
* WARN if ``--severity=warn`` (default) and one of "Maint.", "Locked" or "Busy" is ``True``.
* WARN or CRIT if a product expires within a given threshold.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    <ID>_busy,                                  Number,             "0 = not busy, 1 = operation in progress"
    <ID>_locked,                                Number,             "0 = unlocked, 1 = locked"
    <ID>_maintenance,                           Number,             "0 = not in maintenance, 1 = in maintenance"
    <ID>_size,                                  Bytes,              Allocated Storage Space
    <ID>_storage_reserved,                      Bytes,              Allocated Storage Space


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
