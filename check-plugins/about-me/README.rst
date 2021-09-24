Check about-me
==============

Overview
--------

Reports a overview about the host dimensions, its network interfaces, deployed software and recurring jobs:

* OS, disks: system information
* Interfaces: all IPv4 network interfaces with their IP address
* Software: lists well-known packages installed by your package manager
* Apps (if any): manually installed software that resides in ``/home``, ``/opt`` and ``/var/www/html``
* Tools (if any): tools like dig, wget etc., normally not installed on a minimal server system
* Python modules: reports version of installed Python modules some of our checks depend on
* systemd default target: the default systemd target that will be booted into
* systemd timers: a list of all system systemd timers (excluding user timers)
* systemd enabled units: a list of all enabled systemd system units (excluding user units)
* crontabs: a list of crontabs that are found in the usual locations. note that this list is not complete

Plugin execution may take up to 30 seconds, depending on the amount or type of installed software.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/about-me"
    "Check Interval Recommendation",        "Once a day or once a week"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: about-me [-h] [-V]

    Reports a quick overview about the host dimensions and installed software.

    optional arguments:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./about-me

Output:

.. code-block:: text

    CentOS Linux release 7.9.2009 (Core), 1 CPU, 988.6MiB, Pub IP 185.231.52.10

    # Disks
    * sda   100G

    # Interfaces (IPv4)
    * docker0 172.17.0.1/16
    * eth0 10.168.26.30/24

    # Software
    * Apache httpd 2.4.6
    * Apache Tomcat 7.0.76
    * Borg 1.1.17
    * Containerd 1.4.9
    * Docker Compose 1.24.0
    * Docker/Podman 20.10.8
    * Erlang 23
    * Fail2ban Server 0.11.1
    * g++ 4.8.5
    * gcc 4.8.5
    * Git 1.8.3.1
    * Glances 2.5.1
    * Icinga2 2.13.1-1
    * Java openjdk 1.8.0_302
    * LibreOffice Online (LOOL)
    * Lighttpd 1.4.54 (ssl)
    * Linux 3.10.0-1160.42.2.el7.x86_64
    * MariaDB 10.5.12
    * MongoDB 4.0.27
    * mydumper/myloader 0.10.7
    * Nginx 1.20.1
    * Node 8.17.0
    * NodeJS 6.17.1
    * npm 6.13.4
    * OpenSSL 1.0.2k-fips
    * Perl 5.16.3
    * PHP 7.3.30
    * pip 8.1.2
    * Python mapped to 2.7.5
    * Python2 2.7.5
    * Python3 3.6.8
    * systemd 219
    * vsftpd 3.0.2

    # Apps
    * Collabora Office 6.4
    * Rocket.Chat

    # Tools
    * dig
    * iftop
    * lsof
    * nano
    * ncat
    * nmap
    * rsync
    * tcpdump
    * vim
    * wget
    * wireshark

    # Python modules
    * psutil 5.6.7

    # systemd default Target
    * multi-user.target

    # systemd Timers
    * mariadb-dump.timer
    * borg-backup-daily.timer
    * systemd-tmpfiles-clean.timer
    * notify-and-schedule.timer

    # systemd enabled Units
    * atd.service
    * auditd.service
    * autovt@.service
    * crond.service
    * docker.service
    * fwb.service
    * getty@.service
    * haveged.service
    * httpd.service
    * icinga2.service
    * irqbalance.service
    * loolwsd.service
    * lvm2-monitor.service
    * microcode.service
    * mongod.service
    * ntpd.service
    * ovirt-guest-agent.service
    * postfix.service
    * qemu-guest-agent.service
    * rhel-autorelabel.service
    * rhel-configure.service
    * rhel-dmesg.service
    * rhel-domainname.service
    * rhel-import-state.service
    * rhel-loadmodules.service
    * rhel-readonly.service
    * rocketchat.service
    * rpcbind.service
    * rsyslog.service
    * smartd.service
    * sshd.service
    * sysstat.service
    * systemd-readahead-collect.service
    * systemd-readahead-drop.service
    * systemd-readahead-replay.service
    * tomcat-public.service
    * tuned.service

    # crontabs
    01 * * * * root run-parts /etc/cron.hourly
    */10 * * * * root /usr/lib64/sa/sa1 1 1
    53 23 * * * root /usr/lib64/sa/sa2 -A
    1       5       cron.daily              nice run-parts /etc/cron.daily
    7       25      cron.weekly             nice run-parts /etc/cron.weekly
    @monthly 45     cron.monthly            nice run-parts /etc/cron.monthly


States
------

* Always returns OK.


Perfdata / Metrics
------------------

* cpu: Number of CPUs
* ram: Size of memory
* disks: Number of disks
* osversion: as a Number. "Fedora 33" becomes "33", "CentOS 7.4.1708" becomes "741708" - to see when an update happened


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
