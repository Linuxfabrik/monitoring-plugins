# WildFly Plugins

The WildFly plugins talk to the WildFly / JBoss EAP HTTP management API
(`/management`, default port `9990`). They work for both standalone and
domain modes; in domain mode you additionally pass `--node` and `--instance`
to select the managed server to query.


## Plugins in this group

* `wildfly-deployment-status`: state of every deployed application
  (`.war`, `.ear`).
* `wildfly-gc-status`: garbage-collection activity.
* `wildfly-memory-pool-usage`: JVM memory pool utilization (Eden, Old Gen,
  Metaspace, ...).
* `wildfly-memory-usage`: JVM heap and non-heap totals.
* `wildfly-non-xa-datasource-stats`: connection-pool stats for non-XA
  datasources.
* `wildfly-server-status`: overall server state (alerts when the server is
  not `running`).
* `wildfly-thread-usage`: thread counts (current, daemon, peak).
* `wildfly-uptime`: server uptime.
* `wildfly-xa-datasource-stats`: connection-pool stats for XA datasources.


## Authentication

WildFly's management API requires a user in the `ManagementRealm`. Create
one with the shipped `add-user.sh` script:

```bash
/opt/wildfly/bin/add-user.sh
```

```text
What type of user do you wish to add?
 a) Management User (mgmt-users.properties)
 b) Application User (application-users.properties)
(a): a

Enter the details of the new user to add.
Using realm 'ManagementRealm' as discovered from the existing property files.
Username : wildfly-monitoring
Password :
Re-enter Password :
What groups do you want this user to belong to? (Please enter a comma
separated list, or leave blank for none)[  ]:
About to add user 'wildfly-monitoring' for realm 'ManagementRealm'
Is this correct yes/no? yes
Is this new user going to be used for one AS process to connect to another
AS process?
e.g. for a slave host controller connecting to the master or for a Remoting
connection for server to server Jakarta Enterprise Beans calls.
yes/no? no
```

The plugins are then called with `--url` (e.g.
`http://localhost:9990`), `--username=wildfly-monitoring` and `--password`.


## Common parameters

Shared across all WildFly plugins (run `<plugin> --help` for the full list):

* `--url`: WildFly management API base URL. Default `http://localhost:9990`.
* `--username` / `--password`: credentials of the management user.
* `--mode`: `standalone` (default) or `domain`.
* `--node`: host-controller name to query. Domain mode only.
* `--instance`: server-config name to query. Domain mode only.
* `--insecure`: skip TLS certificate verification.
* `--no-proxy`: ignore `HTTP_PROXY` / `HTTPS_PROXY`.
* `--timeout`: network timeout in seconds.


## Service Sets in the Icinga Director Basket

The shipped basket provides two Service Sets, each activated by its own tag
on the host:

* **Wildfly Service Set**: the full plugin suite against a WildFly server
  reachable on its management port. Assigned by the `wildfly` tag.
* **Wildfly Service Set (Containerized)**: the same plugins, but parameters
  default to a container-friendly setup (for example, adjusted URL and
  timeout values). Assigned by the `wildfly-container` tag.
