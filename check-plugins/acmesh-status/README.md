# Check acmesh-status

## Overview

Reports the state of the certificates acme.sh manages, by reading its certificate store instead of its output. For every certificate it reports the time left until it expires, whether the renewal acme.sh scheduled for itself has come and gone, and whether the certificate the store installed for a web server is still in place. Alerts when a certificate is closer to expiry than the thresholds allow, when a renewal is overdue by more than the grace period, when a certificate was installed somewhere that no longer holds it, when an entry carries no issued certificate at all, and when a certificate that was detached from renewal is still the one a service has deployed. A renewal that keeps failing leaves no trace in the store other than a renewal date that stays in the past, which is what makes it visible here long before the certificate runs out. Every finding comes with the acme.sh command that resolves it, assembled from the paths and options the store records, and one command stands for every certificate it applies to. Certificates can be filtered by `--match` and `--ignore`. Requires root or sudo.

**Important Notes:**

* acme.sh renews every certificate it finds in its store, not the ones a configuration management system currently wants. A domain that was retired without `acme.sh --remove` therefore keeps being renewed, keeps failing once its DNS record is gone, and takes the exit code of the whole renewal run down with it. That is the state this check is built to name: it says which certificate is behind a failed run, which the renewal job itself does not.
* A failed renewal writes nothing into the store. acme.sh records only successful outcomes, so an overdue renewal date is the only trace left behind, and it is what this check alerts on. The reason a renewal failed is not in the store either, which is why the recommendation names the command that prints it.
* The check needs to read the acme.sh configuration directory. acme.sh creates it as `drwx------` owned by root, so the check runs with sudo. See [sudoers File](../../CONTRIBUTING.md#sudoers-file).
* Certificates that `acme.sh --remove` detached from renewal are counted but not listed. Every host that ever changed its key type carries one such directory per domain, because a switch from RSA to ECDSA leaves the old store behind; reporting those would put a permanent warning on a healthy host. Such a store is reported only when it is still the certificate a service has installed, because then nothing renews what is being served.
* `--grace-renewal` has no counterpart in acme.sh and is not an upstream setting. Its default of `2D` covers the daily cron job acme.sh installs for itself. Raise it to cover whatever interval the renewal job actually runs at, for example `--grace-renewal=8D` for a weekly timer, so a run that has not happened yet is not reported as a failure.

**Data Collection:**

* Reads the acme.sh configuration directory given by `--path`, which is the directory acme.sh is called with as `--config-home`. The certificate store is taken from the `CERT_HOME` recorded in `account.conf`, and from the configuration directory itself where that names none, which is where acme.sh keeps it when it was never given `--cert-home`. A relative `CERT_HOME` is resolved below the configuration directory.
* Only the directories acme.sh itself considers are read, which are those whose name carries a dot or a colon. A directory holding neither is not a certificate store to acme.sh and is not reported here.
* Certificate dates and serial numbers are read from the certificate files in the store and from the installed copies the store points at. Nothing is fetched over the network and no TLS endpoint is contacted, so this check answers about the certificates a host holds, not about the ones it serves. Use [cert](../cert) for the latter.
* acme.sh is never executed. Its own `--list` reads each configuration file by sourcing it as shell code, which is not something a check should do to the files it is inspecting, so the files are parsed instead.
* Certificates can be limited with `--match` and excluded with `--ignore`, both case-sensitive Python regular expressions matched against the store directory name (`www.example.com_ecc`); use `(?i)` for case-insensitive matching. An item hit by `--ignore` is dropped even if it also matches `--match`.
* The recommendations are grouped by the command they carry, so the same fault on twenty domains is one line with `$DOMAIN` in place of the name rather than twenty paragraphs. A group covering a single certificate names that domain, so the command runs as it stands. `--ecc` addresses a different store than its absence does, so certificates of both key types are never folded into one command.
* Running the renewal by hand is printed above the recommendations rather than among them. It is not an alternative to them: it produces the reason acme.sh has, which is what decides whether the certificate is repaired or retired.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/acmesh-status> |
| Nagios/Icinga Check Name              | `check_acmesh_status` |
| Check Interval Recommendation         | Every 4 hours |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | acme.sh; User with higher permissions |
| 3rd Party Python modules              | `cryptography` |


## Help

```text
usage: acmesh-status [-h] [-V] [--always-ok] [--brief] [-c CRIT]
                     [--grace-renewal GRACE_RENEWAL] [--ignore IGNORE]
                     [--match MATCH]
                     [--no-match-severity {ok,warn,crit,unknown}]
                     [--no-perfdata] [--path PATH]
                     [--severity {ok,warn,crit,unknown}] [-w WARN]

Reports the state of the certificates acme.sh manages, by reading its
certificate store instead of its output. For every certificate it reports the
time left until it expires, whether the renewal acme.sh scheduled for itself
has come and gone, and whether the certificate the store installed for a web
server is still in place. Alerts when a certificate is closer to expiry than
the thresholds allow, when a renewal is overdue by more than the grace period,
when a certificate was installed somewhere that no longer holds it, when an
entry carries no issued certificate at all, and when a certificate that was
detached from renewal is still the one a service has deployed. A renewal that
keeps failing leaves no trace in the store other than a renewal date that
stays in the past, which is what makes it visible here long before the
certificate runs out. Every finding comes with the acme.sh command that
resolves it, assembled from the paths and options the store records, and one
command stands for every certificate it applies to. Certificates can be
filtered by --match and --ignore. Requires read access to the acme.sh
configuration directory, which usually means root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  -c, --critical CRIT   CRIT threshold for the time remaining until a
                        certificate expires. Accepts a Nagios range in days
                        (`5:`), a percentage of the total validity period
                        (`10%`, CRIT when less than 10% of the lifetime is
                        left), or a duration with a unit (`3d`, `12h`, `2W`,
                        `1M`; CRIT when less time than that is left).
                        Examples: `5:` `10%` `3d`. Default: 5:
  --grace-renewal GRACE_RENEWAL
                        How long an overdue renewal is tolerated before it
                        counts towards the state. Set this to cover the
                        interval the acme.sh renewal job runs at, so a run
                        that has not happened yet is not reported as a
                        failure. Starts at the renewal time acme.sh recorded
                        for the certificate. A duration such as `12h`, `8D` or
                        `2W`; `0D` disables the grace period. Example:
                        `--grace-renewal=8D` for a job that runs weekly.
                        Default: 2D
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead).
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --path PATH           Directory acme.sh keeps its configuration in, the one
                        it is called with as `--config-home`. The certificate
                        store is read from the `CERT_HOME` recorded there, and
                        from this directory itself where that names none.
                        Example: `--path=/etc/acme.sh`. Default: ~/.acme.sh
  --severity {ok,warn,crit,unknown}
                        Severity assigned to a certificate whose renewal is
                        overdue, whose installed copy is missing, which
                        carries no issued certificate, or which is still
                        deployed after having been detached from renewal. Each
                        of these keeps the certificate valid for the time
                        being, which is why they default to warn; the expiry
                        thresholds raise the state on their own as the
                        deadline comes closer. Default: warn
  -w, --warning WARN    WARN threshold for the time remaining until a
                        certificate expires. Accepts a Nagios range in days
                        (`14:`), a percentage of the total validity period
                        (`25%`, WARN when less than 25% of the lifetime is
                        left), or a duration with a unit (`10d`, `12h`, `2W`,
                        `1M`; WARN when less time than that is left).
                        Examples: `14:` `25%` `10d`. Default: 14:

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/acmesh-status/
```


## Usage Examples

```bash
./acmesh-status --path=/etc/acme.sh --grace-renewal=8D
```

Output:

```text
Everything is ok. 3 certificates renew as scheduled. The next one expires in 68d.

Store                ! Days Left ! Renewal  ! Note ! State
---------------------+-----------+----------+------+------
mail.example.com_ecc ! 68d       ! in 1M 1W ! -    ! [OK]
shop.example.com_ecc ! 68d       ! in 1M 1W ! -    ! [OK]
www.example.com_ecc  ! 68d       ! in 1M 1W ! -    ! [OK]
```

Three domains whose DNS records were removed without taking them out of the renewal list, and two whose installed copy has gone missing. The table names the certificates and the commands below it carry the fix, each standing for every certificate it applies to with `$DOMAIN` in place of the name. Running the renewal by hand is what tells the two repairs apart, so it is listed on its own above them rather than as a third option:

```bash
./acmesh-status --path=/etc/acme.sh --grace-renewal=8D
```

Output:

```text
5 of 5 certificates need attention. The next one expires in 4d. 3 detached from renewal.

Store                  ! Days Left ! Renewal       ! Note                      ! State
-----------------------+-----------+---------------+---------------------------+-----------
cloud.example.com_ecc  ! 4d        ! overdue 3W 4D ! renewal overdue, orphaned ! [CRITICAL]
office.example.com_ecc ! 4d        ! overdue 3W 4D ! renewal overdue, orphaned ! [CRITICAL]
ws.example.com_ecc     ! 4d        ! overdue 3W 4D ! renewal overdue, orphaned ! [CRITICAL]
mail.example.com_ecc   ! 68d       ! in 1M 1W      ! orphaned                  ! [WARNING]
www.example.com_ecc    ! 68d       ! in 1M 1W      ! orphaned                  ! [WARNING]

Check why the renewal is not happening: `acme.sh --config-home=/etc/acme.sh --renew --domain=$DOMAIN --ecc`

Recommendations:
* Install the missing copy again: `acme.sh --config-home=/etc/acme.sh --install-cert --domain=$DOMAIN --ecc --cert-file=/etc/pki/tls/certs/$DOMAIN.crt --key-file=/etc/pki/tls/private/$DOMAIN.key --fullchain-file=/etc/pki/tls/certs/$DOMAIN-fullchain.crt --ca-file=/etc/pki/tls/certs/$DOMAIN-chain.crt --reloadcmd='systemctl reload httpd'`
* Or detach a domain that has been retired: `acme.sh --config-home=/etc/acme.sh --remove --domain=$DOMAIN --ecc`
```

On a busy reverse proxy, `--brief` drops the rows that are within the thresholds so only the certificates that need attention are listed. Performance data and the check state are unaffected:

```bash
./acmesh-status --path=/etc/acme.sh --grace-renewal=8D --brief
```


## States

* OK if every certificate has more time left than `--warning` allows, its renewal is not overdue by more than `--grace-renewal`, and its installed copy is where the store says it is.
* WARN if the time left is at or below `--warning` (default: 14 days).
* The state of a row is the worst of everything found for that certificate, so a certificate that is both `orphaned` and close to expiry is reported at the expiry state rather than at the `--severity` one.
* CRIT if the time left is at or below `--critical` (default: 5 days).
* CRIT if a certificate has expired, regardless of the thresholds.
* `--severity` (default: `warn`) is reported for a certificate whose renewal is overdue by more than `--grace-renewal`, whose installed copy is missing, whose store holds no issued certificate, whose configuration carries no creation time so the renewal job skips it, and for a certificate that was detached from renewal while still being the one installed at its recorded path. Set it to `crit` to page on those as well, or to `ok` to trend them without alerting.
* OK for a certificate that was detached from renewal and is no longer installed anywhere. These are counted in the summary and in the performance data but are not listed and never alert.
* `--severity` (default: `warn`) if the configuration directory holds no certificate store at all, because that means either that acme.sh has never issued a certificate or that `--path` names the wrong directory. This is deliberately not covered by `--no-match-severity`: a filter that matches nothing is a question the operator asked, an empty store is not.
* OK with "Nothing checked." if the filters match no certificate.
* UNKNOWN if `--path` does not exist, if the certificate store it names does not exist, on an invalid `--match` or `--ignore` pattern, on a missing `cryptography` module, or on invalid command-line arguments.
* `--no-match-severity` sets the state reported when the filters match no certificate (default: `ok`); set it to `warn`, `crit`, or `unknown` to alert on an empty selection instead of silently returning OK.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| acmesh_certificates | Number | Certificates this check is responsible for: the ones acme.sh renews, plus any detached one that is still installed. |
| acmesh_days_left | Number | Days until the certificate that expires first runs out. Negative once it has expired. |
| acmesh_detached | Number | Certificates that were detached from renewal, whether they are still installed or not. |
| acmesh_needing_attention | Number | Certificates in a WARN or CRIT state. |
| acmesh_orphaned | Number | Certificates whose installed copy is missing from the path the store recorded for it, reported as `orphaned`. |
| acmesh_overdue | Number | Certificates whose renewal is overdue by more than `--grace-renewal`. |


## Troubleshooting

### `renewal overdue`

acme.sh considers a renewal due and it has not happened. The store records only successful renewals, so it holds no reason; the recommendation names the command that produces one:

1. Run the renewal by hand. It prints why acme.sh cannot complete it, most often a validation error naming the domain.
2. A verification error such as `no valid A records found for <domain>` means the domain no longer resolves. If the service behind it was retired, take the certificate out of the renewal list with `acme.sh --config-home=<path> --remove --domain=<domain> --ecc`. This detaches it and leaves its files in place. Leave `--ecc` off for a certificate with an RSA key.
3. If the domain is still in use, fix what broke: the DNS record, the web server that answers on port 80, or the firewall in front of it.

Until the entry is either renewed or removed, every run of the acme.sh renewal job exits non-zero because of it, which is why a single retired domain makes the whole job look broken.

### `orphaned`

acme.sh installed this certificate at a path it recorded, and the file is no longer there. The service reading that path is serving something else, or failing to start. The recommendation carries the full `--install-cert` command rebuilt from the paths and the reload command the store saved, so running it puts the files back and reloads whatever was being reloaded before.

Where the service was decommissioned and the path is not meant to exist any more, take the certificate out of the renewal list instead.

### `detached from renewal but still installed`

The certificate was detached with `acme.sh --remove`, but the file it installed is still the one a service is serving. Nothing renews it any more, so it will expire on its date without a single line appearing in the renewal job's output beforehand. Either issue it again to put it back under renewal, or point the service at the certificate it is meant to serve by now.

### `never issued, skipped by the renewal job`

The configuration for this certificate carries no creation time, which happens when an issue attempt never completed. acme.sh skips such an entry outright when it runs from cron, and a skipped entry never fails a run, so nothing else reports it. Issue the certificate or remove the entry.

### `No certificate stores in ...`

The directory `--path` names is an acme.sh configuration directory, but it holds no certificate at all. On a host that has never issued one this is the expected first state and goes away with the first certificate.

Otherwise `--path` names the wrong directory. An installation that was given `--config-home` keeps its certificates there and leaves its default home behind holding only the script and its `deploy`, `dnsapi` and `notify` directories, which is what makes the wrong one look plausible. The `acme.sh.env` file next to the acme.sh script names the right one:

```bash
grep LE_CONFIG_HOME /path/to/acme.sh/acme.sh.env
```

Point `--path` at what it reports. Where no such file exists, the alias in the shell profile of the account that installed acme.sh carries the same `--config-home` argument.

### The recommendation names `acme.sh` but the script is somewhere else

The command in the recommendation is written with the acme.sh script found next to the configuration directory, or with the one on `PATH`. An installation that keeps the script elsewhere, for example under `/opt`, is not discoverable from the configuration directory, so the bare name is printed instead. Substitute the path the installation actually uses; the arguments are correct either way.

### Certificates are missing from the output

Only directories whose name carries a dot or a colon are read, because those are the only ones acme.sh itself looks into. A store directory named without either is invisible to acme.sh as well and is not renewed by it.

If a certificate is present but not listed, check whether `--match` or `--ignore` drops it. Both match the store directory name including the `_ecc` suffix, not the domain alone.

### `The acme.sh certificate store ... does not exist.`

`account.conf` names a `CERT_HOME` that is not there. This happens when the store was moved without updating the configuration, or when `--path` points at a copy of the configuration directory whose absolute `CERT_HOME` refers to the original host.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
