# Notification notify-host-ntfy


## Overview

Sends host notifications to a topic on an ntfy server, which forwards them as push notifications to the ntfy apps for Android, iOS and the web. Works with the public ntfy.sh service and with self-hosted ntfy servers. The title names the notification type and the host state, the icon follows the notification type and the host state, and so does the priority: acknowledgements arrive with minimum priority, without sound or vibration, recoveries with low and custom notifications with default priority, all other notifications by host state, DOWN with high, UNREACHABLE with default, UP with low priority. The message is formatted as Markdown, with the host output in a code block. An access token gives access to reserved or protected topics. A host output that does not fit into an ntfy message is shortened, keeping its beginning and its end.

**Important Notes:**

* Designed for use with the [Linuxfabrik Icinga Director Basket](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/notification-plugins/notify-host-ntfy/icingaweb2-module-director/notify-host-ntfy.json), which wires the Icinga macros (`$host.state$`, `$notification.type$`, `$notification.author$`, ...) to the parameters of the plugin. Set `--topic` and `--token-file` (or `--token`) on the concrete notification or user object, never on the notification template, so the token does not spread to objects that import the template.
* Anybody who knows the name of an unprotected topic can read and publish to it. On ntfy.sh, reserve the topic in your account and create an access token for it. On a self-hosted ntfy server, set `auth-default-access: deny-all`, grant a user write access to the topic with `ntfy access <user> <topic> rw` and create a token with `ntfy token add <user>`.
* Prefer `--token-file` over `--token`. A token passed with `--token` is visible to every user on the host in the process list while the plugin runs. Keep the file readable only by the user the monitoring daemon runs as.
* The ntfy Android and web apps render Markdown. Clients that do not render it show the Markdown characters (code fences, backslashes before `_` or `*`); use `--no-markdown` for those.
* The plugin prints nothing and exits with 0 once ntfy confirmed the notification. On any error, it prints the reason and exits with 3; Icinga 2 logs this in its main log.

**Data Collection:**

* All notification data is passed via command-line parameters from the notification system.
* Publishes the notification as JSON via HTTP POST to the root of the ntfy server given in `--url`, authenticating with `Authorization: Bearer <token>` if a token is given. Success means that ntfy answered with the published message.
* The title has the form `[<notification type>] <state>: <host display name> (<timestamp>)`, for example `[PROBLEM] DOWN: webserver01 (2026-11-22 20:51:00 +0100)`. Without `--notification-type`, the type is left out.
* The message consists of the comment and its author if there is one, and the host output in a code block, separated by a horizontal rule. A host output that contains code fences of its own is sent without the surrounding code block, so its formatting stays intact.
* Characters that start Markdown formatting (`_`, `*`, `` ` ``, ...) are escaped in the comment, so a text such as `web_01_prod` does not turn into italics.
* With `--icingaweb2-url` and `--hostname`, the notification gets an "Open Icinga Web 2" button that opens the host in Icinga Web 2. Tapping the notification itself opens the ntfy app.
* ntfy limits the size of a message (4096 bytes by default), of its title (1024 bytes) and of the whole request. The plugin shortens the host output first and the rest of the message only if that is not enough. A self-hosted ntfy server with a lower `message-size-limit` turns a longer message into an attachment, or refuses it if attachments are disabled.

**Icons and Priorities:**

The notification type decides icon and priority for acknowledgements, custom notifications and recoveries, the host state for all other types. ntfy plays no sound and does not vibrate for low and minimum priority; minimum priority notifications are listed under "Other notifications" on Android.

| Notification type / host state | Icon |
|----|----|
| ACKNOWLEDGEMENT | 👀 (`eyes`) |
| CUSTOM | 💬 (`speech_balloon`) |
| RECOVERY | ✅ (`white_check_mark`) |
| any other type, DOWN | 🚨 (`rotating_light`) |
| any other type, UNREACHABLE | ❓ (`question`) |
| any other type, UP | ✅ (`white_check_mark`) |

| Notification type / host state | ntfy priority |
|----|----|
| ACKNOWLEDGEMENT | 1 (min) |
| CUSTOM | 3 (default) |
| RECOVERY | 2 (low) |
| any other type, DOWN | 4 (high) |
| any other type, UNREACHABLE | 3 (default) |
| any other type, UP | 2 (low) |


## Fact Sheet

| Fact | Value |
|----|----|
| Notification Plugin Download          | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/notification-plugins/notify-host-ntfy> |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |


## Help

```text
usage: notify-host-ntfy [-h] [-V] --datetime DATETIME
                        --host-displayname HOST_DISPLAYNAME
                        [--host-output HOST_OUTPUT] --host-state HOST_STATE
                        [--hostname HOSTNAME]
                        [--icingaweb2-url ICINGAWEB2_URL] [--insecure]
                        [--no-markdown] [--no-proxy]
                        [--notification-author NOTIFICATION_AUTHOR]
                        [--notification-comment NOTIFICATION_COMMENT]
                        [--notification-type NOTIFICATION_TYPE]
                        [--proxy PROXY] [--timeout TIMEOUT] [--token TOKEN]
                        [--token-file TOKEN_FILE] --topic TOPIC [--url URL]

Sends host notifications to a topic on an ntfy server, which forwards them as
push notifications to the ntfy apps for Android, iOS and the web. Works with
the public ntfy.sh service and with self-hosted ntfy servers. The title names
the notification type and the host state, the icon follows the notification
type and the host state, and so does the priority: acknowledgements arrive
with minimum priority, without sound or vibration, recoveries with low and
custom notifications with default priority, all other notifications by host
state, DOWN with high, UNREACHABLE with default, UP with low priority. The
message is formatted as Markdown, with the host output in a code block. An
access token gives access to reserved or protected topics. A host output that
does not fit into an ntfy message is shortened, keeping its beginning and its
end.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --datetime DATETIME   Set the message timestamp ($icinga.short_date_time$).
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
  --no-markdown         Send the message as plain text instead of Markdown.
                        Useful for clients that do not render Markdown and
                        show its characters.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --notification-author NOTIFICATION_AUTHOR
                        Set the author of the comment ($notification.author$).
  --notification-comment NOTIFICATION_COMMENT
                        Set the comment ($notification.comment$).
  --notification-type NOTIFICATION_TYPE
                        Set the type of notification ($notification.type$).
                        Example: `--notification-type=PROBLEM`.
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --token TOKEN         ntfy access token. Required for topics that are
                        reserved or protected by an access control list.
                        Passed here, the token is visible to every user on
                        this host for as long as the plugin runs, because a
                        command-line argument shows up in the process list;
                        prefer --token-file.
  --token-file TOKEN_FILE
                        Path to a file holding the ntfy access token, read
                        from its first line. Keeps the token out of the
                        process list, where a command line argument is visible
                        to every user on this host. Takes precedence over
                        `--token`. Example: `--token-
                        file=/etc/icinga2/secrets/ntfy`
  --topic TOPIC         ntfy topic to publish to. Letters, digits, `-` and
                        `_`, up to 64 characters. Case-sensitive. Example:
                        `--topic=icinga`
  --url URL             Base URL of the ntfy server, without the topic.
                        Default: https://ntfy.sh

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/notification-plugins/notify-host-ntfy/
```


## Usage Examples

```bash
./notify-host-ntfy \
    --datetime="2026-11-22 20:51:00 +0100" \
    --host-displayname="webserver01" \
    --host-output="CRITICAL - Host Unreachable (192.0.2.10)" \
    --host-state=DOWN \
    --hostname=webserver01.example.com \
    --icingaweb2-url=https://icinga.example.com/icingaweb2 \
    --notification-type=PROBLEM \
    --token-file=/etc/icinga2/secrets/ntfy \
    --topic=icinga \
    --url=https://ntfy.example.com
```

This arrives with high priority and the 🚨 icon, titled `[PROBLEM] DOWN: webserver01 (2026-11-22 20:51:00 +0100)`, with this message:

````text
```
CRITICAL - Host Unreachable (192.0.2.10)
```
````

Its "Open Icinga Web 2" button opens the host in Icinga Web 2.


## Troubleshooting

### Topic does not accept the notification

`HTTP error "403 Forbidden" while fetching <url>`

The topic does not allow anonymous publishing, or the user the token belongs to has no write access to it. Pass a token with `--token-file` or `--token`, and grant the user write access on a self-hosted server with `ntfy access <user> <topic> rw`. On ntfy.sh, check that the topic is reserved by the account the token belongs to.

### Token not accepted

`HTTP error "401 Unauthorized" while fetching <url>`

ntfy does not know the token, for example because it expired or was deleted. Create a new one with `ntfy token add <user>` on a self-hosted server, or in the account settings on ntfy.sh.

### Rate limit reached

`HTTP error "429 Too Many Requests" while fetching <url>`

The ntfy server limits how many messages a client may publish. A large outage can hit that limit on the public ntfy.sh. Publish with a token of an account with higher limits, or raise `visitor-request-limit-burst` and `visitor-message-daily-limit` on a self-hosted server.

### `ntfy did not confirm the message (HTTP 200).`

ntfy answered, but not with the published message, so nothing was published. The usual cause is a redirect, for example from `http://` to `https://` or to another host name: the redirected request loses its content. Set `--url` to the address the ntfy server answers on directly.

### Invalid URL

`` Invalid URL "<url>". `--url` needs the base URL of the ntfy server (for example `https://ntfy.sh`), the topic goes into `--topic`. ``

`--url` contains a path, usually the topic, as in `https://ntfy.sh/icinga`. Set `--url=https://ntfy.sh` and `--topic=icinga`.

### Notifications arrive late on Android

The plugin hands the notification to the ntfy server at once; delivery to the phone is up to the ntfy app. For a topic on a self-hosted server, enable "Instant delivery" for the subscription in the app, or set `upstream-base-url: "https://ntfy.sh"` on the server so that the phone is woken through Firebase Cloud Messaging. Also exempt the ntfy app from battery optimization.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
