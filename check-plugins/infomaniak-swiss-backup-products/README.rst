Check infomaniak-swiss-backup-products
======================================

Overview
--------

Checks your Infomaniak Swiss Backup product details via the Infomaniak API. To use this check, you have to create a Bearer Token at Infomaniak first.

The output table is sorted by the "Tags" column.

Hints:

* In the table output, the column header "Dev" means the number of devices created, "Maint." stands for "Maintenance" and "Busy" for the API result "has_operation_in_progress".

Links:

* Swiss Backup: https://www.infomaniak.com/en/swiss-backup
* API Documentation: https://developer.infomaniak.com/docs/api/get/1/swiss_backups
* API Tokens: https://manager.infomaniak.com/v3/$ACCOUNT_ID/ng/accounts/token


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/infomaniak-swiss-backup-products"
    "Check Interval Recommendation",        "Once an hour"
    "Can be called without parameters",     "No"
    "Compiled for Windows",                 "No"


Help
----

.. code-block:: text

    usage: infomaniak-swiss-backup-products [-h] [-V] --account-id ACCOUNT_ID
                                            [--always-ok] [-c CRIT] [--insecure]
                                            [--no-proxy] [--severity {warn,crit}]
                                            [--timeout TIMEOUT] --token TOKEN
                                            [--test TEST] [-w WARN]

    Checks your Infomaniak Swiss Backup product details via the Infomaniak API.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --account-id ACCOUNT_ID
                            Infomaniak Account-ID
      --always-ok           Always returns OK.
      -c, --critical CRIT   Set the critical for the expiration date in days.
                            Default: 3
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --severity {warn,crit}
                            Severity for alerting other values. Default: warn
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
      --token TOKEN         Infomaniak API token
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w, --warning WARN    Set the warning for the expiration date in days.
                            Default: 5


Usage Examples
--------------

.. code-block:: bash

    ./infomaniak-swiss-backup-products --token=TOKEN --account-id=200999 --warning=21 --severity=crit

Output:

.. code-block:: text

    Everything is ok.

    ID    ! Customer     ! Tag  ! Size (alloc/avail)  ! Dev ! Maint. ! Locked ! Busy  ! Expires in 
    ------+--------------+------+---------------------+-----+--------+--------+-------+------------
    55577 ! BK-200999-1  ! prod ! 9.1TiB / 9.1TiB     ! 1   ! False  ! False  ! False ! 11M 2W     
    55556 ! BK-200999-2  ! test ! 186.3GiB / 186.3GiB ! 2   ! False  ! False  ! False ! 10M 5D     
    55558 ! BK-200999-3  ! prod ! 4.5TiB / 4.5TiB     ! 2   ! False  ! False  ! False ! 9M 4D      
    55560 ! BK-200999-4  ! test ! 1.8TiB / 1.8TiB     ! 1   ! False  ! False  ! False ! 8M 3D      


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
    <ID>-busy,                                  Number,             "0 = not busy, 1 = operation in progress"
    <ID>-locked,                                Number,             "0 = unlocked, 1 = locked"
    <ID>-maintenance,                           Number,             "0 = not in maintenance, 1 = in maintenance"
    <ID>-size,                                  Bytes,              Available Storage Space
    <ID>-storage_reserved,                      Bytes,              Allocated Storage Space


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
