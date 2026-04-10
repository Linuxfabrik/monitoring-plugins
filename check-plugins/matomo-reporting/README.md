# Check matomo-reporting


## Overview

Retrieves common analytics values from a Matomo instance, including visits, unique visitors, bounce rate, and actions. Supports one or multiple websites and any date range or period.

**Important Notes:**

* Provide the Matomo `token_auth` via `--password`. This token is as secret as your login and password. To view or regenerate it, go to Personal > Security > Auth Tokens in the Matomo UI
* See the [Matomo Reporting API documentation](https://developer.matomo.org/api-reference/reporting-api) for details on available metrics, periods, and date formats

**Data Collection:**

* Queries the Matomo REST API (`API.get` method) using the configured `--idsite`, `--period`, and `--date` parameters
* Without `--metric`, all available metrics are printed and included as perfdata
* With `--metric`, only the specified metrics are printed and optionally checked against warning/critical Nagios ranges


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/matomo-reporting> |
| Nagios/Icinga Check Name              | `check_matomo_reporting` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: matomo-reporting [-h] [-V] [--always-ok] [--date DATE]
                        [--idsite IDSITE] [--insecure] [--metric METRIC]
                        [--no-proxy] [--password PASSWORD] [--period PERIOD]
                        [--timeout TIMEOUT] [-u URL]

Retrieves common analytics values from a Matomo instance, including visits,
unique visitors, bounce rate, and actions. Supports one or multiple websites
and any date range or period.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --date DATE          Matomo REST API date parameter. Example: `last10` or
                       `today`. Default: today
  --idsite IDSITE      Matomo REST API idSite parameter. Example: `1`, `1,4,5`
                       or `all`. Default: 1
  --insecure           This option explicitly allows insecure SSL connections.
  --metric METRIC      Filter the output and optionally check against
                       thresholds or ranges. Format:
                       `metric_name[,warn_range][,crit_range]`. Can be
                       specified multiple times. Example: `--metric
                       nb_visits,100:,50:`. Default: None
  --no-proxy           Do not use a proxy.
  --password PASSWORD  Matomo REST API access token. Default: anonymous
  --period PERIOD      Matomo REST API period parameter. Example: `range` or
                       `day`. Default: day
  --timeout TIMEOUT    Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL        Matomo URL. Default: https://demo.matomo.org
```


## Usage Examples

```bash
./matomo-reporting --url https://demo.matomo.org --password anonymous --idsite 1 --period day --date today
./matomo-reporting --url https://demo.matomo.org --password anonymous --idsite 1 --period day --date today --metric nb_visits
./matomo-reporting --period day --date today --metric sum_total_audio_impressions --metric form_resubmitters_rate,3,5 --metric avg_form_time_spent,,:120 --metric nb_visits,0:10000
./matomo-reporting --url https://demo.matomo.org --password anonymous --idsite 1 --period day --date today --metric avg_page_load_time --metric nb_visits,0:10000
```

Output:

```text
avg_page_load_time: 0.6, nb_visits: 42.0
```


## States

* OK if no `--metric` thresholds are specified, or all metric values are within the given ranges.
* WARN if any metric value is outside the given warning range.
* CRIT if any metric value is outside the given critical range.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Perfdata is returned for the specified `--metric` values only. Without `--metric`, all metrics from the Matomo API response are included. For example:

| Name | Type | Description |
|----|----|----|
| avg_page_load_time | Seconds | Average page load time. |
| avg_time_dom_completion | Seconds | Average DOM completion time. |
| avg_time_dom_processing | Seconds | Average DOM processing time. |
| avg_time_network | Seconds | Average network time. |
| avg_time_on_load | Seconds | Average on-load time. |
| avg_time_on_site | Seconds | Average time on site. |
| avg_time_on_site_new | Seconds | Average time on site for new visitors. |
| avg_time_on_site_returning | Seconds | Average time on site for returning visitors. |
| avg_time_server | Seconds | Average server time. |
| avg_time_transfer | Seconds | Average transfer time. |
| bounce_count | Number | Total bounce count. |
| bounce_rate | Percentage | Bounce rate. |
| bounce_rate_new | Percentage | Bounce rate for new visitors. |
| bounce_rate_returning | Percentage | Bounce rate for returning visitors. |
| conversion_rate | Percentage | Conversion rate. |
| conversion_rate_new_visit | Percentage | Conversion rate for new visits. |
| conversion_rate_returning_visit | Percentage | Conversion rate for returning visits. |
| max_actions | Number | Maximum actions per visit. |
| max_actions_new | Number | Maximum actions per visit for new visitors. |
| max_actions_returning | Number | Maximum actions per visit for returning visitors. |
| nb_actions | Number | Total number of actions. |
| nb_actions_new | Number | Total number of actions for new visitors. |
| nb_actions_per_visit | Number | Average number of actions per visit. |
| nb_actions_per_visit_new | Number | Average number of actions per visit for new visitors. |
| nb_actions_per_visit_returning | Number | Average number of actions per visit for returning visitors. |
| nb_actions_returning | Number | Total number of actions for returning visitors. |
| nb_conversions | Number | Total number of conversions. |
| nb_conversions_new_visit | Number | Total number of conversions for new visits. |
| nb_conversions_returning_visit | Number | Total number of conversions for returning visits. |
| nb_downloads | Number | Total number of downloads. |
| nb_keywords | Number | Total number of keywords. |
| nb_outlinks | Number | Total number of outlinks. |
| nb_pageviews | Number | Total number of pageviews. |
| nb_searches | Number | Total number of searches. |
| nb_uniq_downloads | Number | Total number of unique downloads. |
| nb_uniq_outlinks | Number | Total number of unique outlinks. |
| nb_uniq_pageviews | Number | Total number of unique pageviews. |
| nb_uniq_visitors | Number | Total number of unique visitors. |
| nb_uniq_visitors_new | Number | Total number of unique new visitors. |
| nb_uniq_visitors_returning | Number | Total number of unique returning visitors. |
| nb_users | Number | Total number of users. |
| nb_users_new | Number | Total number of new users. |
| nb_users_returning | Number | Total number of returning users. |
| nb_visits | Number | Total number of visits. |
| nb_visits_converted | Number | Total number of converted visits. |
| nb_visits_converted_new_visit | Number | Total number of converted new visits. |
| nb_visits_converted_returning_visit | Number | Total number of converted returning visits. |
| nb_visits_new | Number | Total number of new visits. |
| nb_visits_returning | Number | Total number of returning visits. |
| PagePerformance_domcompletion_hits | Number | Number of hits with DOM completion data. |
| PagePerformance_domcompletion_time | Seconds | Total DOM completion time. |
| PagePerformance_domprocessing_hits | Number | Number of hits with DOM processing data. |
| PagePerformance_domprocessing_time | Seconds | Total DOM processing time. |
| PagePerformance_network_hits | Number | Number of hits with network data. |
| PagePerformance_network_time | Seconds | Total network time. |
| PagePerformance_onload_hits | Number | Number of hits with on-load data. |
| PagePerformance_onload_time | Seconds | Total on-load time. |
| PagePerformance_pageload_hits | Number | Number of hits with page-load data. |
| PagePerformance_pageload_time | Seconds | Total page-load time. |
| PagePerformance_server_hits | Number | Number of hits with server data. |
| PagePerformance_servery_time | Seconds | Total server time. |
| PagePerformance_transfer_hits | Number | Number of hits with transfer data. |
| PagePerformance_transfer_time | Seconds | Total transfer time. |
| Referrers_distinctCampaigns | Number | Number of distinct campaigns. |
| Referrers_distinctKeywords | Number | Number of distinct keywords. |
| Referrers_distinctSearchEngines | Number | Number of distinct search engines. |
| Referrers_distinctSocialNetworks | Number | Number of distinct social networks. |
| Referrers_distinctWebsites | Number | Number of distinct websites. |
| Referrers_distinctWebsitesUrls | Number | Number of distinct website URLs. |
| Referrers_visitorsFromCampaigns | Number | Visitors from campaigns. |
| Referrers_visitorsFromCampaigns_percent | Percentage | Visitors from campaigns in percent. |
| Referrers_visitorsFromDirectEntry | Number | Visitors from direct entry. |
| Referrers_visitorsFromDirectEntry_percent | Percentage | Visitors from direct entry in percent. |
| Referrers_visitorsFromSearchEngines | Number | Visitors from search engines. |
| Referrers_visitorsFromSearchEngines_percent | Percentage | Visitors from search engines in percent. |
| Referrers_visitorsFromSocialNetworks | Number | Visitors from social networks. |
| Referrers_visitorsFromSocialNetworks_percent | Percentage | Visitors from social networks in percent. |
| Referrers_visitorsFromWebsites | Number | Visitors from websites. |
| Referrers_visitorsFromWebsites_percent | Percentage | Visitors from websites in percent. |
| revenue | Number | Total revenue. |
| revenue_new_visit | Number | Revenue from new visits. |
| revenue_returning_visit | Number | Revenue from returning visits. |
| sum_visit_length | Number | Sum of all visit lengths. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
