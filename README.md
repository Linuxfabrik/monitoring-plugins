# Python-based Checks for Icinga, Nagios etc.

This git repo provides various Python 2 based check plugins for Nagios and compatible monitoring systems like Icinga. All checks are tested on CentOS 7+ (Minimal), Fedora 30+ and Ubuntu 16+.

If you

* are disappointed by `nagios-plugins-all`
* search for checks that are all written in Python2 only (your system language on CentOS)
* want to have an easy look into the source code of the checks
* want to use checks that are fast, reliable and mainly focused on CentOS and Icinga2
* want to use checks that all behave uniform and report the same (for example "used") in a short and precise manner
* want to use checks out of the box with some kind of auto-discovery, that use useful defaults and only throw CRITs where it is absolutely necessary
* are happy about checks that provide some additional information to help you troubleshoot your system
* want to use plugins that try to avoid 3rd party dependencies wherever possible

... then these checks might be for you.


## Python2

All checks are written in Python 2, because ...

* in a datacenter environment (where these checks are mainly used) the `python == python2` side is still more popular.
* in CentOS 7, Python 2.7 is the default.
* in CentOS 8, there is no default. You just need to specify whether you want Python 3 or 2.
* support for Python 2 has ended, but not in CentOS 8 (Python 2 remains available in CentOS 8 until the late 2020's decade - for further details have a look at https://developers.redhat.com/blog/2018/11/14/python-in-rhel-8/).

Our checks call Python 2 by using `#!/usr/bin/env python2`.

We try to avoid dependencies on libraries wherever possible. If we have to use additional libraries for various reasons, we stick on official versions.


## Running a Check

To run a check make sure that the `lib` directory or the `lib` symbolic link contains or points to the Python libraries from our GitLab repo [lib-linux](https://git.linuxfabrik.ch/linuxfabrik-icinga-plugins/lib-linux).

So this is what your check plugin directory should look like:

```
$ tree /usr/lib64/nagios/plugins/

/usr/lib64/nagios/plugins/
├── about-me
├── ...
├── ipmi-sensor
├── kvm-vm
├── lib
│   ├── globals.py
│   ├── ...
│   └── ...
├── load
└── ...
```


**CentOS 8**

* Required: Install Python2, for example by using `dnf install python2`
* After that, most of the checks will run out of the box.
* Optional: Install 3rd party Python modules if a check requires them. Some of those modules are found in the EPEL repo. Example:
  `dnf install epel-release; dnf install python2-psutil`.


**CentOS 7**

* Most of the checks will run out of the box.
* Optional: Install 3rd party Python modules if a check requires them. Some of those modules are found in the EPEL repo. Example:
  `yum install epel-release; yum install python2-psutil`.


**Fedora**

* Required: Install Python2, for example by using `dnf install python2`
* After that, most of the checks will run out of the box.
* Optional: Install 3rd party Python modules if a check requires them. Example:
  `dnf install python2-psutil`.


**Ubuntu 16**

* Required: Install Python2, for example by using `apt install python-minimal`
* After that, most of the checks will run out of the box.
* Optional: Install 3rd party Python modules if a check requires them. Example:
  `apt install python-psutil`


**Ubuntu 20**

* Most of the checks will run out of the box.
* Optional: Install 3rd party Python modules if a check requires them. Example:
  `apt install python-psutil`


## Check Plugin Fact Sheet

2020042501

Check Plugin | Works on CentOS | Works on Fedora | Works on Ubuntu | Uses shell_exec() | Requires Python 3rd Party Libs | Uses SQLite DB | Unit Test avail. | Default WARN | Default CRIT
------------------------------|---------:|---------:|---------:|-----------:|-------------------------:|-------:|:-----|:----------------------------------|:------------------------------
about-me                      | 7, 8     | 30+      | 16, 20   | yes        | psutil                   |        |      | -                                 | -
apache-httpd-status           | 7, 8     | 30+      | 16, 20   |            |                          |        |      | #workers >= 80%                   | #workers >= 95%
borgbackup                    | 7, 8     | 30+      | 16, 20   |            |                          |        |      | last backup >= 24h                | -
countdown                     | 7, 8     | 30+      | 16, 20   |            |                          |        |      | 50 days                           | 30 days
cpu-usage                     | 7, 8     | 30+      | 16, 20   |            | psutil                   | yes    | yes  | 5x >= 80%                         | 5x >= 90%
disk-io                       | 7, 8     | 30+      | 16, 20   |            | psutil                   | yes    |      | 5x >= 60 mb/sec                   | 5x >= 100 mb/sec
disk-smart                    | 7, 8     | 30+      | 16, 20   | yes        |                          |        |      | _complex_                         | _complex_
disk-usage                    | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | >= 90%                            | >= 95%
dmesg                         | 7, 8     | 30+      | 16, 20   | yes        |                          |        | yes  | -                                 | dmesg == emerg,alert,crit,err
dns                           | 7, 8     | 30+      | 16, 20   |            |                          |        |      | socket or address related errors  | -
fah-stats                     | 7, 8     | 30+      | 16, 20   |            |                          |        |      | -                                 | -
fail2ban                      | 7, 8     | 30+      | 16, 20   | yes        |                          |        |      | >= 1000 banned ips                | >= 10000 banned ips
feed                          | 7        | 30+      | 16       |            | feedparser               |        |      | 2h on new entries                 | -
file-age                      | 7, 8     | 30+      | 16, 20   |            |                          |        |      | >= 30d                            | >= 365d
file-descriptors              | 7, 8     | 30+      | 16, 20   | yes        | psutil                   |        |      | >= 90%                            | >= 95%
file-ownership                | 7, 8     | 30+      | 16, 20   | yes        |                          |        |      | _complex_                         | _complex_
file-size                     | 7, 8     | 30+      | 16, 20   |            |                          |        |      | >= 25M                            | >= 1G
fortios-cpu-usage             | 7, 8     | 30+      | 16, 20   |            |                          | yes    |      | 5x >= cpu-use-threshold/80%       | 5x >= 90%
fortios-memory-usage          | 7, 8     | 30+      | 16, 20   |            |                          |        | yes  | > memory-use-threshold-green/82%  | > memory-use-threshold-red/88%
fortios-sensor                | 7, 8     | 30+      | 16, 20   |            |                          |        |      | _complex_                         | _complex_
fortios-version               | 7, 8     | 30+      | 16, 20   |            |                          |        |      | update avail.                     | -
fs-file-usage                 | 7, 8     | 30+      | 16, 20   |            |                          |        |      | >= 90%                            | >= 95%
fs-inodes                     | 7, 8     | 30+      | 16, 20   |            |                          |        |      | >= 90%                            | >= 95%
getent                        | 7, 8     | 30+      | 16, 20   | yes        |                          |        |      | key not found                     | -
hostname-fqdn                 | 7, 8     | 30+      | 16, 20   |            |                          |        |      | invalid fqdn                      | -
ipmi-sel                      | 7, 8     | 30+      | 16, 20   | yes        |                          |        |      | any entries found                 | -
ipmi-sensor                   | 7, 8     | 30+      | 16, 20   | yes        |                          |        |      | _complex_                         | _complex_
kvm-vm                        | 7, 8     | 30+      | 16, 20   | yes        |                          |        |      | idle, paused, pmsuspended vm      | crashed vm
load                          | 7, 8     | 30+      | 16, 20   | yes        | psutil                   |        |      | >= 1.15 load15                    | >= 5.00 load15
mailq                         | 7, 8     | 30+      | 16, 20   | yes        |                          |        | yes  | >= 2 mails                        | >= 250 mails
memory-usage                  | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | >= 90%                            | >= 95%
mysql-stats                   | 7        | no       | 16       |            | psutil, mysql.connector  |        |      | _complex_                         | _complex_
needs-restarting              | 7, 8     | 30+      | no       | yes        |                          |        |      | (service) reboot needed           | -
network-connections           | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | -                                 | -
network-port-tcp              | 7, 8     | 30+      | 16, 20   |            |                          |        |      | unreachable                       | -
nextcloud-security-scan       | 7, 8     | 30+      | 16, 20   |            |                          |        |      | outdated scan result, low rating  | lowest rating
nextcloud-stats               | 7, 8     | 30+      | 16, 20   |            |                          |        |      | app updates avail.                | -
nextcloud-version             | 7, 8     | 30+      | 16, 20   |            |                          | yes    |      | server update avail.              | -
ntp-offset                    | 7, 8     | 30+      | 16, 20   | yes        |                          |        |      | >= 800ms                          | >= 1001ms
openvpn-client-list           | 7, 8     | 30+      | 16, 20   |            |                          |        |      | -                                 | -
ping                          | 7, 8     | 30+      | 16, 20   | yes        |                          |        | yes  | -                                 | 100% packet loss
procs                         | 7, 8     | 30+      | 16, 20   | yes        |                          |        |      | -                                 | -
rocket.chat-stats             | 7, 8     | 30+      | 16, 20   |            |                          |        |      | -                                 | -
rocket.chat-version           | 7, 8     | 30+      | 16, 20   |            |                          | yes    |      | server update avail.              | -
rpm-lastactivity              | 7, 8     | 30+      | no       | yes        |                          |        |      | > 90d                             | > 365d
selinux-mode                  | 7, 8     | 30+      | no       | yes        |                          |        |      | != enforcing                      | -
sensors-battery               | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | battery power <= 20%              | battery power <= 5%
sensors-fans                  | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | fan speed >= 10000 rpm            | fan speed => 20000 rpm
sensors-temperatures          | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | sensor temp >= hardware threshold | sensor temp >= hardware threshold
swap-usage                    | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | >= 70%                            | >= 90%
systemd-unit                  | 7, 8     | 30+      | 16, 20   | yes        |                          |        |      | _complex_                         | -
top3-most-memory-consuming-p  | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | -                                 | -
top3-processes-opening-more-  | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | -                                 | -
top3-processes-which-caused-  | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | -                                 | -
top3-processes-which-consume  | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | -                                 | -
uptime                        | 7, 8     | 30+      | 16, 20   |            | psutil                   |        |      | >= 180d                           | >= 366d
users                         | 7, 8     | 30+      | 16, 20   | yes        |                          |        |      | >= 1 tty                          | -

