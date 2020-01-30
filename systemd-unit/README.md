* show ALL unit files: `systemctl list-unit-files --all`
* show loaded units: `systemctl list-unit-files` 
* get current state of a unit (needed as input for this check: `systemctl show -p LoadState,ActiveState,SubState,UnitFileState firewalld`

systemctl show -p LoadState,ActiveState,SubState,UnitFileState <name>


What to check:
* crond.service
* postfix.service
* rsyslog.service
* sshd.service

No perfdata.



## Parameters

`--unit`:
* The unit name (service, timer, mount etc.).
* Required.

`--loadstate`:
* Reflects whether the unit definition was properly loaded.
* loadstate=loaded,not-found
* Default: loaded

`--activestate`:
* The high-level unit activation state, i.e. generalization of SUB.
* activestate=active,failed,inactive
* Default: active

`--substate`:
* The low-level unit activation state, values depend on unit type.
* substate=abandoned,active,dead,exited,failed,listening,mounted,plugged,running,waiting
* Default: none

`--unitfilestate`:
* unitfilestate=bad,disabled,enabled,enabled-runtime,generated,indirect,static,transient
* Default: none

`--severity`:
* If something was found, the check returns WARN unless set here.
* severity=warn,crit
* Default: warn

Attention:
* If any of `--substate` or `--unitfilestate` is ommited, their value will not be checked at all (don't care).
* The above mentioned defaults make sense in 99% of all cases.
* Best practise is to specify `--activestate` and `--substate` at least.
* The unit suffix `.service` is optional for service units only.


## Usage

Examples:

* Does the service exist? (and nothing more!) `systemd-unit --unit=firewalld`
* Is the service running? `systemd-unit --substate=running --unit=firewalld.service`
* Is the service disabled? `systemd-unit --unitfilestate=disabled --unit=firewalld`
* Is the service stopped and disabled? `systemd-unit --activestate=inactive --substate=dead --unitfilestate=disabled --unit=firewalld`
* Is the service exited? `systemd-unit --substate=exited --unit=firewalld.service`
* Is this service with instance name "server" running? `systemd-unit --substate=running --unit=openvpn-server@server.service`
* Is this service absent/uninstalled? `systemd-unit --loadstate=not-found --unit=firewalld`
* Is this path mounted? `systemd-unit --substate=mounted --unit=mnt-smb.mount`
* Is this device plugged in? `systemd-unit --substate=plugged --unit=sys-devices-virtual-net-tun0.device`


## Things to check on CentOS 7

Might be useful to check on a fresh CentOS 7 Minimal:

```
./systemd-unit --loadstate=loaded --activestate=active --substate=running --unitfilestate=enabled --unit=auditd.service
./systemd-unit --loadstate=loaded --activestate=active --substate=running --unitfilestate=enabled --unit=crond.service
./systemd-unit --loadstate=loaded --activestate=active --substate=running --unitfilestate=enabled --unit=postfix.service
./systemd-unit --loadstate=loaded --activestate=active --substate=running --unitfilestate=enabled --unit=rsyslog.service
./systemd-unit --loadstate=loaded --activestate=active --substate=running --unitfilestate=enabled --unit=sshd.service
./systemd-unit --loadstate=loaded --activestate=active --substate=running --unitfilestate=enabled --unit=tuned.service
```

