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


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/systemd-unit> |
| Nagios/Icinga Check Name              | `check_systemd_unit` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--unit` is required) |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: systemd-unit [-h] [-V]
                    [--activestate {None,activating,active,deactivating,failed,inactive}]
                    [--loadstate {None,activating,active,deactivating,failed,inactive,loaded,maintenance,masked,not-found,reloading}]
                    [--machine MACHINE] [--severity {warn,crit}]
                    [--substate {None,abandoned,activating,activating-done,active,auto-restart,cleaning,condition,deactivating,deactivating-sigkill,deactivating-sigterm,dead,elapsed,exited,failed,final-sigkill,final-sigterm,final-watchdog,listening,mounted,mounting,mounting-done,plugged,reload,remounting,remounting-sigkill,remounting-sigterm,running,start,start-chown,start-post,start-pre,stop,stop-post,stop-pre,stop-pre-sigkill,stop-pre-sigterm,stop-sigkill,stop-sigterm,stop-watchdog,tentative,unmounting,unmounting-sigkill,unmounting-sigterm,waiting}]
                    --unit UNIT
                    [--unitfilestate {None,bad,disabled,empty,enabled,enabled-runtime,generated,indirect,linked,linked-runtime,masked,masked-runtime,static,transient}]
                    [--user]

Checks the state of a specific systemd unit (service, socket, device, mount,
timer, scope, etc.) via systemctl. Verifies the active state, sub-state, load
state, and unit file state against expected values. Alerts when the unit is
not in the expected state. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --activestate {None,activating,active,deactivating,failed,inactive}
                        Expected systemd ActiveState (high-level unit
                        activation state, i.e. generalization of SUB). Can be
                        specified multiple times. If omitted or set to "None",
                        the unit's active state will not be checked.
  --loadstate {None,activating,active,deactivating,failed,inactive,loaded,maintenance,masked,not-found,reloading}
                        Expected systemd LoadState, reflecting whether the
                        unit definition was properly loaded. If omitted or set
                        to "None", the unit's load state will not be checked.
                        Default: loaded
  --machine MACHINE     Execute operation on a local container. Specify a
                        container name to connect to, optionally prefixed by a
                        user name and a separating "@" character. The special
                        string ".host" connects to the local system (useful
                        for reaching a specific user's bus: `--user
                        --machine=lennart@.host`). Without "@" syntax, the
                        connection is made as root. With "@" syntax, either
                        side may be omitted (but not both), defaulting to the
                        local user name and ".host".
  --severity {warn,crit}
                        Severity for alerting. Default: warn
  --substate {None,abandoned,activating,activating-done,active,auto-restart,cleaning,condition,deactivating,deactivating-sigkill,deactivating-sigterm,dead,elapsed,exited,failed,final-sigkill,final-sigterm,final-watchdog,listening,mounted,mounting,mounting-done,plugged,reload,remounting,remounting-sigkill,remounting-sigterm,running,start,start-chown,start-post,start-pre,stop,stop-post,stop-pre,stop-pre-sigkill,stop-pre-sigterm,stop-sigkill,stop-sigterm,stop-watchdog,tentative,unmounting,unmounting-sigkill,unmounting-sigterm,waiting}
                        Expected systemd SubState (low-level unit activation
                        state; values depend on unit type). Can be specified
                        multiple times. If omitted or set to "None", the
                        unit's substate will not be checked.
  --unit UNIT           Systemd unit name to check (service, timer, mount,
                        etc.). Required. Example: `--unit sshd.service`.
  --unitfilestate {None,bad,disabled,empty,enabled,enabled-runtime,generated,indirect,linked,linked-runtime,masked,masked-runtime,static,transient}
                        Expected systemd UnitFileState. If set to "empty",
                        checks exactly for `UnitFileState=""`. If omitted or
                        set to "None", the unit's unit-file state will not be
                        checked.
  --user                Talk to the service manager of the calling user rather
                        than the service manager of the system.
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
