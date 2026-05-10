# Check cert


## Overview

Inspects an X.509 certificate and alerts on days remaining until expiry, hostname mismatch and chain verification failures. Two sources via `--source`: `url` connects to a TLS endpoint, runs a TLS handshake and captures the server certificate; `file` reads one or many local certificate files, with glob expansion for batch monitoring of cert directories. With `--source=url` the plugin only runs the TLS handshake and reads the server certificate (no HTTP request is sent), so it works for any "TLS from start" service - HTTPS, IMAPS, LDAPS, SMTPS, AMQPS, MQTTS, custom TLS ports. STARTTLS-style upgrades on plaintext ports (SMTP 587, IMAP 143, LDAP 389) are not supported. `p12` and `jks` sources are reserved for future expansion without renaming the plugin or breaking existing service templates.

**Important Notes:**

* `--source=url`: Hostname mismatch and chain verification failures share one `--severity` (default WARN), so operators running internal CAs are not paged for trust issues that are expected in their environment. Set `--severity=crit` to enforce strict trust.
* `--source=file`: chain and hostname checks are not performed. Only days remaining is evaluated. With a glob that matches many files, the worst state across all matches drives the plugin state.
* Expired certificates are unconditionally reported as CRIT, regardless of the `--warning` and `--critical` thresholds.
* `--insecure` skips chain and hostname verification entirely (only meaningful for `--source=url`). The certificate is still fetched and inspected, the chain verdict is then reported as "verification skipped".
* When a PEM file contains multiple certificates (for example `fullchain.pem`, a CA bundle, or a chain file), each certificate becomes its own item in the output and is checked independently. So a `fullchain.pem` with leaf plus one intermediate produces two rows in the table; the worst state across all of them drives the plugin state. To check only the leaf, point `--filename` at a single-cert file like `cert.pem`.
* What "chain verified" actually covers: the leaf chains to a trust anchor in the system trust store (or `--ca-file`) using the intermediates the server sent or that the local trust store has cached, every certificate in the verified path is within its `notBefore`/`notAfter` window, every signature in that path is cryptographically valid, and the value of `--sni-hostname` (or, when not set, the host part of `--url`) appears in the leaf certificate's `subjectAltName` (or `CommonName` for legacy certs). What it does **not** cover: OCSP responder lookups, CRL checks, Certificate Transparency / SCT validation, enforcement of the order in which the server sends the chain, detection of SHA-1 in the verified chain, and the completeness of the chain the server sent (a server that omits intermediates may still verify locally if they are cached, but break for clients with empty caches). For those compliance-style checks use a dedicated TLS scanner like `sslyze`.

**Data Collection:**

* `--source=url`: opens a TCP connection to the host and port from `--url`, runs a TLS handshake and reads the server certificate. No HTTP request is sent. The chain is verified against the system trust store; pass `--ca-file` to use a custom CA bundle. `--sni-hostname` overrides the SNI value sent during the handshake; `--client-cert` and `--client-key` attach a client certificate for mutual TLS.
* `--source=file`: reads each file matching `--filename` (PEM or DER, autodetected) and parses every certificate found. PEM bundles expand to one item per certificate. `--filename` supports glob (`*`, `?`, `[abc]`) and recursive glob (`**`). When the glob matches files that don't look like certificates (private keys, plain text), they are silently skipped so recursive scans of `/etc/ssl/**` are safe. **Always quote the glob pattern**, otherwise the shell expands it before the plugin sees it and only the first match reaches `--filename`.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cert> |
| Nagios/Icinga Check Name              | `check_cert` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | No (`--source` plus `--url` or `--filename`) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `cryptography` |


## Help

```text
usage: cert [-h] [-V] [--always-ok] [--ca-file CA_FILE]
            [--client-cert CLIENT_CERT] [--client-key CLIENT_KEY] [-c CRIT]
            [--filename FILENAME] [--insecure] [--lengthy]
            [--severity {crit,warn}] [--sni-hostname SNI_HOSTNAME]
            [--source {file,url}] [--timeout TIMEOUT] [--url URL] [-w WARN]

Inspects an X.509 certificate and alerts on days remaining until expiry,
hostname mismatch and chain verification failures. Sources via --source: `url`
fetches the certificate from a TLS endpoint and verifies the chain against the
system trust store by default (override with --ca-file); `file` reads one or
many certificate files via glob expansion (PEM or DER). PEM bundles expand to
one item per certificate, so a fullchain.pem produces a row for the leaf and a
row for each intermediate. With --source url the plugin only runs the TLS
handshake and reads the server certificate; no HTTP request is sent. That
means it works for any "TLS from start" service, not only HTTPS: IMAPS (port
993), LDAPS (636), SMTPS (465), AMQPS (5671), MQTTS (8883), custom TLS ports -
just point --url at the right host and port (`https://mail.example.com:993/`
inspects the IMAPS cert). STARTTLS protocols that upgrade an existing
plaintext connection (SMTP submission on 587, IMAP on 143, LDAP on 389) are
not supported. Hostname mismatch and chain verification failures share one
--severity (warn or crit) and only apply to --source url. Expired certificates
are unconditionally reported as CRIT. With --source file, the worst state
across all matched files drives the plugin state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --ca-file CA_FILE     Path to a CA bundle in PEM format used for chain
                        verification. Default uses the system trust store.
  --client-cert CLIENT_CERT
                        Path to a client certificate in PEM format for mutual
                        TLS.
  --client-key CLIENT_KEY
                        Path to the client certificate private key in PEM
                        format.
  -c, --critical CRIT   CRIT threshold for days remaining until the
                        certificate expires. Supports Nagios ranges. Example:
                        `5:` (CRIT when below 5 days). Default: 5:
  --filename FILENAME   Path to a certificate file or a glob pattern matching
                        multiple certificate files. Required when
                        --source=file. Files are read as PEM or DER
                        (autodetected); when a PEM bundle contains multiple
                        certificates (typical for fullchain.pem or a CA
                        bundle), each certificate becomes its own row in the
                        output. Globs follow Python conventions: `*` matches
                        one path segment, `**` matches across directories.
                        Always quote the pattern in shells so that the shell
                        does not expand the wildcard before the plugin sees
                        it. Example: `--filename='/etc/ssl/certs/*.pem'`.
                        Recursive example:
                        `--filename='/etc/letsencrypt/live/**/cert.pem'`
  --insecure            Skip chain and hostname verification entirely. The
                        certificate is still fetched and inspected, but the
                        chain verdict is reported as "verification skipped".
  --lengthy             Extended reporting.
  --severity {crit,warn}
                        Severity assigned to hostname mismatch and chain
                        verification failures. Defaults to warn so that
                        operators running internal CAs are not paged by trust
                        issues that are expected in their environment. Set to
                        `crit` to enforce strict trust.
  --sni-hostname SNI_HOSTNAME
                        SNI hostname sent during the TLS handshake and used
                        for hostname verification. Useful when --url points at
                        an IP address or a load balancer that needs an
                        explicit SNI. Default uses the hostname from --url.
  --source {file,url}   Where the certificate is fetched from. `url` fetches
                        it from a TLS endpoint (requires --url). `file` reads
                        it from one or many local files (requires --filename,
                        supports glob patterns). `p12` and `jks` are reserved
                        for future expansion. Default: url
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             URL of the TLS endpoint to inspect. Required when
                        --source=url. Example: `https://www.example.com/`
  -w, --warning WARN    WARN threshold for days remaining until the
                        certificate expires. Supports Nagios ranges. Example:
                        `14:` (WARN when below 14 days). Default: 14:
```


## Usage Examples

```bash
./cert --source=url --url=https://www.example.com/
```

Output (default, OK):

```text
www.example.com, 61d left, chain verified|'cert_days_left'=61d;14:;5: 'tls_handshake_time'=0.07s;;;0
```

Self-signed certificate, default `--severity=warn`:

```bash
./cert --source=url --url=https://internal.example.com/
```

Output:

```text
internal.example.com, 725d left [WARNING], chain unverified (self-signed certificate)|'cert_days_left'=725d;14:;5: 'tls_handshake_time'=0.5s;;;0
```

Skip chain verification entirely (still inspect the cert), pin a custom CA bundle, attach mTLS client cert, override SNI:

```bash
./cert --source=url --url=https://api.example.com/ --insecure
./cert --source=url --url=https://api.example.com/ --ca-file=/etc/pki/ca-trust/source/anchors/internal.pem
./cert --source=url --url=https://api.example.com/ --client-cert=/etc/icinga2/client.pem --client-key=/etc/icinga2/client.key
./cert --source=url --url=https://10.0.0.5/ --sni-hostname=api.example.com
```

Inspect a local certificate file:

```bash
./cert --source=file --filename=/etc/letsencrypt/live/example.com/cert.pem
```

Batch-inspect every certificate under a directory via glob, including recursive descent. Note the single quotes - they keep the shell from expanding the wildcard before the plugin sees it:

```bash
./cert --source=file --filename='/etc/ssl/certs/*.pem' --warning=14: --critical=5:
./cert --source=file --filename='/etc/pki/**/*.crt'
./cert --source=file --filename='/etc/letsencrypt/live/**/cert.pem'
```

Inspect a non-HTTPS TLS service - point `--url` at the service's TLS port:

```bash
./cert --source=url --url=https://mail.example.com:993/   # IMAPS
./cert --source=url --url=https://ldap.example.com:636/   # LDAPS
./cert --source=url --url=https://smtp.example.com:465/   # SMTPS
```

Output (multiple files, one expired):

```text
3 certificates checked, worst -42d left [CRITICAL]

File                                  ! Subject CN              ! Days Left ! State
--------------------------------------+-------------------------+-----------+-----------
/etc/ssl/certs/web1.pem               ! www1.example.com        ! 90        ! [OK]
/etc/ssl/certs/web2.pem               ! www2.example.com        ! -42       ! [CRITICAL]
/etc/ssl/certs/web3.pem               ! www3.example.com        ! 100       ! [OK]
```

With `--lengthy`:

```text
www.example.com, 61d left, chain verified

Field               ! Value
--------------------+--------------------------------------------------
Subject CN          ! www.example.com
Issuer CN           ! R13
Serial              ! 5700EBF15B911BC3D902A0BFE488552C112
Signature Algorithm ! sha256WithRSAEncryption
Public Key          ! RSA 4096
SANs                ! www.example.com
Not Before          ! 2026-04-11T22:19:04Z
Not After           ! 2026-07-10T22:19:03Z
SHA-256 Fingerprint ! BF:DF:BB:23:93:A9:31:CD:8B:B9:A9:61:18:6D:0A:07
TLS Version         ! TLSv1.3
Chain               ! verified
```


## States

* OK if the certificate is within `--warning` and `--critical` thresholds, the chain verifies and the hostname matches.
* WARN if days remaining hits `--warning` (default `14:`), or chain/hostname verification fails and `--severity` is `warn` (default).
* CRIT if days remaining hits `--critical` (default `5:`), the certificate is expired, or chain/hostname verification fails and `--severity` is `crit`.
* UNKNOWN on connection errors, TLS handshake failures, missing `--url`, missing `cryptography` Python module, or invalid command-line arguments.
* `--always-ok` suppresses all alerts and always returns OK.
* `--insecure` reports the chain as "verification skipped" and never raises a chain-related state.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cert_days_left | Days | Days remaining until the certificate's `notAfter` date. Negative when expired. |
| tls_handshake_time | Seconds | Wall-clock time for the TCP connect plus TLS handshake. |


## Troubleshooting

`Python module "cryptography" is not installed.`  
Install `cryptography`: `pip install cryptography` or `dnf install python3-cryptography`.

`Cannot connect to host:port: ...`  
The TCP connection failed. Check DNS, firewall, the port number in `--url` and `--timeout`.

`TLS handshake failed for host:port: ...`  
The server rejected the TLS handshake. Possible causes: TLS version mismatch, unsupported cipher, missing SNI (try `--sni-hostname`), missing client certificate (try `--client-cert` / `--client-key`).

`chain unverified (...)`  
The chain did not verify against the system trust store. The reason in parentheses is the OpenSSL verification message; common values are `self-signed certificate`, `unable to get local issuer certificate`, `certificate has expired` and `Hostname mismatch, certificate is not valid for ...`. Pass `--ca-file` for internal CAs, `--sni-hostname` for hostname mismatches caused by SNI, or `--insecure` to bypass the check entirely.

`No files match "<pattern>"`  
The glob did not expand to any path. Two likely causes: the path is wrong, or the shell expanded the glob before the plugin saw it. Always quote glob patterns: `--filename='/etc/ssl/**/*.pem'` instead of `--filename=/etc/ssl/**/*.pem`.

`No parseable certificates among N file(s) matching "<pattern>"`  
The glob matched files, but none of them looked like a certificate (no PEM `BEGIN CERTIFICATE` marker and no DER signature). Tighten the pattern (for example `*.crt` instead of `*`) or point `--filename` directly at a known cert file.

`Cannot parse certificate from /path/to/file: ...`  
The file looks like a certificate (PEM marker present or DER prefix detected) but the content is corrupt or in an unsupported encoding. Inspect the file with `openssl x509 -in /path/to/file -noout -text` to see the underlying error.

`Cannot read /path/to/file: ...`  
The plugin could not read the file. Typical cause is permissions: certificate files are sometimes mode `0600` and owned by the service account, in which case the monitoring user has no read access. Either grant read permission or copy the public certificate to a path the monitoring user can read.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
