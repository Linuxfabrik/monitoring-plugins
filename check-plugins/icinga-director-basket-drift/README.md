# Check icinga-director-basket-drift


## Overview

Compares the Linuxfabrik objects in the Icinga Director (data fields, commands, host and service templates, Service Sets) with the Director basket that ships with the installed plugins. Alerts if one of them is missing in the Director or differs from the basket: either it was changed in the Director, and the next import of the basket would overwrite that change, or the basket of a newer plugin release has not been imported yet. Says what to do about it. Objects of your own are not checked. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Runs on the host with Icinga Web 2 and the Icinga Director module, typically the Icinga master. It calls `icingacli`, so the account running the check has to be able to read the Icinga Web 2 configuration. On most installations it is enough to add the monitoring user to the group `icingaweb2`: `sudo usermod --append --groups icingaweb2 icinga`, followed by a restart of Icinga 2. The LFOps role `icingaweb2` does this. Without `icingacli`, or without the permission to read the configuration, the check returns WARN, as there is something to fix on the host it was deployed to
* The plugins ship the joined Director basket of their own release at `<plugin-dir>/assets/icingaweb2-module-director-basket.json`. Right after an update of the plugins, every object the new release changes is listed until the basket is imported. That is intended: the warning is the reminder to import it
* The check cannot tell a change made in the Director from a release that has not been imported yet. Both are fixed the same way, and in both cases the import overwrites what is in the Director now
* Objects that exist only in the Director, your own templates and commands or objects that a former release dropped, are not checked: importing the basket leaves them alone. Overrides per host are listed by the check `icinga-director-overrides`
* Differences that are only a matter of how the Director exports an object are ignored: renumbered data fields, the short form of a command argument, the plugin directory in a command line, `25` against `"25"`, an empty field against a missing one, and the description of a service
* Icinga DB Web shows only the first 10000 characters of a plugin output (`plugin_output_character_limit` in its `config.ini`, 65536 with LFOps). Without `--lengthy`, the check therefore lists at most 30 differences, shortens values to 40 characters and leaves out the data fields and the data field bindings of commands, as they come with the commands that use them. Run it with `--lengthy` on the command line to see everything
* A list that shares members with its counterpart shows only the members that differ, the shared ones are replaced by `...`: `[..., "load-old"]` against `[..., "load"]`, so that a long list does not hide its difference behind a shortened value
* Values of variables whose name contains `api-key`, `community`, `credential`, `pass`, `private-key`, `secret` or `token` are masked, as are credentials in the form `password=...` or in the userinfo of a URL

**Data Collection:**

* Reads the objects in the Icinga Director with `icingacli director basket dump --name export`. The basket definition `export` comes with the Linuxfabrik basket and covers all object types it contains. The dump is built in memory and not stored, it takes 4 to 10 seconds
* Matches the objects of both sides by their uuid and compares them field by field


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/icinga-director-basket-drift> |
| Nagios/Icinga Check Name              | `check_icinga_director_basket_drift` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | Icinga Web 2 with the Icinga Director module, `icingacli`; an account that can read the Icinga Web 2 configuration |


## Help

```text
usage: icinga-director-basket-drift [-h] [-V] [--always-ok] [--basket BASKET]
                                    [--basket-name BASKET_NAME] [--lengthy]
                                    [--timeout TIMEOUT]

Compares the Linuxfabrik objects in the Icinga Director (data fields,
commands, host and service templates, Service Sets) with the Director basket
that ships with the installed plugins. Alerts if one of them is missing in the
Director or differs from the basket: either it was changed in the Director,
and the next import of the basket would overwrite that change, or the basket
of a newer plugin release has not been imported yet. Says what to do about it.
Objects of your own are not checked. Supports extended reporting via
--lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --basket BASKET       Path to the Director basket to compare with. Default:
                        `assets/icingaweb2-module-director-basket.json` in the
                        directory of this plugin, the basket that ships with
                        the installed plugins.
  --basket-name BASKET_NAME
                        Name of the basket definition in the Icinga Director
                        whose objects are read. It has to cover the commands,
                        data fields, host templates, service templates and
                        Service Sets. Case-sensitive. Default: export
  --lengthy             Extended reporting. Lists every difference, data
                        fields included, and does not shorten long values.
  --timeout TIMEOUT     Timeout for the call of `icingacli`, in seconds.
                        Default: 30 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/icinga-director-basket-drift/
```


## Usage Examples

```bash
./icinga-director-basket-drift
```

Output:

```text
Icinga Director not up to date with the plugins basket: 4 objects differ, 1 missing [WARNING]

The import of the basket overwrites local changes to these objects, so move changes you want to keep into your own templates or into host overrides first. Then import the basket with `sudo icingacli director basket restore < /usr/lib64/nagios/plugins/assets/icingaweb2-module-director-basket.json` and deploy the result to Icinga 2 with `sudo icingacli director config deploy` (or in the Icinga Director under "Activity Log > Deploy"). Afterwards, look for overrides without effect in "Icinga Director Overrides": they point to renamed parameters.

Type             ! Object                       ! Field                          ! Current                                  ! After Import
-----------------+------------------------------+--------------------------------+------------------------------------------+-----------------------------
Service Set      ! Linux Service Set > Load     ! groups                         ! [..., "load-old"]                        ! [..., "load"]
Service Set      ! Linux Service Set > Load     ! imports                        ! ["tpl-service-load-old"]                 ! ["tpl-service-load"]
Service Template ! tpl-service-load             ! vars.load_warning              ! 85                                       ! 80
Service Template ! tpl-service-nextcloud-status ! vars.nextcloud_status_password ! ******                                   ! (not set)
Service Template ! tpl-service-nextcloud-status ! vars.nextcloud_status_url      ! https://nagios:******@cloud.example.c... ! http://localhost/status.php
Service Template ! tpl-service-swap             !                                ! missing                                  !
Command          ! cmd-check-load               ! arguments.--critical           ! (not set)                                ! {"value": "$load_critical$"}
```

A service of a Service Set is shown as `<Service Set> > <service>`. Current is the value in the Icinga Director now, After Import the value an import of the basket that ships with the plugins sets. If the object was changed in the Director, After Import is the older value, and the import undoes the change.

With `--lengthy`, every difference is listed, data fields included, and long values are not shortened:

```bash
./icinga-director-basket-drift --lengthy
```

Output (table only):

```text
Type             ! Object                       ! Field                          ! Current                                            ! After Import
-----------------+------------------------------+--------------------------------+----------------------------------------------------+-----------------------------
Service Set      ! Linux Service Set > Load     ! groups                         ! [..., "load-old"]                                  ! [..., "load"]
Service Set      ! Linux Service Set > Load     ! imports                        ! ["tpl-service-load-old"]                           ! ["tpl-service-load"]
Service Template ! tpl-service-load             ! vars.load_warning              ! 85                                                 ! 80
Service Template ! tpl-service-nextcloud-status ! vars.nextcloud_status_password ! ******                                             ! (not set)
Service Template ! tpl-service-nextcloud-status ! vars.nextcloud_status_url      ! https://nagios:******@cloud.example.com/status.php ! http://localhost/status.php
Service Template ! tpl-service-swap             !                                ! missing                                            !
Command          ! cmd-check-load               ! arguments.--critical           ! (not set)                                          ! {"value": "$load_critical$"}
```


## States

* OK if every Linuxfabrik object of the basket exists in the Icinga Director and matches the basket.
* WARN if one of them is missing or differs.
* WARN if `icingacli` is missing, times out, fails or does not return valid data.
* UNKNOWN if the basket cannot be read or is not a Director basket, on invalid command-line arguments, or if the Icinga Director returns its objects in an unexpected shape.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Troubleshooting

### Objects differ or are missing

1. If the plugins were updated recently, the new basket has probably not been imported yet. Otherwise, the listed objects were changed in the Icinga Director.
2. Run the check with `--lengthy` to see both values of every differing field.
3. Move changes you want to keep out of the Linuxfabrik objects: into a service template of your own that imports the Linuxfabrik one, or into a host override with "Modify".
4. Import the basket: `sudo icingacli director basket restore < /usr/lib64/nagios/plugins/assets/icingaweb2-module-director-basket.json` (the path of the plugin directory differs by distribution, the check names it in its output).
5. Deploy the result to Icinga 2: `sudo icingacli director config deploy`, or in the Icinga Director under "Activity Log > Deploy". Until then, the import only changed the configuration in the Icinga Director.
6. Check "Icinga Director Overrides" for overrides without effect: a parameter that the release renamed shows up there with its old name.

### Basket not readable

`` Cannot read the basket `/usr/lib64/nagios/plugins/assets/icingaweb2-module-director-basket.json`. ``

The plugins were installed without their assets, or from a release that did not ship the basket yet. Reinstall the plugins, or point `--basket` at a basket built with `tools/basket-join` from the matching release of the repository.

### Icinga Web 2 configuration not readable

`` `icingacli director basket dump` failed with exit code 1: ERROR: Cannot read enabled modules. Config directory "/etc/icingaweb2" is not readable. ``

The account running the check cannot read the Icinga Web 2 configuration. Add the monitoring user to the group `icingaweb2` (`sudo usermod --append --groups icingaweb2 icinga`) and restart Icinga 2, so that the new group membership applies to the checks it runs.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
