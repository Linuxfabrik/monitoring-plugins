# Python-based Checks for Icinga, Nagios etc.

This git repo provides various Python 2 based check plugins for Nagios and compatible monitoring systems like Icinga. All checks are tested on CentOS 7 Minimal and Fedora >= 30.

If you
* are disappointed by `nagios-plugins-all`
* search for checks that are written in Python2 only (your system language on CentOS)
* want to have a look into the source code of the checks
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

To run a check make sure that the symbolic link `lib` points to `lib-linux`, which you also have to clone (from [lib-linux](https://git.linuxfabrik.ch/linuxfabrik-icinga-plugins/lib-linux)).


