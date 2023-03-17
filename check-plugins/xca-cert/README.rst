Check xca-cert
==============

Overview
--------

If you are using XCA by Christian Hohnstädt (an *application that is intended for creating and managing X.509 certificates, certificate requests, RSA, DSA and EC private keys, Smart-cards and CRLs*) with `"Remote Databases" feature enabled <https://hohnstaedt.de/xca/index.php/documentation/remote-databases>`_, this plugin lets you check the expiration date of any certificate within those XCA MySQL/MariaDB databases. CRLs are also taken into account.

Hints:

* This check works with MySQL/MariaDB backend only, although XCA is supporting PostgreSQL as well.
* We recommend to run this check directly on your database host.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/xca-cert"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"
    "Requirements",                         "User with SELECT privileges on the XCA database, locked down to ``127.0.0.1`` - for example ``monitoring\@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."
    "3rd Party Python modules",             "``pymysql``"


Help
----

.. code-block:: text

    usage: xca-cert [-h] [-V] [-c CRIT] [--database DATABASE] [-H HOSTNAME]
                    [-p PASSWORD] [--prefix PREFIX] [-u USERNAME] [-w WARN]

    Checks expiration date of certificates in a XCA based MySQL/MariaDB database.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -c CRIT, --critical CRIT
                            Set the critical for the expiration date in days.
                            Default: 5
      --database DATABASE   Set the MySQL database running the XCA database.
                            Default: xca
      -H HOSTNAME, --hostname HOSTNAME
                            Set the hostname of the MySQL server running the XCA
                            database. Default: localhost
      -p PASSWORD, --password PASSWORD
                            Set the password for the MySQL server running the XCA
                            database. Default:
      --prefix PREFIX       Set the table prefix of the XCA database.
      -u USERNAME, --username USERNAME
                            Set the username for the MySQL server running the XCA
                            database. Default: root
      -w WARN, --warning WARN
                            Set the warning for the expiration date in days.
                            Default: 14


Usage Examples
--------------

.. code-block:: bash

    ./xca-cert --hostname localhost --database xca --username dbuser --password dbpass --prefix xca_prefix_ --warning 14 --critical 5

Output:

.. code-block:: text

    39 Certificates and 1 CRL checked.

    Certificates:
    commonName                 ! CA ! Serial  ! State ! Expiry date         
    ---------------------------+----+---------+-------+---------------------
    LF Root CA SHA 384         ! y  ! 4F389A7 ! [OK]  ! 2022-03-12 23:59:59 
    Linuxfabrik App CA SHA 384 ! y  ! 48B7851 ! [OK]  ! 2022-03-12 23:59:59 
    server1                    ! n  ! 6485ECE ! [OK]  ! 2021-12-01 14:49:00 
    user1@linuxfabrik.ch       ! n  ! 19EE889 ! [OK]  ! 2021-12-24 14:56:00 
    user2@linuxfabrik.ch       ! n  ! 3C74DEF ! [OK]  ! 2021-12-26 14:58:00 
    ...

    CRLs:
    commonName                 ! State ! Expiry date         
    ---------------------------+-------+---------------------
    Linuxfabrik App CA SHA 384 ! [OK]  ! 2023-07-13 07:52:00


States
------

* WARN or CRIT if a certificate expires within a given threshold.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
