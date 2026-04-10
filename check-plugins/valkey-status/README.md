# Check valkey-status

## Overview

Monitors a Valkey server via the `INFO` command and the `MEMORY DOCTOR` subcommand. Reports memory usage, fragmentation ratio, keyspace hit rate, connected clients, replication status, and persistence state.

**Data Collection:**

* Executes `valkey-cli info default` to collect server, memory, keyspace, replication, persistence, CPU, and stats sections
* Executes `valkey-cli memory doctor` to detect memory issues
* Reads OS kernel parameters (`/proc/sys/vm/overcommit_memory`, `/sys/kernel/mm/transparent_hugepage/enabled`, `/proc/sys/net/core/somaxconn`, `/proc/sys/net/ipv4/tcp_max_syn_backlog`) to verify system-level configuration
* Supports TLS connections via `--tls` and `--cacert`
* Supports Unix socket connections via `--socket`
* Supports ACL-based authentication via `--username` and `--password`

**Compatibility:**

* Cross-platform


**