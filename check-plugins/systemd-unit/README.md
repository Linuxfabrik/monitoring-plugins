# Check systemd-unit


## Overview

Checks the state of a specific systemd unit (service, socket, device, mount, timer, scope, etc.) via `systemctl show`. Verifies the active state, sub-state, load state, and unit file state against expected values.

**Important Notes:**

* Best practice: specify `--activestate` and `--substate` at least
* The `.service` suffix is optional for service units, but recommended
* The `--machine` parameter connects to a local container, optionally prefixed by a user name and `@` (e.g. `linus@.host`)

**Data Collection:**

* Executes `systemctl show -p LoadState,ActiveState,SubState,UnitFileState <unit>`
* Optionally supports `--machine` to query units inside local containers (requires systemd >= 209)
* Optionally supports `--user` to query user-level service manager

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/systemd-unit> |
| Nagios/Icinga Check Name              | `check_systemd_unit` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--unit` is required) |
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
    help=lib.args.help('--severity') + ' Default: %(default)s',
         ^^^^^^^^
AttributeError: module 'lib' has no attribute 'args'
```


## Usage Examples

Does the service exist (and nothing more)?

```bash
./systemd-unit --unit=firewalld.service
```

Is the service running?

```bash
./systemd-unit --substate=running --unit=firewalld.service
```

Is the service disabled?

```bash
./systemd-unit --unitfilestate=disabled --unit=firewalld.service
```

Is the service stopped and disabled?

```bash
./systemd-unit --activestate=inactive --substate=dead --unitfilestate=disabled --unit=firewalld.service
```

Is the service exited?

```bash
./systemd-unit --substate=exited --unit=firewalld.service
```

Is this service with instance name "server" running?

```bash
./systemd-unit --substate=running --unit=openvpn-server@server.service
```

Is this service absent/uninstalled?

```bash
./systemd-unit --loadstate=not-found --unit=firewalld.service
```

Is this path mounted?

```bash
./systemd-unit --substate=mounted --unit=mnt-smb.mount
```

Is this device plugged in?

```bash
./systemd-unit --substate=plugged --unit=sys-devices-virtual-net-tun0.device
```

Check a timer job (has one activestate and two substates)?

```bash
./systemd-unit --activestate=active --substate=waiting --substate=running --unit=myjob.timer
```

Check a service depending on a timer (has two activestates and two substates)?

```bash
./systemd-unit --activestate=active --activestate=inactive --substate=dead --substate=running --unit=myjob.service
```

Use the `--machine` parameter:

```bash
./systemd-unit --machine=linus@.host --unit sshd
```

Output (mismatch):

```text
firewalld.service - LoadState is "loaded", but should be set to "not-found"
```


## States

* OK if all checked states match the expected values.
* WARN (default) if any checked state does not match the expected value.
* CRIT if `--severity=crit` is set and any checked state does not match.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
