Check csv-values
================

Overview
--------

This check imports a CSV file into a local `SQLite database <https://www.sqlite.org>`_ into a table named ``data``, and can then run a separate warning and/or critical query on it. The result - the number of items found or a specific number, depending on the query - can be checked against a `range expression <https://github.com/Linuxfabrik/monitoring-plugins#threshold-and-ranges>`_.

This monitoring plugin works for all conceivable kinds of CSV files. Large CSV files are handled with care by breaking the data into chunks. CSV files can be retrieved from the file system, from an SMB path or from a URL, both supporting authentication.

As an example, consider a simple CSV list of clients:

.. code-block:: text

    PC-Hostname, Waiting Updates
    alice,        3
    bob,         11
    charlie,      5
    david,        7
    erin,         0
    frank,        6

The use case: Issue a warning when the number of clients with 5 or more waiting updates is greater than 2.

First you need to tell ``csv-values`` the structure/data types of your CSV file like in the SQLite ``CREATE TABLE`` format. Important: The names of the the columns in the CSV file don't matter, you simply define names for the columns in the SQLite database. ``csv-values`` simply goes through the CSV file column by column and creates the columns specified here in the SQLite database. The names specified are therefore only important for the subsequent SQL queries.

.. code-block:: text

    Hostname TEXT, WaitingUpdates INTEGER

Useful column `datatypes in SQLite <https://www.sqlite.org/datatype3.html>`_ are:

* ``TEXT``
* ``NUMERIC``
* ``INTEGER``
* ``REAL``

The ``data`` table created by the import has no ``PRIMARY KEY`` and no constraints of any kind. The default value of each column is ``NULL``. The default collation sequence for each column of the new table is ``BINARY``. 

One possible SQL statement for getting the number of clients with 5 or more waiting updates is:

.. code-block:: text

    select *
    from data
    where WaitingUpdates >= 5

In the above example, 4 *rows* are returned, so ``csv-values`` checks the number of rows against the given threshold.

You also may count the number of clients directly, which just returns one row with a value of ``4`` in one column:

.. code-block:: text

    select count(*) as cnt
    from data
    where WaitingUpdates >= 5

In this case, ``csv-values`` checks the returned value ``4`` with the specified threshold.

The full command line call describing the columns, retrieving the data and applying the thresholds (which are `ranges <https://github.com/Linuxfabrik/monitoring-plugins#threshold-and-ranges>`_) is:

.. code-block:: bash

    csv-values \
        --filename path/to/hosts-with-waiting-updates.csv \
        --columns-query='Hostname TEXT, WaitingUpdates INTEGER' \
        --warning-query='select * from data where WaitingUpdates >= 5' \
        --warning=2

Helpful resources:

* SQLite Tutorial: https://www.sqlitetutorial.net
* SQLite Documentation: https://www.sqlite.org/doclist.html


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/json-values"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python modules ``PySmbClient``, ``smbprotocol``"


Help
----

.. code-block:: text

    usage: csv-values [-h] [-V] [--always-ok] [--chunksize CHUNKSIZE]
                      --columns-query COLUMNS_QUERY [-c CRIT]
                      [--critical-query CRITICAL_QUERY] [--delimiter DELIMITER]
                      [--filename FILENAME] [--insecure] [--newline NEWLINE]
                      [--no-proxy] [--password PASSWORD] [--quotechar QUOTECHAR]
                      [--skip-header] [--test TEST] [--timeout TIMEOUT] [-u URL]
                      [--username USERNAME] [-w WARN]
                      [--warning-query WARNING_QUERY]

    This check imports a CSV file into an SQLite database and can then run a
    separate warning query and/or a critical query against it. The result - the
    number of items found or a specific number - can be checked against a range
    expression.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --chunksize CHUNKSIZE
                            Breaks up the transfer of data from the csv to the
                            SQLite database in chunks as to not run out of memory.
                            Default: 1000
      --columns-query COLUMNS_QUERY
                            Describe the columns and their datatypes using an sql
                            statement. Example: `"col1 INTEGER PRIMARY KEY, col2
                            TEXT NOT NULL, col3 TEXT NOT NULL UNIQUE"`
      -c CRIT, --critical CRIT
                            Set the CRIT threshold. Supports ranges. Default:
                            "None"
      --critical-query CRITICAL_QUERY
                            `SELECT` statement. If its result contains more than
                            one column, the number of rows is checked against
                            `--critical`, otherwise the single value is used.
                            Default: "None"
      --delimiter DELIMITER
                            CSV delimiter. Default: `","`
      --filename FILENAME   Path to CSV file. This is mutually exclusive with -u /
                            --url.
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --newline NEWLINE     CSV newline. When reading input from the CSV, if
                            newline is `None`, universal newlines mode is enabled.
                            Lines in the input can end in `" "`, `" "`, or `" "`,
                            and these are translated into `" "` before being
                            returned to this plugin. If it is `""`, universal
                            newlines mode is enabled, but line endings are
                            returned to this plugin untranslated. If it has any of
                            the other legal values, input lines are only
                            terminated by the given string, and the line ending is
                            returned to this plugin untranslated. Default: None
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   SMB or HTTP Basic Auth Password.
      --quotechar QUOTECHAR
                            CSV quotechar. Default: `"`
      --skip-header         Treat the first row as header names. Default: True
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -u URL, --url URL     Set the url of the CSV file, either starting with
                            "http://", "https://" or "smb://". This is mutually
                            exclusive with --filename.
      --username USERNAME   SMB or HTTP Basic Auth Username.
      -w WARN, --warning WARN
                            Set the WARN threshold. Supports ranges. Default:
                            "None"
      --warning-query WARNING_QUERY
                            `SELECT` statement. If its result contains more than
                            one column, the number of rows is checked against
                            `--warning`, otherwise the single value is used.
                            Default: "None"


Usage Examples
--------------

Local CSV file (example):

.. code-block:: bash

    cat > /tmp/example.csv << 'EOF'
    Date,Network,Hostname,WaitingUpdates
    2023-01-01,A,alice,0
    2023-01-01,A,bob,1
    2023-01-01,A,charlie,2
    2023-01-01,A,david,3
    2023-01-01,A,erin,4
    2023-01-01,A,faythe,5
    2023-01-01,A,frank,6
    2023-01-01,A,grace,7
    2023-01-01,A,heidi,8
    2023-01-01,A,ivan,9
    2023-01-01,A,judy,10
    2023-01-01,B,mallory,0
    2023-01-01,B,michael,1
    2023-01-01,B,niaj,2
    2023-01-01,B,olivia,3
    2023-01-01,B,oscar,4
    2023-01-01,B,peggy,5
    2023-01-01,B,rupert,6
    2023-01-01,B,sybil,7
    2023-01-01,C,trent,0
    2023-01-01,C,trudy,1
    2023-01-01,C,victor,2
    2023-01-01,C,walter,3
    2023-01-01,C,wendy,4
    EOF

Checking this local CSV file: WARN if more than 6 hosts in network A have more than 3 waiting updates, and CRIT if more than 2 hosts in networks B and C have more than 4 waiting updates:

.. code-block:: bash

    ./csv-values \
        --filename=tmp/example.csv \
        --columns-query='date TEXT, network TEXT, hostname TEXT, waitingupdates INTEGER' \
        --warning-query='select * from data where network = "A" and WaitingUpdates > 3' \
        --warning=6 \
        --critical-query='select * from data where network <> "A" and WaitingUpdates > 4' \
        --critical=2

Output:

.. code-block:: text

    7 results from warning query `select * from data where network = "A" and WaitingUpdates > 3` [WARNING] and 3 results from critical query `select * from data where network <> "A" and WaitingUpdates > 4` [CRITICAL]

    date       ! network ! hostname ! waitingupdates 
    -----------+---------+----------+----------------
    2023-01-01 ! A       ! erin     ! 4              
    2023-01-01 ! A       ! faythe   ! 5              
    2023-01-01 ! A       ! frank    ! 6              
    2023-01-01 ! A       ! grace    ! 7              
    2023-01-01 ! A       ! heidi    ! 8              
    2023-01-01 ! A       ! ivan     ! 9              
    2023-01-01 ! A       ! judy     ! 10             

    date       ! network ! hostname ! waitingupdates 
    -----------+---------+----------+----------------
    2023-01-01 ! B       ! peggy    ! 5              
    2023-01-01 ! B       ! rupert   ! 6              
    2023-01-01 ! B       ! sybil    ! 7

Checking a remote CSV file on a webserver, plus HTTP basic authentication:

.. code-block:: bash

    ./csv-values \
        --url=http://example.com/example.csv \
        --username=user \
        --password=linuxfabrik
        ...

Checking a remote CSV file on a (not-mounted) samba/cifs share, plus authentication:

.. code-block:: bash

    ./csv-values \
        --url=smb://example.com/share/example.csv \
        --username=user \
        --password=linuxfabrik
        ...


States
------

* WARN if number of rows or single value of ``--warning-query`` is outside ``--warning`` range
* CRIT if number of rows or single value of ``--critical-query`` is outside ``--critical`` range
* Otherwise OK


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    cnt_warn,                                   Number,             Number of rows or single value of ``--warning-query``
    cnt_crit,                                   Number,             Number of rows or single value of ``--critical-query``


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
