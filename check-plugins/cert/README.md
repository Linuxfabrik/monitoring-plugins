# Check cert


## Overview

Inspects an X.509 server certificate from a TLS endpoint and alerts on days remaining until expiry, hostname mismatch and chain verification failures. Connects to the TLS endpoint, runs a TLS handshake, captures the server certificate (DER) and reports the relevant fields. Designed so additional sources (`file`, `p12`, `jks`) can be added later via `--source` without renaming the plugin or breaking existing service templates.

**Important Notes:**

* Hostname mismatch and chain verification failures share one `--severity` (default WARN), so operators running internal CAs are not paged for trust issues that are expected in their environment. Set `--severity crit` to enforce strict trust.
* Expired certificates are unconditionally reported as CRIT, regardless of the `--warning` and `--critical` thresholds.
* `--insecure` skips chain and hostname verification entirely. The certificate is still fetched and inspected, the chain verdict is then reported as "verification skipped".

**Data Collection:**

* Opens a TCP connection to the host and port from `--url`, runs a TLS handshake and reads the server certificate. No HTTP request is sent.
* The chain is verified against the system trust store; pass `--ca-file` to use a custom CA bundle.
* `--sni-hostname` overrides the SNI value sent during the handshake. Useful when `--url` points at an IP address or a load balancer that needs an explicit SNI.
* `--client-cert` and `--client-key` attach a client certificate for mutual TLS.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cert> |
| Nagios/Icinga Check Name              | `check_cert` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | No (`--source` and `--url` required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `cryptography` |


## Help

```text
usage: cert [-h] [-V] [--always-ok] [--ca-file CA_FILE]
            [--client-cert CLIENT_CERT] [--client-key CLIENT_KEY] [-c CRIT]
            [--insecure] [--lengthy] [--severity {crit,warn}]
            [--sni-hostname SNI_HOSTNAME] [--source {url}] [--timeout TIMEOUT]
            [--url URL] [-w WARN]

Inspects an X.509 server certificate from a TLS endpoint and alerts on days
remaining until expiry, hostname mismatch, and chain verification failures.
The chain is verified against the system trust store by default; pass --ca-
file to override. Hostname mismatch and chain verification failures share one
--severity (warn or crit). Expired certificates are unconditionally reported
as CRIT. Pluggable via --source, currently only "url" is implemented; "file",
"p12" and "jks" sources can be added later without renaming the plugin.

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
  --source {url}        Where the certificate is fetched from. Currently only
                        "url" is implemented; "file", "p12" and "jks" are
                        reserved for future expansion. Default: url
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             URL of the TLS endpoint to inspect. Required when
                        --source=url. Example: `https://www.example.com/`
  -w, --warning WARN    WARN threshold for days remaining until the
                        certificate expires. Supports Nagios ranges. Example:
                        `14:` (WARN when below 14 days). Default: 14:
```


## Usage Examples

```bash
./cert --source url --url https://www.example.com/
```

Output (default, OK):

```text
www.example.com, 61d left, chain verified|'cert_days_left'=61d;14:;5: 'tls_handshake_time'=0.07s;;;0
```

Self-signed certificate, default `--severity warn`:

```bash
./cert --source url --url https://internal.example.com/
```

Output:

```text
internal.example.com, 725d left [WARNING], chain unverified (self-signed certificate)|'cert_days_left'=725d;14:;5: 'tls_handshake_time'=0.5s;;;0
```

Skip chain verification entirely (still inspect the cert), pin a custom CA bundle, attach mTLS client cert, override SNI:

```bash
./cert --source url --url https://api.example.com/ --insecure
./cert --source url --url https://api.example.com/ --ca-file /etc/pki/ca-trust/source/anchors/internal.pem
./cert --source url --url https://api.example.com/ --client-cert /etc/icinga2/client.pem --client-key /etc/icinga2/client.key
./cert --source url --url https://10.0.0.5/ --sni-hostname api.example.com
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
The chain did not verify against the system trust store. The reason in parentheses comes from OpenSSL: typical values are `self-signed certificate`, `unable to get local issuer certificate`, `Hostname mismatch, certificate is not valid for ...`. Pass `--ca-file` for internal CAs, `--sni-hostname` for hostname mismatches caused by SNI, or `--insecure` to bypass the check entirely.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
