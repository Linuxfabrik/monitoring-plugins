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
                            "what is my ip" online services. For example: "https:/
                            /ipv4.icanhazip.com,https://ipecho.net/plain,https://i
                            pinfo.io/ip" (these examples are located in the United
                            States). Default: None
      --tags                Guess a list of tags to apply in Icinga Director
                            (Linuxfabrik Basket Config).


Usage Examples
--------------

.. code-block:: bash

    ./about-me

Full output example:

.. code-block:: text

    myhostname: Fedora Linux 36 (Thirty Six) Kernel 6.2.10-100.fc36.x86_64 virtualized on kvm, OpenStack Foundation OpenStack Nova, Firmware: n/a, SerNo: 8259353c-789d-4c63-be49-e246ae23b31c, Proc: pc-i440fx-5.2, #Cores: 2, #Threads: 2, Current Speed: 2000 MHz, 4.0GiB RAM, Disk vda 20G, BIOS boot, born 2022-05-25. Features: iptables, lvm, nftables, selinux. Missing: firewalld. About-me v2023042301

    Listening TCP Ports:
    * 0.0.0.0:22/tcp4
    * [::]:22/tcp6
    * 127.0.0.1:25/tcp4
    * 127.0.0.54:53/tcp4
    * 127.0.0.53:53/tcp4
    * 0.0.0.0:80/tcp4
    * 0.0.0.0:443/tcp4
    * [::]:3306/tcp6
    * [::]:5355/tcp6
    * 0.0.0.0:5355/tcp4
    * [::]:5665/tcp6

    SW installed:
    * Apache httpd 2.4.56
    * chronyd 4.3
    * duplicity 0.8.23
    * FreeIPA 4.9.11
    * gcc 12.2.1
    * Git 2.39.2
    * Glances 3.3.1
    * gpg (GnuPG) 2.3.7
    * Icinga2 r2.13.6-1
    * Linux Kernel 6.2.10-100.fc36.x86_64
    * MariaDB 10.5.18-MariaDB
    * Node 16.17.1
    * npm 8.15.0
    * OpenSSL 3.0.8
    * Perl 5.34.1
    * PHP 7.4.33
    * PHP-FPM 7.4.33
    * pip 21.3.1
    * Postfix 3.6.4
    * Python 3.10.10
    * `python` cmd mapped to 3.10.10
    * `python3` cmd mapped to 3.10.10
    * QEMU Guest Agent 6.2.0
    * ssh 8.8p1
    * sudo 1.9.13p2
    * systemd 250

    SW found/guessed:
    * Firewall Builder
    * mod_security

    Tools:
    * dig
    * hdparm
    * iftop
    * lsof
    * nano
    * rsync
    * tmux
    * vim
    * wget

    Non-default Users:
    user        ! pw ! uid  ! gid  ! comment           ! home_dir           ! user_shell    
    ------------+----+------+------+-------------------+--------------------+---------------
    apache      ! x  ! 48   ! 48   ! Apache            ! /usr/share/httpd   ! /sbin/nologin 
    icinga      ! x  ! 993  ! 991  ! icinga            ! /var/spool/icinga2 ! /sbin/nologin 
    linuxfabrik ! x  ! 1000 ! 1000 ! fedora Cloud User ! /home/linuxfabrik  ! /bin/bash     
    mysql       ! x  ! 27   ! 27   ! MySQL Server      ! /var/lib/mysql     ! /sbin/nologin 
    nginx       ! x  ! 992  ! 988  ! Nginx web server  ! /var/lib/nginx     ! /sbin/nologin 
    postfix     ! x  ! 89   ! 89   !                   ! /var/spool/postfix ! /sbin/nologin 

    systemctl get-default:
    * multi-user.target

    systemctl list-unit-files --type service --state enabled:
    * atd.service
    * auditd.service
    * bluetooth.service
    * chronyd.service
    * dbus-broker.service
    * fwb.service
    * getty@.service
    * httpd.service
    * icinga2.service
    * import-state.service
    * lvm2-monitor.service
    * mariadb.service
    * mdmonitor.service
    * NetworkManager-dispatcher.service
    * NetworkManager-wait-online.service
    * NetworkManager.service
    * nfs-convert.service
    * nis-domainname.service
    * oddjobd.service
    * php-fpm.service
    * postfix.service
    * qemu-guest-agent.service
    * rngd.service
    * rpmdb-rebuild.service
    * selinux-autorelabel-mark.service
    * sshd.service
    * sssd.service
    * supervisord.service
    * systemd-homed-activate.service
    * systemd-homed.service
    * systemd-oomd.service
    * systemd-resolved.service
    * udisks2.service

    systemctl list-unit-files --type mount --state static --state generated:
    * -.mount
    * boot.mount
    * data.mount
    * dev-hugepages.mount
    * dev-mqueue.mount
    * home.mount
    * proc-fs-nfsd.mount
    * sys-fs-fuse-connections.mount
    * sys-kernel-config.mount
    * sys-kernel-debug.mount
    * sys-kernel-tracing.mount
    * tmp.mount
    * var-lib-nfs-rpc_pipefs.mount
    * var-log-audit.mount
    * var-log.mount
    * var-tmp.mount
    * var.mount

    systemctl list-unit-files --type automount --state enabled --state static:
    * proc-sys-fs-binfmt_misc.automount

    systemctl list-timers:
    * logrotate.timer
    * unbound-anchor.timer
    * duba.timer
    * fstrim.timer
    * systemd-tmpfiles-clean.timer
    * notify-and-schedule.timer
    * raid-check.timer

    3rd-party Python libs required by any of the plugins when running in source code variant:
    * Installed: psutil 5.8.0, pymysql.cursors 0.10.1
    * Missing: bs4, pysmbclient, smbprotocol.exceptions, vici

    Guessed Tags:
    * apache-httpd
    * chronyd
    * duplicity
    * fwbuilder
    * OS: Fedora Linux 36 (Thirty Six), family "RedHat"
    * mariadb* / mysql*
    * mod_qos
    * php
    * php-fpm
    * pip
    * postfix-mta
    * system-update


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
