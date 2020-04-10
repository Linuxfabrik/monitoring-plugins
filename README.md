# Python-based Checks for Icinga, Nagios etc.

This git repo provides various Python 2 based check plugins for Nagios and compatible monitoring systems like Icinga. All checks are tested on CentOS 7 Minimal and Fedora >= 30.

If you

* are disappointed by `nagios-plugins-all`
* search for checks that are all written in Python2 only (your system language on CentOS)
* want to have an easy look into the source code of the checks
* want to use checks that are fast, reliable and focused on CentOS and Icinga2
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
* support for Python 2 will end, but not in CentOS 8 (Python 2 remains available in CentOS 8 until the late 2020's - for further details have a look at https://developers.redhat.com/blog/2018/11/14/python-in-rhel-8/).

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
├── ...
└── xca
```


## Default Thresholds

This table describes the default thresholds of each check at a glance.

Check                                            | WARN  | CRIT  
------------------------------------------------ | -----:| -----:
about-me                                         | -     | -
apache-httpd-status     	             	   | #Workers > 80% | #Workers > 95%
borgbackup                           | Last Backup >= 24h | -
countdown                                      | 50 days | 30 days
cpu-usage                                    | 5x >= 80% | 5x >= 90%
disk-io                                | 5x >= 60 MB/sec | 5x >= 100 MB/sec
disk-smart                                   | _complex_ | _complex_
disk-usage                                       | > 90% | > 95%
dmesg                                            | -     | dmesg == emerg,alert,crit,err  
fail2ban                             | > 1000 banned IPs | > 10000 banned IPs
feed                                 | 2h on new entries | -
file-age                                         | > 30d | > 365d
file-descriptors                                 | > 90% | > 95%
file-ownership                               | _complex_ | _complex_
file-size                                       | > 100M | > 1G
fs-file-usage                                    | > 90% | > 95%
fs-inodes                                        | > 90% | > 95%
hostname-fqdn                             | invalid FQDN | -
ipmi-sel                             | any entries found | -
ipmi-sensor                                  | _complex_ | _complex_
kvm-vm                    | idle, paused, pmsuspended VM | crashed VM
load                                     | >= 1.15 Load15 | >= 5.00 Load15
mailq                                       | >= 2 Mails | >= 250 Mails
memory-usage                                     | >= 90% | >= 95%
mysql-stats                                  | _complex_ | _complex_
needs-restarting               | (Service) Reboot needed | -
network-connections                              | -     | -
network-io                                       |       |       
network-port-tcp                           | unreachable | -
nextcloud-security-scan | outdated scan result, low rating | lowest rating
nextcloud-stats                     | App Updates avail. | -
nextcloud-version                 | Server Update avail. | -
ntp-offset                                     | > 500ms | > 1000ms
openvpn-client-list                              | -     | -
ping                                             | -     | 100% packet loss
procs                                            | -     | -
rocket.chat-stats                                | -     | -
rocket.chat-version               | Server Update avail. | -
rpm-lastactivity                                 | > 90d | > 365d
selinux-mode                              | != Enforcing | -
sensors                               | any Sensor Alarm | -
swap-usage                                      | > 70%  | > 90%
systemd-unit                                 | _complex_ | -
top3-most-memory-consuming-processes             | -     | -
top3-processes-opening-more-file-descriptors     | -     | -
top3-processes-which-caused-the-most-io          | -     | -
top3-processes-which-consumed-the-most-cpu-time  | -     | -
uptime                                          | > 180d | > 366d
users                                         | >= 1 TTY | -
xca-cert                                    | < 14d left | < 5d left
