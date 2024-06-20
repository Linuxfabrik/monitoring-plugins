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
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: avelon-tickets   [-h] [-V] [--always-ok] [--client-id] [--client-secret]
                            [--username] [--password] [--no-closed-ticket]
                            [--verify] [--proxies] [--timeout] [--test]

    The current tickets (alerts) of your Avelon Cloud are being reviewed, and depending on their status, critical alerts or warnings can be triggered. You    
    need a license to access the public API of the Avelon Cloud.

    options:
  		-h, --help            show this help message and exit
  		-V, --version         show program's version number and exit
  		--always-ok           Always returns OK.
  		--client-id 					Avelon API client_id.
  		--client-secret				Avelon API client_secret.
  		--username    				Avelon Cloud username.
  		--password    				Avelon Cloud password.
  		--no-closed-ticket 		The option allows viewing the closed alarms as well. Default: True
  		--verify        			This option explicitly allows to perform "insecure" SSL connections. Default: True
  		--proxies             This option allows you to set specific proxies. For no proxy: {"http": None, "https": None}. Default: {} (System Proxy)
  		--timeout      				Network timeout in seconds. Default: 8 (seconds)
  		--test            		For unit tests. Needs "path-to-stdout-file,path-to-stderr-file,expected-retc".


Usage Examples
--------------

.. code-block:: bash
		./avelon-tickets --client-id "CLIENT_ID" --client-secret "CLIENT_SECRET" --username "USER" --password "PASSWORD" --no-closed-ticket "False"

Output:

.. code-block:: text

    There are open alarm ticket(s).

		ID       ! Timestamp                     ! Type  ! Message                                                                 ! Status       ! State      
		---------+-------------------------------+-------+-------------------------------------------------------------------------+--------------+------------
		13910313 ! 2024-06-13T07:43:53.000+02:00 ! ALARM ! ALARM: Abschaltend: 6102/5/33: Differenzdruck DP101 zu tief             ! CLOSED       !
		13910314 ! 2024-06-13T07:43:54.000+02:00 ! ALARM ! ALARM: Störung: 6102/5/0: Anlage Zustand Störung                        ! CLOSED       !
		13911337 ! 2024-06-13T13:40:39.000+02:00 ! ALARM ! ALARM: Störung: 6102/5/5: Vorlauftemperatur TT201 zu tief -> Notkühlung ! CLOSED       !
		13912010 ! 2024-06-13T17:37:13.000+02:00 ! ALARM ! ALARM: Störung: 6102/0/6: Vorlauftemperatur TT201                       ! CLOSED       !
		13915922 ! 2024-06-14T23:58:36.000+02:00 ! ALARM ! ALARM: Störung: 6102/5/5: Vorlauftemperatur TT201 zu tief -> Notkühlung ! CLOSED       !
		13915923 ! 2024-06-14T23:58:36.000+02:00 ! ALARM ! ALARM: Störung: 6102/5/0: Anlage Zustand Störung                        ! CLOSED       !
		13916766 ! 2024-06-15T07:19:26.000+02:00 ! ALARM ! ALARM: Störung: 6102/0/6: Vorlauftemperatur TT201                       ! CLOSED       !
		13927572 ! 2024-06-18T19:46:56.000+02:00 ! ALARM ! ALARM: Abschaltend: 6102/5/22: Durchfluss Notkühlung FQ201 Störung      ! OPEN         ! [CRITICAL]    
		13927573 ! 2024-06-18T19:46:56.000+02:00 ! ALARM ! ALARM: Störung: 6102/5/0: Anlage Zustand Störung                        ! ACKNOWLEDGED ! [WARNING]  


States
------

Needs to be added.


Perfdata / Metrics
------------------

Needs to be added.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
