# Event cloudflare-security-level


## Overview

Changes the Cloudflare security level for one or more zones based on the current Icinga service state. When the service state changes to CRITICAL (even in SOFT state), the security level is set to "under_attack". When the state returns to OK, the security level is set back to "medium". This is useful, for example, when the Apache httpd status check reports overuse, to automatically enable Cloudflare's "Under Attack Mode" which displays a JavaScript challenge to visitors.

**Data Collection:**

* Uses the [Cloudflare API v4](https://api.cloudflare.com/#zone-settings-change-security-level-setting) to change the security level setting per zone
* Authenticates via `--username` (Cloudflare email) and `--key` (Cloudflare API key)
* Supports multiple zones via repeated `--zone-id` parameters


## Fact Sheet

| Fact | Value |
|----|-----|
| Event Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/event-plugins/cloudflare-security-level> |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |


## Help

```text
usage: cloudflare-security-level [-h] [-V] --key KEY
                                 --servicestate {CRITICAL,OK,UNKNOWN,WARNING}
                                 --username USERNAME --zone-id ZONE_ID

Event Plugin: Changes the security level for a zone at Cloudflare to
"under_attack" if the state of the service, from which this event plugin was
called, changes to CRITICAL (even in SOFT state). Changes it back to "medium"
when the state is OK. In "Under Attack Mode", Cloudflare displays a 5 second
delay when a visitor opens the website. This is useful, for example, when the
Apache httpd status check reports overuse.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --key KEY             Cloudflare API key.
  --servicestate {CRITICAL,OK,UNKNOWN,WARNING}
                        The current state of the service.
  --username USERNAME   Cloudflare API username (email address).
  --zone-id ZONE_ID     Cloudflare API zone identifier (from Cloudflare Portal
                        > Home > choose your site > Overview). Can be
                        specified multiple times.
```


## Usage Examples

Enable Cloudflare "Under Attack Mode" for two zones:

```bash
./cloudflare-security-level \
    --servicestate=CRITICAL \
    --key=1234 \
    --username=info@linuxfabrik.ch \
    --zone-id=0815 \
    --zone-id=4711
```

Disable Cloudflare "Under Attack Mode":

```bash
./cloudflare-security-level \
    --servicestate=OK \
    --key=1234 \
    --username=info@linuxfabrik.ch \
    --zone-id=0815 \
    --zone-id=4711
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
