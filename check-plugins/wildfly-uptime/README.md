# Check wildfly-uptime

## Overview

Reports the uptime of a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode. Useful for detecting application servers that have not been restarted after deployments or updates.

**Data Collection:**

* Queries the WildFly management API at `/core-service/platform-mbean/type/runtime` using the `read-resource` operation with runtime data
* Authenticates via HTTP Digest Auth (`--username`, `--password`)

**Compatibility:**

* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)

**Important Notes:**

* Tested with WildFly 11 and WildFly 23+


## 