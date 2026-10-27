# Check valkey-status


## Overview

Monitors a Valkey server via the `INFO` command and the `MEMORY DOCTOR` subcommand. Reports memory usage, fragmentation ratio, keyspace hit rate, connected clients, replication status, and persistence state. Alerts on memory consumption, high fragmentation, low hit rates, and OS-level misconfigurations such as overcommit and transparent huge pages.

**Important Notes:**

* Tested with Valkey 7.2, 8.0 and 8.1
* The `*_per_second` and `cpu_*` metrics are rates between two check runs, kept per server, so they appear from the second run on and are missing for one run after a restart of Valkey
* `--verbose` appends the `INFO` answer below the result, one field per line
* "I'm here to keep you safe, Sam. I want to help you." comes from the character GERTY in the movie "Moon" (2009).

**Data Collection:**

* Executes `valkey-cli info default` to collect server, memory, keyspace, replication, persistence, CPU, and stats sections
* Executes `valkey-cli memory doctor` to detect memory issues
* Reads OS kernel parameters (`/proc/sys/vm/overcommit_memory`, `/sys/kernel/mm/transparent_hugepage/enabled`, `/proc/sys/net/core/somaxconn`, `/proc/sys/net/ipv4/tcp_max_syn_backlog`) to verify system-level configuration
* Supports TLS connections via `--tls` and `--cacert`
* Supports Unix socket connections via `--socket`
* Supports ACL-based authentication via `--username` and `--password`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/valkey-status> |
| Nagios/Icinga Check Name              | `check_valkey_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `valkey-cli` |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-valkey-status.db` |


## Help

```text
usage: valkey-status [-h] [-V] [--always-ok] [--cacert CACERT] [-c CRIT]
                     [-H HOSTNAME] [--ignore-maxmemory0] [--ignore-overcommit]
                     [--ignore-somaxconn] [--ignore-sync-partial-err]
                     [--ignore-thp] [--no-perfdata] [-p PASSWORD]
                     [--port PORT] [--socket SOCKET] [--timeout TIMEOUT]
                     [--tls] [--username USERNAME] [--verbose] [-w WARN]

Monitors a Valkey server via the INFO command. Reports memory usage,
fragmentation ratio, keyspace hit rate, connected clients, replication status,
and persistence state. Alerts on memory consumption, high fragmentation, low
hit rates, and OS-level misconfigurations such as overcommit and transparent
huge pages. Includes Valkey Memory Doctor diagnostics when available.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cacert CACERT       CA certificate file for TLS verification. Requires
                        `--tls`. Default: /etc/pki/tls/certs/rootCA.pem
  -c, --critical CRIT   CRIT threshold for memory usage as a percentage.
                        Default: >= None
  -H, --hostname HOSTNAME
                        Valkey server hostname. Default: 127.0.0.1
  --ignore-maxmemory0   Suppress the warning when Valkey maxmemory is set to 0
                        (unlimited).
  --ignore-overcommit   Suppress the warning when vm.overcommit_memory is not
                        set to 1.
  --ignore-somaxconn    Suppress the warning when net.core.somaxconn is lower
                        than net.ipv4.tcp_max_syn_backlog.
  --ignore-sync-partial-err
                        Suppress the warning when replicas were denied a
                        partial resync since the last check and fell back to a
                        full sync.
  --ignore-thp          Suppress the warning about transparent huge pages
                        being set to "always".
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  -p, --password PASSWORD
                        Password for Valkey server authentication.
  --port PORT           Valkey server port. Default: 6379
  --socket SOCKET       Valkey server Unix socket path. Overrides --hostname
                        and --port.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --tls                 Establish a secure TLS connection to Valkey.
  --username USERNAME   Username for Valkey server authentication.
  --verbose             Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood.
  -w, --warning WARN    WARN threshold for memory usage as a percentage.
                        Default: >= 90

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/valkey-status/
```


## Usage Examples

```bash
./valkey-status \
    --ignore-maxmemory0 \
    --ignore-overcommit \
    --ignore-somaxconn \
    --ignore-sync-partial-err \
    --ignore-thp \
    --username=linus \
    --password=linuxfabrik
```

Output:

```text
Valkey v8.0.3 (based on Redis v7.2.4), standalone mode on 127.0.0.1:6379, /etc/valkey/valkey.conf,
up 52m 17s, unlimited memory usage enabled, 0.0% memory usage (959.1KiB/3.8GiB, 959.1KiB peak,
14.5MiB RSS), maxmemory-policy=noeviction, 0.0 evicted keys, 0.0 expired keys, hit rate 0%
(0 hits, 0 misses), vm.overcommit_memory is not set to 1, kernel transparent_hugepage
is not set to "madvise" or "never"
```


## States

* OK if memory usage is below the warning threshold and no OS or memory doctor issues are detected.
* WARN or CRIT if memory usage exceeds `--warning` (default: 90) or `--critical` (default: None).
* WARN when `maxmemory` is 0 (unless `--ignore-maxmemory0`).
* WARN on OS misconfigurations: `vm.overcommit_memory`, `transparent_hugepage`, `somaxconn` (each suppressible via the corresponding `--ignore-*` flag).
* WARN if replicas were denied a partial resync since the previous check and had to fall back to a full sync, unless suppressed via `--ignore-sync-partial-err`. A denial before the previous check, still counted by the server until its restart, does not warn again.
* WARN on memory doctor findings (peak-memory-only and jemalloc-related high-RSS are auto-suppressed).
* WARN if `valkey-cli` cannot reach the server, or gets no answer within `--timeout`.
* UNKNOWN if the login fails, because `--password` is missing or Valkey rejects the username or password.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Latest info can be found [here](https://valkey.io/commands/info/).

| Name | Type | Description |
|----|----|----|
| clients_blocked_clients | Number | Number of clients pending on a blocking call. |
| clients_connected_clients | Number | Number of client connections (excluding connections from replicas). |
| cpu_used_cpu_sys_children_percent | Percentage | System CPU consumed by child processes, in percent. |
| cpu_used_cpu_sys_percent | Percentage | System (kernel) CPU consumed by the server, in percent. |
| cpu_used_cpu_user_children_percent | Percentage | User CPU consumed by child processes, in percent. |
| cpu_used_cpu_user_percent | Percentage | User CPU consumed by the server, in percent. |
| db_count | Number | Number of Valkey databases holding keys. |
| key_count | Number | Sum of all keys across all databases. |
| keyspace_DBNAME_avg_ttl | Seconds | Average TTL for keys in this database. |
| keyspace_DBNAME_expires | Number | Number of keys with an expiration in this database. |
| keyspace_DBNAME_keys | Number | Number of keys in this database. |
| keyspace_hit_rate | Percentage | Percentage of key lookups successfully returned since the server start. |
| mem_usage | Percentage | Memory usage relative to `maxmemory` (or total system memory if `maxmemory` is 0). |
| memory_maxmemory | Bytes | Configured maximum memory limit, 0 if unlimited. |
| memory_mem_fragmentation_ratio | Number | Ratio between `used_memory_rss` and `used_memory`. |
| memory_used_memory | Bytes | Total bytes allocated by Valkey using its allocator. |
| memory_used_memory_lua | Bytes | Bytes used by the Lua engine. |
| memory_used_memory_rss | Bytes | Bytes allocated as seen by the OS (resident set size). |
| persistence_aof_current_rewrite_time_sec | Seconds | Duration of the on-going AOF rewrite, 0 if none is running. |
| persistence_rdb_changes_since_last_save | Number | Number of changes since the last dump. |
| persistence_rdb_current_bgsave_time_sec | Seconds | Duration of the on-going RDB save, 0 if none is running. |
| replication_connected_slaves | Number | Number of connected replicas. |
| replication_repl_backlog_histlen | Bytes | Size of the data in the replication backlog buffer. |
| replication_repl_backlog_size | Bytes | Total size of the replication backlog buffer. |
| server_uptime_in_seconds | Seconds | Number of seconds since Valkey server start. |
| stats_evicted_keys_per_second | Number | Keys evicted per second because of the `maxmemory` limit. |
| stats_expired_keys_per_second | Number | Key expiration events per second. |
| stats_keyspace_hits_per_second | Number | Successful key lookups per second. |
| stats_keyspace_misses_per_second | Number | Failed key lookups per second. |
| stats_latest_fork_usec | Microseconds | Duration of the latest fork operation. |
| stats_rejected_connections_per_second | Number | Connections rejected per second because of the `maxclients` limit. |
| stats_sync_full_per_second | Number | Full resyncs with replicas per second. |
| stats_sync_partial_err_per_second | Number | Denied partial resync requests per second. |
| stats_sync_partial_ok_per_second | Number | Accepted partial resync requests per second. |
| stats_total_commands_processed_per_second | Number | Commands processed per second. |
| stats_total_connections_received_per_second | Number | Connections accepted per second. |
| stats_total_net_input_bytes_per_second | Bytes | Bytes read from the network per second. |
| stats_total_net_output_bytes_per_second | Bytes | Bytes written to the network per second. |


## Troubleshooting

### `Failed to authenticate`

`valkey-cli` reports a refused login with exit code 0, so the plugin reads the answer. Valkey requires a password (`requirepass` or an ACL user) and none was given: pass it with `--password`, and the account with `--username` if it is an ACL user. Valkey rejected the credentials: check `--username` and `--password` against the `requirepass` or `user` line of the Valkey configuration. The state is UNKNOWN, because the check cannot say anything about the server without logging in.

### `vm.overcommit_memory is not set to 1`

Run `sysctl -w vm.overcommit_memory=1`.

### `kernel transparent_hugepage is not set to "madvise" or "never"`

Run `echo madvise > /sys/kernel/mm/transparent_hugepage/enabled`.

### `net.core.somaxconn is lower than net.ipv4.tcp_max_syn_backlog`

`tcp_max_syn_backlog` represents the maximal number of connections in `SYN_RECV` queue. `somaxconn` represents the maximal size of `ESTABLISHED` queue and should be greater than `tcp_max_syn_backlog`, so do something like this: `sysctl -w net.core.somaxconn=1024; sysctl -w net.ipv4.tcp_max_syn_backlog=512`


### Replicas were denied a partial resync

`replicas were denied a partial resync since the last check and fell back to a full sync`

A replica lost its connection to this primary, asked to continue where it left off, and was refused. It then fetched a complete copy, which makes the primary fork and transfer a full dump. A single event after a network outage or a restart is harmless, the replication has recovered by the time the check reports it, and the next check is OK again. If it keeps coming back:

1. Look for the reason in the Valkey log of the primary: `for lack of backlog` or `Replication ID mismatch`.
2. On `for lack of backlog`, the replication backlog is too small to cover the time a replica is away. Raise `repl-backlog-size` in `valkey.conf` (the default is 10 MB), or at runtime with `valkey-cli config set repl-backlog-size 64mb`.
3. On `Replication ID mismatch`, the primary changed its replication history, for example after a restart without persistence. Check why the primary restarted or lost its data.

## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch); [Claudio Kuenzler](https://www.claudiokuenzler.com)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
