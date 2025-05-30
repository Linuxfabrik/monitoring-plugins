Check matomo-reporting
======================

Overview
--------

This plugin lets you check the most common analytics values from Matomo, for one website and for any given date and period.

Use the ``--metric=name[,warn-range][,crit-range]`` parameter to filter the output and to check against thresholds. You have to provide the Matomo ``token_auth`` to the Plugin's ``--password`` parameter. This ``token_auth`` is as secret as your login and password, so do not share it. If you want to view or change this token, please go to Personal > Security > Auth Tokens (there, click on the token to see the full information). For details, have a look at the `Matomo API documentation <https://developer.matomo.org/api-reference/reporting-api>`_.

Run this check as often as needed.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/matomo-reporting"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"


Help
----

.. code-block:: text

    usage: matomo-reporting [-h] [-V] [--always-ok] [--date DATE]
                            [--idsite IDSITE] [--insecure] [--metric METRIC]
                            [--no-proxy] [--password PASSWORD] [--period PERIOD]
                            [--timeout TIMEOUT] [-u URL]

    This plugin lets you check the most common analytics values from Matomo, for
    one or several websites and for any given date and period.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      --date DATE          REST API date, for example "date=last10" or
                           "date="today". Default: today
      --idsite IDSITE      REST API idSite, for example "idsite=1", "idsite=1,4,5"
                           or "idsite=all". Default: 1
      --insecure           This option explicitly allows to perform "insecure" SSL
                           connections. Default: False
      --metric METRIC      Filter the output and optionally check against
                           thresholds or ranges, for example "--metric
                           nb_visits,100:,50:" (repeating, csv, works with
                           ranges). Default: []
      --no-proxy           Do not use a proxy. Default: False
      --password PASSWORD  REST API Access Token. Default: anonymous
      --period PERIOD      REST API period, for example "period=range" or
                           "period=day". Default: day
      --timeout TIMEOUT    Network timeout in seconds. Default: 3 (seconds)
      -u, --url URL        Matomo URL. Default: https://demo.matomo.org


Usage Examples
--------------

.. code-block:: bash

    ./matomo-reporting --url https://demo.matomo.org --password anonymous --idsite 1 --period day --date today
    ./matomo-reporting --url https://demo.matomo.org --password anonymous --idsite 1 --period day --date today --metric nb_visits
    ./matomo-reporting --period day --date today --metric sum_total_audio_impressions --metric form_resubmitters_rate,3,5 --metric avg_form_time_spent,,:120 --metric nb_visits,0:10000 
    ./matomo-reporting --url https://demo.matomo.org --password anonymous --idsite 1 --period day --date today --metric avg_page_load_time --metric nb_visits,0:10000 
    
Output:

.. code-block:: text

    avg_page_load_time: 0.6, nb_visits: 42.0


States
------

* If wanted, always returns OK,
* else returns WARN or CRIT if any of the metrics is in, not in, above or below the given thresholds and ranges.


Perfdata / Metrics
------------------

Perfdata is returned for the given metrics only. For example:

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    avg_page_load_time,                         Seconds,            
    avg_time_dom_completion,                    Seconds,            
    avg_time_dom_processing,                    Seconds,            
    avg_time_network,                           Seconds,            
    avg_time_on_load,                           Seconds,            
    avg_time_on_site,                           Seconds,            
    avg_time_on_site_new,                       Seconds,            
    avg_time_on_site_returning,                 Seconds,            
    avg_time_server,                            Seconds,            
    avg_time_transfer,                          Seconds,            
    bounce_count,                               Number,             
    bounce_rate,                                Number,             
    bounce_rate_new,                            Number,             
    bounce_rate_returning,                      Number,             
    conversion_rate,                            Number,             
    conversion_rate_new_visit,                  Number,             
    conversion_rate_returning_visit,            Number,             
    max_actions,                                Number,             
    max_actions_new,                            Number,             
    max_actions_returning,                      Number,             
    nb_actions,                                 Number,             
    nb_actions_new,                             Number,             
    nb_actions_per_visit,                       Number,             
    nb_actions_per_visit_new,                   Number,             
    nb_actions_per_visit_returning,             Number,             
    nb_actions_returning,                       Number,             
    nb_conversions,                             Number,             
    nb_conversions_new_visit,                   Number,             
    nb_conversions_returning_visit,             Number,             
    nb_downloads,                               Number,             
    nb_keywords,                                Number,             
    nb_outlinks,                                Number,             
    nb_pageviews,                               Number,             
    nb_searches,                                Number,             
    nb_uniq_downloads,                          Number,             
    nb_uniq_outlinks,                           Number,             
    nb_uniq_pageviews,                          Number,             
    nb_uniq_visitors,                           Number,             
    nb_uniq_visitors_new,                       Number,             
    nb_uniq_visitors_returning,                 Number,             
    nb_users,                                   Number,             
    nb_users_new,                               Number,             
    nb_users_returning,                         Number,             
    nb_visits,                                  Number,             
    nb_visits_converted,                        Number,             
    nb_visits_converted_new_visit,              Number,             
    nb_visits_converted_returning_visit,        Number,             
    nb_visits_new,                              Number,             
    nb_visits_returning,                        Number,             
    PagePerformance_domcompletion_hits,         Number,             
    PagePerformance_domcompletion_time,         Seconds,            
    PagePerformance_domprocessing_hits,         Number,             
    PagePerformance_domprocessing_time,         Seconds,            
    PagePerformance_network_hits,               Number,             
    PagePerformance_network_time,               Seconds,            
    PagePerformance_onload_hits,                Number,             
    PagePerformance_onload_time,                Seconds,            
    PagePerformance_pageload_hits,              Number,             
    PagePerformance_pageload_time,              Seconds,            
    PagePerformance_server_hits,                Number,             
    PagePerformance_servery_time,               Seconds,            
    PagePerformance_transfer_hits,              Number,             
    PagePerformance_transfer_time,              Seconds,            
    Referrers_distinctCampaigns,                Number,             
    Referrers_distinctKeywords,                 Number,             
    Referrers_distinctSearchEngines,            Number,             
    Referrers_distinctSocialNetworks,           Number,             
    Referrers_distinctWebsites,                 Number,             
    Referrers_distinctWebsitesUrls,             Number,             
    Referrers_visitorsFromCampaigns,            Number,             
    Referrers_visitorsFromCampaigns_percent,    Percentage,         
    Referrers_visitorsFromDirectEntry,          Number,             
    Referrers_visitorsFromDirectEntry_percent,  Percentage,         
    Referrers_visitorsFromSearchEngines,        Number,             
    Referrers_visitorsFromSearchEngines_percent,Percentage,         
    Referrers_visitorsFromSocialNetworks,       Number,             
    Referrers_visitorsFromSocialNetworks_percent,Percentage,        
    Referrers_visitorsFromWebsites,             Number,             
    Referrers_visitorsFromWebsites_percent,     Percentage,         
    revenue,                                    Number,             
    revenue_new_visit,                          Number,             
    revenue_returning_visit,                    Number,             
    sum_visit_length,                           Number,             


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
