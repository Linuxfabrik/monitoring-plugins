# Notification notify-service-mail

## Overview

Sends notifications for services using mail.

Note: Use the `--short` parameter to create a short message without a subject, for exmple for sending to a SMS relay service.


## Fact Sheet

| Fact | Value |
|----|----|
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


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
