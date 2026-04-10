# Check wildfly-deployment-status

## Overview

Checks the deployment status of applications on a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode.

**Data Collection:**

* Queries the WildFly management API at `/deployment/*` using the `read-attribute` operation for the `status` attribute
* Authenticates via HTTP Digest Auth (`--username`, `--password`)
* Specific deployments can be checked using `--deployment` (repeatable); if omitted, all deployments are checked

**Compatibility:**

* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)

**Important Notes:**

* Tested with WildFly 11 and WildFly 23+


## 