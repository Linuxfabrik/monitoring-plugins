Check about-me
==============

Overview
--------

Reports an overview about the host dimensions, its network interfaces, deployed software and recurring jobs:

* System information (OS, CPUs, disks, ram, UEFI y/n etc.)
* Python modules: Reports version of installed Python modules some of our checks depend on
* Interfaces: All IPv4 network interfaces with their IP address
* Listening TCP ports
* Software installed: Lists well-known packages installed by your package manager
* Software found/guessed: Manually installed software that resides in ``/home``, ``/opt`` and ``/var/www/html``
* Tools: Admin-preferred tools like dig, vim, wget etc. - normally not installed on a minimal server system
* Non-default system users
* systemctl get-default: Default systemd target that will be booted into
* systemctl List-unit-files: List of all systemd system units (excluding user units)
* systemctl List-timers: List of all system systemd timers (excluding user timers)
* crontab: List of crontabs that are found in the usual locations. note that this list is not complete

Have a look at the output examples below.

Plugin execution may take up to 30 seconds, depending on the amount or type of installed software.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/about-me"
    "Check Interval Recommendation",        "Once a day or once a week"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"
    "3rd Party Python modules",             "``psutil`` (optional)"


Help
----

.. code-block:: text

    usage: about-me [-h] [-V] [--public-ip-url PUBLIC_IP_URL] [--tags]

    Reports a quick overview about the host dimensions and installed software.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --public-ip-url PUBLIC_IP_URL
                            If you want this check to return the public IP
                            address, specify one ore more comma-separated URLs to
                            "what is my ip" online services. For example (all
                            located in the United States): "https://ipv4.icanhazip
                            .com,https://ipecho.net/plain,https://ipinfo.io/ip".
                            Default: None
      --tags                Guess a list of tags to apply in Icinga Director
                            (Linuxfabrik Basket Config).


Usage Examples
--------------

.. code-block:: bash

    ./about-me

Output (first line) on a VM:

.. code-block:: text

    myhostname: Rocky Linux release 8.7 (Green Obsidian) virtualized on kvm, QEMU Standard PC (i440FX + PIIX, 1996), Firmware: n/a, SerNo: n/a, Proc: pc-i440fx-7.0, #Cores: 4, #Threads: 4, Current Speed: 2000 MHz, 6 GB RAM, BIOS boot, Disk vda 128G, tuned profile "virtual-guest", Public IP 92.107.220.171, born 2022-09-02. Features: firewalld, iptables, lvm, nftables, selinux. About-me v2023021401

Output (first line) on a Laptop:

.. code-block:: text

    myhostname: Fedora release 37 (Thirty Seven) on Bare-Metal, Dell Inc. XPS 13 9310, Firmware: n/a, SerNo: ABC1234, Proc: 11th Gen Intel Core i7-1185G7 @ 3.00GHz, #Cores: 4, #Threads: 8, Current Speed: 3000 MHz, 16 GB RAM, UEFI boot, Disk nvme0n1 953.9G, Public IP 1.2.3.4, born 2022-01-16. Features: firewalld, iptables, lvm, nftables, selinux. About-me v2023021401

Output (first line) on a Raspberry Pi:

.. code-block:: text

    myhostname: Raspbian GNU/Linux 10 (buster) on Bare-Metal, Raspberry Pi 4 Model B Rev 1.4, 4 CPUs, 7.7GiB RAM, BIOS boot, Public IP 1.2.3.4, Missing: firewalld, iptables, lvm, nftables, selinux. About-me v2023021401

Example for full Output:

.. code-block:: text

    myhostname - Rocky Linux release 8.6 (Green Obsidian) virtualized on kvm, BIOS boot, sys dimensions n/a (consider installing psutil), Disk vda 128G, tuned profile "virtual-guest", Public IP 1.2.3.4, born 2022-09-02. Features: lvm, selinux. Missing: firewalld, iptables, nftables. About-me v2023010501

    SW installed:
    * chronyd 4.2
    * Exim 4.96
    * g++ 8.5.0
    * gcc 8.5.0
    * gpg (GnuPG) 2.2.20
    * ipmitool 1.8.18
    * Linux Kernel 4.18.0-372.19.1.el8_6.x86_64
    * OpenSSL 1.1.1k
    * Perl 5.26.3
    * Python 3.6.8
    * `python3` cmd mapped to 3.6.8
    * QEMU Guest Agent 6.2.0
    * ssh 8.0p1
    * sudo 1.8.29
    * systemd 239

    SW found/guessed:
    * Firewall Builder

    Tools:
    * dig
    * hdparm
    * lsof
    * nano
    * rsync
    * telnet
    * vim
    * wget

    Non-default Users:
    user    ! pw ! uid  ! gid  ! comment ! home_dir        ! user_shell    
    --------+----+------+------+---------+-----------------+---------------
    exim    ! x  ! 93   ! 93   !         ! /var/spool/exim ! /sbin/nologin 
    vagrant ! x  ! 1000 ! 1000 !         ! /home/vagrant   ! /bin/bash     

    systemctl get-default:
    * multi-user.target

    systemctl list-unit-files --type service --state enabled:
    * auditd.service
    * autovt@.service
    * chronyd.service
    * crond.service
    * dbus-org.freedesktop.nm-dispatcher.service
    * dbus-org.freedesktop.timedate1.service
    * getty@.service
    * haveged.service
    * import-state.service
    * irqbalance.service
    * loadmodules.service
    * lvm2-monitor.service
    * NetworkManager-dispatcher.service
    * NetworkManager-wait-online.service
    * NetworkManager.service
    * nfs-server.service
    * nis-domainname.service
    * qemu-guest-agent.service
    * rpcbind.service
    * rsyncd.service
    * rsyslog.service
    * selinux-autorelabel-mark.service
    * snmpd.service
    * sshd.service
    * sssd.service
    * syslog.service
    * sysstat.service
    * timedatex.service
    * tuned.service
    * vsftpd.service

    systemctl list-unit-files --type mount --state static --state generated:
    * -.mount
    * boot.mount
    * dev-hugepages.mount
    * dev-mqueue.mount
    * proc-fs-nfsd.mount
    * proc-sys-fs-binfmt_misc.mount
    * sys-fs-fuse-connections.mount
    * sys-kernel-config.mount
    * sys-kernel-debug.mount
    * var-lib-nfs-rpc_pipefs.mount

    systemctl list-unit-files --type automount --state enabled --state static:
    * proc-sys-fs-binfmt_misc.automount

    systemctl list-timers:
    * sysstat-collect.timer
    * dnf-makecache.timer
    * mlocate-updatedb.timer
    * unbound-anchor.timer
    * sysstat-summary.timer
    * systemd-tmpfiles-clean.timer

    crontab:
    01 * * * * root run-parts /etc/cron.hourly
    1   5   cron.daily      nice run-parts /etc/cron.daily
    7   25  cron.weekly     nice run-parts /etc/cron.weekly
    @monthly 45 cron.monthly        nice run-parts /etc/cron.monthly

    3rd-party Python libraries required by any of the plugins:
    * Installed: none
    * Missing: bs4, psutil, pymysql.cursors, smbprotocol.exceptions, vici

    Tags:
    * chronyd
    * exim
    * fwbuilder
    * ipmi
    * OS: Rocky Linux release 8.6 (Green Obsidian), family "RedHat"
    * nfs-server
    * rsyncd
    * snmpd
    * vsftpd


States
------

* Always returns OK.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                Type,               Description                                           
    cpu,                 Number,             Number of CPUs (if ``dmidecode`` is not available)
    cpu_cores_enabled,   Number,             Number of enabled CPU cores (if ``dmidecode`` is available)
    cpu_speed,           Number,             CPU speed (if ``dmidecode`` is available)
    cpu_threads,         Number,             Number of CPU cores with Hyper-Threading enabled (if ``dmidecode`` is available)
    disks,               Number,             Number of disks
    osversion,           None,               "'Fedora 33' becomes '33', 'CentOS 7.4.1708' becomes '741708' - to see when an upgrade happened"
    ram,                 Bytes,              Size of memory (if ``dmidecode`` is not available)
    ram,                 Bytes,              Size of memory (if ``dmidecode`` is available)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
