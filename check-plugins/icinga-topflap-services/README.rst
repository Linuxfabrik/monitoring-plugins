Check icinga-topflap-services
=============================

Overview
--------

This check plugin counts the number of state changes per service within a given lookback interval. This makes it possible to detect fast flapping services. The data is retrieved from the History > Event Overview view in IcingaDB. To access the URL, all you need is an IcingaWeb2 user with the 'icingadb > General Module Access' permission.

An output like ``srv01 ! Swap usage ! 10 ! [WARNING]`` means that the service 'Swap Usage' on host 'srv01' has had 10 service state changes in the lookback interval. With this information, you can now examine the history of the specified service.

Instead of specifying url, user and password on the command line, you can create and specify an INI file like this

.. code block:: text

    [icingaweb2]
    url = http://localhost/icingaweb2/icingadb/history?limit=250
    username = alice
    password = linuxfabrik

Command line arguments override the settings in the password INI file.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/icinga-topflap-services"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "IcingaDB, Read access to ``/icingaweb2/icingadb/history``"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-monitoring-plugins-icinga-topflap-services.db``"


Help
----

.. code-block:: text

    usage: icinga-topflap-services [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                                   [--lookback LOOKBACK] [--no-proxy]
                                   [--password PASSWORD] [--pwfile PWFILE]
                                   [--timeout TIMEOUT] [--url URL]
                                   [--username USERNAME] [-w WARN]

    This check plugin counts the number of state changes per service within a
    given lookback interval. This makes it possible to detect fast flapping
    services. The data is determined in the 'History > Event Overview' view in
    IcingaDB. An output like `srv01 ! Swap Usage ! 10 ! [WARNING]` means that the
    service 'Swap Usage' on host 'srv01' has had 10 service state changes in the
    lookback interval. With this information, you can now examine the history of
    the specified service.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      -c, --critical CRIT  Critical number of state changes per service within the
                           "lookback" period. Supports Nagios ranges. Default: 19
      --insecure           This option explicitly allows to perform "insecure" SSL
                           connections. Default: False
      --lookback LOOKBACK  Seconds in the past that the plugin should consider
                           when looking for data. Default: 14400
      --no-proxy           Do not use a proxy. Default: False
      --password PASSWORD  IcingaWeb Password. Takes precedence over setting in
                           `--password-file`.
      --pwfile PWFILE      Specifies a password file to read "url", "user" or
                           "password" for IcingaWeb from (instead of specifying
                           them on the command line), for example
                           `/var/spool/icinga2/.icingaweb`. Default:
                           /var/spool/icinga2/.icingaweb
      --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
      --url URL            URL to IcingaDB > History > Event Overview, including
                           filter parameters. Takes precedence over setting in
                           `--password-file`.Something like
                           `https:/icinga//icingaweb2/icingadb/history?limit=250
      --username USERNAME  IcingaWeb Username. Takes precedence over setting in
                           `--password-file`.
      -w, --warning WARN   Warning number of state changes per service within the
                           "lookback" period. Supports Nagios ranges. Default: 7


Usage Examples
--------------

.. code-block:: bash

    ./icinga-topflap-services \
        --username=alice \
        --password=linuxfabrik \
        --url='https://icinga/icingaweb2/icingadb/history?limit=250' \
        --lookback=86400

Output:

.. code-block:: text

    There are warnings. (lookback=1D warn=5 crit=19)

    Host            ! Service                 ! Cnt ! State     
    ----------------+-------------------------+-----+-----------
    srv-mon01       ! Swap Usage              ! 12  ! [WARNING] 
    srv-analytics01 ! Load                    ! 10  ! [WARNING] 
    srv-analytics01 ! CPU Usage               ! 8   ! [WARNING] 
    srv-vcs01       ! Swap Usage              ! 6   ! [WARNING] 
    srv-cloud02     ! Apache httpd Status     ! 4   ! [OK]      
    srv-repo01      ! Journald Usage          ! 2   ! [OK]      
    srv-cloud01     ! Nextcloud Stats         ! 2   ! [OK]      


States
------

* WARN or CRIT if a specified number of flapping services are found within the lookback interval.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
