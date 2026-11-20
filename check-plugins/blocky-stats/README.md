# Check blocky-stats

## Overview

Monitors a blocky DNS proxy and ad-blocker through its Prometheus metrics endpoint. Reports the queries per second, the share of blocked, cached and failed queries, the average time the upstream resolvers take to answer and the size of the deny- and allowlists, measured between two consecutive check runs. Alerts when the share of failed queries exceeds the warning or critical threshold, when blocking is disabled, when a denylist group holds no entries, or when the lists have not been refreshed for too long. Requires `prometheus.enable: true` and an HTTP port in the blocky configuration.

**Important Notes:**

* blocky serves no metrics by default. Enable them in `config.yml` and restart blocky:

    ```yaml
    ports:
      http: '127.0.0.1:4000'
    prometheus:
      enable: true
    ```

* Older blocky releases use other metric names and are reported as UNKNOWN.
* After the first run and after every restart of blocky, which resets its counters, the rates show "Waiting for more data". Blocking state, list sizes and list age are evaluated on every run.
* blocky reports a disabled blocking the same way for all and for some groups.
* With `loading.refreshPeriod: 0` blocky reads its lists only at startup, so set `--warning-age=0D`.

**Data Collection:**

* Reads the Prometheus metrics from `--url`.
* Keeps the counters of the previous run in a local SQLite database per `--url`.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/blocky-stats> |
| Nagios/Icinga Check Name              | `check_blocky_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | blocky with `prometheus.enable: true` and `ports.http` |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-blocky-stats-<url>.db` |


## Help

```text
usage: blocky-stats [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                    [--no-perfdata] [--no-proxy] [--proxy PROXY]
                    [--timeout TIMEOUT] [-u URL] [-w WARN]
                    [--warning-age WARN_AGE]

Monitors a blocky DNS proxy and ad-blocker through its Prometheus metrics
endpoint. Reports the queries per second, the share of blocked, cached and
failed queries, the average time the upstream resolvers take to answer and the
size of the deny- and allowlists, measured between two consecutive check runs.
Alerts when the share of failed queries exceeds the warning or critical
threshold, when blocking is disabled, when a denylist group holds no entries,
or when the lists have not been refreshed for too long. Requires
`prometheus.enable: true` and an HTTP port in the blocky configuration.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the share of failed queries since
                        the last check run, in percent. A query fails when no
                        upstream resolver answers it, and the client gets
                        SERVFAIL. Supports Nagios ranges. Default: 50
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         blocky Prometheus metrics endpoint, served on the HTTP
                        port (`ports.http`) under the path set in
                        `prometheus.path`. Default:
                        http://localhost:4000/metrics
  -w, --warning WARN    WARN threshold for the share of failed queries since
                        the last check run, in percent. A query fails when no
                        upstream resolver answers it, and the client gets
                        SERVFAIL. Supports Nagios ranges. Default: 5
  --warning-age WARN_AGE
                        WARN threshold for the time since blocky last
                        refreshed a deny- or allowlist successfully. A blocky
                        that cannot download its lists keeps blocking with the
                        entries it has, so the lists silently grow stale. A
                        duration such as `12h`, `8D` or `2W`; `0D` disables
                        the age check. Example: `--warning-age=12h` for lists
                        refreshed every hour. Default: 1D

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/blocky-stats/
```


## Usage Examples

```bash
./blocky-stats --url=http://localhost:4000/metrics
```

Output (first run):

```text
Waiting for more data, 2 denylist entries (blocky v0.36.0)

Group ! Allowlist ! Denylist
------+-----------+---------
ads   ! 1         ! 2
```

Output (subsequent runs):

```text
10.0 queries/s, 50.0% blocked, 47.5% cached, 0.0% failed, upstream 6ms 55us avg, 2 denylist entries (blocky v0.36.0)

Group ! Allowlist ! Denylist
------+-----------+---------
ads   ! 1         ! 2
```

A denylist group whose lists could not be downloaded, with blocking disabled through the API:

```text
Blocking is disabled for some or all groups [WARNING]. Denylist group broken holds no entries [WARNING]. 0.1 queries/s, 33.3% blocked, 33.3% cached, 0.0% failed, upstream 11ms 183us avg, 2 denylist entries (blocky v0.36.0)

Group  ! Allowlist ! Denylist
-------+-----------+------------
ads    ! 1         ! 2
broken ! -         ! 0 [WARNING]
```


## States

* OK if the share of failed queries is below the warning threshold, blocking is enabled, every denylist group holds entries and the lists were refreshed recently.
* OK with "Waiting for more data" on the first run and after a restart of blocky.
* WARN if the share of failed queries since the last run is >= `--warning` (default: 5%).
* CRIT if the share of failed queries since the last run is >= `--critical` (default: 50%).
* WARN if blocking is disabled for some or all groups.
* WARN if a denylist group holds no entries.
* WARN if the last successful list refresh is at least `--warning-age` ago (default: 1D). `0D` disables this check.
* WARN if the endpoint does not answer within `--timeout`.
* UNKNOWN if the endpoint refuses the connection or answers with an error, does not serve blocky metrics, or serves those of an older blocky release, and on invalid command-line arguments.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| allowlist_entries | Number | Entries in all allowlist groups. |
| blocked | Percentage | Share of queries blocked since the last run. |
| cache_entries | Number | Entries in the DNS response cache. |
| cached | Percentage | Share of queries answered from the cache since the last run. |
| denylist_entries | Number | Entries in all denylist groups. |
| failed | Percentage | Share of queries that failed since the last run. |
| list_age | Seconds | Time since the last successful refresh of a deny- or allowlist group. |
| queries_per_second | Number | Queries per second since the last run. |
| resolve_time | Seconds | Average time of the queries blocky forwarded to an upstream resolver, since the last run. Missing when no query was forwarded. |
| response_time | Seconds | Average time of all answered queries, including blocked and cached ones, since the last run. |


## Troubleshooting

### `HTTP error "404 Not Found" while fetching http://localhost:4000/metrics`

The HTTP port answers, but blocky serves no metrics. Set `prometheus: enable: true` in `/etc/blocky/config.yml` and restart blocky. If `prometheus.path` is set, append that path to `--url` instead of `/metrics`.

### `URL error "[Errno 111] Connection refused"`

blocky is not running, or listens on no HTTP port. Check `systemctl status blocky.service`, and set `ports: http: 4000` in `/etc/blocky/config.yml`. If the HTTP port is bound to an address other than localhost, point `--url` there.

### `Timeout after 3s while fetching http://localhost:4000/metrics.`

blocky does not answer on its HTTP port. Check whether it is overloaded or hangs (`systemctl status blocky.service`, `journalctl --unit=blocky.service`).

### `This blocky uses the metric names from before v0.25.`

Update blocky. Older releases use other metric names.

### A denylist group holds no entries

`Denylist group ads holds no entries`

blocky could not download any list of that group, at startup or since, so it blocks nothing for the clients of that group. Find the failing downloads with `journalctl --unit=blocky.service --grep='cannot open source'`, fix the URL or the network access, and trigger a refresh with `curl --request POST http://localhost:4000/api/lists/refresh`.

### Lists not refreshed for a long time

`Lists last refreshed 2D ago`

blocky keeps blocking with the lists it has, but no refresh succeeded for that long. Look for failed downloads with `journalctl --unit=blocky.service --grep='list_cache'`.

### High share of failed queries

1. Check whether the upstream resolvers answer, for each upstream in `/etc/blocky/config.yml`, for example `dig @192.0.2.53 example.com`.
2. Look at the reason blocky gives: `journalctl --unit=blocky.service --grep='error on processing request'`.
3. A single client asking for a broken domain can push the share up on a quiet resolver. `queries_per_second` tells whether the share rests on a handful of queries.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
