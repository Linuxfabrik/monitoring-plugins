# Check valkey-status

## Overview

Monitors a Valkey server via the `INFO` command and the `MEMORY DOCTOR` subcommand. Reports memory usage, fragmentation ratio, keyspace hit rate, connected clients, replication status, and persistence state.

**Important Notes:**

* Tested with Valkey 7.2 and 8.0
* "I'm here to keep you safe, Sam. I want to help you." comes from the character GERTY in the movie "Moon" (2009).


**Data Collection:**

* Executes `valkey-cli info default` to collect server, memory, keyspace, replication, persistence, CPU, and stats sections
* Executes `valkey-cli memory doctor` to detect memory issues
* Reads OS kernel parameters (`/proc/sys/vm/overcommit_memory`, `/sys/kernel/mm/transparent_hugepage/enabled`, `/proc/sys/net/core/somaxconn`, `/proc/sys/net/ipv4/tcp_max_syn_backlog`) to verify system-level configuration
* Supports TLS connections via `--tls` and `--cacert`
* Supports Unix socket connections via `--socket`
* Supports ACL-based authentication via `--username` and `--password`

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/valkey-status> |
| Nagios/Icinga Check Name              | `check_valkey_status` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `valkey-cli` |


## Help

```text
usage: valkey-status [-h] [-V] [--always-ok] [--cacert CACERT] [-c CRIT]
                     [-H HOSTNAME] [--ignore-maxmemory0] [--ignore-overcommit]
                     [--ignore-somaxconn] [--ignore-sync-partial-err]
                     [--ignore-thp] [-p PASSWORD] [--port PORT]
                     [--socket SOCKET] [--test TEST] [--tls]
                     [--username USERNAME] [--verbose] [-w WARN]

Monitors a Valkey server via the INFO command. Reports memory usage,
fragmentation ratio, keyspace hit rate, connected clients, replication status,
and persistence state. Alerts on memory consumption, high fragmentation, and
low hit rates.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cacert CACERT       CA certificate file for TLS verification. Requires
                        `--tls`. Default: /etc/pki/tls/certs/rootCA.pem
  -c, --critical CRIT   CRIT threshold for memory usage in percent. Default:
                        >= None
  -H, --hostname HOSTNAME
                        Valkey server hostname. Default: 127.0.0.1
  --ignore-maxmemory0   Suppress warning when Valkey maxmemory is set to 0
                        (unlimited).
  --ignore-overcommit   Suppress warning when vm.overcommit_memory is not set
                        to 1.
  --ignore-somaxconn    Suppress warning when net.core.somaxconn is lower than
                        net.ipv4.tcp_max_syn_backlog.
  --ignore-sync-partial-err
                        Suppress warning about partial sync errors. Useful
                        when asynchronous replication is in use, where a small
                        number of "denied partial resync requests" might be
                        normal.
  --ignore-thp          Suppress warning about transparent huge pages being
                        set to "always".
  -p, --password PASSWORD
                        Password for Valkey server authentication.
  --port PORT           Valkey server port. Default: 6379
  --socket SOCKET       Valkey server Unix socket path. Overrides hostname and
                        port.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --tls                 Establish a secure TLS connection to the Valkey
                        server.
  --username USERNAME   Username for Valkey server authentication.
  --verbose             Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood.
  -w, --warning WARN    WARN threshold for memory usage in percent. Default:
                        >= 90
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
(0.0 hits, 0.0 misses), vm.overcommit_memory is not set to 1, kernel transparent_hugepage
is not set to "madvise" or "never"
```


## States

* OK if memory usage is below the warning threshold and no OS or memory doctor issues are detected.
* WARN or CRIT if memory usage exceeds `--warning` (default: 90) or `--critical` (default: None).
* WARN when `maxmemory` is 0 (unless `--ignore-maxmemory0`).
* WARN on OS misconfigurations: `vm.overcommit_memory`, `transparent_hugepage`, `somaxconn` (each suppressible via the corresponding `--ignore-*` flag).
* WARN on partial sync errors (unless `--ignore-sync-partial-err`).
* WARN on memory doctor findings (peak-memory-only and jemalloc-related high-RSS are auto-suppressed).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Latest info can be found [here](https://valkey.io/commands/info/).

| Name | Type | Description |
|----|----|----|
| clients_blocked_clients | Number | Number of clients pending on a blocking call. |
| clients_connected_clients | Number | Number of client connections (excluding connections from replicas). |
| cpu_used_cpu_sys | Number | System CPU consumed by the Valkey server (main thread and background threads). |
| cpu_used_cpu_sys_children | Number | System CPU consumed by background processes. |
| cpu_used_cpu_user | Number | User CPU consumed by the Valkey server (main thread and background threads). |
| cpu_used_cpu_user_children | Number | User CPU consumed by background processes. |
| db_count | Number | Number of Valkey databases. |
| key_count | Number | Sum of all keys across all databases. |
| keyspace_DBNAME_avg_ttl | Seconds | Average TTL for keys in this database. |
| keyspace_DBNAME_expires | Number | Number of keys with an expiration in this database. |
| keyspace_DBNAME_keys | Number | Number of keys in this database. |
| keyspace_hit_rate | Percentage | Percentage of key lookups successfully returned. A higher value indicates better cache efficiency. |
| mem_usage | Percentage | Memory usage relative to `maxmemory` (or total system memory if `maxmemory` is 0). |
| memory_maxmemory | Bytes | Configured maximum memory limit. |
| memory_mem_fragmentation_ratio | Number | Ratio between `used_memory_rss` and `used_memory`. |
| memory_total_system_memory | Bytes | Total amount of memory on the Valkey host. |
| memory_used_memory | Bytes | Total bytes allocated by Valkey using its allocator. |
| memory_used_memory_lua | Bytes | Bytes used by the Lua engine. |
| memory_used_memory_rss | Bytes | Bytes allocated as seen by the OS (resident set size). |
| persistance_aof_current_rewrite_time_sec | Seconds | Duration of the on-going AOF rewrite operation if any. |
| persistance_aof_rewrite_in_progress | Number | Flag indicating an AOF rewrite operation is on-going. |
| persistance_aof_rewrite_scheduled | Number | Flag indicating an AOF rewrite will be scheduled once the on-going RDB save is complete. |
| persistance_loading | Number | Flag indicating if the load of a dump file is on-going. |
| persistance_rdb_bgsave_in_progress | Number | Flag indicating a RDB save is on-going. |
| persistance_rdb_changes_since_last_save | Number | Number of changes since the last dump. |
| persistance_rdb_current_bgsave_time_sec | Seconds | Duration of the on-going RDB save operation if any. |
| replication_connected_slaves | Number | Number of connected replicas. |
| replication_repl_backlog_histlen | Bytes | Size of the data in the replication backlog buffer. |
| replication_repl_backlog_size | Bytes | Total size of the replication backlog buffer. |
| server_uptime_in_seconds | Seconds | Number of seconds since Valkey server start. |
| stats_evicted_keys | Continuous Counter | Number of evicted keys due to maxmemory limit. |
| stats_expired_keys | Continuous Counter | Total number of key expiration events. |
| stats_instantaneous_input | Bytes | Network read rate per second. |
| stats_instantaneous_ops_per_sec | Number | Number of commands processed per second. |
| stats_instantaneous_output | Bytes | Network write rate per second. |
| stats_keyspace_hits | Number | Number of successful key lookups. |
| stats_keyspace_misses | Number | Number of failed key lookups. |
| stats_latest_fork_usec | Microseconds | Duration of the latest fork operation. |
| stats_migrate_cached_sockets | Number | Number of sockets open for MIGRATE purposes. |
| stats_pubsub_channels | Number | Global number of pub/sub channels with client subscriptions. |
| stats_pubsub_patterns | Number | Global number of pub/sub patterns with client subscriptions. |
| stats_rejected_connections | Number | Number of connections rejected because of maxclients limit. |
| stats_sync_full | Number | Number of full resyncs with replicas. |
| stats_sync_partial_err | Number | Number of denied partial resync requests. |
| stats_sync_partial_ok | Number | Number of accepted partial resync requests. |
| stats_total_commands_processed | Continuous Counter | Total number of commands processed by the server. |
| stats_total_connections_received | Continuous Counter | Total number of connections accepted by the server. |
| stats_total_net_input_bytes | Continuous Counter | Total number of bytes read from the network. |
| stats_total_net_output_bytes | Continuous Counter | Total number of bytes written to the network. |


## Troubleshooting

`vm.overcommit_memory is not set to 1`
Fix: `sysctl -w vm.overcommit_memory=1`

`kernel transparent_hugepage is not set to "madvise" or "never"`
Fix: `echo madvise > /sys/kernel/mm/transparent_hugepage/enabled`

`net.core.somaxconn is lower than net.ipv4.tcp_max_syn_backlog`
`tcp_max_syn_backlog` represents the maximal number of connections in `SYN_RECV` queue. `somaxconn` represents the maximal size of `ESTABLISHED` queue and should be greater than `tcp_max_syn_backlog`, so do something like this: `sysctl -w net.core.somaxconn=1024; sysctl -w net.ipv4.tcp_max_syn_backlog=512`


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch); [Claudio Kuenzler](https://www.claudiokuenzler.com)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
