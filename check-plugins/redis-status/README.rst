Check redis-status
==================

Overview
--------

Returns information and statistics about the Redis server. Alerts on memory consumption, memory fragmentation, hit rates and more. Connects to Redis via 127.0.0.1:6379 by default.

Hints:

* Tested on Redis 3.0, 3.2, 6.0, 6.2 and 7.0.
* "I'm here to keep you safe, Sam. I want to help you." comes from the character GERTY in the movie "Moon" (2009).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redis-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "command-line tool ``redis-cli``"


Help
----

.. code-block:: text

    usage: redis-status [-h] [-V] [--always-ok] [-c CRIT] [-H HOSTNAME]
                        [--maxmemory0-ok] [-p PASSWORD] [--port PORT]
                        [--socket SOCKET] [--test TEST] [-w WARN]

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold as a percentage. Default: >=
                            None
      -H HOSTNAME, --hostname HOSTNAME
                            Server hostname. Default: 127.0.0.1
      --maxmemory0-ok       Don't warn on maxmemory=0. Default: False
      -p PASSWORD, --password PASSWORD
                            Password to use when connecting to the server.
      --port PORT           Server port. Default: 6379
      --socket SOCKET       Server socket (overrides hostname and port).
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w WARN, --warning WARN
                            Set the WARN threshold as a percentage. Default: >= 90


Usage Examples
--------------

.. code-block:: bash

    ./redis-status --maxmemory0-ok

Output:

.. code-block:: text

    Redis v7.0.0, standalone mode on 127.0.0.1:6379, /etc/redis/redis.conf, up 3W 3h, 22.5% memory usage (644.6MiB/2.8GiB, 1014.6MiB peak, 625.4MiB RSS), maxmemory-policy=volatile-lru, 1 DB (db0) with 13547 keys, 0.0 evicted keys, 555.5K expired keys, hit rate 62.7% (4.1M hits, 2.4M misses), Sam, I detected a few issues in this Redis instance memory implants:

    * Peak memory: In the past this instance used more than 150% the memory that is currently using. The allocator is normally not able to release memory after a peak, so you can expect to see a big fragmentation ratio, however this is actually harmless and is only due to the memory peak, and if the Redis instance Resident Set Size (RSS) is currently bigger than expected, the memory will be used as soon as you fill the Redis instance with more data. If the memory peak was only occasional and you want to try to reclaim memory, please try the MEMORY PURGE command, otherwise the only other option is to shutdown and restart the instance.


States
------

* WARN on ``maxmemory 0`` (can be disabled by ``--maxmemory0-ok``)
* WARN or CRIT in case of memory usage above the specified thresholds
* WARN in case of keyspace hit ratio below 10%
* WARN on any memory issues
* WARN on partial sync errors
* WARN on bad OS configuration


Perfdata / Metrics
------------------

Latest info can be found `here <https://redis.io/commands/INFO>`_.

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    clients_blocked_clients,                    Number,             Number of clients pending on a blocking call
    clients_connected_clients,                  Number,             Number of client connections (excluding connections from replicas)
    cpu_used_cpu_sys,                           Number,             "System CPU consumed by the Redis server, which is the sum of system CPU consumed by all threads of the server process (main thread and background threads)"
    cpu_used_cpu_sys_children,                  Number,             System CPU consumed by the background processes
    cpu_used_cpu_user,                          Number,             "User CPU consumed by the Redis server, which is the sum of user CPU consumed by all threads of the server process (main thread and background threads)"
    cpu_used_cpu_user_children,                 Number,             User CPU consumed by the background processes
    db_count,                                   Number,             Number of Redis databases
    key_count,                                  Number,             Sum of all keys across all databases
    keyspace_<dbname>_keys,                     Number,             The number of keys
    keyspace_<dbname>_expires,                  Number,             The number of keys with an expiration
    keyspace_<dbname>_avg_ttl,                  Seonds,             
    keyspace_hit_rate,                          Percentage,         "Percentage of key lookups that are successfully returned by keys in your Redis instance. Generally speaking, a higher cache-hit ratio is better than a lower cache-hit ratio. You should make a note of your cache-hit ratio before you make any large configuration changes such as adjusting the maxmemory-gb limit, changing your eviction policy, or scaling your instance. Then, after you modify your instance, check the cache-hit ratio again to see how your change impacted this metric."
    mem_usage,                                  Percentage,         "Indicates how close your working set size is to reaching the maxmemory-gb limit. Unless the eviction policy is set to no-eviction, the instance data reaching maxmemory does not always indicate a problem. However, key eviction is a background process that takes time. If you have a high write-rate, you could run out of memory before Redis has time to evict keys to free up space."
    memory_maxmemory,                           Bytes, 
    memory_mem_fragmentation_ratio,             Number,             "Ratio between used_memory_rss and used_memory. Note that this doesn't only includes fragmentation, but also other process overheads (see the allocator\_\* metrics), and also overheads like code, shared libraries, stack, etc. Memory fragmentation can cause your Memorystore instance to run out of memory even when the used memory to maxmemory-gb ratio is low. Memory fragmentation happens when the operating system allocates memory pages which Redis cannot fully utilize after repeated write and delete operations. The accumulation of such pages can result in the system running out of memory and eventually causes the Redis server to crash."
    memory_total_system_memory,                 Bytes,              The total amount of memory that the Redis host has
    memory_used_memory,                         Bytes,              "Total number of bytes allocated by Redis using its allocator (either standard libc, jemalloc, or an alternative allocator such as tcmalloc)"
    memory_used_memory_lua,                     Bytes,              Number of bytes used by the Lua engine
    memory_used_memory_rss,                     Bytes,              Number of bytes that Redis allocated as seen by the operating system (a.k.a resident set size). This is the number reported by tools such as top(1) and ps(1)
    persistance_aof_current_rewrite_time_sec,   Seconds,            Duration of the on-going AOF rewrite operation if any
    persistance_aof_rewrite_in_progress,        Number,             Flag indicating a AOF rewrite operation is on-going
    persistance_aof_rewrite_scheduled,          Number,             Flag indicating an AOF rewrite operation will be scheduled once the on-going RDB save is complete.
    persistance_loading,                        Number,             Flag indicating if the load of a dump file is on-going
    persistance_rdb_bgsave_in_progress,         Number,             Flag indicating a RDB save is on-going
    persistance_rdb_changes_since_last_save,    Number,             Number of changes since the last dump
    persistance_rdb_current_bgsave_time_sec,    Seconds,            Duration of the on-going RDB save operation if any
    replication_connected_slaves,               Number,             Number of connected replicas
    replication_repl_backlog_histlen,           Bytes,              Size in bytes of the data in the replication backlog buffer
    replication_repl_backlog_size,              Bytes,              Total size in bytes of the replication backlog buffer
    server_uptime_in_seconds,                   Seconds,            Number of seconds since Redis server start
    stats_evicted_keys,                         Number,             Number of evicted keys due to maxmemory limit
    stats_expired_keys,                         Number,             "Total number of key expiration events. If there are no expirable keys, it can be an indication that you are not setting TTLs on keys. In such cases, when your instance data reaches the maxmemory-gb limit, there are no keys to evict which can result in an out of memory condition. If the metric shows many expired keys, but you still see memory pressure on your instance, you should lower maxmemory-gb."
    stats_instantaneous_input,                  Number,             The network read rate per second in KB/sec
    stats_instantaneous_ops_per_sec,            Number,             Number of commands processed per second
    stats_instantaneous_output,                 Number,             The networks write rate per second in KB/sec
    stats_keyspace_hits,                        Number,             Number of successful lookup of keys in the main dictionary
    stats_keyspace_misses,                      Number,             Number of failed lookup of keys in the main dictionary
    stats_latest_fork_usec,                     Number,             Duration of the latest fork operation in microseconds
    stats_migrate_cached_sockets,               Number,             The number of sockets open for MIGRATE purposes
    stats_pubsub_channels,                      Number,             Global number of pub/sub channels with client subscriptions
    stats_pubsub_patterns,                      Number,             Global number of pub/sub pattern with client subscriptions
    stats_rejected_connections,                 Number,             Number of connections rejected because of maxclients limit
    stats_sync_full,                            Number,             The number of full resyncs with replicas
    stats_sync_partial_err,                     Number,             The number of denied partial resync requests
    stats_sync_partial_ok,                      Number,             The number of accepted partial resync requests
    stats_total_commands_processed,             Number,             Total number of commands processed by the server
    stats_total_connections_received,           Number,             Total number of connections accepted by the server
    stats_total_net_input_bytes,                Bytes,              The total number of bytes read from the network
    stats_total_net_output_bytes,               Bytes,              The total number of bytes written to the network


Troubleshooting
---------------

vm.overcommit_memory is not set to 1
    ``sysctl -w vm.overcommit_memory=1``

kernel transparent_hugepage is not set to "madvise"
    ``echo madvise > /sys/kernel/mm/transparent_hugepage/enabled``

net.core.somaxconn is lower than net.ipv4.tcp_max_syn_backlog
    ``tcp_max_syn_backlog`` represents the maximal number of connections in ``SYN_RECV`` queue. ``somaxconn`` represents the maximal size of ``ESTABLISHED`` queue and should be greater than ``tcp_max_syn_backlog``, so do something like this: ``sysctl -w net.core.somaxconn=1024; sysctl -w net.ipv4.tcp_max_syn_backlog=512``


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
