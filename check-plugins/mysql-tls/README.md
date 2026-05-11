# Check mysql-tls


## Overview

Checks MySQL/MariaDB TLS/SSL posture: the monitoring connection itself, the server's TLS capability (`have_ssl`), enforcement (`require_secure_transport`), enabled TLS versions (no TLSv1.0/1.1, at least TLSv1.2 or TLSv1.3), the presence of a server certificate and key, the local expiry of `ssl_cert` and `ssl_ca` files (when readable on the same host), and any remote accounts that can still connect without `REQUIRE SSL`. Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):ssl_tls_recommendations(), check_local_certificates() and check_remote_user_ssl(), verified in sync with MySQLTuner v2.8.41.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* The session-cipher check reflects the monitoring connection only. To verify it, configure SSL in the monitoring `.my.cnf` (for example `ssl=true` or `ssl-ca=/etc/pki/tls/certs/ca.crt`) so `pymysql` negotiates TLS
* The local certificate expiry check is silently skipped when the file path is empty. When the path is set but the file is missing or unreadable (typical for a remote monitoring host), the plugin reports "expiry check skipped" without raising an alert
* The local certificate expiry check requires the Python `cryptography` module; if it is not installed the check is skipped with a clear reason and no alert
* mysqltuner's local-cert audit only checks `ssl_cert` and `ssl_ca` (not `ssl_key`); we follow the same scope - no key match, no CN/SAN check
* The remote-user check uses the same host filter as mysqltuner (`host NOT IN ('localhost', '127.0.0.1', '::1')`) and reads `mysql.global_priv` on MariaDB 10.4+ and `mysql.user.ssl_type` otherwise

**Data Collection:**

* Reads `SHOW GLOBAL VARIABLES` once for `have_ssl`, `require_secure_transport`, `tls_version`, `ssl_cert`, `ssl_key`, `ssl_ca` and `version`
* Reads `SHOW SESSION STATUS LIKE 'Ssl_cipher'` to detect whether the monitoring connection is encrypted
* Queries `mysql.user` (or `mysql.global_priv` on MariaDB 10.4+) for remote accounts without `REQUIRE SSL`
* Reads the `ssl_cert` and `ssl_ca` files via the `cryptography` Python module to derive the days until expiry, when the files are locally readable


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-tls> |
| Nagios/Icinga Check Name              | `check_mysql_tls` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `SELECT` privilege on `mysql.*` (or `*.*`), locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. For the local certificate expiry check, the user running the plugin must be able to read the files referenced by `ssl_cert` / `ssl_ca` (typically only true on the database host itself). |
| 3rd Party Python modules              | `pymysql`, optionally `cryptography` (for the local cert expiry check) |


## Help

```text
usage: mysql-tls [-h] [-V] [--always-ok] [-c CRIT]
                 [--defaults-file DEFAULTS_FILE]
                 [--defaults-group DEFAULTS_GROUP] [--severity {warn,crit}]
                 [--timeout TIMEOUT] [-w WARN]

Checks MySQL/MariaDB TLS/SSL posture: the monitoring connection itself, the
server's TLS capability (`have_ssl`), enforcement
(`require_secure_transport`), enabled TLS versions (no TLSv1.0/1.1, at least
TLSv1.2 or TLSv1.3), the presence of a server certificate and key, the local
expiry of `ssl_cert` and `ssl_ca` files (when readable on the same host), and
any remote accounts that can still connect without `REQUIRE SSL`. Each finding
maps to a copy-pasteable SQL or `openssl` recommendation.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   Days until local `ssl_cert` / `ssl_ca` expiry that
                        trigger CRIT. Supports Nagios ranges. Example:
                        `--critical=14:`. Default: 7:
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --severity {warn,crit}
                        Severity for the threshold-less TLS findings (session
                        not encrypted, `have_ssl=DISABLED`,
                        `require_secure_transport=OFF`, weak TLS versions,
                        missing cert/key, remote users without `REQUIRE SSL`).
                        One of `warn` or `crit`. Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARN    Days until local `ssl_cert` / `ssl_ca` expiry that
                        trigger WARN. Supports Nagios ranges. Example:
                        `--warning=60:`. Default: 30:
```


## Usage Examples

```bash
./mysql-tls --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. Monitoring connection encrypted (TLS_AES_256_GCM_SHA384). `have_ssl` enabled. `require_secure_transport` = ON. TLS versions: TLSv1.2, TLSv1.3. `ssl_cert` (/etc/mysql/ssl/server.pem) expires in 318d. `ssl_ca` (/etc/mysql/ssl/ca.pem) expires in 1825d. 0 remote users without `REQUIRE SSL`.
```

WARN output:

```text
Monitoring connection not encrypted [WARNING]. `have_ssl` enabled. `require_secure_transport` = OFF [WARNING]. 1 insecure TLS version enabled (in `TLSv1.1, TLSv1.2, TLSv1.3`) [WARNING]. `ssl_cert` (/etc/mysql/ssl/server.pem) expires in 12d [WARNING]. `ssl_ca` (/etc/mysql/ssl/ca.pem) expiry check skipped (file not readable: /etc/mysql/ssl/ca.pem). 2 remote users without `REQUIRE SSL` [WARNING].

Recommendations:
* Add `ssl=true` (or `ssl-ca=...`) to the [client] section of the monitoring `.my.cnf`, and ensure the server is reachable over TLS.
* `SET GLOBAL require_secure_transport = 'ON';`
* Persist `require_secure_transport = ON` in the server config so the setting survives restarts.
* Set `tls_version=TLSv1.2,TLSv1.3` in your server config and restart the service.
* Renew `ssl_cert` (/etc/mysql/ssl/server.pem) and reload the server.
* `ALTER USER 'app'@'10.%' REQUIRE SSL;`
* `ALTER USER 'replica'@'10.0.0.5' REQUIRE SSL;`
```


## States

* OK if every finding passes.
* `--severity warn` (default) or `--severity crit` controls the state returned for each of the threshold-less findings (session not encrypted, `have_ssl=DISABLED`, `require_secure_transport=OFF`, weak TLS versions, missing cert/key, remote users without `REQUIRE SSL`).
* The local certificate expiry check has its own thresholds via `--warning` / `--critical` (Nagios ranges, defaults `30:` warn / `7:` crit). An already-expired certificate is always CRIT.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_tls_have_ssl | Number (0/1) | `1` when `have_ssl` is `YES` or `ON`, `0` otherwise. |
| mysql_tls_modern_protocol_versions | Number | Count of modern TLS versions enabled in `tls_version` (0-2: TLSv1.2 and/or TLSv1.3). |
| mysql_tls_remote_users_without_ssl | Number | Count of accounts on a non-localhost host that can connect without `REQUIRE SSL`. |
| mysql_tls_required | Number (0/1) | `1` when `require_secure_transport` is `ON`. Always `0` on servers that do not expose the variable (very old MySQL/MariaDB). |
| mysql_tls_session_encrypted | Number (0/1) | `1` when the monitoring connection itself uses TLS (non-empty `Ssl_cipher`). |
| mysql_tls_ssl_ca_days_until_expiry | Number (d) | Days until the local `ssl_ca` file expires. Omitted when no `ssl_ca` is configured or the file is not readable. |
| mysql_tls_ssl_cert_days_until_expiry | Number (d) | Days until the local `ssl_cert` file expires. Omitted when no `ssl_cert` is configured or the file is not readable. |
| mysql_tls_weak_protocol_versions | Number | Count of insecure TLS versions enabled in `tls_version` (0-2: TLSv1.0 and/or TLSv1.1). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
