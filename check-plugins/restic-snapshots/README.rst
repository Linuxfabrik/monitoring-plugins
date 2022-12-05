Check restic-snapshots
======================

Overview
--------

This plugin checks the age of the newest of all snapshots stored in the restic repository. It also supports filtering and grouping snapshots by host, paths and/or tags.

Refer to the `online manual <https://restic.readthedocs.io/en/latest/index.html>`_ for more details about restic.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/restic-snapshots"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: restic-snapshots [-h] [-V] [-c CRIT] [--group-by GROUP_BY]
                            [--host HOST] [--latest LATEST]
                            [--password-file PASSWORD_FILE] [--path PATH] --repo
                            REPO [--tag TAG] [--test TEST] [-w WARN]

    Check the age of the newest restic repository snapshot.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -c CRIT, --critical CRIT
                            Set the critical threshold for the time difference to
                            the start of the last backup (in each group) (in
                            hours). Default: None
      --group-by GROUP_BY   String for grouping snapshots by host,paths,tags.
                            Default: host,tags,paths
      --host HOST           Only consider snapshots for this host (can be
                            specified multiple times).
      --latest LATEST       Only show the last n snapshots for each host and path.
                            Default: 3
      --password-file PASSWORD_FILE
                            File to read the repository password from.
      --path PATH           Only consider snapshots for this path (can be
                            specified multiple times).
      --repo REPO           Repository location
      --tag TAG             Only consider snapshots which include this taglist in
                            the format `tag[,tag,...]` (can be specified multiple
                            times).
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w WARN, --warning WARN
                            Set the warning threshold for the time difference to
                            the start of the last backup (in each group) (in
                            hours). Default: 24


Usage Examples
--------------

Just show the latest three snapshots for host www.example.com, grouped by hosts, tags and paths:

.. code-block:: bash

    ./restic-snapshots --repo=/path/to/restic-repo --password-file=/path/to/restic-pwd --host=www.example.com --latest=3 --group-by='hosts,tags,paths' --warn=8

Output:

.. code-block:: text

    There are warnings.

    Latest snapshot 17h 52m ago [WARNING] (2022-12-04 16:10:05@www.example.com:/home, ID 34751e52); 3 snapshots found

    Short ID ! Timestamp           ! Age               ! Host                  ! Paths ! Tags 
    ---------+---------------------+-------------------+-----------------------+-------+------
    34751e52 ! 2022-12-04 16:10:05 ! 17h 52m [WARNING] ! www.example.com       ! /home !      
    f958e789 ! 2022-12-04 16:08:51 ! 17h 53m           ! www.example.com       ! /home !      
    4d2a09b2 ! 2022-12-04 16:08:49 ! 17h 53m           ! www.example.com       ! /home !      


    Latest snapshot 17m 38s ago (2022-12-05 09:45:00@www.example.com:/home, ID a5cae06b); 1 snapshot found

    Short ID ! Timestamp           ! Age     ! Host                  ! Paths ! Tags 
    ---------+---------------------+---------+-----------------------+-------+------
    a5cae06b ! 2022-12-05 09:45:00 ! 17m 38s ! www.example.com       ! /home ! myTag

The same check on the same restic repo, but without grouping - here the result is OK:

.. code-block:: bash

    ./restic-snapshots --repo=/path/to/restic-repo --password-file=/path/to/restic-pwd --host=www.example.com --latest=3 --group-by='' --warn=8

Output:

.. code-block:: text

    Everything is ok.

    Latest snapshot 28m 48s ago (2022-12-05 09:45:00@www.example.com:/home, ID a5cae06b); 5 snapshots found

    Short ID ! Timestamp           ! Age     ! Host                  ! Paths ! Tags 
    ---------+---------------------+---------+-----------------------+-------+------
    a5cae06b ! 2022-12-05 09:45:00 ! 17m 38s ! www.example.com       ! /home ! tagA 
    34751e52 ! 2022-12-04 16:10:05 ! 17h 52m ! www.example.com       ! /home !      
    f958e789 ! 2022-12-04 16:08:51 ! 17h 53m ! www.example.com       ! /home !      


States
------

* WARN (or CRIT) if the age of the newest snapshot (for each group) is above certain thresholds (default 24h).


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,          Type,       Description                                           
    snapshots,     Number,     Number of snapshots found based on the specified criteria.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
