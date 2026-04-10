# Notification notify-service-mail


## Overview

Sends service notifications via email for Icinga/Nagios. Generates an HTML-formatted email with color-coded notification types and service states, including an embedded Icinga logo. Includes host display name, service display name, service state, service output, IP address, event time, perfdata, and an optional link to Icinga Web 2.

**Important Notes:**

* Use the `--short` parameter to create a short message without a subject, for example for sending to a SMS relay service.

**Data Collection:**

* All notification data is passed via command-line parameters from the Icinga/Nagios notification system
* Sends the email via SMTP (`--mail-server`, default: localhost, port 25)
* Supports SMTP authentication via `--mail-user` and `--mail-password`


## Fact Sheet

| Fact | Value |
|----|-----|
| Notification Plugin Download          | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/notification-plugins/notify-service-mail> |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |


## Help

```text
usage: notify-service-mail  [-h] [-V] --datetime DATETIME --host-displayname
                            HOST_DISPLAYNAME [--host-address HOST_ADDRESS]
                            [--hostname HOSTNAME]
                            [--icingaweb2-url ICINGAWEB2_URL]
                            [--mail-port MAIL_PORT]
                            [--mail-password MAIL_PASSWORD]
                            [--mail-user MAIL_USER] --mail-recipient
                            MAIL_RECIPIENT --mail-sender MAIL_SENDER
                            [--mail-server MAIL_SERVER] [--notes NOTES]
                            [--notes-url NOTES_URL]
                            [--notification-author NOTIFICATION_AUTHOR]
                            [--notification-comment NOTIFICATION_COMMENT]
                            [--notification-type NOTIFICATION_TYPE]
                            [--perfdata PERFDATA] [--short]
                            --service-displayname SERVICE_DISPLAYNAME
                            [--service-output SERVICE_OUTPUT] --service-state
                            SERVICE_STATE [--servicename SERVICENAME]

Sends notifications for services using mail.

optional arguments:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --datetime DATETIME   Set the message timestamp.
  --host-displayname HOST_DISPLAYNAME
                        Set the display name of the host.
  --host-address HOST_ADDRESS
                        Set the IPv4 address of the host.
  --hostname HOSTNAME   Set the hostname.
  --icingaweb2-url ICINGAWEB2_URL
                        Set the Icinga Web 2 URL, for example
                        "https://example.com/icingaweb2".
  --mail-port MAIL_PORT
                        Set the mail server port. Default: 25.
  --mail-password MAIL_PASSWORD
                        Set the mail server login password.
  --mail-user MAIL_USER
                        Set the mail server login user.
  --mail-recipient MAIL_RECIPIENT
                        Set the mail recipient.
  --mail-sender MAIL_SENDER
                        Set the mail sender.
  --mail-server MAIL_SERVER
                        Set the mail server. Default: localhost.
  --notes NOTES         Set the notes.
  --notes-url NOTES_URL
                        Set the notes url.
  --notification-author NOTIFICATION_AUTHOR
                        Set the author of the comment.
  --notification-comment NOTIFICATION_COMMENT
                        Set the comment.
  --notification-type NOTIFICATION_TYPE
                        Set the type of notification like "PROBLEM" or
                        "RECOVERY".
  --perfdata PERFDATA   Set the perfdata.
  --short               Send a short message. This can be useful when using a
                        SMS relay, for example.
  --service-displayname SERVICE_DISPLAYNAME
                        Set the display name of the service.
  --service-output SERVICE_OUTPUT
                        Set the service output.
  --service-state SERVICE_STATE
                        Set the service state.
  --servicename SERVICENAME
                        Set the servicename.
```


## Usage Examples

```bash
./notify-service-mail \
    --datetime="2026-04-09 10:30:00" \
    --host-displayname="webserver01" \
    --service-displayname="HTTP" \
    --service-state=CRITICAL \
    --service-output="HTTP CRITICAL - Connection refused" \
    --hostname=webserver01.example.com \
    --notification-type=PROBLEM \
    --mail-recipient=admin@example.com \
    --mail-sender=icinga@example.com
```

Short message (e.g. for SMS relay):

```bash
./notify-service-mail \
    --short \
    --datetime="2026-04-09 10:30:00" \
    --host-displayname="webserver01" \
    --service-displayname="HTTP" \
    --service-state=CRITICAL \
    --mail-recipient=sms-relay@example.com \
    --mail-sender=icinga@example.com
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
