Check docker-info
=================

Overview
--------

Displays system-wide docker or podman information.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-info"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: docker-info [-h] [-V] [--always-ok] [--test TEST]

    Displays system-wide docker information.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --test TEST    For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                     file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./docker-info

Output:

.. code-block:: text

    WARNING: the devicemapper storage-driver is deprecated, and will be removed in a future release., 37 Containers (2 running, 0 paused, 35 stopped), 103 Images, Storage Driver: devicemapper, Logging Driver: json-file, Registry: https://index.docker.io/v1/, Docker v20.10.6, 6 CPUs, 15.51GiB Memory


States
------

* WARN on ``docker info`` warnings
* CRIT on ``docker info`` errors
* CRIT on ``docker info`` return codes != 0


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    containers,                                 Number,             Number of containers
    containers_paused,                          Number,             Number of paused containers
    containers_running,                         Number,             Number of running containers
    containers_stopped,                         Number,             Number of stopped containers
    cpu,                                        Number,             Number of Host CPUs
    images,                                     Number,             Number of images
    ram,                                        Number,             Total Host Memory


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
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
