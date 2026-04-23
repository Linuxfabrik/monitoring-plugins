# Icinga Director Integration

The Linuxfabrik Monitoring Plugins ship a complete Icinga Director configuration:
one Command per plugin, Host Templates, Service Templates, ~150 Service Sets with
ready-made `assign` filters, Time Periods, a Notification setup, and the Data
Lists and Datafields they reference. You get from "fresh Director" to "Linux and
Windows hosts are monitored" by importing one basket and tagging your hosts.

This document explains what the basket contains, how to import it, how to operate
it day-to-day, and how we expect you to extend it. Plugin authors looking for the
per-plugin basket workflow (editing the YAML under
`check-plugins/<name>/icingaweb2-module-director/`, regenerating with
`build-basket`) should read the Icinga Director Basket Config section in
[CONTRIBUTING.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/CONTRIBUTING.md)
instead.


## Quick Start

1. Generate the joined basket:

    ```bash
    ./tools/basket-join
    ```

    This produces `icingaweb2-module-director-basket.json` at the repository
    root. On any Director v1.9.0 or newer (that is, every currently supported
    release), the file imports as-is. The legacy `basket-remove-uuids` tool is
    still available for the rare edge cases described in *Troubleshooting*.

2. Import it on the Icinga 2 master:

    ```bash
    icingacli director basket restore --verbose < icingaweb2-module-director-basket.json
    ```

    Alternatively, upload the file in the Director GUI under
    *Configuration Baskets > Upload*, then open the freshly uploaded snapshot
    and click *Restore*.

3. Create your first host:

    * Import template `tpl-host-linux` (or `tpl-host-windows`).
    * Set `host_criticality` (A, B, or C) and `tag_list` (e.g. `rocky10`,
      `nextcloud`, `mysql`).

    Service Sets are applied automatically based on the tags you set. No
    `apply` rules to write by hand.


## What the Basket Ships

The basket is assembled by `tools/basket-join` from two sources:

* Per-plugin baskets at `check-plugins/<name>/icingaweb2-module-director/<name>.json`
  (generated from the matching `<name>.yml` by `tools/build-basket`). Each
  contributes one Command, one Service Template, the Datafields its parameters
  need, and occasionally an extra Service Set.
* The shared framework in `assets/icingaweb2-module-director/all-the-rest.json`:
  Host Templates, core Service Templates, Service Sets, Time Periods,
  Notifications, a User Template, Data Lists.

The result has the following object classes. Inspect the joined JSON if you need
the full list.


### Host Templates

* `tpl-host-generic`: base template, sets check interval and notification policy.
* `tpl-host-hardware-server`: extends `tpl-host-generic` for physical servers.
* `tpl-host-linux`: Linux hosts, pulls in the Linux Service Set baseline.
* `tpl-host-other`: for appliances, switches and anything that is neither Linux
  nor Windows. No OS-specific Service Sets.
* `tpl-host-windows`: Windows hosts.
* `tpl-host-without-ping`: hosts that do not answer ICMP (for example, hosts
  only reachable through the Icinga Agent on a non-routed management interface).


### Service Templates

All service templates inherit the `criticality` concept (see *Core Concepts*)
and link `notes_url` to the matching docs page on
<https://linuxfabrik.github.io/monitoring-plugins/>.

* `tpl-service-cert`: certificate checks that run on the Icinga Agent of the
  host owning the certificate.
* `tpl-service-cert-no-agent`: certificate checks executed from the Icinga
  master against a remote endpoint.
* `tpl-service-generic`: base for all active checks. Most per-plugin Service
  Templates import this.
* `tpl-service-icinga`: for checks targeting the Icinga 2 infrastructure
  itself.
* `tpl-service-passive`: for passive checks fed by external sources.
* `tpl-service-url`: HTTP(S) URL checks that run on an Icinga Agent.
* `tpl-service-url-no-agent`: HTTP(S) URL checks from the master (no agent
  needed on the target).


### Service Sets

The basket ships roughly 150 Service Sets that cover operating systems
(Debian 10-13, Rocky 8-10, Ubuntu 16-26, Windows Server, ...), applications
(Apache HTTPD, MySQL, Nextcloud, Postfix, Rocket.Chat, WildFly, ...) and roles
(mail server, backup target, DHCP server, ...).

Each Service Set is auto-applied by an `assign_filter` of the form:

```text
"<tag>"=host.vars.tags
```

The set activates on any host that has the matching tag in its `tag_list`.
Example: the `AIDE Service Set` activates for hosts tagged `aide` and ships two
`systemd-unit` services (`aide-check.service`, `aide-check.timer`).

Rather than documenting every set, browse the sets directly in the Director GUI
after import (*Services > Service Sets*) or grep the joined basket file:

```bash
jq '.ServiceSet | keys[]' icingaweb2-module-director-basket.json
```


### Time Periods

The basket defines five periods we rely on in the notification rules:

* `5x12`: Monday to Friday, 07:00 to 19:00.
* `7x8`: every day, 08:00 to 16:00.
* `7x12`: every day, 07:00 to 19:00.
* `7x24`: always on.
* `Non-working-hours`: the complement of `5x12`, used to mute warnings that only
  matter during business hours.


### Notifications and User Template

Four notification templates are provided for Host and Service Notifications
during `5x12` and `7x24`. They are marked
`do not use directly - clone to use`: to make a notification rule that actually
sends, clone the matching template, set your notification command, and link the
user (or a group derived from the `tpl-user` template).


### Data Lists

* `host_criticality_list`: enum A, B, C for the host's `criticality` field.
* `size_unit_list`, `time_unit_list`: reused across Datafields.
* `tag_list`: the fundamental list of tags. Assign one or more of these to each
  host to activate the matching Service Sets.
* `delete_me_custom_tag_list`: a placeholder demonstrating how a site can add
  custom tag lists next to ours. Rename it to your actual list name after
  import and drop the suffix.


### Datafields

Around 35 Datafields are shared across plugins (common parameters like
`--warning`, `--critical`, `--url`, `--username`, `--timeout`). `basket-join`
renumbers their IDs while merging so you end up with a single, conflict-free
ID space.


## Core Concepts


### Host-to-Service Assignment via Tags

Every Service Set carries an `assign_filter` of the form `"<tag>"=host.vars.tags`.
To activate services on a host, drop the matching tags into its `tag_list`
custom variable. No manual per-host service assignment and no `apply` rules are
needed.

Typical tags you will set: an OS family and release (for example `rocky10`), one
or more hardware/role tags, and one tag per installed application you monitor.

If you need tags outside of our list, create your own Data List (or rename the
shipped `delete_me_custom_tag_list`) and reference it from an additional
Datafield attached to your Host Template. Do not edit our `tag_list`; see
*Day-to-Day Operations*.


### Criticality

We manage notifications with a custom variable `criticality`, present on both
hosts and services. A criticality of `A` triggers notifications 7x24, `B`
during `5x12`, `C` never.

The host's criticality caps its services' effective criticality. A service
tagged `A` on a host tagged `B` is treated as `B`. We try to set reasonable
defaults in the Service Templates, so in most cases you only need to set the
host criticality.

Host notifications:

| Host Criticality | Result           |
|------------------|------------------|
| `A`              | sent during 7x24 |
| `B`              | sent during 5x12 |
| `C`              | not sent         |

Service notifications:

| Host Criticality | Service Criticality | Result           |
|------------------|---------------------|------------------|
| `A`              | `A`                 | sent during 7x24 |
| `A`              | `B`                 | sent during 5x12 |
| `A`              | `C`                 | not sent         |
| `B`              | `A`                 | sent during 5x12 |
| `B`              | `B`                 | sent during 5x12 |
| `B`              | `C`                 | not sent         |
| `C`              | `A`                 | not sent         |
| `C`              | `B`                 | not sent         |
| `C`              | `C`                 | not sent         |

The criticality behaviour relies on the notification rules in
`all-the-rest.json`. If you replace those, the table no longer applies.


### Agent vs. Agentless

Most checks run on the Icinga Agent of the monitored host (the plugin files are
deployed there). Checks where that is impossible or wasteful (typical example:
external HTTPS endpoints, certificate checks from a central vantage point) use
the `-no-agent` variants of `tpl-service-url` / `tpl-service-cert`, which run
from the Icinga master instead. Pick the variant that matches where you want
the check to actually execute.


### Notes URL

Each Service Template's `notes_url` points at the matching plugin documentation
page on <https://linuxfabrik.github.io/monitoring-plugins/>. In the Icinga Web 2
service detail view, click the book icon to jump straight to that page. If you
regenerate the basket after editing Service Templates locally, re-run
`tools/build-basket --auto` so the links stay in sync.


## Upstream Director vs. Linuxfabrik Fork

The basket is designed for the
[upstream Icinga Director](https://github.com/Icinga/icingaweb2-module-director)
from v1.9.0 onwards (UUIDs are supported there since 2022). That is our
recommended deployment target.

We additionally maintain a
[fork](https://github.com/Linuxfabrik/icingaweb2-module-director) that adds one
feature: **automatic renaming of applied related vars during basket imports**.
Use it only if you regularly reimport baskets and want the values you already
set on hosts and services to follow when a Datafield is renamed. The fork
currently tracks upstream v1.11.7. Everything else in this document applies to
both.


## Importing


### Full Basket

Use this for fresh installs and for version upgrades.

1. From a checkout of the monitoring-plugins repository, build the joined
   basket:

    ```bash
    ./tools/basket-join
    ```

    This writes `icingaweb2-module-director-basket.json` at the repository
    root. The file merges every per-plugin basket with `all-the-rest.json` and
    renumbers Datafield IDs.

2. If your Icinga 2 master zone is not named `master`, replace the placeholder
   in the generated file:

    ```bash
    sed --in-place 's/"zone": "master"/"zone": "your-master-zone"/g' \
        icingaweb2-module-director-basket.json
    ```

3. Import on the master:

    ```bash
    icingacli director basket restore --verbose \
        < icingaweb2-module-director-basket.json
    ```

    Or upload the file in the GUI under *Configuration Baskets > Upload*, then
    open the new snapshot and click *Restore*.

4. Activate the changes in the Director (*Activity Log > Deploy*).


### Single-Plugin Basket

Each per-plugin basket under
`check-plugins/<name>/icingaweb2-module-director/<name>.json` is importable on
its own. Use this to try out a new plugin on a Director that already has your
production config, without touching anything else:

```bash
icingacli director basket restore --verbose < cpu-usage.json
```

The per-plugin basket ships the Command and the Service Template only; Host
Templates, Service Sets, Time Periods and Notifications come with the full
basket.


### Manual Command Definition

If you do not want to use baskets at all, you can re-create one Command by
hand. For `cpu-usage`:

* *Director > Commands > Commands > Add*, type *Plugin Check Command*.
* Command name `cmd-check-cpu-usage`, Command
  `/usr/lib64/nagios/plugins/cpu-usage`, Timeout `10`.
* Under *Arguments*, add an argument for every option the plugin supports, for
  example:

    * `--always-ok`, Value type *String*, Condition `$cpu_usage_always_ok$`
    * `--count`, Value type *String*, Value `$cpu_usage_count$`
    * `--critical`, Value type *String*, Value `$cpu_usage_critical$`
    * `--warning`, Value type *String*, Value `$cpu_usage_warning$`

* Under *Fields*, expose the arguments as user-facing fields (`CPU Usage:
  Warning`, etc.).

Run the plugin's `--help` to see the full option list. This path is tedious
for ~230 plugins: we mention it for completeness, but recommend the basket
workflow.


## Day-to-Day Operations


### Onboarding a new host

1. Create the host, import `tpl-host-linux` or `tpl-host-windows`.
2. Set `host_criticality` (A, B, C).
3. Set `tag_list` with one OS tag plus one tag per application or role
   you want monitored on this host.
4. Deploy.


### Updating After a Plugin Release

On every release, regenerate the basket and review the diff before importing:

```bash
./tools/basket-join
./tools/basket-compare \
    --old <previous-version>/icingaweb2-module-director-basket.json \
    --new icingaweb2-module-director-basket.json
```

`basket-compare` prints one table per object class (Datafield, Command, Host
Template, Service Template, Service Set) showing only the rows that changed,
so you can spot parameter renames and new Service Sets before they hit your
Director. Then restore as usual.

For Director Branches users: test the new basket in a branch first. The
Linuxfabrik fork is not tested with the Configuration Branches module.


### Adding your own Service Sets

Append them to `assets/icingaweb2-module-director/all-the-rest.json`, generate
a new UUID for every object you add, and run `./tools/basket-join` again. A
quick syntax check:

```bash
jq . assets/icingaweb2-module-director/all-the-rest.json > /dev/null
```

If you need deeper hooks into the basket generation (for example, per-OS
variants of a check command), see the CONTRIBUTING.md section on
Icinga Director Basket Config.


### Overriding our Service Templates

Do not edit our templates in place, as basket reimports will overwrite them.
Clone the shipped template to `tpl-service-<name>-local` (or similar) in your
own basket or Director, set your overrides there, and have your services
import the local version.


## Troubleshooting


### "exceeds the defined ini size" on Upload

The joined basket can exceed a few megabytes. If the GUI rejects the upload,
increase your PHP and database limits
([upstream issue #2458](https://github.com/Icinga/icingaweb2-module-director/issues/2458)):

* PHP: `upload_max_filesize` and `post_max_size` in `php.ini`. Restart
  `php-fpm` if you use it.
* MariaDB / MySQL: `max_allowed_packet` in the server config.

As a workaround, use the CLI (`icingacli director basket restore < file`),
which is not subject to the PHP upload limit.


### Basket Import Fails with UUID Conflicts

On Director v1.9.0 and later, the UUID-carrying basket imports cleanly. This
section applies to two narrow edge cases only:

* a Director installation older than v1.9.0 that predates UUID support,
* a reimport where a UUID in the basket collides with a different object that
  already owns that UUID in the target database (typically after the basket
  was regenerated from a different source tree).

Strip UUIDs and import the cleaned file:

```bash
./tools/basket-join
./tools/basket-remove-uuids \
    --input-file icingaweb2-module-director-basket.json \
    --output-file icingaweb2-module-director-basket-no-uuids.json
icingacli director basket restore --verbose \
    < icingaweb2-module-director-basket-no-uuids.json
```

Trade-off: without UUIDs, Director falls back to name-based object matching,
which loses the ability to rename a Datafield while preserving the values
already set on hosts and services. Use this only after an actual import
error.


### Master zone is not named `master`

Every Service Template in `all-the-rest.json` carries `"zone": "master"`. If
your Icinga 2 master zone has a different name, replace the literal before
importing:

```bash
sed --in-place 's/"zone": "master"/"zone": "icinga-master-zone"/g' \
    icingaweb2-module-director-basket.json
```
