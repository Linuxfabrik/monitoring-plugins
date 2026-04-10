# Check redis-status

## Overview

Monitors a Redis server via the `INFO` command, reporting memory usage, fragmentation ratio, keyspace hit rate, connected clients, replication status, and persistence state.

**Data Collection:**

* Executes `redis-cli info default` and `redis-cli memory doctor` against the target Redis instance
* Connects via hostname/port (default: 127.0.0.1:6379) or Unix socket
* Supports authentication (username/password) and TLS connections
* Reads OS-level settings from `/proc/sys/vm/overcommit_memory`, `/sys/kernel/mm/transparent_hugepage/enabled`, `/proc/sys/net/core/somaxconn`, and `/proc/sys/net/ipv4/tcp_max_syn_backlog`

**Important Notes:**

* Tested on Redis 3.0+
* Requires the `redis-cli` command-line tool
* "I'm here to keep you safe, Sam. I want to help you." comes from the character GERTY in the movie "Moon" (2009)

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redis-status> |
| Nagios/Icinga Check Name              | `check_redis_status` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `redis-cli` |


## Help

```text
usage: redis-status [-h] [-V] [--always-ok] [--cacert CACERT] [-c CRIT]
                    [-H HOSTNAME] [--ignore-maxmemory0] [--ignore-overcommit]
                    [--ignore-somaxconn] [--ignore-sync-partial-err]
                    [--ignore-thp] [-p PASSWORD] [--port PORT]
                    [--socket SOCKET] [--test TEST] [--tls]
                    [--username USERNAME] [--verbose] [-w WARN]

Monitors a Redis server via the INFO command. Reports memory usage,
fragmentation ratio, keyspace hit rate, connected clients, replication status,
and persistence state. Alerts on memory consumption, high fragmentation, low
hit rates, and OS-level misconfigurations such as overcommit and transparent
huge pages. Includes Redis Memory Doctor diagnostics when available.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cacert CACERT       CA certificate file for TLS verification. Requires
                        `--tls`. Default: /etc/pki/tls/certs/rootCA.pem
  -c, --critical CRIT   CRIT threshold for memory usage as a percentage.
                        Default: >= None
  -H, --hostname HOSTNAME
                        Redis server hostname. Default: 127.0.0.1
  --ignore-maxmemory0   Suppress the warning when Redis maxmemory is set to 0
                        (unlimited). Default: False
  --ignore-overcommit   Suppress the warning when vm.overcommit_memory is not
                        set to 1. Default: False
  --ignore-somaxconn    Suppress the warning when net.core.somaxconn is lower
                        than net.ipv4.tcp_max_syn_backlog. Default: False
  --ignore-sync-partial-err
                        Suppress the warning about partial sync errors. Useful
                        for asynchronous replication setups where a small
                        number of "denied partial resync requests" is
                        expected. Default: False
  --ignore-thp          Suppress the warning about transparent huge pages
                        being enabled. Default: False
  -p, --password PASSWORD
                        Password for Redis server authentication.
  --port PORT           Redis server port. Default: 6379
  --socket SOCKET       Redis server Unix socket path. Overrides --hostname
                        and --port.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --tls                 Establish a secure TLS connection to Redis.
  --username USERNAME   Username for Redis server authentication.
  --verbose             Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Default: False
  -w, --warning WARN    WARN threshold for memory usage as a percentage.
                        Default: >= 90
```


## Usage Examples

```bash
./redis-status \
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
Redis v5.0.3, standalone mode on 127.0.0.1:6379, /etc/redis.conf, up 4m 25s, 100.9% memory usage
[WARNING] (9.6MiB/9.5MiB, 9.6MiB peak, 19.6MiB RSS), maxmemory-policy=noeviction, 3 DBs
(db0 db3 db4) with 10 keys, 0.0 evicted keys, 0.0 expired keys, hit rate 100.0%
(3.0M hits, 0.0 misses), vm.overcommit_memory is not set to 1, kernel transparent_hugepage is not
set to "madvise" or "never", net.core.somaxconn (128) is lower than net.ipv4.tcp_max_syn_backlog
(256). Sam, I detected a few issues in this Redis instance memory implants:

 * High total RSS: This instance has a memory fragmentation and RSS overhead greater than 1.4
 (this means that the Resident Set Size of the Redis process is much larger than the sum of the
logical allocations Redis performed). This problem is usually due either to a large peak
memory (check if there is a peak memory entry above in the report) or may result from a workload
that causes the allocator to fragment memory a lot. If the problem is a large peak memory, then
there is no issue. Otherwise, make sure you are using the Jemalloc allocator and not the default
libc malloc. Note: The currently used allocator is "jemalloc-5.1.0".

I'm here to keep you safe, Sam. I want to help you.
```


## States

* OK if memory usage is below the warning threshold and no OS-level misconfigurations are detected.
* WARN or CRIT if memory usage exceeds the configured thresholds (default: WARN >= 90%).
* WARN when `maxmemory` is set to 0 (unlimited), unless suppressed via `--ignore-maxmemory0`.
* WARN on memory issues reported by Redis Memory Doctor (except harmless peak-only or jemalloc cases).
* WARN on partial sync errors, unless suppressed via `--ignore-sync-partial-err`.
* WARN on OS-level misconfigurations (`vm.overcommit_memory`, transparent huge pages, `somaxconn`), each individually suppressible.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Latest info can be found [here](https://redis.io/commands/INFO).

| Name | Type | Description |
|----|----|----|
| clients_blocked_clients | Number | Number of clients pending on a blocking call |
| clients_connected_clients | Number | Number of client connections (excluding connections from replicas) |
| cpu_used_cpu_sys | Number | System CPU consumed by the Redis server, which is the sum of system CPU consumed by all threads of the server process (main thread and background threads) |
| cpu_used_cpu_sys_children | Number | System CPU consumed by the background processes |
| cpu_used_cpu_user | Number | User CPU consumed by the Redis server, which is the sum of user CPU consumed by all threads of the server process (main thread and background threads) |
| cpu_used_cpu_user_children | Number | User CPU consumed by the background processes |
| db_count | Number | Number of Redis databases |
| key_count | Number | Sum of all keys across all databases |
| keyspace_DBNAME_avg_ttl | Seconds | Average TTL for keys in this database |
| keyspace_DBNAME_expires | Number | The number of keys with an expiration |
| keyspace_DBNAME_keys | Number | The number of keys |
| keyspace_hit_rate | Percentage | Percentage of key lookups that are successfully returned by keys in your Redis instance |
| mem_usage | Percentage | How close the working set size is to reaching the maxmemory limit |
| memory_maxmemory | Bytes | Configured maximum memory limit |
| memory_mem_fragmentation_ratio | Number | Ratio between used_memory_rss and used_memory |
| memory_total_system_memory | Bytes | The total amount of memory that the Redis host has |
| memory_used_memory | Bytes | Total number of bytes allocated by Redis using its allocator |
| memory_used_memory_lua | Bytes | Number of bytes used by the Lua engine |
| memory_used_memory_rss | Bytes | Number of bytes that Redis allocated as seen by the operating system (resident set size) |
| persistance_aof_current_rewrite_time_sec | Seconds | Duration of the on-going AOF rewrite operation if any |
| persistance_aof_rewrite_in_progress | Number | Flag indicating an AOF rewrite operation is on-going |
| persistance_aof_rewrite_scheduled | Number | Flag indicating an AOF rewrite operation will be scheduled once the on-going RDB save is complete |
| persistance_loading | Number | Flag indicating if the load of a dump file is on-going |
| persistance_rdb_bgsave_in_progress | Number | Flag indicating a RDB save is on-going |
| persistance_rdb_changes_since_last_save | Number | Number of changes since the last dump |
| persistance_rdb_current_bgsave_time_sec | Seconds | Duration of the on-going RDB save operation if any |
| replication_connected_slaves | Number | Number of connected replicas |
| replication_repl_backlog_histlen | Bytes | Size in bytes of the data in the replication backlog buffer |
| replication_repl_backlog_size | Bytes | Total size in bytes of the replication backlog buffer |
| server_uptime_in_seconds | Seconds | Number of seconds since Redis server start |
| stats_evicted_keys | Continuous Counter | Number of evicted keys due to maxmemory limit |
| stats_expired_keys | Continuous Counter | Total number of key expiration events |
| stats_instantaneous_input | Number | The network read rate per second in KB/sec |
| stats_instantaneous_ops_per_sec | Number | Number of commands processed per second |
| stats_instantaneous_output | Number | The network write rate per second in KB/sec |
| stats_keyspace_hits | Number | Number of successful lookup of keys in the main dictionary |
| stats_keyspace_misses | Number | Number of failed lookup of keys in the main dictionary |
| stats_latest_fork_usec | Number | Duration of the latest fork operation in microseconds |
| stats_migrate_cached_sockets | Number | The number of sockets open for MIGRATE purposes |
| stats_pubsub_channels | Number | Global number of pub/sub channels with client subscriptions |
| stats_pubsub_patterns | Number | Global number of pub/sub patterns with client subscriptions |
| stats_rejected_connections | Number | Number of connections rejected because of maxclients limit |
| stats_sync_full | Number | The number of full resyncs with replicas |
| stats_sync_partial_err | Number | The number of denied partial resync requests |
| stats_sync_partial_ok | Number | The number of accepted partial resync requests |
| stats_total_commands_processed | Number | Total number of commands processed by the server |
| stats_total_connections_received | Number | Total number of connections accepted by the server |
| stats_total_net_input_bytes | Bytes | The total number of bytes read from the network |
| stats_total_net_output_bytes | Bytes | The total number of bytes written to the network |


## Troubleshooting

`vm.overcommit_memory is not set to 1`  
`sysctl -w vm.overcommit_memory=1`

`kernel transparent_hugepage is not set to "madvise"`  
`echo madvise > /sys/kernel/mm/transparent_hugepage/enabled`

`net.core.somaxconn is lower than net.ipv4.tcp_max_syn_backlog`  
`tcp_max_syn_backlog` represents the maximal number of connections in `SYN_RECV` queue. `somaxconn` represents the maximal size of `ESTABLISHED` queue and should be greater than `tcp_max_syn_backlog`, so do something like this: `sysctl -w net.core.somaxconn=1024; sysctl -w net.ipv4.tcp_max_syn_backlog=512`


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
