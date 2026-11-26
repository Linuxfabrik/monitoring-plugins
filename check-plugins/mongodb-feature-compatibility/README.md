# Check mongodb-feature-compatibility


## Overview

Checks whether the featureCompatibilityVersion of a MongoDB server matches the release of the running binaries. Alerts if it is lower, which means that an upgrade or a downgrade was not finished: features of the running release are not available, and the binaries of the next release refuse to start on the data files.

**Important Notes:**

* The check needs `mongosh`, which the `mongodb-org` package installs together with the server. It can run on any host with `mongosh` that reaches the MongoDB server, by default it connects to `127.0.0.1:27017`.
* With authorization enabled on the server (`security.authorization: enabled`), the check needs a MongoDB user, see "Creating a monitoring user" below. Without one, it reports UNKNOWN, also as a member of the MongoDB Service Set until the credentials are set on the host or the service.

**Data Collection:**

* Runs `mongosh --eval=<script> --host=<hostname> --norc --port=<port> --quiet` (configurable via `--path`) to read the version of the running server (`db.version()`) and its featureCompatibilityVersion (`db.adminCommand({getParameter: 1, featureCompatibilityVersion: 1})`)
* Logs in with `--username` and `--password` (or `--password-file`) after connecting, and hands the credentials to mongosh through the environment, so they do not show up in the process list of the host
* Compares the featureCompatibilityVersion against the major and minor version of the running server

**featureCompatibilityVersion:**

After the binaries of a MongoDB server have been upgraded, for example from 7.0 to 8.0, the server keeps its data files compatible with the previous release until the featureCompatibilityVersion is raised with `setFeatureCompatibilityVersion`. Until then, features of the new release are not available, and the binaries of the next major release refuse to start on these data files. The upgrade is only finished once the featureCompatibilityVersion matches the major and minor version of the server. A downgrade works the other way round: the featureCompatibilityVersion is lowered first, then the binaries are replaced.

**Creating a monitoring user:**

Reading the featureCompatibilityVersion requires the `getParameter` action on the cluster resource. The built-in role `clusterMonitor` grants it, among other read-only monitoring privileges. A role with nothing but this action is enough as well:

```javascript
db.getSiblingDB('admin').createRole({
    role: 'lfMonitoringGetParameter',
    privileges: [{resource: {cluster: true}, actions: ['getParameter']}],
    roles: [],
})
db.getSiblingDB('admin').createUser({
    user: 'monitoring',
    pwd: 'linuxfabrik',
    roles: ['lfMonitoringGetParameter'],
})
```

Pass the password with `--password-file` rather than `--password`, see [Credentials](https://linuxfabrik.github.io/monitoring-plugins/credentials/).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mongodb-feature-compatibility> |
| Nagios/Icinga Check Name              | `check_mongodb_feature_compatibility` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes (if authorization is disabled on the MongoDB server) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `mongosh`; with authorization enabled, a MongoDB user with the `getParameter` action on the cluster resource |


## Help

```text
usage: mongodb-feature-compatibility [-h] [-V] [--always-ok]
                                     [--authentication-database AUTHENTICATION_DATABASE]
                                     [--hostname HOSTNAME]
                                     [--password PASSWORD]
                                     [--password-file PASSWORD_FILE]
                                     [--path PATH] [--port PORT]
                                     [--timeout TIMEOUT] [--username USERNAME]

Checks whether the featureCompatibilityVersion of a MongoDB server matches the
release of the running binaries. Alerts if it is lower, which means that an
upgrade or a downgrade was not finished: features of the running release are
not available, and the binaries of the next release refuse to start on the
data files.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --authentication-database AUTHENTICATION_DATABASE
                        Database in which the MongoDB user given by
                        `--username` is defined. Default: admin
  --hostname HOSTNAME   MongoDB server hostname or IP address. Default:
                        127.0.0.1
  --password PASSWORD   Password of the MongoDB user given by `--username`.
  --password-file PASSWORD_FILE
                        Path to a file holding the password, read from its
                        first line. Keeps the password out of the process
                        list, where a command-line argument is visible to
                        every user on the host. Takes precedence over
                        `--password`. Keep the file readable only by the
                        monitoring user. Example: `--password-
                        file=/etc/icinga2/secrets/storage`.
  --path PATH           Path to the mongosh binary. Resolved via $PATH when
                        given without a directory. Default: mongosh
  --port PORT           MongoDB server port. Default: 27017
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --username USERNAME   MongoDB user to log in with. Without it, the check
                        does not log in, which only works if authorization is
                        disabled on the server.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mongodb-feature-compatibility/
```


## Usage Examples

```bash
./mongodb-feature-compatibility --username=monitoring --password-file=/etc/icinga2/secrets/mongodb
```

Output:

```text
MongoDB v8.0.38, featureCompatibilityVersion 8.0
```

The binaries were upgraded from 7.0 to 8.0, but the featureCompatibilityVersion was not raised:

```text
MongoDB v8.0.38, featureCompatibilityVersion 7.0 [WARNING]
It is lower than the release of the binaries, 8.0. Either the upgrade to 8.0 is not finished, finish it with `db.adminCommand({setFeatureCompatibilityVersion: "8.0", confirm: true})`. Or the downgrade to 7.0 is finished, and the binaries of 7.0 are still to be installed.
```

A `setFeatureCompatibilityVersion` from 8.0 to 9.0 failed halfway:

```text
MongoDB v9.0.8, featureCompatibilityVersion 8.0, upgrade from 8.0 to 9.0 not finished [WARNING]
Finish it with `db.adminCommand({setFeatureCompatibilityVersion: "9.0", confirm: true})`.
```


## States

* OK if the featureCompatibilityVersion matches the major and minor version of the running server.
* WARN if the featureCompatibilityVersion is lower than the major and minor version of the running server.
* WARN while an upgrade or a downgrade of the featureCompatibilityVersion is in progress or failed halfway, also if the featureCompatibilityVersion already matches the running server.
* WARN if mongosh does not answer within `--timeout` (default: 8 seconds), for example because the host is unreachable.
* UNKNOWN if mongosh cannot connect to the server, the login fails, the user is not allowed to read the featureCompatibilityVersion, or only one of `--username` and `--password` is given.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Troubleshooting

### `requires a login to read the featureCompatibilityVersion`

Authorization is enabled on the MongoDB server, and the check was called without `--username`. Create a monitoring user as described in "Creating a monitoring user" above and pass it with `--username` and `--password-file`.

### `does not let the user ... read the featureCompatibilityVersion`

The login worked, but the user lacks the `getParameter` action on the cluster resource. Grant it the `clusterMonitor` role, or a role with only this action, for example `db.getSiblingDB('admin').grantRolesToUser('monitoring', ['lfMonitoringGetParameter'])`.

### `Failed to authenticate: MongoDB rejected the username or password.`

The username or the password is wrong, or the user is defined in another database than the one given by `--authentication-database` (default: `admin`). `db.getSiblingDB('<database>').getUsers()` lists the users of a database.

### `mongosh could not connect to MongoDB at 127.0.0.1:27017: MongoNetworkError: connect ECONNREFUSED 127.0.0.1:27017`

The MongoDB server is not running, or it does not listen on the address and port given by `--hostname` and `--port`. Check `systemctl status mongod` and `net.bindIp` and `net.port` in `/etc/mongod.conf`.

### featureCompatibilityVersion lower than the binaries

`featureCompatibilityVersion 7.0 [WARNING]` / `It is lower than the release of the binaries, 8.0.`

Either the binaries were upgraded and the featureCompatibilityVersion was not raised yet, or a downgrade of the featureCompatibilityVersion is complete and the binaries of the older release are not installed yet. To finish an upgrade:

1. Make sure that all members of a replica set or sharded cluster run the new binaries.
2. Make sure that you do not want to go back to the previous release: after raising the featureCompatibilityVersion, a downgrade requires lowering it first.
3. Run the command the check names as a user with the `clusterManager` or `root` role, for example `db.adminCommand({setFeatureCompatibilityVersion: "8.0", confirm: true})`. On a replica set, run it on the primary.

To finish a downgrade, replace the binaries with those of the release the featureCompatibilityVersion names.

### Upgrade or downgrade not finished

`featureCompatibilityVersion 8.0, upgrade from 8.0 to 9.0 not finished [WARNING]`

An earlier `setFeatureCompatibilityVersion` did not complete. Run the command the check names again until it succeeds, for example `db.adminCommand({setFeatureCompatibilityVersion: "9.0", confirm: true})`. Going back to the release it started from instead is only possible while the featureCompatibilityVersion still names that release, as in the example above. Once it names the target (`featureCompatibilityVersion 9.0, upgrade from 8.0 to 9.0`, and every interrupted downgrade), MongoDB refuses to go back until the transition is finished.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
