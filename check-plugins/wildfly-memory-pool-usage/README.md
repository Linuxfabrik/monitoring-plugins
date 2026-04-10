# Check wildfly-memory-pool-usage

## Overview

Checks Java memory pool usage (Eden, Survivor, Old Gen, Metaspace, Compressed Class Space, Code Cache, etc.) on a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode.

**Data Collection:**

* Queries the WildFly management API at `/core-service/platform-mbean/type/memory-pool` using the `read-resource` operation with runtime data
* Authenticates via HTTP Digest Auth (`--username`, `--password`)
* Reports used/committed/max for each pool, both for regular usage and collection usage (if available)
* Peak values are intentionally ignored as they are not relevant in a monitoring scenario with frequent checks

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

**Compatibility:**

* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)


## 