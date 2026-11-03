# Check icinga-director-overrides


## Overview

Lists the service variables that were deliberately overridden for a single host in the Icinga Director, for example a threshold changed with "Modify" on a service that comes from a Service Set or an apply rule. For each override, the plugin shows the value the service would have without it, as configured in its templates, Service Sets and host templates, so the deviation from the configured default is visible at a glance. Overrides that no longer have an effect are listed separately: those for services that no longer exist on the host, for variables that the check command does not use (for example after a variable was renamed), and those that merely repeat the default. Values of hidden or sensitive variables are masked. Overrides never cause an alert, as this is an inventory. Alerts only if the configuration of the Icinga Director cannot be read. Supports extended reporting via `--lengthy`.

The default of a service is everything configured for it in the Icinga Director: its service templates, the Service Set or apply rule it comes from, and the overrides on the host templates the host imports, including your own templates. Only what was entered for the host itself counts as an override.

**Important Notes:**

* Runs on the host with Icinga Web 2 and the Icinga Director module, typically the Icinga master. It calls `icingacli`, so the account running the check has to be able to read the Icinga Web 2 configuration. On most installations it is enough to add the monitoring user to the group `icingaweb2`: `sudo usermod --append --groups icingaweb2 icinga`, followed by a restart of Icinga 2. Without `icingacli`, or without the permission to read the configuration, the check returns WARN, as there is something to fix on the host it was deployed to
* Services created directly on a host ("single services") are not covered. They are specific to their host by design, and every variable on them would count as an override
* A host's override of a service replaces the overrides that its host templates define for the same service as a whole, it does not add to them. A variable that only a host template overrides is therefore back at the value of the service on such a host. The plugin lists it as an override, with the value of the host template as the default
* The Icinga Director does not tell from its exports whether a service of a Service Set was deactivated for a host. Overrides for such a service are listed as if the service were active
* To keep the tables narrow, a host is shown by its short name (the part before the first dot), unless another host has the same short name or the name is an IP address. A variable name loses its leading service name, so `cpu_usage_warning` of the service "CPU Usage" becomes `warning`
* Values are compared the way they reach the plugin: `25` and `"25"` are the same, and a list with the same members in another order is not a change
* A value is masked if its data field is hidden, if its custom variable (or a member of it) is of the type "sensitive", or if its name contains `api-key`, `community`, `credential`, `pass`, `private-key`, `secret` or `token`. In all other values, credentials in the form `password=...` or in the userinfo of a URL (`https://user:******@host`) are masked as well

**Data Collection:**

* Reads all hosts and host templates with `icingacli director hosts fetch`, and the check commands with `icingacli director commands fetch`
* Reads the data fields and custom variables with `icingacli director export datafields` and `icingacli director export customproperties` to know which values to mask. An Icinga Director without custom variables is supported
* For every enabled host with overrides of its own, reads its services with `icingacli director host show --resolved --with-services --all-services`. This lets the Icinga Director resolve which Service Sets and apply rules match the host, and returns each service with the values of its templates, without the overrides of the host. These calls take 0.5 to 1.2 seconds each and run in parallel, see `--max-workers`
* An override has no effect if its service is not on the host, if neither the arguments nor the command line of the check command use the variable (directly, or through the value of another variable they use), or if it repeats the default


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/icinga-director-overrides> |
| Nagios/Icinga Check Name              | `check_icinga_director_overrides` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | Icinga Web 2 with the Icinga Director module, `icingacli`; an account that can read the Icinga Web 2 configuration |


## Help

```text
usage: icinga-director-overrides [-h] [-V] [--lengthy]
                                 [--max-workers MAX_WORKERS]
                                 [--override-varname OVERRIDE_VARNAME]
                                 [--timeout TIMEOUT]

Lists the service variables that were deliberately overridden for a single
host in the Icinga Director, for example a threshold changed with "Modify" on
a service that comes from a Service Set or an apply rule. For each override,
the plugin shows the value the service would have without it, as configured in
its templates, Service Sets and host templates, so the deviation from the
configured default is visible at a glance. Overrides that no longer have an
effect are listed separately: those for services that no longer exist on the
host, for variables that the check command does not use (for example after a
variable was renamed), and those that merely repeat the default. Values of
hidden or sensitive variables are masked. Overrides never cause an alert, as
this is an inventory. Alerts only if the configuration of the Icinga Director
cannot be read. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --lengthy             Extended reporting. Adds the Service Set of each
                        service and does not shorten long values.
  --max-workers MAX_WORKERS
                        Maximum number of hosts whose services are read from
                        the Icinga Director in parallel. Default: 4
  --override-varname OVERRIDE_VARNAME
                        Name of the host variable in which the Icinga Director
                        stores the per-host overrides of service variables.
                        Only needs to be changed if the Director setting
                        "override_services_varname" was changed. Case-
                        sensitive. Default: _override_servicevars
  --timeout TIMEOUT     Timeout for each call of `icingacli`, in seconds.
                        Default: 8 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/icinga-director-overrides/
```


## Usage Examples

```bash
./icinga-director-overrides
```

Output:

```text
9 overridden service variables on 2 of 3 hosts, 5 overrides without effect.

Host  ! Service               ! Variable ! Default                            ! Override
------+-----------------------+----------+------------------------------------+-----------------------------------------
db01  ! Apache httpd Security ! ignore   ! ["Proxy modules", "Status module"] ! ["Status module", "Proxy modules", "R...
db01  ! CPU Usage             ! warning  ! 80                                 ! 90
db01  ! Nextcloud Stats       ! hostname ! localhost                          ! cloud.example.com
db01  ! Nextcloud Stats       ! login    ! ******                             ! ******
db01  ! Nextcloud Stats       ! password ! (not set)                          ! ******
db01  ! Nextcloud Status      ! url      ! http://localhost/status.php        ! https://nagios:******@cloud.example.c...
db01  ! SNMP Uptime           ! snmp_v3  ! (not set)                          ! ******
web01 ! Swap Usage            ! critical ! 90                                 ! 95
web01 ! Swap Usage            ! warning  ! 70                                 ! 50

Host ! Service     ! Variable    ! Without effect
-----+-------------+-------------+-----------------------------------
db01 ! CPU Usage   ! critical    ! same as the default
db01 ! CPU Usage   ! criticality ! not used by the check command
db01 ! CPU Usage   ! warn        ! not used by the check command
db01 ! Disk Usage  ! ignore      ! same as the default
db01 ! Old Service ! warning     ! service does not exist on the host
```

`warning` of "Swap Usage" on web01 shows the case described in the Important Notes: a host template sets it to 70 for all hosts, but web01 overrides "Swap Usage" itself, which drops the value of the host template.

With `--lengthy`, the Service Set of each service is added, and long values are not shortened:

```bash
./icinga-director-overrides --lengthy
```

Output (first table only):

```text
9 overridden service variables on 2 of 3 hosts, 5 overrides without effect.

Host  ! Service               ! Variable ! Default                            ! Override                                                 ! Service Set
------+-----------------------+----------+------------------------------------+----------------------------------------------------------+----------------------------
db01  ! Apache httpd Security ! ignore   ! ["Proxy modules", "Status module"] ! ["Status module", "Proxy modules", "Request line limit"] ! Apache httpd Service Set
db01  ! CPU Usage             ! warning  ! 80                                 ! 90                                                       ! OS - RHEL Basic Service Set
db01  ! Nextcloud Stats       ! hostname ! localhost                          ! cloud.example.com                                        ! Nextcloud Service Set
db01  ! Nextcloud Stats       ! login    ! ******                             ! ******                                                   ! Nextcloud Service Set
db01  ! Nextcloud Stats       ! password ! (not set)                          ! ******                                                   ! Nextcloud Service Set
db01  ! Nextcloud Status      ! url      ! http://localhost/status.php        ! https://nagios:******@cloud.example.com/status.php       ! Nextcloud Service Set
db01  ! SNMP Uptime           ! snmp_v3  ! (not set)                          ! ******                                                   !
web01 ! Swap Usage            ! critical ! 90                                 ! 95                                                       ! OS - RHEL Basic Service Set
web01 ! Swap Usage            ! warning  ! 70                                 ! 50                                                       ! OS - RHEL Basic Service Set
```


## States

* OK, whatever overrides are found.
* WARN if `icingacli` is missing, times out, fails or does not return valid data. If only the services of some hosts cannot be read, the overrides of all other hosts are still listed.
* UNKNOWN on invalid command-line arguments, or if the Icinga Director returns its hosts in an unexpected shape.


## Perfdata / Metrics

There is no perfdata.


## Troubleshooting

### Icinga Web 2 configuration not readable

`` `icingacli director hosts fetch` failed with exit code 1: ERROR: Cannot read enabled modules. Config directory "/etc/icingaweb2" is not readable. ``

The account running the check cannot read the Icinga Web 2 configuration. Add the monitoring user to the group `icingaweb2` (`sudo usermod --append --groups icingaweb2 icinga`) and restart Icinga 2, so that the new group membership applies to the checks it runs.

### `icingacli` not found

`` `icingacli director hosts fetch` failed: Command "icingacli" not found (No such file or directory). Install it, or make sure it is in the PATH of the account running this. ``

The check does not run on the host with Icinga Web 2, or `icingacli` is not in the `PATH` of the monitoring user. Run the check on the Icinga master that hosts the Icinga Director.

### `` `icingacli director host show` failed: Timeout after 8 seconds. ``

A single call of `icingacli` took longer than `--timeout`. Reading the services of a host with several hundred services can take longer; raise `--timeout`. If the whole check runs into the timeout of the check command instead, lower the number of hosts read one after the other by raising `--max-workers`, or raise the timeout of the check command.

### A variable is listed as "not used by the check command", but the plugin does use it

Usually the variable was renamed in the check command, for example by a basket import, and the override still uses the old name. Its value no longer reaches the plugin. Compare the name with the arguments of the check command in the Icinga Director, move the value to the new variable with "Modify" and remove the old one. If the check command really uses the variable, it builds the macro in a way this check does not recognize, for example with a name assembled in a function.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
