# Check cert


## Overview

Inspects X.509 certificates and alerts on days remaining until expiry, hostname mismatch and chain verification failures. Three sources via `--source`: `url` connects to a single TLS endpoint, runs a TLS handshake and captures the server certificate; `file` reads one or many local certificate files, with glob expansion for batch monitoring of cert directories; `scan` discovers the hosts of a subnet (the default interface's subnet, a chosen interface, an explicit network in CIDR notation, or an explicit host list) and probes each host on the ports given by `--ports`, inspecting every certificate it gets. With `--source=url` the plugin only runs the TLS handshake and reads the server certificate (no HTTP request is sent), so it works for any "TLS from start" service - HTTPS, IMAPS, LDAPS, SMTPS, AMQPS, MQTTS, custom TLS ports. STARTTLS-style upgrades on plaintext ports (SMTP 587, IMAP 143, LDAP 389) are not supported. The default source is `scan`, so without any parameter the plugin scans the default interface's subnet on a set of common data-center TLS ports (HTTPS, mail, LDAPS, AMQPS, MQTTS and common management interfaces; see the `--ports` help for the full default list). `p12` and `jks` sources are reserved for future expansion without renaming the plugin or breaking existing service templates.

**Important Notes:**

* `--source=url`: Hostname mismatch and chain verification failures share one `--severity` (default WARN), so operators running internal CAs are not paged for trust issues that are expected in their environment. Set `--severity=crit` to enforce strict trust.
* `--source=file`: chain and hostname checks are not performed. Only days remaining is evaluated. With a glob that matches many files, the worst state across all matches drives the plugin state. The File column abbreviates each path zsh-style (`/etc/ssl/certs/web1.pem` becomes `/e/s/c/web1.pem`) so wide cert-directory listings stay readable; the full path is shown in `--lengthy` output.
* `--source=scan`: each reachable certificate is checked for expiry **and** for chain/trust (does it chain to a CA in the system trust store, or one added via `--ca-file`?). Hostname verification is not done, because a subnet scan reaches IP addresses whose certificates legitimately do not match. A valid self-signed certificate is tolerated (it is cryptographically as sound as a publicly trusted one); other trust failures (unknown CA, expired or broken chain) raise the state via `--severity` (default WARN, `crit` to enforce). `--insecure` turns trust verification off entirely for pure expiry monitoring. Counting follows the `lynis` check and is done per host, not per host/port: a `/24` reports `X/254 hosts responded`, not `X/508 targets`. Hosts (or host/port combinations) that do not answer within `--timeout` are skipped silently, so an empty subnet returns OK with `0/N hosts responded`. The worst state across all reachable certificates drives the plugin state. Scan a large subnet from a host that can actually reach it, and tune `--max-workers` (parallelism) and `--timeout` so the run finishes within the check interval.
* `--source=url`: the plugin inspects the full certificate chain the server sends, not just the leaf. The leaf carries the chain/hostname verdict; every intermediate is additionally checked for expiry, so a soon-to-expire intermediate raises the state and shows up as the soonest-expiring certificate in the output. Capturing the chain requires Python 3.13 or newer (`ssl.SSLSocket.get_unverified_chain()`); on older Python only the leaf is inspected. The chain is shown one block per certificate in `--lengthy`.
* `--warning` and `--critical` accept three forms: a Nagios range in days (`14:`), a percentage of the certificate's total validity period (`25%`, alert when less than 25% of the lifetime is left), or a duration with a unit (`14d`, `12h`, `2W`, `1M`). The percentage form matches the convention of other X.509 scanners and adapts to short-lived (90-day) and long-lived certificates alike.
* Expired certificates are unconditionally reported as CRIT, regardless of the `--warning` and `--critical` thresholds.
* `--insecure` skips chain (and, for `--source=url`, hostname) verification entirely. The certificate is still fetched and inspected for expiry, the chain verdict is then reported as "verification skipped". Use it for pure expiry monitoring when trust is verified elsewhere or not relevant.
* When a PEM file contains multiple certificates (for example `fullchain.pem`, a CA bundle, or a chain file), each certificate becomes its own item in the output and is checked independently. So a `fullchain.pem` with leaf plus one intermediate produces two rows in the table; the worst state across all of them drives the plugin state. To check only the leaf, point `--filename` at a single-cert file like `cert.pem`.
* What "chain verified" actually covers: the leaf chains to a trust anchor in the system trust store (or `--ca-file`) using the intermediates the server sent or that the local trust store has cached, every certificate in the verified path is within its `notBefore`/`notAfter` window, every signature in that path is cryptographically valid, and the value of `--sni-hostname` (or, when not set, the host part of `--url`) appears in the leaf certificate's `subjectAltName` (or `CommonName` for legacy certs). What it does **not** cover: OCSP responder lookups, CRL checks, Certificate Transparency / SCT validation, enforcement of the order in which the server sends the chain, detection of SHA-1 in the verified chain, and the completeness of the chain the server sent (a server that omits intermediates may still verify locally if they are cached, but break for clients with empty caches). For those compliance-style checks use a dedicated TLS scanner like `sslyze`.

**Data Collection:**

* `--source=url`: opens a TCP connection to the host and port from `--url`, runs a TLS handshake and reads the certificate chain the server presents (leaf plus intermediates on Python 3.13+, leaf only on older Python). No HTTP request is sent. The chain is verified against the system trust store; `--ca-file` adds one or more CA bundles to the trusted set and can be given multiple times. `--sni-hostname` overrides the SNI value sent during the handshake; `--client-cert` and `--client-key` attach a client certificate for mutual TLS.
* `--source=file`: reads each file matching `--filename` (PEM or DER, autodetected) and parses every certificate found. PEM bundles expand to one item per certificate. `--filename` supports glob (`*`, `?`, `[abc]`) and recursive glob (`**`). When the glob matches files that don't look like certificates (private keys, plain text), they are silently skipped so recursive scans of `/etc/ssl/**` are safe. **Always quote the glob pattern**, otherwise the shell expands it before the plugin sees it and only the first match reaches `--filename`.
* `--source=scan`: enumerates the target hosts (`--host` overrides discovery, otherwise `--network` in CIDR notation, otherwise `--interface`, otherwise the default interface's subnet; `--exclude` drops individual addresses or names), then probes each host in parallel (`--max-workers`) on every port from `--ports` (each value a single port like `443` or a range like `8000-8100`). For each reachable port it runs a TLS handshake, verifies the chain against the system trust store plus any `--ca-file` (without hostname checking), and evaluates the certificate's expiry. `--client-cert` and `--client-key` attach a client certificate for mutual TLS. Auto-discovery via `--interface` or the default interface requires the `psutil` Python module.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cert> |
| Nagios/Icinga Check Name              | `check_cert` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes (scans the default interface's subnet on common TLS ports) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `cryptography`, `psutil` (only for `--source=scan` auto-discovery) |


## Help

```text
usage: cert [-h] [-V] [--always-ok] [--ca-file CA_FILE]
            [--client-cert CLIENT_CERT] [--client-key CLIENT_KEY] [-c CRIT]
            [--exclude EXCLUDE] [--filename FILENAME] [-H HOST] [--insecure]
            [--interface INTERFACE] [--lengthy] [--max-workers MAX_WORKERS]
            [--network NETWORK] [--ports PORTS] [--severity {crit,warn}]
            [--sni-hostname SNI_HOSTNAME] [--source {file,scan,url}]
            [--timeout TIMEOUT] [--url URL] [--verbose] [-w WARN]

Inspects X.509 certificates and alerts on days remaining until expiry,
hostname mismatch and chain verification failures. Sources via --source: `url`
fetches the certificate from a single TLS endpoint and verifies the chain
against the system trust store by default (override with --ca-file); `file`
reads one or many certificate files via glob expansion (PEM or DER); `scan`
discovers the hosts of a subnet (the subnet of the default interface, a chosen
interface, an explicit network in CIDR notation, or an explicit host list),
connects to each one on the ports given by --ports and inspects every
certificate it gets. PEM bundles expand to one item per certificate, so a
fullchain.pem produces a row for the leaf and a row for each intermediate.
With --source url the plugin only runs the TLS handshake and reads the server
certificate; no HTTP request is sent. That means it works for any "TLS from
start" service, not only HTTPS: IMAPS (port 993), LDAPS (636), SMTPS (465),
AMQPS (5671), MQTTS (8883), custom TLS ports - just point --url at the right
host and port (`https://mail.example.com:993/` inspects the IMAPS cert).
STARTTLS protocols that upgrade an existing plaintext connection (SMTP
submission on 587, IMAP on 143, LDAP on 389) are not supported. Hostname
verification only applies to --source url; chain/trust verification applies to
--source url and --source scan and its failures use --severity (warn or crit),
while a valid self-signed certificate is tolerated. Expired certificates are
unconditionally reported as CRIT. With --source file and --source scan the
worst state across all inspected certificates drives the plugin state; targets
that do not answer within --timeout are skipped. The default source is `scan`,
so without any parameter the plugin scans the default interface's subnet on a
set of common data-center TLS ports (HTTPS, mail, LDAPS, AMQPS, MQTTS and
common management interfaces); see --ports for the full default list.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --ca-file CA_FILE     Path to a CA bundle in PEM format, trusted for chain
                        verification in addition to the system trust store.
                        Can be specified multiple times to combine several
                        bundles. Applies to --source=url and --source=scan.
                        Example: `--ca-file=/etc/pki/ca-
                        trust/source/anchors/internal.pem`
  --client-cert CLIENT_CERT
                        Path to a client certificate in PEM format for mutual
                        TLS.
  --client-key CLIENT_KEY
                        Path to the client certificate private key in PEM
                        format.
  -c, --critical CRIT   CRIT threshold for the time remaining until the
                        certificate expires. Accepts a Nagios range in days
                        (`5:`), a percentage of the total validity period
                        (`10%`, CRIT when less than 10% of the lifetime is
                        left), or a duration with a unit (`3d`, `12h`, `2W`,
                        `1M`; CRIT when less time than that is left).
                        Examples: `5:` `10%` `3d`. Default: 5:
  --exclude EXCLUDE     IP address or hostname to skip during a scan. Matched
                        against both the discovered target address and, for
                        --host, the given name. Only applies to --source=scan.
                        Can be specified multiple times. Example:
                        `--exclude=192.0.2.1 --exclude=192.0.2.254`
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
  -H, --host HOST       Target host to scan. Overrides subnet auto-discovery.
                        Only applies to --source=scan. Can be specified
                        multiple times. If not specified, the subnet of the
                        default interface is scanned. Example:
                        `--host=mail.example.com --host=192.0.2.10`
  --insecure            Skip chain and hostname verification entirely. The
                        certificate is still fetched and inspected, but the
                        chain verdict is reported as "verification skipped".
  --interface INTERFACE
                        Network interface whose subnet is scanned. Only
                        applies to --source=scan. Ignored when --host or
                        --network is given. If not specified, the default
                        interface (the one carrying the default route) is
                        used.
  --lengthy             Extended reporting.
  --max-workers MAX_WORKERS
                        Maximum number of targets to scan in parallel. Only
                        applies to --source=scan. Default: 10
  --network NETWORK     Network in CIDR notation to scan for targets via auto-
                        discovery. Only applies to --source=scan. Takes
                        precedence over --interface. Can be specified multiple
                        times. Example: `--network=192.0.2.0/24`
  --ports PORTS         TCP port to probe on every scanned target. A range is
                        written `start-end`. Only applies to --source=scan.
                        Can be specified multiple times. If not specified, a
                        set of common data-center TLS ports is probed (443,
                        465, 636, 990, 993, 995, 3269, 5671, 5986, 6443, 8006,
                        8200, 8443, 8883, 9090, 9443, 10000). Example:
                        `--ports=443 --ports=993 --ports=8000-8100`
  --severity {crit,warn}
                        Severity assigned to chain/trust verification failures
                        (--source=url and --source=scan) and to hostname
                        mismatches (--source=url only). A valid self-signed
                        certificate is always tolerated. Defaults to warn so
                        that operators running internal CAs are not paged by
                        trust issues that are expected in their environment.
                        Set to `crit` to enforce strict trust.
  --sni-hostname SNI_HOSTNAME
                        SNI hostname sent during the TLS handshake and used
                        for hostname verification. Useful when --url points at
                        an IP address or a load balancer that needs an
                        explicit SNI. Default uses the hostname from --url.
  --source {file,scan,url}
                        Where the certificates are fetched from. `url` fetches
                        one from a TLS endpoint (requires --url). `file` reads
                        one or many from local files (requires --filename,
                        supports glob patterns). `scan` discovers the hosts of
                        a subnet (via --host, --network, --interface or the
                        default interface) and probes each one on --ports.
                        `p12` and `jks` are reserved for future expansion.
                        Default: scan
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             URL of the TLS endpoint to inspect. Required when
                        --source=url. Example: `https://www.example.com/`
  --verbose             Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Default: False
  -w, --warning WARN    WARN threshold for the time remaining until the
                        certificate expires. Accepts a Nagios range in days
                        (`14:`), a percentage of the total validity period
                        (`25%`, WARN when less than 25% of the lifetime is
                        left), or a duration with a unit (`14d`, `12h`, `2W`,
                        `1M`; WARN when less time than that is left).
                        Examples: `14:` `25%` `14d`. Default: 14:
```


## Usage Examples

```bash
./cert --source=url --url=https://www.example.com/
```

Output (default, OK):

```text
www.example.com, 61d left, chain verified|'cert_days_left'=61d;14:;5: 'tls_handshake_time'=0.07s;;;0
```

Alert relative to the certificate's lifetime instead of a fixed number of days. Here WARN when less than 25% of the validity period is left, CRIT below 10% (adapts to short-lived 90-day certs and multi-year certs alike):

```bash
./cert --source=url --url=https://www.example.com/ --warning=25% --critical=10%
```

Alert on a fixed duration left, for example WARN below two weeks and CRIT below three days:

```bash
./cert --source=url --url=https://www.example.com/ --warning=2W --critical=3d
```

Self-signed certificate, default `--severity=warn`:

```bash
./cert --source=url --url=https://internal.example.com/
```

Output:

```text
internal.example.com, 725d left, chain unverified (self-signed certificate) [WARNING]|'cert_days_left'=725d;14:;5: 'tls_handshake_time'=0.5s;;;0
```

Skip chain verification entirely, but still inspect the cert:

```bash
./cert --source=url --url=https://api.example.com/ --insecure
```

Pin a custom CA bundle for chain verification:

```bash
./cert --source=url --url=https://api.example.com/ --ca-file=/etc/pki/ca-trust/source/anchors/internal.pem
```

Attach an mTLS (mutual TLS; client certificate authentication):

```bash
./cert --source=url --url=https://api.example.com/ --client-cert=/etc/icinga2/client.pem --client-key=/etc/icinga2/client.key
```

Override the SNI hostname, for example when `--url` points at an IP:

```bash
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

Output (glob matches multiple files, one expired):

```text
3 certificates in /etc/ssl/certs/*.pem checked, worst expired 42 days ago (www2.example.com) [CRITICAL]

File            ! Subject CN       ! Status              ! State
----------------+------------------+---------------------+-----------
/e/s/c/web1.pem ! www1.example.com ! 90d left            ! [OK]
/e/s/c/web2.pem ! www2.example.com ! expired 42 days ago ! [CRITICAL]
/e/s/c/web3.pem ! www3.example.com ! 100d left           ! [OK]
```

Inspect a non-HTTPS TLS service - point `--url` at the service's TLS port. Each line is an independent check; `--source=url` inspects exactly one endpoint per run:

```bash
./cert --source=url --url=https://mail.example.com:993/   # IMAPS
./cert --source=url --url=https://ldap.example.com:636/   # LDAPS
./cert --source=url --url=https://smtp.example.com:465/   # SMTPS
```

Output (single endpoint, same one-line form as the first example):

```text
mail.example.com, 61d left, chain verified|'cert_days_left'=61d;14:;5: 'tls_handshake_time'=0.07s;;;0
```

Full field/value table per certificate with `--lengthy`:

```bash
./cert --source=url --url=https://www.example.com/ --lengthy
```

Output:

```text
www.example.com, 61d left, chain verified

Field               ! Value
--------------------+----------------------------------------------------------------------------------------------------
Subject CN          ! www.example.com
Issuer CN           ! R13
Serial              ! 5700EBF15B911BC3D902A0BFE488552C112
Signature Algorithm ! sha256WithRSAEncryption
Public Key          ! RSA 4096 (e=65537)
SANs                ! www.example.com
Not Before          ! 2026-04-11T22:19:04Z
Not After           ! 2026-07-10T22:19:03Z
SHA-256 Fingerprint ! BF:DF:BB:23:93:A9:31:CD:8B:B9:A9:61:18:6D:0A:07:2C:4E:1F:9A:55:D0:7B:38:E2:6C:A4:90:11:F3:5D:88
OCSP Must-Staple    ! no
TLS Version         ! TLSv1.3
Chain               ! verified
```

Scan the default interface's subnet on the default set of common TLS ports. This is also what the plugin does without any parameter:

```bash
./cert
./cert --source=scan
```

Scan an explicit network on a custom set of ports, excluding the gateway:

```bash
./cert --source=scan --network=192.0.2.0/24 --ports=443 --ports=8443 --ports=9443 --exclude=192.0.2.1
```

Scan a handful of named hosts (a hostname target sends SNI, so virtual hosts present the right certificate):

```bash
./cert --source=scan --host=mail.example.com --host=ldap.example.com --ports=993 --ports=636
```

Scan a subnet and trust your internal CA, so internally-issued certificates count as verified instead of raising a trust warning (self-signed certs are tolerated either way):

```bash
./cert --source=scan --network=192.0.2.0/24 --ca-file=/etc/pki/ca-trust/source/anchors/internal.pem
```

Output (scan, one host answered on two ports, one certificate close to expiry):

```text
1/254 hosts responded, 2 certificates, worst 9d left (b.example.com) [WARNING]

Target            ! Subject CN    ! Status   ! State
------------------+---------------+----------+----------
192.0.2.10:443    ! a.example.com ! 59d left ! [OK]
192.0.2.10:8443   ! b.example.com ! 9d left  ! [WARNING]
```


## States

* OK if the certificate is within `--warning` and `--critical` thresholds, the chain verifies and the hostname matches. A `--source=scan` run where no host answers is also OK.
* WARN if days remaining hits `--warning` (default `14:`), or chain/hostname verification fails and `--severity` is `warn` (default).
* CRIT if days remaining hits `--critical` (default `5:`), the certificate is expired, or chain/hostname verification fails and `--severity` is `crit`.
* UNKNOWN on connection errors, TLS handshake failures (`--source=url`), missing `--url`, missing `--filename`, no host left to scan, invalid `--ports`, missing `cryptography` (or `psutil` for scan auto-discovery) Python module, or invalid command-line arguments.
* `--always-ok` suppresses all alerts and always returns OK.
* `--insecure` reports the chain as "verification skipped" and never raises a chain-related state.
* With `--source=scan`, the chain/trust check runs (without hostname verification): a valid self-signed certificate is tolerated, other trust failures raise the state via `--severity`. Expiry is always evaluated, and the worst state across all reachable certificates wins.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cert_days_left | Days | Days remaining until the certificate's `notAfter` date (the worst across all inspected certificates). Negative when expired. Absent on a `--source=scan` run where no host answered. |
| certs_found | Number | `--source=scan` only: number of certificates collected across all reachable hosts and ports. |
| hosts_responded | Number | `--source=scan` only: number of scanned hosts that returned at least one certificate. |
| hosts_total | Number | `--source=scan` only: number of hosts scanned (subnet size, after `--exclude`). |
| tls_handshake_time | Seconds | `--source=url` only: wall-clock time for the TCP connect plus TLS handshake. |


## Troubleshooting

### `cryptography` module not installed

`Python module "cryptography" is not installed.`

The plugin needs the `cryptography` library to parse certificates. Install it with `dnf install python3-cryptography` (RHEL) or `pip install cryptography`.

### TCP connection fails

`Cannot connect to host:port: ...`

The TCP connection never established. Check DNS resolution, firewall rules, the port number in `--url`, and `--timeout`.

### TLS handshake fails

`TLS handshake failed for host:port: ...`

The server rejected the TLS handshake, usually a TLS version mismatch, an unsupported cipher, missing SNI, or a required client certificate. Pass `--sni-hostname` when the server needs SNI, `--client-cert` / `--client-key` for client authentication, or verify the server's supported TLS versions and ciphers.

### Certificate chain does not verify

`chain unverified (...)`

The chain did not verify against the system trust store. The text in parentheses is the OpenSSL verification message; common values are `self-signed certificate`, `unable to get local issuer certificate`, `certificate has expired`, and `Hostname mismatch, certificate is not valid for ...`. Pass `--ca-file` for internal CAs, `--sni-hostname` for hostname mismatches caused by SNI, or `--insecure` to bypass the check entirely.

### Glob matches no files

`No files match "<pattern>"`

The glob did not expand to any path, either because the path is wrong or because the shell expanded the glob before the plugin saw it. Quote the glob pattern: `--filename='/etc/ssl/**/*.pem'` instead of `--filename=/etc/ssl/**/*.pem`.

### Glob matches files but no certificates

`No parseable certificates among N file(s) matching "<pattern>"`

The glob matched files, but none of them looked like a certificate (no PEM `BEGIN CERTIFICATE` marker and no DER signature). Tighten the pattern (for example `*.crt` instead of `*`) or point `--filename` directly at a known certificate file.

### Certificate file cannot be parsed

`Cannot parse certificate from /path/to/file: ...`

The file looks like a certificate (PEM marker present or DER prefix detected) but the content is corrupt or in an unsupported encoding. Inspect the file with `openssl x509 -in /path/to/file -noout -text` to see the underlying error.

### Certificate file cannot be read

`Cannot read /path/to/file: ...`

The plugin could not read the file, typically a permissions problem: certificate files are sometimes mode `0600` and owned by the service account, so the monitoring user has no read access. Grant read permission, or copy the public certificate to a path the monitoring user can read.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
