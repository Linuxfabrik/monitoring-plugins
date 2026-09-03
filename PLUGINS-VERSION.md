# Version Plugins

The version plugins answer one question: is the software installed here still
supported, and is there something newer? They differ only in how they read the
installed version. Almost all of them then judge it against
[endoflife.date](https://endoflife.date/), which is why that half is described
once here rather than in every README.


## endoflife.date-based Version Plugins

These 28 plugins share the same verdict logic. Each one reads the installed
version its own way and hands it to the same routine, so everything below
applies to all of them:

| Plugin | endoflife.date page |
|----|----|
| `apache-httpd-version` | [apache-http-server](https://endoflife.date/apache-http-server) |
| `apache-solr-version` | [solr](https://endoflife.date/solr) |
| `apache-tomcat-version` | [tomcat](https://endoflife.date/tomcat) |
| `composer-version` | [composer](https://endoflife.date/composer) |
| `fedora-version` | [fedora](https://endoflife.date/fedora) |
| `fortios-version` | [fortios](https://endoflife.date/fortios) |
| `gitlab-version` | [gitlab](https://endoflife.date/gitlab) |
| `grafana-version` | [grafana](https://endoflife.date/grafana) |
| `graylog-version` | [graylog](https://endoflife.date/graylog) |
| `icinga-version` | [icinga](https://endoflife.date/icinga) |
| `keycloak-version` | [keycloak](https://endoflife.date/keycloak) |
| `mastodon-version` | [mastodon](https://endoflife.date/mastodon) |
| `matomo-version` | [matomo](https://endoflife.date/matomo) |
| `mediawiki-version` | [mediawiki](https://endoflife.date/mediawiki) |
| `moodle-version` | [moodle](https://endoflife.date/moodle) |
| `mysql-version` | [mariadb](https://endoflife.date/mariadb), [mysql](https://endoflife.date/mysql) |
| `nextcloud-version` | [nextcloud](https://endoflife.date/nextcloud) |
| `openjdk-redhat-version` | [redhat-build-of-openjdk](https://endoflife.date/redhat-build-of-openjdk) |
| `openvpn-version` | [openvpn](https://endoflife.date/openvpn) |
| `php-version` | [php](https://endoflife.date/php) |
| `postfix-version` | [postfix](https://endoflife.date/postfix) |
| `postgresql-version` | [postgresql](https://endoflife.date/postgresql) |
| `python-version` | [python](https://endoflife.date/python) |
| `redis-version` | [redis](https://endoflife.date/redis) |
| `rhel-version` | [rhel](https://endoflife.date/rhel) |
| `rocketchat-version` | [rocket-chat](https://endoflife.date/rocket-chat) |
| `valkey-version` | [valkey](https://endoflife.date/valkey) |
| `wordpress-version` | [wordpress](https://endoflife.date/wordpress) |


### States

endoflife.date groups releases into cycles and answers the end of support per
cycle. The plugin looks up the cycle the installed version belongs to and
reports:

| Situation | State | Output says |
|----|----|----|
| The cycle ends on a date still ahead | OK | `EOL <date> <offset>d` |
| The cycle ended, or ends within `--offset-eol` days | WARN | `EOL <date> <offset>d [WARNING]` |
| The cycle has no announced end | OK | `no EOL announced` |
| The cycle is marked end of life without a date | WARN | `EOL, no date announced [WARNING]` |
| Full support ended but security support continues | see above | prefixed with `full support ended on <date>` |

The installed version does not always have a cycle of its own. Where it sits
relative to the cycles that *are* listed decides what that means:

| Situation | State | Output says |
|----|----|----|
| Newer than every listed cycle | OK | `newer than anything endoflife.date lists` |
| Older than every listed cycle | WARN | `older than anything endoflife.date lists` |
| Between two listed cycles, its own missing | UNKNOWN | `version <version> unknown` |

A release that endoflife.date has not catalogued yet is the normal state of
affairs for a host that updates promptly, and no administrator can act on it,
so it does not alert. A release below the oldest cycle upstream still records
is out of support for certain, even without a date saying so.

On top of the end-of-life verdict, the plugin reports a newer release whenever
one exists, and alerts on it only when asked:

* `--check-major`, `--check-minor`, `--check-patch` turn `major 9.7.2
  available` and its siblings into a WARN. Without them the note is still in
  the output, it just does not change the state.
* `--offset-eol` moves the warning window. The default `-30` warns 30 days
  before the end of life date, a positive value warns that many days after it.
* `--always-ok` suppresses every alert.


### When endoflife.date cannot be reached

The plugins ship a snapshot of the endoflife.date data and fall back to it when
the API does not answer, so a host without internet access still gets a verdict.
The snapshot ages with the release it came with; how much that matters is a
decision per environment, which is what `--unreachable-severity` is for:

* `ok` (default): use the snapshot and say so in the output.
* `warn`, `crit`, `unknown`: use the snapshot and raise the state, for
  environments where a stale verdict is not good enough.

A successful lookup is cached for 24 hours, keyed by the endoflife.date product.
Products do not share an entry, so a host running a dozen version checks makes a
dozen lookups. What the cache saves is the repetition over time, not the number
of products: a check scheduled every few minutes still reaches the API only once
per product per day. The bundled snapshot is deliberately not cached, so the next
run retries the API instead of hiding a persistent outage behind the cache.

The plugins reach the API through `--proxy`, or through the proxy the
environment names; `--no-proxy` ignores both.


### Reporting an outdated entry

The end-of-life dates come from endoflife.date, not from us. A cycle that is
missing, mis-dated or stale is fixed in
[their repository](https://github.com/endoflife-date/endoflife.date), and every
plugin picks the correction up on its next run.


## Version Plugins with their own source

Five plugins ask the vendor rather than endoflife.date, because there is no
endoflife.date product for them. They alert on an available update, not on an
end of life date, and their READMEs describe them in full:

* `librenms-version`: the LibreNMS instance information, version included.
* `mydumper-version`: the latest mydumper/myloader release.
* `nodebb-version`: the latest NodeBB release.
* `qts-version`: firmware updates from the QNAP update API.
* `wildfly-version`: the latest WildFly release.
