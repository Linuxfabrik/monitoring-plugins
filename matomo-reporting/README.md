# Check "matomo-reporting" - Overview

This plugin lets you check the most common analytics values from Matomo, for one website and for any given date and period.

Use the `--metric=name[,warn-range][,crit-range]` parameter to filter the output and to check against thresholds.

You have to provide the Matomo `token_auth` to the Plugin's `--password` parameter. This `token_auth` is as secret as your login and password, so do not share it. If you want to view or change this token, please go to Personal > Settings > API Authentication Token (there, click on the token to see the full information).

For details on the Matomo API, have a look at the [documentation](https://developer.matomo.org/api-reference/reporting-api).

Run this check as often as needed.


# Installation and Usage

```bash
./matomo-reporting
./matomo-reporting --url https://demo.matomo.org --password anonymous --idsite 1 --period day --date today
./matomo-reporting --url https://demo.matomo.org --password anonymous --idsite 1 --period day --date today --metric nb_visits
./matomo-reporting --period day --date today --metric sum_total_audio_impressions --metric form_resubmitters_rate,3,5 --metric avg_form_time_spent,,:120 --metric nb_visits,0:10000 
./matomo-reporting --url https://demo.matomo.org --password anonymous --idsite 1 --period day --date today --metric sum_total_audio_impressions --metric form_resubmitters_rate,3,5 --metric avg_form_time_spent,,:120 --metric nb_visits,0:10000 
```


# States

* If wanted, always returns OK,
* else returns WARN or CRIT if any of the metrics is in, not in, above or below the given thresholds and ranges.


# Perfdata

Perfdata is always returned completely, for example: 

* `avg_form_time_hesitation`
* `avg_form_time_spent`
* `avg_form_time_to_conversion`
* `avg_form_time_to_first_submission`
* `avg_time_generation`
* `avg_time_on_site`
* `avg_time_on_site_new`
* `avg_time_on_site_returning`
* `bounce_count`
* `bounce_rate`
* `bounce_rate_new`
* `bounce_rate_returning`
* `conversion_rate`
* `conversion_rate_new_visit`
* `conversion_rate_returning_visit`
* `finish_rate`
* `form_conversion_rate`
* `form_resubmitters_rate`
* `form_starters_rate`
* `form_submitter_rate`
* `impression_rate`
* `max_actions`
* `max_actions_new`
* `max_actions_returning`
* `nb_actions`
* `nb_actions_new`
* `nb_actions_per_visit`
* `nb_actions_per_visit_new`
* `nb_actions_per_visit_returning`
* `nb_actions_returning`
* `nb_conversions`
* `nb_conversions_new_visit`
* `nb_conversions_returning_visit`
* `nb_downloads`
* `nb_finishes`
* `nb_form_conversions`
* `nb_form_resubmitters`
* `nb_form_starters`
* `nb_form_starts`
* `nb_form_submissions`
* `nb_form_submitters`
* `nb_form_viewers`
* `nb_form_views`
* `nb_hits_with_time_generation`
* `nb_impressions`
* `nb_keywords`
* `nb_outlinks`
* `nb_pageviews`
* `nb_plays`
* `nb_searches`
* `nb_uniq_downloads`
* `nb_uniq_outlinks`
* `nb_uniq_pageviews`
* `nb_uniq_visitors`
* `nb_uniq_visitors_new`
* `nb_uniq_visitors_returning`
* `nb_unique_visitors_impressions`
* `nb_unique_visitors_plays`
* `nb_users`
* `nb_users_new`
* `nb_users_returning`
* `nb_visits`
* `nb_visits_converted`
* `nb_visits_converted_new_visit`
* `nb_visits_converted_returning_visit`
* `nb_visits_new`
* `nb_visits_returning`
* `play_rate`
* `Referrers_distinctCampaigns`
* `Referrers_distinctKeywords`
* `Referrers_distinctSearchEngines`
* `Referrers_distinctSocialNetworks`
* `Referrers_distinctWebsites`
* `Referrers_distinctWebsitesUrls`
* `Referrers_visitorsFromCampaigns`
* `Referrers_visitorsFromCampaigns_percent`
* `Referrers_visitorsFromDirectEntry`
* `Referrers_visitorsFromDirectEntry_percent`
* `Referrers_visitorsFromSearchEngines`
* `Referrers_visitorsFromSearchEngines_percent`
* `Referrers_visitorsFromSocialNetworks`
* `Referrers_visitorsFromSocialNetworks_percent`
* `Referrers_visitorsFromWebsites`
* `Referrers_visitorsFromWebsites_percent`
* `revenue`
* `revenue_new_visit`
* `revenue_returning_visit`
* `sum_total_audio_impressions`
* `sum_total_audio_plays`
* `sum_total_time_watched`
* `sum_total_video_impressions`
* `sum_total_video_plays`
* `sum_visit_length`


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
