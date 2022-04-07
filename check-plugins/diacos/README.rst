Check diacos
=========================

Overview
--------

This plugin checks for function and performance by doing a login, search and logout against a ID DIACOS® installation.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/diacos"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3"
    "Requirements",                         "https://github.com/Linuxfabrik/lib"


Help
----

.. code-block:: text

    usage: diacos [-h] [--always-ok] [-V] [--protocol {http,https}] [--no-proxy] -H HOSTNAME [-p PORT] [-w WARNING] [-c CRITICAL]
                   [--test TEST] [--timeout TIMEOUT] [--computer COMPUTER] --ip IP --name NAME --licence LICENCE [--country COUNTRY]
                   [--year YEAR] [--format FORMAT] [--sort SORT_MODE] [--concept CONCEPT_FILTER] [--search SEARCHTEXT]

    This plugin does a function check of ID DIACOS® by authenticating and doing a search. (https://www.id-suisse-
    ag.ch/loesungen/abrechnung/id-diacos/)

    optional arguments:
      -h, --help            show this help message and exit
      --always-ok           Always return OK.
      -V, --version         show program's version number and exit
      --protocol {http,https}
                            Protocol. Default: http
      --no-proxy            Do not use a proxy. Default: False
      -H HOSTNAME, --hostname HOSTNAME
                            hostname
      -p PORT, --port PORT  Port
      -w WARNING, --warning WARNING
                            warning in ms
      -c CRITICAL, --critical CRITICAL
                            critical im ms
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 15 (seconds)
      --computer COMPUTER   user.Login argument Computer
      --ip IP               user.Login argument IP
      --name NAME           user.Login argument NAME
      --licence LICENCE     user.Login argument LICENCE
      --country COUNTRY     classification.SearchDiagnoses argument COUNTRY
      --year YEAR           classification.SearchDiagnoses argument YEAR
      --format FORMAT       classification.SearchDiagnoses argument FORMAT
      --sort SORT_MODE      classification.SearchDiagnoses argument SORT_MODE
      --concept CONCEPT_FILTER
                            classification.SearchDiagnoses argument CONCEPT_FILTER
      --search SEARCHTEXT   classification.SearchDiagnoses argument SEARCHTEXT
		

Usage Examples
--------------

.. code-block:: bash

    ./diacos --computer STRING --concept STRING --country CH --critical 9000 --format STRING --hostname SERVERNAME --ip STRING --licence LONGSTRING --name STRING --port 9999 --protocol https --search STRING --sort STRING --timeout 15 --warning 3000 --year 2020

Output:

.. code-block:: text

    [WARNING] executing login, search and logout took 8.013s|'execution_duration'=8013ms;6000;9000;0;15000 'login_duration'=3ms;6000;9000;0;15000 'search_duration'=7678ms;6000;9000;0;15000 'logout_duration'=2ms;6000;9000;0;15000


States
------

* OK if execution duration inside thresholds.
* WARN if exection duration outside warning threshold but inside critical threshold.
* CRIT if exection duration outside critial threshold.
* UNKNOWN if someting with the requests went wrong.
* If wanted, always returns OK.


Perfdata / Metrics
------------------

exectuion_duration, login_duration, search_duration and logout_duration.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_; originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
