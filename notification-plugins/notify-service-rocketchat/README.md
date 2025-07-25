# Notification notify-service-rocketchat

## Overview

Sends service notifications using the RocketChat API, falling back to Telegram.


## Fact Sheet

| Fact | Value |
|----|----|
| Notification Plugin Download          | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/notification-plugins/notify-service-rocketchat> |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |


## Help

```text
usage: notify-service-rocketchat [-h] --datetime DATETIME --host-displayname
                                 HOST_DISPLAYNAME [--hostname HOSTNAME]
                                 [--icingaweb2-url ICINGAWEB2_URL]
                                 [--notification-author NOTIFICATION_AUTHOR]
                                 [--notification-comment NOTIFICATION_COMMENT]
                                 [--rocketchat-mentions ROCKETCHAT_MENTIONS]
                                 --rocketchat-url ROCKETCHAT_URL
                                 [--service-output SERVICE_OUTPUT]
                                 --service-state SERVICE_STATE
                                 [--servicename SERVICENAME] [-V]

Sends service notifications using the RocketChat API.

options:
  -h, --help            show this help message and exit
  --datetime DATETIME   Set the message timestamp.
  --host-displayname HOST_DISPLAYNAME
                        Set the display name of the host.
  --hostname HOSTNAME   Set the hostname.
  --icingaweb2-url ICINGAWEB2_URL
                        Set the Icinga Web 2 URL, for example
                        "https://example.com/icingaweb2".
  --notification-author NOTIFICATION_AUTHOR
                        Set the author of the comment.
  --notification-comment NOTIFICATION_COMMENT
                        Set the comment.
  --rocketchat-mentions ROCKETCHAT_MENTIONS
                        Set the Rocket.Chat Mentions (repeating).
  --rocketchat-url ROCKETCHAT_URL
                        Set the Rocket.Chat Webhook API URL.
  --service-output SERVICE_OUTPUT
                        Set the service output.
  --service-state SERVICE_STATE
                        Set the service state.
  --servicename SERVICENAME
                        Set the servicename.
  -V, --version         show program's version number and exit
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
