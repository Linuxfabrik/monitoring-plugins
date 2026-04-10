# Check wildfly-memory-pool-usage


## Overview

Checks Java memory pool usage (Eden, Survivor, Old Gen, Metaspace, Compressed Class Space, Code Cache, etc.) on a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode.

**Important Notes:**

* Tested with WildFly 11 and WildFly 23+
* [How is the Java memory pool divided?](https://stackoverflow.com/questions/1262328/how-is-the-java-memory-pool-divided)

    **Heap memory** is the runtime data area from which the Java VM allocates memory for all class instances and arrays. The garbage collector is an automatic memory management system that reclaims heap memory for objects.

    * PS Eden Space: The pool from which memory is initially allocated for most objects.
    * PS Tenured Generation or PS Old Gen: The pool containing objects that have existed for some time in the survivor space.
    * PS Survivor Space: The pool containing objects that have survived the garbage collection of the Eden space.

    **Non-heap memory** includes a method area shared among all threads and memory required for the internal processing or optimization for the Java VM.

    * Code Cache: Memory used for compilation and storage of native code.
    * Permanent Generation: The pool containing all the reflective data of the virtual machine itself.
    * Compressed Class Space
    * Metaspace

**Data Collection:**

* Queries the WildFly management API at `/core-service/platform-mbean/type/memory-pool` using the `read-resource` operation with runtime data
* Authenticates via HTTP Digest Auth (`--username`, `--password`)
* Reports used/committed/max for each pool, both for regular usage and collection usage (if available)
* Peak values are intentionally ignored as they are not relevant in a monitoring scenario with frequent checks

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-memory-pool-usage> |
| Nagios/Icinga Check Name              | `check_wildfly_memory_pool_usage` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-memory-pool-usage [-h] [-V] [--always-ok] [--insecure]
                                 [--instance INSTANCE]
                                 [--mode {standalone,domain}] [--no-proxy]
                                 [--node NODE] -p PASSWORD [--timeout TIMEOUT]
                                 [--url URL] --username USERNAME

Checks Java memory pool usage (Eden, Survivor, Old Gen, Metaspace, etc.) on a
WildFly/JBoss AS server via its HTTP management API. Alerts when any pool
exceeds the configured usage threshold.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --instance INSTANCE   WildFly instance (server-config) to check when running
                        in domain mode.
  --mode {standalone,domain}
                        WildFly server mode. Default: standalone
  --no-proxy            Do not use a proxy.
  --node NODE           WildFly node (host) when running in domain mode.
  -p, --password PASSWORD
                        WildFly management API password.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             WildFly management API URL. Default:
                        http://localhost:9990
  --username USERNAME   WildFly management API username. Default: wildfly-
                        monitoring
```


## Usage Examples

```bash
./wildfly-memory-pool-usage --username=wildfly-monitoring --password=password --url=http://wildfly:9990
```

Output:

```text
Everything is ok.

name                   ! Type     ! Usage used / committed / max    ! Collection used / committed/ max 
-----------------------+----------+---------------------------------+----------------------------------
Code_Cache             ! NON_HEAP ! 37.6MiB / 38.1MiB / 240.0MiB   ! N/A                              
Metaspace              ! NON_HEAP ! 124.6MiB / 137.4MiB / 256.0MiB ! N/A                              
Compressed_Class_Space ! NON_HEAP ! 16.7MiB / 20.1MiB / 248.0MiB   ! N/A                              
Eden_Space             ! HEAP     ! 28.3MiB / 43.8MiB / 136.5MiB   ! 0.0B / 43.8MiB / 136.5MiB        
Survivor_Space         ! HEAP     ! 86.0KiB / 5.4MiB / 17.1MiB     ! 86.0KiB / 5.4MiB / 17.1MiB       
Tenured_Gen            ! HEAP     ! 65.7MiB / 109.0MiB / 341.4MiB  ! 65.4MiB / 81.8MiB / 341.4MiB
```


## States

* OK if no memory pool issues are detected.
* WARN if a memory pool instance is invalid.
* WARN if the usage threshold of any memory pool has been exceeded.
* WARN if the collection usage threshold of any memory pool has been exceeded.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| memory-pool-NAME-collection-usage-committed | Bytes | Only if "Collection Usage" is enabled. |
| memory-pool-NAME-collection-usage-init | Bytes | Only if "Collection Usage" is enabled. |
| memory-pool-NAME-collection-usage-max | Bytes | Only if "Collection Usage" is enabled. |
| memory-pool-NAME-collection-usage-used | Bytes | Only if "Collection Usage" is enabled. |
| memory-pool-NAME-usage-committed | Bytes | Amount of memory reserved at the OS level for the JVM process. |
| memory-pool-NAME-usage-init | Bytes | Initial amount of memory requested from the OS at startup (controlled by `-Xms`). |
| memory-pool-NAME-usage-max | Bytes | Maximum amount of memory the JVM will try to allocate (controlled by `-Xmx`). |
| memory-pool-NAME-usage-used | Bytes | Amount of memory actually in use, including unreachable objects not yet garbage collected. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
