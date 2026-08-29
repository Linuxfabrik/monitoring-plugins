Check avelon-tickets
====================

Overview
--------

Check if there are any pending tickets (alarms) on the Avelon Cloud and whether they are still open, acknowledged, or closed.

What is the Avelon Cloud?
Avelon's products and services have been used in professional building operations for over 20 years. From commercial and industrial buildings to office buildings, airports, and railway facilities. The Avelon Cloud propels buildings into a professional era. Avelon takes care of security and maintenance throughout the entire usage period. With Avelon Cloud, operations become cheaper and more professional.

Notes:

To use this monitoring plugin, you need to have a REST API license from Avelon.
If you already have a license, log in to Avelon and click on Settings in the user menu at the top right. On the General tab, you will see a section called Public OAuth API Key. The Client ID and Client Secret displayed there are required to authenticate with our API (Monitoring-Plugin).

Links:

* `Avelon <https://avelon.com>`_
* `Avelon Cloud Platform <https://avelon.cloud>`_
* `Avelon Documentation <https://avelon.cloud/docs>`_
* `API Documentation <https://avelon.cloud/swagger/swagger-ui/index.html?urls.primaryName=Public%20API#>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/avelon-tickets"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: avelon-tickets [-h] [-V] [--always-ok] --client-id CLIENT_ID --client-secret CLIENT_SECRET [--closed-ticket]
                          [-c [{ACKNOWLEDGED,ACKNOWLEDGED_AND_GONE,GONE,OPEN} ...]] [--insecure] [--no-proxy] --password PASSWORD --username
                          USERNAME [--test TEST] [--timeout TIMEOUT] [-w [{ACKNOWLEDGED,ACKNOWLEDGED_AND_GONE,GONE,OPEN} ...]]

    The current tickets (alerts) of your Avelon Cloud are being reviewed, and depending on their status, critical alerts or warnings can be        
    triggered. You need a license to access the public API of the Avelon Cloud.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --client-id CLIENT_ID
                            Avelon API client_id.
      --client-secret CLIENT_SECRET
                            Avelon API client_secret.
      --closed-ticket       The option allows viewing the closed alarms as well. Default: False
      -c [{ACKNOWLEDGED,ACKNOWLEDGED_AND_GONE,GONE,OPEN} ...], --critical [{ACKNOWLEDGED,ACKNOWLEDGED_AND_GONE,GONE,OPEN} ...]
                            Set the CRIT threshold as a status of the ticket (alarm). Default: >= []
      --insecure            This option explicitly allows to perform "insecure" SSL connections. Default: False
      --no-proxy            Do not use a proxy.Default: False
      --password PASSWORD   Avelon Cloud password.
      --username USERNAME   Avelon Cloud username.
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
      -w [{ACKNOWLEDGED,ACKNOWLEDGED_AND_GONE,GONE,OPEN} ...], --warning [{ACKNOWLEDGED,ACKNOWLEDGED_AND_GONE,GONE,OPEN} ...]
                            Set the WARN threshold as a status of the ticket (alarm). Default: >= ['ACKNOWLEDGED', 'ACKNOWLEDGED_AND_GONE',        
                            'GONE', 'OPEN']


Usage Examples
--------------

.. code-block:: bash

    ./avelon-tickets --client-id CLIENT_ID --client-secret CLIENT_SECRET --username USER --password PASSWORD --critical ACKNOWLEDGED OPEN

Output:

.. code-block:: text

    There are CRITICAL alarm ticket(s).

    ID       ! Timestamp                        ! Message                                                     ! State
    ---------+----------------------------------+-------------------------------------------------------------+-------------------------
    13927572 ! 2024-06-18 19:46:56 (5D 14h ago) ! Abschaltend: 6102/5/22: Durchfluss Notkühlung FQ201 Störung ! OPEN [CRITICAL]
    13927573 ! 2024-06-18 19:46:56 (5D 14h ago) ! Störung: 6102/5/0: Anlage Zustand Störung                   ! ACKNOWLEDGED [CRITICAL]


States
------

* WARN or CRIT if a ticket (alarm) status matches the defined values (ACKNOWLEDGED, ACKNOWLEDGED_AND_GONE, GONE and OPEN).


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
