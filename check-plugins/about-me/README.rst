Check about-me
==============

Overview
--------

Reports an overview about the host dimensions, its network interfaces, deployed software and recurring jobs:

* System and hardware information (OS, CPUs, disks, ram, UEFI y/n etc.)
* Interfaces: All network interfaces with their IP address
* Listening TCP and UDP ports
* Non-default software (software that was added later)
* Non-default system users
* systemctl get-default: Default systemd target that will be booted into
* systemctl list-unit-files: List of all systemd services, mounts and automounts (excluding user units)
* systemctl list-timers: List of all system systemd timers (excluding user timers)
* crontab: List of crontabs that are found in the usual locations. Note that this might not be complete.

Have a look at the output example below.

Plugin execution may take up to 30 seconds, depending on the amount or type of installed software.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/about-me"
    "Check Interval Recommendation",        "Once a day or once a week"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"
    "3rd Party Python modules",             "``psutil`` (optional)"


Help
----

.. code-block:: text

    usage: about-me [-h] [-V] [--insecure] [--no-proxy]
                    [--public-ip-url PUBLIC_IP_URL] [--tags] [--timeout TIMEOUT]

    Provides a quick overview of host dimensions and software.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --public-ip-url PUBLIC_IP_URL
                            If you want this check to return the public IP
                            address, specify one ore more comma-separated URLs to
                            "what is my ip" online services. For example: "https:/
                            /ipv4.icanhazip.com,https://ipecho.net/plain,https://i
                            pinfo.io/ip" (these examples are located in the United
                            States). Default: None
      --tags                Guess a list of tags to apply in Icinga Director
                            (Linuxfabrik Basket Config).
      --timeout TIMEOUT     Network timeout in seconds. Default: 2 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./about-me

Shortened output example:

.. code-block:: text

    Plugin Output
    server.example.com: Fedora Linux 39 (Workstation Edition) Kernel 6.8.4-200.fc39.x86_64 on Bare-Metal, Dell Inc. XPS 13 9310, Firmware: n/a, SerNo: 39d3e1cd, Proc: 11th Gen Intel Core i7-1185G7 @ 3.00GHz, #Cores: 4, #Threads: 8, Current Speed: 3000 MHz, 16.0GiB RAM, Disk nvme0n1 1.8T, UEFI boot, Display Server wayland, tuned profile "throughput-performance", born 2024-03-20. About-me v2024041001

    Hardware Info:
    * BIOS: Dell Inc., Ver 3.21.0 (released 02/01/2024), ROM 32 MB
    * SysInfo: Dell Inc. XPS 13 9310, SerNo 39d3e1cd, SKU N/A, Wake-up Type "Other",
      UUID 4c4c4544-0044-5a10-8052-c4c04f334a33
    * Base Board: Type Motherboard Dell Inc. 07P9Y7, SerNo /2cc8a595/20ca3e48/, Ver A00
    * Chassis: Dell Inc., Type Notebook, SKU N/A, SerNo 875b42b9
      States: boot-up=Safe, pwr-supply=Safe, thermal=Safe, security=None
    * Proc: Intel(R) Corporation, Ver 11th Gen Intel(R) Core(TM) i7-1185G7 @ 3.00GHz,
      Speed 3000 MHz/3000 MHz max., 4/4 Cores enabled, 8 Threads, Voltage 0.8 V
    * System Boot: No errors detected

    Interfaces (IPv4):
    * ens10 192.0.2.6/32

    Listening TCP/UDP Ports (ordered by port, proto, ip):
    * 127.0.0.1:25/tcp4
    * [::]:80/tcp6
    * 0.0.0.0:111/tcp4
    * [::]:111/tcp6
    * 0.0.0.0:111/udp4
    * [::]:111/udp6

    Non-default Software (ordered by name):
    name               ! version    ! from_repo                              ! installtime      
    -------------------+------------+----------------------------------------+------------------
    at                 ! 3.1.20     ! baseos                                 ! 2022-12-07 07:18 
    bash-completion    ! 2.7        ! baseos                                 ! 2022-10-04 09:59 
    bzip2              ! 1.0.6      ! baseos                                 ! 2022-10-04 11:40 
    chrony             ! 4.2        ! baseos                                 ! 2022-12-07 07:17 
    yum-utils          ! 4.0.21     ! baseos                                 ! 2023-11-28 03:21 
    zstd               ! 1.4.4      ! appstream                              ! 2023-08-29 08:02 

    Non-default Users:
    user        ! pw ! uid  ! gid  ! comment                   ! home_dir           ! user_shell    
    ------------+----+------+------+---------------------------+--------------------+---------------
    apache      ! x  ! 48   ! 48   ! Apache                    ! /usr/share/httpd   ! /sbin/nologin 
    postfix     ! x  ! 89   ! 89   !                           ! /var/spool/postfix ! /sbin/nologin 
    redis       ! x  ! 991  ! 986  ! Redis Database Server     ! /var/lib/redis     ! /sbin/nologin 

    systemctl get-default:
    * multi-user.target

    systemctl list-unit-files --type=service --state=enabled:
    * atd.service
    * auditd.service
    * autovt@.service
    * chronyd.service

    systemctl list-unit-files --type=mount --state=static --state=generated:
    * -.mount
    * boot-efi.mount
    * dev-hugepages.mount

    systemctl list-unit-files --type=automount --state=enabled --state=static:
    * proc-sys-fs-binfmt_misc.automount

    systemctl list-timers:
    unit                               ! activates                      ! next                         
    -----------------------------------+--------------------------------+------------------------------
    fstrim.timer                       ! fstrim.service                 ! Mon 2024-04-15 01:07:55 CEST 
    systemd-tmpfiles-clean.timer       ! systemd-tmpfiles-clean.service ! Thu 2024-04-11 04:35:37 CEST 
    unbound-anchor.timer               ! unbound-anchor.service         ! Thu 2024-04-11 00:00:00 CEST 

    crontab:
    01 * * * * root run-parts /etc/cron.hourly
    0 1 * * Sun root /usr/sbin/raid-check


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
