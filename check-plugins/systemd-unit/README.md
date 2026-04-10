# Check systemd-unit

## Overview

Checks the state of a service, job, mount etc., using `systemctl show`.

Simple example: `./systemd-unit --loadstate=loaded --activestate=active --substate=running --unitfilestate=enabled --unit=crond.service` is checked against `systemctl show -p LoadState,ActiveState,SubState,UnitFileState crond.service`.

How do you get an idea what to check for?

1.  Show ALL possible unit files - services, mounts, timers etc.: `systemctl list-unit-files --all`
2.  Show units, and optionally compare them with another system: `systemctl list-units` (here you get the states)
3.  If you know what to look for, get the state data for this check: `systemctl show -p LoadState,ActiveState,SubState,UnitFileState <service-name>`

<div class="attention">

<div class="title">

Attention

</div>

* If any of `--activestate`, `--substate` or `--unitfilestate` is ommited, the related unit state value will not be checked (so the check don't care, just prints).
* Best practise is to specify `--activestate` and `--substate` at least.
* The unit suffix `.service` is optional for service units only, but it is - as always - recommended to use it.

</div>


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/systemd-unit> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
Traceback (most recent call last):
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/systemd-unit/systemd-unit", line 317, in 'module'
    main()
    ~~~~^^
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/systemd-unit/systemd-unit", line 215, in main
    args = parse_args()
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/systemd-unit/systemd-unit", line 102, in parse_args
    help=lib.args.help('--severity') + ' Default: %(default)s.',
         ^^^^^^^^
AttributeError: module 'lib' has no attribute 'args'
```


## Usage Examples

* Does the service exist? (and nothing more!)  
  `./systemd-unit --unit=firewalld.service`

* Is the service running?  
  `./systemd-unit --substate=running --unit=firewalld.service`

* Is the service disabled?  
  `./systemd-unit --unitfilestate=disabled --unit=firewalld.service`

* Is the service stopped and disabled?  
  `./systemd-unit --activestate=inactive --substate=dead --unitfilestate=disabled --unit=firewalld.service`

* Is the service exited?  
  `./systemd-unit --substate=exited --unit=firewalld.service`

* Is this service with instance name "server" running?  
  `./systemd-unit --substate=running --unit=openvpn-server@server.service`

* Is this service absent/uninstalled?  
  `./systemd-unit --loadstate=not-found --unit=firewalld.service`

* Is this path mounted? (Output shown below)  
  `./systemd-unit --substate=mounted --unit=mnt-smb.mount`

* Is this device plugged in?  
  `./systemd-unit --substate=plugged --unit=sys-devices-virtual-net-tun0.device`

* The current state of a timer job? (has one activestate and two substates)  
  `./systemd-unit --activestate=active --substate=waiting --substate=running --unit=myjob.timer`

* Check a service depending on a timer (has two activestates and two substates):  
  `./systemd-unit --activestate=active --activestate=inactive --substate=dead --substate=running --unit=myjob.service`

* Use the `--machine` parameter:  
  `./systemd-unit --machine=linus@.host --unit sshd`

Output:

```text
firewalld.service - LoadState is "loaded", but should be set to "not-found"
```


## States

* WARN if result does not match parameter values.
* CRIT only if configured as such.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
