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
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: matomo-reporting [-h] [-V] [--always-ok] [--date DATE]
                            [--idsite IDSITE] [--insecure] [--metric METRIC]
                            [--no-proxy] [--password PASSWORD] [--period PERIOD]
                            [--timeout TIMEOUT] [-u URL]

    This plugin lets you check the most common analytics values from Matomo, for
    one or several websites and for any given date and period.

    optional arguments:
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
      -u URL, --url URL    Matomo URL. Default: https://demo.matomo.org


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

Perfdata is always returned completely, for example: 

* avg_page_load_time
* avg_time_dom_completion
* avg_time_dom_processing
* avg_time_network
* avg_time_on_load
* avg_time_on_site
* avg_time_on_site_new
* avg_time_on_site_returning
* avg_time_server
* avg_time_transfer
* bounce_count
* bounce_rate
* bounce_rate_new
* bounce_rate_returning
* conversion_rate
* conversion_rate_new_visit
* conversion_rate_returning_visit
* max_actions
* max_actions_new
* max_actions_returning
* nb_actions
* nb_actions_new
* nb_actions_per_visit
* nb_actions_per_visit_new
* nb_actions_per_visit_returning
* nb_actions_returning
* nb_conversions
* nb_conversions_new_visit
* nb_conversions_returning_visit
* nb_downloads
* nb_keywords
* nb_outlinks
* nb_pageviews
* nb_searches
* nb_uniq_downloads
* nb_uniq_outlinks
* nb_uniq_pageviews
* nb_uniq_visitors
* nb_uniq_visitors_new
* nb_uniq_visitors_returning
* nb_users
* nb_users_new
* nb_users_returning
* nb_visits
* nb_visits_converted
* nb_visits_converted_new_visit
* nb_visits_converted_returning_visit
* nb_visits_new
* nb_visits_returning
* PagePerformance_domcompletion_hits
* PagePerformance_domcompletion_time
* PagePerformance_domprocessing_hits
* PagePerformance_domprocessing_time
* PagePerformance_network_hits
* PagePerformance_network_time
* PagePerformance_onload_hits
* PagePerformance_onload_time
* PagePerformance_pageload_hits
* PagePerformance_pageload_time
* PagePerformance_server_hits
* PagePerformance_servery_time
* PagePerformance_transfer_hits
* PagePerformance_transfer_time
* Referrers_distinctCampaigns
* Referrers_distinctKeywords
* Referrers_distinctSearchEngines
* Referrers_distinctSocialNetworks
* Referrers_distinctWebsites
* Referrers_distinctWebsitesUrls
* Referrers_visitorsFromCampaigns
* Referrers_visitorsFromCampaigns_percent
* Referrers_visitorsFromDirectEntry
* Referrers_visitorsFromDirectEntry_percent
* Referrers_visitorsFromSearchEngines
* Referrers_visitorsFromSearchEngines_percent
* Referrers_visitorsFromSocialNetworks
* Referrers_visitorsFromSocialNetworks_percent
* Referrers_visitorsFromWebsites
* Referrers_visitorsFromWebsites_percent
* revenue
* revenue_new_visit
* revenue_returning_visit
* sum_visit_length


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
