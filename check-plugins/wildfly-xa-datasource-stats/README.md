# Check wildfly-xa-datasource-stats

## Overview

Monitors XA datasource connection pool metrics on a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode. Reports active, available, and idle connections per datasource, including XA transaction counters.

**Data Collection:**

* Queries the WildFly management API at `/subsystem/datasources/xa-data-source/*/statistics/pool/` using the `read-resource` operation with runtime data
* Authenticates via HTTP Digest Auth (`--username`, `--password`)
* Specific datasources can be checked using `--datasource` (repeatable); if omitted, all XA datasources are checked
* The check detects if statistics are not enabled for a datasource and reports this accordingly

**Important Notes:**

* Tested with WildFly 11 and WildFly 23+
* To enable database statistics:

    * Open the WildFly Admin Console
    * Go to Configuration > Subsystems > Datasources & Drivers > Datasources
    * Select your datasource
    * Click on View > Tab Attributes > Edit "Statistics Enabled"

**Compatibility:**

* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)


## 