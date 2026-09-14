# Notification notify-host-mail


## Overview

Sends host notifications via email for Icinga/Nagios. Generates an HTML-formatted email with color-coded notification types and host states, including an embedded Icinga logo. Includes host display name, state, output, IP address, event time, perfdata, and an optional link to Icinga Web 2.

**Important Notes:**

* Designed for use with the [Linuxfabrik Icinga Director Basket](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/notification-plugins/notify-host-mail/icingaweb2-module-director/notify-host-mail.json). The basket wires every Icinga macro (`$host.state$`, `$host.display_name$`, `$notification.author$`, etc.) to the parameter names the plugin actually expects (`--host-state`, `--host-displayname`, `--notification-author`, ...). Icinga's stock ITL notification templates (`mail-host-notification` from `icinga2-common`) use different parameter names (`--hoststate`, `--hostdisplayname`, `--longdatetime`, ...) and will not work with this plugin. If you plug the plugin directly into the stock ITL template, `argparse` fails with "the following arguments are required: ..." because the names do not match. Import the basket into Icinga Director instead.
* Use the `--short` parameter to create a short message without a subject, for example for sending to an SMS relay service.

**Data Collection:**

* All notification data is passed via command-line parameters from the Icinga/Nagios notification system
* Sends the email via SMTP (`--mail-server`, default: localhost, port 25)
* Supports SMTP authentication via `--mail-user` and `--mail-password`
* Encrypts the connection with STARTTLS or implicit TLS (SMTPS) via `--mail-encryption`. The server certificate is verified against the trust store of the host unless `--insecure` is given. Without `--mail-encryption`, the mail and the login are sent in plaintext


## Fact Sheet

| Fact | Value |
|----|----|
| Notification Plugin Download          | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/notification-plugins/notify-host-mail> |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |


## Help

```text
usage: notify-host-mail [-h] [-V] --datetime DATETIME
                        [--host-address HOST_ADDRESS]
                        --host-displayname HOST_DISPLAYNAME
                        [--host-output HOST_OUTPUT] --host-state HOST_STATE
                        [--hostname HOSTNAME]
                        [--icingaweb2-url ICINGAWEB2_URL] [--insecure]
                        [--mail-encryption {none,starttls,tls}]
                        [--mail-password MAIL_PASSWORD]
                        [--mail-port MAIL_PORT]
                        --mail-recipient MAIL_RECIPIENT
                        --mail-sender MAIL_SENDER [--mail-server MAIL_SERVER]
                        [--mail-user MAIL_USER] [--notes NOTES]
                        [--notes-url NOTES_URL]
                        [--notification-author NOTIFICATION_AUTHOR]
                        [--notification-comment NOTIFICATION_COMMENT]
                        [--notification-type NOTIFICATION_TYPE]
                        [--perfdata PERFDATA] [--short]

Sends notifications for hosts using mail.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --datetime DATETIME   Set the message timestamp ($icinga.short_date_time$).
  --host-address HOST_ADDRESS
                        Set the IPv4 address of the host.
  --host-displayname HOST_DISPLAYNAME
                        Set the display name of the host
                        ($host.display_name$).
  --host-output HOST_OUTPUT
                        Set the host output ($host.output$).
  --host-state HOST_STATE
                        Set the host state ($host.state$).
  --hostname HOSTNAME   Set the hostname ($host.name$).
  --icingaweb2-url ICINGAWEB2_URL
                        Set the Icinga Web 2 URL. Example: `--icingaweb2-
                        url=https://icinga.example.com/icingaweb2`.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --mail-encryption {none,starttls,tls}
                        Set how the connection to the mail server is
                        encrypted. `none` sends the mail and the login in
                        plaintext. `starttls` upgrades the connection with
                        STARTTLS, which the server has to offer. `tls`
                        encrypts the connection from the start (SMTPS,
                        implicit TLS). The server certificate is verified
                        unless `--insecure` is given. Example: `--mail-
                        encryption=tls --mail-port=465`. Default: none.
  --mail-password MAIL_PASSWORD
                        Set the mail server login password.
  --mail-port MAIL_PORT
                        Set the mail server port. Default: 25.
  --mail-recipient MAIL_RECIPIENT
                        Set the mail recipient.
  --mail-sender MAIL_SENDER
                        Set the mail sender.
  --mail-server MAIL_SERVER
                        Set the mail server. Default: localhost.
  --mail-user MAIL_USER
                        Set the mail server login user.
  --notes NOTES         Set the notes.
  --notes-url NOTES_URL
                        Set the notes url.
  --notification-author NOTIFICATION_AUTHOR
                        Set the author of the comment ($notification.author$).
  --notification-comment NOTIFICATION_COMMENT
                        Set the comment ($notification.comment$).
  --notification-type NOTIFICATION_TYPE
                        Set the type of notification ($notification.type$).
                        Example: `--notification-type=PROBLEM`.
  --perfdata PERFDATA   Set the perfdata.
  --short               Send a short message. This can be useful when using an
                        SMS relay, for example.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/notification-plugins/notify-host-mail/
```


## Usage Examples

```bash
./notify-host-mail \
    --datetime="2026-04-09 10:30:00" \
    --host-displayname="webserver01" \
    --host-state=DOWN \
    --hostname=webserver01.example.com \
    --host-address=192.168.1.10 \
    --notification-type=PROBLEM \
    --mail-recipient=admin@example.com \
    --mail-sender=icinga@example.com
```

Through a mail provider that only accepts encrypted connections, with login:

```bash
./notify-host-mail \
    --datetime="2026-04-09 10:30:00" \
    --host-displayname="webserver01" \
    --host-state=DOWN \
    --mail-encryption=tls \
    --mail-port=465 \
    --mail-server=smtp.example.com \
    --mail-user=icinga@example.com \
    --mail-password=linuxfabrik \
    --mail-recipient=admin@example.com \
    --mail-sender=icinga@example.com
```

Use `--mail-encryption=starttls` together with `--mail-port=587` for a mail server that expects STARTTLS on the submission port.

Short message (e.g. for SMS relay):

```bash
./notify-host-mail \
    --short \
    --datetime="2026-04-09 10:30:00" \
    --host-displayname="webserver01" \
    --host-state=DOWN \
    --mail-recipient=sms-relay@example.com \
    --mail-sender=icinga@example.com
```


## Troubleshooting

### `Error: SMTP AUTH extension not supported by server.`

The mail server offers no login on this connection. Many mail servers only offer it once the connection is encrypted, so set `--mail-encryption=starttls` (usually port 587) or `--mail-encryption=tls` (usually port 465). A relay that accepts mail without a login, such as a local MTA, offers none at all; leave out `--mail-user` and `--mail-password` there.

### `Error: STARTTLS extension not supported by server.`

The mail server does not offer STARTTLS on this port, so the plugin refuses to send the mail in plaintext. Check which port the provider documents for encrypted submission. If it is port 465, use `--mail-encryption=tls` instead.

### Certificate verification failed

`Error: TLS certificate verification failed for <server>:<port>: ...`

The certificate of the mail server is not signed by a CA the host trusts, or it does not carry the name given in `--mail-server`. The message names the reason. A `Hostname mismatch` or `IP address mismatch` means `--mail-server` has to name the server exactly as its certificate does, so use the host name instead of an IP address. For a certificate signed by an internal CA, add the CA to the trust store of the host: copy it to `/etc/pki/ca-trust/source/anchors/` and run `update-ca-trust` on RHEL, or copy it to `/usr/local/share/ca-certificates/` with a `.crt` extension (other names are skipped) and run `update-ca-certificates` on Debian. Recent Python versions also refuse a CA certificate that does not mark itself as one properly, for example with `CA cert does not include key usage extension`; such a CA has to be reissued. `--insecure` skips the verification, but then anybody able to intercept the connection can read the login.

### Encryption does not match the port

`Error: <server>:<port> does not speak TLS from the start. It expects a plaintext connection, possibly upgraded with STARTTLS.`

`Error: Connection unexpectedly closed: timed out`

`--mail-encryption` does not match what the port expects. `tls` against a port that speaks plaintext or STARTTLS first (usually 25 and 587) fails with the first message. `starttls` or `none` against a port that expects implicit TLS (usually 465) waits for a greeting that never comes and runs into the timeout.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
