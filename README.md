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


**Ubuntu 20**

* Most of the checks will run out of the box.
* Optional: Install 3rd party Python modules if a check requires them. Example:
  `apt install python-psutil`


## Check Plugin Fact Sheet

                              | CentOS   | Fedora   | Ubuntu   | shell_exec | Libs for Python          | SQLite | Test | WARN                              | CRIT                          
------------------------------|:---------|:---------|:---------|:-----------|:-------------------------|:-------|:-----|:----------------------------------|:------------------------------
about-me                      | 7, 8     | 30+      | no       | yes        | psutil                   |        |      | -                                 | -                             
apache-httpd-status           | 7, 8     | 30+      | 20       |            |                          |        |      | #Workers > 80%                    | #Workers > 95%                
borgbackup                    | 7, 8     | 30+      | 20       |            |                          |        |      | Last Backup >= 24h                | -                             
countdown                     | 7, 8     | 30+      | 20       |            |                          |        |      | 50 days                           | 30 days                       
cpu-usage                     | 7, 8     | 30+      | 20       |            | psutil                   | yes    | yes  | 5x >= 80%                         | 5x >= 90%                     
disk-io                       | 7, 8     | 30+      | 20       |            | psutil                   | yes    |      | 5x >= 60 MB/sec                   | 5x >= 100 MB/sec              
disk-smart                    | 7, 8     | 30+      | no       | yes        |                          |        |      | _complex_                         | _complex_                     
disk-usage                    | 7, 8     | 30+      | 20       |            | psutil                   |        |      | > 90%                             | > 95%                         
dmesg                         | 7, 8     | 30+      | no       | yes        |                          |        | yes  | -                                 | dmesg == emerg,alert,crit,err 
fah-stats                     | 7, 8     | 30+      | 20       |            |                          |        |      |                                   |                               
fail2ban                      | 7, 8     | 30+      | no       | yes        |                          |        |      | > 1000 banned IPs                 | > 10000 banned IPs            
feed                          | 7        | 30+      | no       |            | feedparser               |        |      | 2h on new entries                 | -                             
file-age                      | 7, 8     | 30+      | 20       |            |                          |        |      | > 30d                             | > 365d                        
file-descriptors              | 7, 8     | 30+      | no       | yes        | psutil                   |        |      | > 90%                             | > 95%                         
file-ownership                | 7, 8     | 30+      | no       | yes        |                          |        |      | _complex_                         | _complex_                     
file-size                     | 7, 8     | 30+      | 20       |            |                          |        |      | > 100M                            | > 1G                          
fs-file-usage                 | 7, 8     | 30+      | 20       |            |                          |        |      | > 90%                             | > 95%                         
fs-inodes                     | 7, 8     | 30+      | 20       |            |                          |        |      | > 90%                             | > 95%                         
getent                        | 7, 8     | 30+      | no       | yes        |                          |        |      |                                   |                               
hostname-fqdn                 | 7, 8     | 30+      | 20       |            |                          |        |      | Invalid FQDN                      | -                             
ipmi-sel                      | 7, 8     | 30+      | no       | yes        |                          |        |      | any entries found                 | -                             
ipmi-sensor                   | 7, 8     | 30+      | no       | yes        |                          |        |      | _complex_                         | _complex_                     
kvm-vm                        | 7, 8     | 30+      | no       | yes        |                          |        |      | idle, paused, pmsuspended VM      | crashed VM                    
load                          | 7, 8     | 30+      | no       | yes        | psutil                   |        |      | >= 1.15 Load15                    | >= 5.00 Load15                
mailq                         | 7, 8     | 30+      | no       | yes        |                          |        | yes  | >= 2 Mails                        | >= 250 Mails                  
memory-usage                  | 7, 8     | 30+      | 20       |            | psutil                   |        |      | >= 90%                            | >= 95%                        
mysql-stats                   | 7        | no       | no       |            | psutil, mysql.connector  |        |      | _complex_                         | _complex_                     
needs-restarting              | 7, 8     | 30+      | no       | yes        |                          |        |      | (Service) Reboot needed           | -                             
network-connections           | 7, 8     | 30+      | 20       |            | psutil                   |        |      | -                                 | -                             
network-port-tcp              | 7, 8     | 30+      | 20       |            |                          |        |      | unreachable                       | -                             
nextcloud-security-scan       | 7, 8     | 30+      | 20       |            |                          |        |      | outdated scan result, low rating  | lowest rating                 
nextcloud-stats               | 7, 8     | 30+      | 20       |            |                          |        |      | App Updates avail.                | -                             
nextcloud-version             | 7, 8     | 30+      | 20       |            |                          | yes    |      | Server Update avail.              | -                             
ntp-offset                    | 7, 8     | 30+      | no       | yes        |                          |        |      | > 500ms                           | > 1000ms                      
openvpn-client-list           | 7, 8     | 30+      | 20       |            |                          |        |      | -                                 | -                             
ping                          | 7, 8     | 30+      | no       | yes        |                          |        | yes  | -                                 | 100% packet loss              
procs                         | 7, 8     | 30+      | no       | yes        |                          |        |      | -                                 | -                             
rocket.chat-stats             | 7, 8     | 30+      | 20       |            |                          |        |      | -                                 | -                             
rocket.chat-version           | 7, 8     | 30+      | 20       |            |                          | yes    |      | Server Update avail.              | -                             
rpm-lastactivity              | 7, 8     | 30+      | no       | yes        |                          |        |      | > 90d                             | > 365d                        
selinux-mode                  | 7, 8     | 30+      | no       | yes        |                          |        |      | != Enforcing                      | -                             
sensors                       | 7, 8     | 30+      | no       | yes        |                          |        | yes  | any Sensor Alarm                  | -                             
swap-usage                    | 7, 8     | 30+      | 20       |            | psutil                   |        |      | > 70%                             | > 90%                         
systemd-unit                  | 7, 8     | 30+      | no       | yes        |                          |        |      | _complex_                         | -                             
top3-most-memory-consuming-p  | 7, 8     | 30+      | 20       |            | psutil                   |        |      | -                                 | -                             
top3-processes-opening-more-  | 7, 8     | 30+      | 20       |            | psutil                   |        |      | -                                 | -                             
top3-processes-which-caused-  | 7, 8     | 30+      | 20       |            | psutil                   |        |      | -                                 | -                             
top3-processes-which-consume  | 7, 8     | 30+      | 20       |            | psutil                   |        |      | -                                 | -                             
uptime                        | 7, 8     | 30+      | 20       |            | psutil                   |        |      | > 180d                            | > 366d                        
users                         | 7, 8     | 30+      | no       | yes        |                          |        |      | >= 1 TTY                          | -                             
