Check statuspal
===============

Overview
--------

Statuspal is a status page provider from Germany. This check plugin gets the summary of a Statuspal status page, checks its status, services, active incidents and lists maintenances. You need to provide the URL to the Statuspal API ``summary`` endpoint.

Hints:

* Website: https://www.statuspal.io/
* API Documentation: https://www.statuspal.io/api-docs/v2

List of public Statuspal sites - Europe:

* https://statuspal.eu/api/v2/status_pages/a/summary
* https://statuspal.eu/api/v2/status_pages/exoscalestatus/summary
* https://statuspal.eu/api/v2/status_pages/oneid/summary
* https://statuspal.eu/api/v2/status_pages/rasannnt/summary
* https://statuspal.eu/api/v2/status_pages/rmdit/summary
* https://statuspal.eu/api/v2/status_pages/seppmail/summary

List of public Statuspal sites - USA:

* https://statuspal.io/api/v2/status_pages/2factor/summary
* https://statuspal.io/api/v2/status_pages/activityinfo/summary
* https://statuspal.io/api/v2/status_pages/ae/summary
* https://statuspal.io/api/v2/status_pages/aeratechnology/summary
* https://statuspal.io/api/v2/status_pages/alchemix/summary
* https://statuspal.io/api/v2/status_pages/aleeva/summary
* https://statuspal.io/api/v2/status_pages/amestoapps/summary
* https://statuspal.io/api/v2/status_pages/animaker/summary
* https://statuspal.io/api/v2/status_pages/anycloud/summary
* https://statuspal.io/api/v2/status_pages/aplaut/summary
* https://statuspal.io/api/v2/status_pages/aplaut/summary
* https://statuspal.io/api/v2/status_pages/arvancloud/summary
* https://statuspal.io/api/v2/status_pages/arvancloud/summary
* https://statuspal.io/api/v2/status_pages/as134220/summary
* https://statuspal.io/api/v2/status_pages/ascentlogistics/summary
* https://statuspal.io/api/v2/status_pages/avakin/summary
* https://statuspal.io/api/v2/status_pages/cloudcone/summary
* https://statuspal.io/api/v2/status_pages/edudip/summary
* https://statuspal.io/api/v2/status_pages/elkir/summary
* https://statuspal.io/api/v2/status_pages/emango/summary
* https://statuspal.io/api/v2/status_pages/everynet/summary
* https://statuspal.io/api/v2/status_pages/finqu/summary
* https://statuspal.io/api/v2/status_pages/hosttech/summary
* https://statuspal.io/api/v2/status_pages/maslak/summary


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/statuspal"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``flatdict``"


Help
----

.. code-block:: text

    usage: statuspal [-h] [-V] [--always-ok] [--test TEST] [--url URL]

    Statuspal is a status page provider from Germany. This check plugin gets the
    summary of a Statuspal status page, checks its status, services, active
    incidents and lists maintenances. You need to provide the URL to the Statuspal
    API `summary` endpoint.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --test TEST    For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                     file,expected-retc".
      --url URL      Statuspal API URL. Default: https://statuspal.eu/api/v2/statu
                     s_pages/exoscalestatus/summary


Usage statuspals
----------------

.. code-block:: bash

    ./statuspal --url=https://statuspal.eu/api/v2/status_pages/exoscalestatus/summary

Output:

.. code-block:: text

    All systems operational @ Exoscale (exoscale.com, TZ Europe/Zurich)

    Service                            ! State 
    -----------------------------------+-------
    Global.DNS                         ! [OK]  
    Global.Portal                      ! [OK]  
    CH-GVA-2                           ! [OK]  
    CH-GVA-2.API                       ! [OK]  
    CH-GVA-2.Compute                   ! [OK]  
    BG-SOF-1.Object Storage SOS        ! [OK]  

    Upcoming Maintenance                                ! Type      ! Start               ! End      
    ----------------------------------------------------+-----------+---------------------+----------
    Core Network Architecture - Internal routing update ! scheduled ! 2023-09-20 07:00:00 ! open end


.. code-block:: bash

    ./statuspal --url=https://statuspal.io/api/v2/status_pages/ascentlogistics/summary

Output:

.. code-block:: text

    Major incidents @ Ascent Global Logistics (ascentlogistics.com, TZ America/Detroit): Service PEAK - Customer API  Production seems to be down / According to our monitoring system this service has become unresponsive, we're investigating. (2022-04-20 18:27:16)

    Service                               ! State      
    --------------------------------------+------------
    Ascent Websites.Main Ascent Website   ! [OK]       
    PEAK.PEAK - Customer API  Integration ! [CRITICAL] 
    PEAK.PEAK - Customer API  Production  ! [CRITICAL] 
    Global IT Monitoring                  ! [CRITICAL]


States
------

* WARN if minor incidents are found.
* CRIT if major incidents are found.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
