Check diacos
============

Overview
--------

This plugin checks availability and performance of an `ID DIACOS® installation <(https://www.id-suisse-ag.ch/loesungen/abrechnung/id-diacos/>`_ by doing a login, search and logout.

From the manufacturer:

    ID DIACOS® is synonymous with accurate and fast invoicing in hospitals. The coding software allows clinical services to be documented quickly and reliably. ID DIACOS® offers functions that allow fees to be determined directly within the respective fee-payment systems, e.g., G-DRG, SWISS-DRG, EBM, etc., while ensuring full compliance with statutory requirements. The coding quality is optimized through bi-directional integration with hospital information systems. `Source <https://www.id-berlin.de/en/products/codierung/id-diacos/>`_

Plugin execution may take more than 10 seconds.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/diacos"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: diacos [-h] [-V] [--always-ok] [-c CRITICAL]
                  [--login-computer COMPUTER] [--login-ip IP] --login-licence
                  LICENCE --login-name NAME [--no-proxy]
                  [--search-concept-filter CONCEPT_FILTER]
                  [--search-country COUNTRY] [--search-format FORMAT]
                  [--search-searchtext SEARCHTEXT] [--search-sort-mode SORT_MODE]
                  [--search-year YEAR] [--test TEST] [--timeout TIMEOUT]
                  [--url URL] [-w WARNING]

    This plugin checks availability and performance of an ID DIACOS® installation
    by doing a login, search and logout. (https://www.id-suisse-
    ag.ch/loesungen/abrechnung/id-diacos/)

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always return OK.
      -c CRITICAL, --critical CRITICAL
                            Critical threshold for duration of
                            login+search+logout. Default: 6000 (ms)
      --login-computer COMPUTER
                            user.Login argument COMPUTER. Default: Brower_APP
      --login-ip IP         user.Login argument IP. Default: 127.0.0.1
      --login-licence LICENCE
                            user.Login argument LICENCE (required)
      --login-name NAME     user.Login argument NAME (required)
      --no-proxy            Do not use a proxy. Default: False
      --search-concept-filter CONCEPT_FILTER
                            classification.SearchDiagnoses argument
                            CONCEPT_FILTER. Default: %25R239%3BC%3BD99.99
      --search-country COUNTRY
                            classification.SearchDiagnoses argument COUNTRY.
                            Default: CH
      --search-format FORMAT
                            classification.SearchDiagnoses argument FORMAT.
                            Default: %25T0%25C%3F%25I%25R
      --search-searchtext SEARCHTEXT
                            classification.SearchDiagnoses argument SEARCHTEXT.
                            Default: Haut
      --search-sort-mode SORT_MODE
                            classification.SearchDiagnoses argument SORT_MODE.
                            Default: %25T
      --search-year YEAR    classification.SearchDiagnoses argument YEAR. Default:
                            2020
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 7 (seconds)
      --url URL             ID DIACOS URL. Default: http://localhost:9999
      -w WARNING, --warning WARNING
                            Warning threshold for duration of login+search+logout.
                            Default: 3000 (ms)


Usage Examples
--------------

.. code-block:: bash

    ./diacos \
        --critical 6000 \
        --login-computer Brower_APP \
        --login-ip 127.0.0.1 \
        --login-licence 4b903485-1def-4f1b-a4d5-dd5464176954 \
        --login-name supervisor \
        --search-concept-filter '%25R239%3BC%3BD99.99' \
        --search-country 'CH' \
        --search-format '%25T0%25C%3F%25I%25R' \
        --search-searchtext Haut \
        --search-sort-mode '%25T' \
        --search-year 2020 \
        --timeout 7 \
        --url http://localhost:9999
        --warning 3000

Output:

.. code-block:: text

    7368ms for login, search and logout [CRITICAL]


States
------

* WARN or CRIT if total runtime of login, search and logout is greater than or equal to the given thresholds.
* If wanted, always returns OK.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    runtime,                                    Milliseconds,       "Total runtime of login, search and logout"
    login_duration,                             Milliseconds,       Duration of the login operation
    search_duration,                            Milliseconds,       Duration of the search operation
    logout_duration,                            Milliseconds,       Duration of the logout operation


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_; originally written by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
