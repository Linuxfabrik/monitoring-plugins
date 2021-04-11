Check "docker-info"
===================

Overview
--------

Displays system-wide docker or podman information. We recommend to run this check every 5 minutes.


Installation and Usage
----------------------

Requirements:

* ``docker`` or ``podman``

.. code-block:: bash

    ./docker-info
    ./docker-info --always-ok
    ./docker-info --help
```

States
------

* WARN on ``docker info`` warnings
* CRIT on ``docker info`` errors


Perfdata
--------

* containers: Number of containers
    
    * containers_paused
    * containers_running
    * containers_stopped

* cpus: Number of Host CPUs
* images: Number of images
* memory: Total Host Memory


Troubleshooting
---------------

WARNING: bridge-nf-call-iptables is disabled, WARNING: bridge-nf-call-ip6tables is disabled
    These settings control whether packets traversing a network bridge are processed by iptables rules on the host system. Typically, enabling these options is not desirable as this can cause guest container traffic to be blocked by iptables rules that are intended for the host. This could cause unpredictable behavior for containers that do not expect traffic to be firewalled at the host level.

    If you accept and understand the implications of enabling these options or you have no iptables rules set on the host, you can enable these options to remove the warning messages.

    To enable:

    .. code-block:: bash

        sysctl -p net.bridge.bridge-nf-call-iptables=1
        sysctl -p net.bridge.bridge-nf-call-ip6tables=1


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.

