# Check nextcloud-enterprise

## Overview

Monitors an installed Nextcloud Enterprise subscription and the number of accounts it has to cover, reporting license level, expiration date, per-feature subscriptions and the account breakdown by backend. Alerts when the subscription has expired, when its data has gone stale because nothing refreshes it any more, when the account count exceeds the licensed amount or a locally configured account limit, and when it crosses the thresholds on an instance that carries no limit of its own. A grace period holds back the account-count alerts, so a directory synchronisation that briefly overshoots stays quiet. Requires root or sudo.

**Important Notes:**

* Runs on every Nextcloud instance, with or without a subscription. Without one it reports the account count alone, which is what the thresholds are for.
* The account count the subscription is measured against is the number of accounts that exist minus the disabled ones. Only where the subscription was sold on active accounts is the number of accounts that have logged in at least once used instead. Both figures are always reported.
* Two different limits can apply at the same time, and only one of them is this instance's own. The licensed amount belongs to the subscription, and a subscription can be spread over several instances that all carry the same key and all read the same figure, so it is reported as the total it is and never as this instance's headroom. The locally configured limit is the per-instance bound, and it stops new accounts from being created as soon as the count reaches it, one account earlier than the licensed amount does
* The locally configured limit is enforced by the `support` app, which Nextcloud asks before it creates an account, before it re-enables a disabled one, and before it maps a new directory user. While that app is disabled, or while the stored subscription has passed its end date, the limit sits in the configuration without any effect, and the check says so rather than claiming that accounts are being refused
* Those three are the only places that ask. A backend that provisions accounts on its own, SAML for example, writes them straight into its own table and is never held to the limit, so an instance can carry far more accounts than its limit allows while local account creation is refused at the same time. The limit is not a cap on the account count, it is a gate on three specific paths
* A directory user that cannot be mapped because the limit is reached is skipped silently on the ordinary paths, and only the provisioning API reports an error. Where accounts stop appearing from a directory without anything being logged, the limit is the first thing to check
* Where the subscription is shared, set `--warning` to the share this instance is meant to carry. The check cannot see its sibling instances, so the pool can be exhausted while every single instance still reports OK
* The subscription figures come from the answer the `support` app stores locally. That answer survives the app being disabled, so an instance can keep reporting a subscription that nobody refreshes any more. Once it is older than two days the check alerts on that and stops drawing conclusions from it: a subscription renewed since would look expired here, and one that lapsed would look valid until the stored date passes. The output then dates the figures instead of presenting them as current, and the subscription contributes no performance data
* An installed Enterprise build is reported next to a stale record, because it says the instance is being kept on the Enterprise track. It is not read as proof that the subscription still runs: the customer download channel has been observed serving a key whose stored record said the subscription had ended years earlier, and nothing on the host tells a renewal that was never recorded from a channel that was never revoked. Only a refreshed record settles that

**Data Collection:**

* Requires sudo permissions for the UID under which the Nextcloud application runs
* Reads `version.php` of the installation directly, which costs no Nextcloud process, for the Enterprise marker and the build date
* Reads the subscription data and the account counts through two Nextcloud `occ` commands. Each one pays for a full application bootstrap, which is what the check spends nearly all of its runtime on, so both read everything they are asked for in one go
* Keeps a local SQLite database to remember since when the account count has been above its limit, which is what `--grace-wait` ages

## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-enterprise> |
| Nagios/Icinga Check Name              | `check_nextcloud_enterprise` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | User with higher permissions |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-nextcloud-enterprise.db` |

## Help

```text
usage: nextcloud-enterprise [-h] [-V] [--always-ok] [-c CRIT]
                            [--grace-wait GRACE_WAIT] [--no-perfdata]
                            [--path PATH] [--timeout TIMEOUT] [-w WARN]

Monitors an installed Nextcloud Enterprise subscription and the number of
accounts it has to cover, reporting license level, expiration date,
per-feature subscriptions and the account breakdown by backend. Alerts when
the subscription has expired, when its data has gone stale because nothing
refreshes it any more, when the account count exceeds the licensed amount or a
locally configured account limit, and when it crosses the thresholds on an
instance that carries no limit of its own. A grace period holds back the
account-count alerts, so a directory synchronisation that briefly overshoots
stays quiet. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the number of accounts the
                        subscription has to cover. Supports Nagios ranges.
                        Evaluated whenever it is given. When omitted, it is
                        evaluated only on an instance that declares no account
                        limit of its own, because a declared limit is compared
                        against the account count anyway. Default: empty, no
                        CRIT threshold
  --grace-wait GRACE_WAIT
                        How long an account count above its limit is tolerated
                        before it counts towards the state. Set this to cover
                        the time a directory synchronisation needs to settle,
                        so an import that briefly overshoots stays quiet until
                        it has had its chance. Starts when the count first
                        goes over and starts over once it is back within the
                        limit. A duration such as `12h`, `8D` or `2W`; `0D`
                        disables the grace period. Default: 0D
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --path PATH           Local path to the Nextcloud installation, typically
                        the web server document root. Default:
                        /var/www/html/nextcloud
  --timeout TIMEOUT     Timeout in seconds for a single Nextcloud command.
                        Default: 8 (seconds)
  -w, --warning WARN    WARN threshold for the number of accounts the
                        subscription has to cover. Supports Nagios ranges.
                        Evaluated whenever it is given. When omitted, it is
                        evaluated only on an instance that declares no account
                        limit of its own, because a declared limit is compared
                        against the account count anyway. The default covers
                        the smallest Nextcloud subscription, which stops short
                        of 150 accounts. Default: @150:

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-enterprise/
```


## Usage Examples

```bash
./nextcloud-enterprise --path=/var/www/html/nextcloud
```

Output:

```text
196 accounts, local limit 200. Subscription: standard_1y, covers 300 accounts, ends 2026-11-30, Enterprise build of 2026-08-13, key *****9SEZA. 207 accounts in total, 11 disabled, 197 have logged in at least once (Database: 207, user_saml: 0).
Subscr. Renewal: True, Count active users only: False, Hard User Limit: False, Extended Support: False, Branding: False, Branding Plus: False, Customization Service: False
Account Manager: Firstname Lastname, +49 711 252 123 45, firstname.lastname@nextcloud.com

           ! hasSubscription ! users ! endDate ! mcu   ! mcuUsers ! level
-----------+-----------------+-------+---------+-------+----------+------
groupware  ! False           !       ! None    !       !          !
talk       ! False           ! 0     ! None    ! False ! 0        !
collabora  ! False           ! 0     ! None    !       !          !
onlyoffice ! False           ! 0     ! None    !       !          !
outlook    ! False           ! 0     ! None    !       !          ! old
sip_bridge ! False           ! 0     ! None    !       !          !
```

An instance whose `support` app was disabled years ago. The stored figures are dated instead of being reported as current, and the installed Enterprise build is named without being turned into a verdict:

```text
Subscription data 2Y 10M old [WARNING]. Subscription as of 2023-11-11: standard_1y, covers 300 accounts, ends 2023-11-30, Enterprise build of 2026-08-13, key *****9SEZA. 0 disabled, 8 have logged in at least once (Database: 8, user_saml: 0).
Nothing refreshes the subscription data, so every subscription figure above is a memory rather than a fact, the end date included. An Enterprise build of 2026-08-13 is installed, so the instance is being kept on the Enterprise track, but whether the subscription behind it still runs cannot be told here while nothing refreshes the record. Enable the `support` app again, and it answers that within a day. Do not remove the subscription key, the update channel is derived from it and removing it settles nothing.
```

Alerting only once the account count has been over its limit for three days:

```bash
./nextcloud-enterprise --grace-wait=3D
```

Output while the grace period is still running:

```text
115 accounts, 1 more within the grace period (3D). Subscription: standard_1y, covers 100 accounts, ends 2027-01-01, key *****9SEZA. 120 accounts in total, 5 disabled, 110 have logged in at least once (Database: 120).
```

## States

* OK if the account count is within every limit that applies, the subscription has not expired and its data is current.
* WARN if the account count exceeds the licensed amount, once it has been over it for longer than `--grace-wait`.
* WARN if the account count has reached the locally configured limit. The grace period does not apply here, since account creation is already being refused on the paths that ask. The limit only takes effect while the `support` app is enabled and while the stored subscription has not passed its end date; where either is not the case the check reports the limit as exceeded and not enforced instead of claiming that accounts are blocked.
* WARN if the subscription has expired, provided its data is current. On stale data the expiry is not reported as a verdict, because the instance has no way of telling a renewal from a lapse; the staleness alone is the finding.
* WARN if nothing has refreshed the subscription data for two days, or if it was never refreshed at all. The `support` app renews it every 23 hours, so anything older means the app, the background jobs or the connection to Nextcloud stopped working. The output then dates the subscription figures, stops relating the account count to the licensed amount and reports no subscription performance data, because none of it is a confirmed entitlement any more. Where an Enterprise build is installed the check names it, without concluding from it that the subscription still runs, and says that the key must stay, because the update channel is derived from it.
* WARN or CRIT if the account count crosses `--warning` or `--critical`. Given explicitly, both are always evaluated. Left at their defaults, they apply only to an instance that declares no account limit of its own, because a declared limit is compared against the account count anyway. The default warns at 150 accounts, one past the largest instance the smallest Nextcloud subscription covers.
* OK with "No enterprise subscription found." on an instance that carries no subscription key. The account count and its thresholds are still evaluated.
* UNKNOWN if the Nextcloud installation cannot be reached at `--path`, if `occ` fails or times out, or if no account backend on the instance supports counting.
* `--always-ok` suppresses all alerts and always returns OK.

The check never returns CRIT on its own. Every condition it reports is a licensing or housekeeping matter that is dealt with during office hours, not one that justifies waking somebody up.

## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| account_limit | Number | Locally configured limit on the number of accounts, set with `occ config:app:set support user-limit`. This is the per-instance bound and the one `accounts_counted` carries as its warning threshold. Absent where no limit is set. |
| accounts_counted | Number | Number of accounts the subscription is measured against. |
| accounts_disabled | Number | Number of disabled accounts. |
| accounts_licensed | Number | Number of accounts the subscription covers in total, not this instance's share of it: every instance of a shared subscription reports the same figure. Absent on an unlimited subscription, on an instance without one, and while the subscription data is stale. |
| accounts_seen | Number | Number of accounts that have logged in at least once. |
| accounts_total | Number | Number of accounts that exist, enabled and disabled, across all backends. |
| subscription_seconds_left | Seconds | Time left until the subscription expires, negative once it has. Absent where the subscription carries no end date, and while the subscription data is stale, because a countdown drawn from a dead record would paint an expiry into the dashboard that nobody can confirm. |

## Troubleshooting

### `Nextcloud did not report an account total.`

No account backend on the instance supports counting, so Nextcloud cannot say how many accounts it holds and neither can the check. This is what an instance served exclusively by a backend without counting support looks like, an unusual configuration on a production system. Verify with `occ user:report` that the report lists at least one backend with a number next to it.

### Subscription data is old although the instance has a valid subscription

This is the common case, and it does not mean the subscription lapsed. The `support` app renews the stored answer every 23 hours through a background job, and everything the check reports about the subscription comes from that answer. Once the renewal stops, the answer stays behind at whatever it said last, end date included.

An installed Enterprise build tells you the instance is still being kept on the Enterprise track, and no more than that. The customer download channel has been seen serving a key years after the stored record said the subscription had ended, and neither the build nor `updater.server.url` is ever reset when a subscription lapses, so neither answers the question. The only thing that does is a refreshed record. **Do not remove the subscription key to clear the message.** The key is what `updater.server.url` is built from, removing it cuts the instance off from Enterprise updates, and it settles nothing.

Check the three things that stop the renewal, in this order:

1. `occ app:list | grep support` - the app has to be enabled. Its stored answer survives being disabled, which is why the check keeps reporting a subscription that nobody maintains.
2. `occ background-job:list` and the system cron for Nextcloud - the renewal only happens when background jobs run.
3. The instance needs to reach Nextcloud over the internet. Where it cannot, the app records the reason, visible under Administration settings, Support.

Once the app runs again, it refreshes the answer within 23 hours and the check reports the current subscription.

### The account count is above the threshold on a licensed instance

An instance that declares a limit of its own is not measured against `--warning` and `--critical` by default, so this only shows up where the thresholds were set explicitly. Either raise them or drop them and let the declared limit be the bound.

### Every instance reports OK while the subscription is oversubscribed

The check sees one instance. Where several instances share a subscription, and they do whenever they carry the same subscription key, each of them compares its own account count against the same subscription total, so the seats can be used up across the estate while no single instance ever crosses it.

Give each instance the share it is meant to carry, either as its locally configured limit with `occ config:app:set support user-limit`, which Nextcloud then also enforces, or as `--warning` on the service, which only alerts. Verify what the estate consumes by adding up `accounts_counted` over the instances that carry the same key; `accounts_licensed` is the same number on all of them and must not be summed.

### `Could not determine the owner of ...`

`--path` does not point at a Nextcloud installation, or `config/config.php` below it cannot be read by the user running the check. The check has to run `occ` as the account that owns that file, which is why it needs root or sudo.

## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
