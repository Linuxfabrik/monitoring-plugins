# Check icinga-director-template-overrides


## Overview

Lists where your own templates in the Icinga Director override the defaults of the Linuxfabrik templates: service templates that import a Linuxfabrik service template, directly or through further templates, and set variables of its check command to other values, and host templates whose service overrides apply to every host that imports them. For each override, the plugin shows the default it replaces. Overrides that no longer have an effect are listed separately: those for variables that the check command does not use (for example after a variable was renamed), those that merely repeat the default, and host template overrides for services that no host gets. Values of hidden or sensitive variables are masked. Overrides never cause an alert, as this is an inventory. Alerts only if the configuration of the Icinga Director cannot be read. Supports extended reporting via `--lengthy`.

It complements two other checks: `icinga-director-overrides` lists the overrides on single hosts ("Modify"), and `icinga-director-basket-drift` the changes made to the Linuxfabrik objects themselves.

**Important Notes:**

* Runs on the host with Icinga Web 2 and the Icinga Director module, typically the Icinga master. It calls `icingacli`, so the account running the check has to be able to read the Icinga Web 2 configuration. On most installations it is enough to add the monitoring user to the group `icingaweb2`: `sudo usermod --append --groups icingaweb2 icinga`, followed by a restart of Icinga 2. The LFOps role `icingaweb2` does this. Without `icingacli`, or without the permission to read the configuration, the check returns WARN, as there is something to fix on the host it was deployed to
* Which commands and templates are the Linuxfabrik ones is taken from the Director basket that ships with the plugins, at `<plugin-dir>/assets/icingaweb2-module-director-basket.json`
* A service template of your own counts if it imports a Linuxfabrik service template, at any depth, and its check command is a Linuxfabrik one. A template that runs a check command of its own and only borrows settings from a Linuxfabrik template, for example `tpl-service-generic`, is not listed
* Each template lists the variables it sets itself. The default is the value that the Linuxfabrik templates of its chain set. A variable that the check command uses but no Linuxfabrik template sets is listed with `(not set)` as the default, as the plugin then runs with its own default
* Only variables are compared, not other settings of a template such as the check interval
* The services a host gets depend on its own tags and imports. For a host template with overrides, the first enabled host that imports it stands in for all of them, so a service that this one host does not get is listed as missing
* To keep the tables narrow, a variable name loses its leading service or plugin name, so `cpu_usage_warning` becomes `warning`
* Values are compared the way they reach the plugin: `25` and `"25"` are the same, and a list with the same members in another order is not a change
* A value is masked if its data field is hidden, if its custom variable (or a member of it) is of the type "sensitive", or if its name contains `api-key`, `community`, `credential`, `pass`, `private-key`, `secret` or `token`. In all other values, credentials in the form `password=...` or in the userinfo of a URL (`https://user:******@host`) are masked as well
* Icinga DB Web shows only the first 10000 characters of a plugin output (`plugin_output_character_limit` in its `config.ini`, 65536 with LFOps). Without `--lengthy`, the check therefore lists at most 15 overrides of service templates, 15 of host templates and 10 without effect, and says how many it left out. Run it with `--lengthy` on the command line to see all of them

**Data Collection:**

* Reads the commands, data fields, host and service templates with `icingacli director basket dump --name export`. The basket definition `export` comes with the Linuxfabrik basket. The dump is built in memory and not stored, it takes 4 to 10 seconds
* Reads the custom variables with `icingacli director export customproperties` to know which values to mask. An Icinga Director without custom variables is supported
* Only if a host template carries overrides: reads all hosts with `icingacli director hosts fetch`, and for each such template the services of one host that imports it with `icingacli director host show --resolved --with-services --all-services`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/icinga-director-template-overrides> |
| Nagios/Icinga Check Name              | `check_icinga_director_template_overrides` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | Icinga Web 2 with the Icinga Director module, `icingacli`; an account that can read the Icinga Web 2 configuration |


## Help

```text
usage: icinga-director-template-overrides [-h] [-V] [--basket BASKET]
                                          [--basket-name BASKET_NAME]
                                          [--lengthy]
                                          [--override-varname OVERRIDE_VARNAME]
                                          [--timeout TIMEOUT]

Lists where your own templates in the Icinga Director override the defaults of
the Linuxfabrik templates: service templates that import a Linuxfabrik service
template, directly or through further templates, and set variables of its
check command to other values, and host templates whose service overrides
apply to every host that imports them. For each override, the plugin shows the
default it replaces. Overrides that no longer have an effect are listed
separately: those for variables that the check command does not use (for
example after a variable was renamed), those that merely repeat the default,
and host template overrides for services that no host gets. Values of hidden
or sensitive variables are masked. Overrides never cause an alert, as this is
an inventory. Alerts only if the configuration of the Icinga Director cannot
be read. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --basket BASKET       Path to the Director basket that tells which templates
                        and commands are the Linuxfabrik ones. Default:
                        `assets/icingaweb2-module-director-basket.json` in the
                        directory of this plugin, the basket that ships with
                        the installed plugins.
  --basket-name BASKET_NAME
                        Name of the basket definition in the Icinga Director
                        whose objects are read. It has to cover the commands,
                        data fields, host templates, service templates and
                        Service Sets. Case-sensitive. Default: export
  --lengthy             Extended reporting. Adds the Linuxfabrik template an
                        override replaces, does not shorten long values and
                        lists every override instead of the first ones.
  --override-varname OVERRIDE_VARNAME
                        Name of the host variable in which the Icinga Director
                        stores the per-host overrides of service variables.
                        Only needs to be changed if the Director setting
                        "override_services_varname" was changed. Case-
                        sensitive. Default: _override_servicevars
  --timeout TIMEOUT     Timeout for each call of `icingacli`, in seconds.
                        Default: 30 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/icinga-director-template-overrides/
```


## Usage Examples

```bash
./icinga-director-template-overrides
```

Output:

```text
6 variables overridden in 3 service templates, 1 in 1 host template, 7 overrides without effect.

Service Template                     ! Variable ! Default              ! Override
-------------------------------------+----------+----------------------+-----------------------------------------
tpl-service-cpu-usage-customer       ! count    ! (not set)            ! 3
tpl-service-cpu-usage-customer       ! warning  ! 80                   ! 90
tpl-service-cpu-usage-customer-db    ! critical ! 90                   ! 95
tpl-service-nextcloud-stats-customer ! login    ! ******               ! ******
tpl-service-nextcloud-stats-customer ! password ! (not set)            ! ******
tpl-service-nextcloud-stats-customer ! url      ! http://localhost/ocs ! https://nagios:******@cloud.example.c...

Host Template     ! Service    ! Variable ! Default ! Override
------------------+------------+----------+---------+---------
tpl-host-customer ! Swap Usage ! warning  ! 50      ! 70

Template                       ! Service     ! Variable    ! Without effect
-------------------------------+-------------+-------------+--------------------------------------------
tpl-host-customer              ! Old Service ! warning     ! service does not exist on web01.example.com
tpl-host-customer              ! Swap Usage  ! crit        ! not used by the check command
tpl-host-customer              ! Swap Usage  ! critical    ! same as the default
tpl-host-unused                ! Swap Usage  ! warning     ! no enabled host imports the template
tpl-service-cpu-usage-customer !             ! critical    ! same as the default
tpl-service-cpu-usage-customer !             ! criticality ! not used by the check command
tpl-service-cpu-usage-customer !             ! warn        ! not used by the check command
```

`tpl-service-cpu-usage-customer-db` imports `tpl-service-cpu-usage-customer`, which imports `tpl-service-cpu-usage`. Its `critical` of 95 replaces the 90 of the Linuxfabrik template, while its `warning` of 90 comes from the template in between and is listed there.

With `--lengthy`, every override is listed, long values are not shortened, and the service templates show the Linuxfabrik template they are based on:

```bash
./icinga-director-template-overrides --lengthy
```

Output (first table only):

```text
Service Template                     ! Variable ! Default              ! Override                                    ! Based on
-------------------------------------+----------+----------------------+---------------------------------------------+----------------------------
tpl-service-cpu-usage-customer       ! count    ! (not set)            ! 3                                           ! tpl-service-cpu-usage
tpl-service-cpu-usage-customer       ! warning  ! 80                   ! 90                                          ! tpl-service-cpu-usage
tpl-service-cpu-usage-customer-db    ! critical ! 90                   ! 95                                          ! tpl-service-cpu-usage
tpl-service-nextcloud-stats-customer ! login    ! ******               ! ******                                      ! tpl-service-nextcloud-stats
tpl-service-nextcloud-stats-customer ! password ! (not set)            ! ******                                      ! tpl-service-nextcloud-stats
tpl-service-nextcloud-stats-customer ! url      ! http://localhost/ocs ! https://nagios:******@cloud.example.com/ocs ! tpl-service-nextcloud-stats
```


## States

* OK, whatever overrides are found.
* WARN if `icingacli` is missing, times out, fails or does not return valid data. If only the services of the host standing in for a host template cannot be read, everything else is still listed.
* UNKNOWN if the basket that ships with the plugins cannot be read or is not a Director basket, on invalid command-line arguments, or if the Icinga Director returns its objects in an unexpected shape.


## Perfdata / Metrics

There is no perfdata.


## Troubleshooting

### A variable is listed as "not used by the check command"

Usually the variable was renamed in the Linuxfabrik check command, and your template still sets the old name. Its value no longer reaches the plugin. Compare the name with the arguments of the check command in the Icinga Director, move the value to the new variable in your template and remove the old one. If the check command really uses the variable, it builds the macro in a way this check does not recognize, for example with a name assembled in a function.

### Basket not readable

`` Cannot read the basket `/usr/lib64/nagios/plugins/assets/icingaweb2-module-director-basket.json`. ``

The plugins were installed without their assets, or from a release that did not ship the basket yet. Reinstall the plugins, or point `--basket` at a basket built with `tools/basket-join` from the matching release of the repository.

### Icinga Web 2 configuration not readable

`` `icingacli director basket dump` failed with exit code 1: ERROR: Cannot read enabled modules. Config directory "/etc/icingaweb2" is not readable. ``

The account running the check cannot read the Icinga Web 2 configuration. Add the monitoring user to the group `icingaweb2` (`sudo usermod --append --groups icingaweb2 icinga`) and restart Icinga 2, so that the new group membership applies to the checks it runs.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
