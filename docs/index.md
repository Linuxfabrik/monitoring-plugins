# Linuxfabrik Monitoring Plugins

230+ monitoring plugins for Icinga, Nagios and compatible monitoring systems. Python 3.9+, all platforms. Smart defaults, auto-discovery, consistent cross-platform metrics, minimal dependencies.

Made by [Linuxfabrik](https://www.linuxfabrik.ch).


## Overview

This Enterprise Class Check Plugin Collection offers a package of Python-based, Nagios-compatible check plugins for Icinga, Naemon, Nagios, OP5, Shinken, Sensu and other monitoring applications. Each plugin is a stand-alone command line tool that provides a specific type of check. Typically, your monitoring software will run these check plugins to determine the current status of hosts and services on your network.

All plugins are written in Python and licensed under the [UNLICENSE](https://unlicense.org/). They run on all platforms that support Python 3.9 and above, like Linux, Windows, macOS, FreeBSD and others. For Windows, there are compiled plugins available, meaning you don't need Python.

The plugins are fast and reliable, using as few system resources as possible. They report the same metrics consistently and uniformly on all platforms. Where possible, automatic detection and auto-discovery mechanisms are built in. The plugins use meaningful default settings to trigger WARNs and CRITs only where absolutely necessary.


## Quick Start

1. [Install the plugins](install.md)
2. [Configure Icinga Director](icinga.md)
3. [Set up Grafana dashboards](grafana.md)


## Plugin Groups

Some plugins belong together and share a common setup:

- [Keycloak Plugins](plugins-keycloak.md)
- [MySQL Plugins](plugins-mysql.md)
- [Rocket.Chat Plugins](plugins-rocketchat.md)
- [WildFly Plugins](plugins-wildfly.md)


## Want to see some Plugins in Action?

Visit [icinga-demo.linuxfabrik.ch](https://icinga-demo.linuxfabrik.ch).


## Links

- [GitHub Repository](https://github.com/Linuxfabrik/monitoring-plugins)
- [Report an Issue](https://github.com/Linuxfabrik/monitoring-plugins/issues/new/choose)
- [Linuxfabrik Lib (Python libraries)](https://linuxfabrik.github.io/lib/lib.html)
- [LFOps Ansible Collection](https://github.com/Linuxfabrik/lfops)
- [Linuxfabrik Website](https://www.linuxfabrik.ch)
