# Check wildfly-server-status

## Overview

Checks the overall server status of a WildFly/JBoss AS instance via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode. Reports server state, launch type, running mode, and product version.

**Data Collection:**

* Queries the WildFly management API for `server-state`, `launch-type`, `running-mode`, and `product-version` (falls back to `release-version` if `product-version` is not available)
* Authenticates via HTTP Digest Auth (`--username`, `--password`)

**Compatibility:**

* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)

**Important Notes:**

* Tested with WildFly 11 and WildFly 23+


## 