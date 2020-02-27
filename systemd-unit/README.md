# Overview

Checks states of a service, job, mount etc., using `systemctl show`.

Simple example: `./systemd-unit --loadstate=loaded --activestate=active --substate=running --unitfilestate=enabled --unit=crond.service` is checked against `systemctl show -p LoadState,ActiveState,SubState,UnitFileState crond.service`.

How do you get an idea what to check for?

1. Show ALL possible unit files - services, mounts, timers etc.: `systemctl list-unit-files --all`
2. Show units, and optionally compare them with another system: `systemctl list-units` (here you get the states)
3. If you know what to look for, get the state data for this check: `systemctl show -p LoadState,ActiveState,SubState,UnitFileState firewalld`

We recommend to run this check every minute.


# Installation and Usage

## Examples

* Does the service exist? (and nothing more!) `systemd-unit --unit=firewalld.service`
* Is the service running? `systemd-unit --substate=running --unit=firewalld.service`
* Is the service disabled? `systemd-unit --unitfilestate=disabled --unit=firewalld.service`
* Is the service stopped and disabled? `systemd-unit --activestate=inactive --substate=dead --unitfilestate=disabled --unit=firewalld.service`
* Is the service exited? `systemd-unit --substate=exited --unit=firewalld.service`
* Is this service with instance name "server" running? `systemd-unit --substate=running --unit=openvpn-server@server.service`
* Is this service absent/uninstalled? `systemd-unit --loadstate=not-found --unit=firewalld.service`
* Is this path mounted? `systemd-unit --substate=mounted --unit=mnt-smb.mount`
* Is this device plugged in? `systemd-unit --substate=plugged --unit=sys-devices-virtual-net-tun0.device`
* The current state of a timer job? (has one activestate and two substates) `systemd-unit --activestate=active --substate=waiting --substate=running --unit=myjob.timer`
* Check a service depending on a timer (has two activestates and two substates): `systemd-unit --activestate=active --activestate=inactive --substate=dead --substate=running --unit=myjob.service`


## Parameters

Attention:
* If any of `--activestate`, `--substate` or `--unitfilestate` is ommited, the related unit state value will not be checked (so the check don't care, just prints).
* Best practise is to specify `--activestate` and `--substate` at least.
* The unit suffix `.service` is optional for service units only, but it is - as always - recommended to use it.

`--unit`:
* The unit name (service, timer, mount etc.).
* Required.

`--loadstate`:
* Reflects whether the unit definition was properly loaded.
* loadstate=loaded,not-found
* Default: loaded

`--activestate` (repeating):
* The high-level unit activation state(s), i.e. generalization of SUB.
* If ommited, the unit's active state will not be checked.
* activestate=active,failed,inactive
* Default: none

`--substate` (repeating):
* The low-level unit activation state(s); values depend on unit type.
* If ommited, the unit's substate will not be checked.
* substate=abandoned,active,dead,exited,failed,listening,mounted,plugged,running,waiting
* Default: none

`--unitfilestate`:
* If ommited, the unit's unit-file state will not be checked.
* unitfilestate=bad,disabled,enabled,enabled-runtime,generated,indirect,static,transient
* Default: none

`--severity`:
* If something was found, the check returns WARN unless set here.
* severity=warn,crit
* Default: warn


# States and Perfdata

* WARN if result does not match parameter values.
* CRIT only if configured as such.

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
