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

    myhostname - Fedora release 34 (Thirty Four) on bare-metal, 8 CPUs, 15.2GiB RAM, Public IP 1.2.3.4

    # Disks
    * nvme0n1 953.9G


    # Interfaces (IPv4)
    * virbr0 192.168.122.1/24
    * wlp0s20f3 10.80.32.245/24


    # Software
    * Apache httpd 2.4.49
    * Docker Compose 1.28.6
    * Docker/Podman 3.3.1
    * Firefox 92.0
    * g++ 11.2.1
    * gcc 11.2.1
    * Git 2.31.1
    * Glances 3.1.4.1
    * GNOME Display Manager 40.1
    * GNOME Shell 40.4
    * Java openjdk 11.0.12 2021-07-20
    * LibreOffice 7.1.6.2.0
    * Linux Kernel 5.13.19-200.fc34.x86_64
    * MySQL 8.0.26
    * Node 14.17.6
    * npm 6.14.15
    * ntpd ntpsec-1.2.1
    * OpenSSL 1.1.1l
    * OpenVPN 2.5.3
    * Perl 5.32.1
    * PHP 7.4.23
    * PHP-FPM 7.4.23
    * pip 21.0.1
    * Python mapped to 3.9.7
    * Python2 2.7.18
    * Python3 3.9.7
    * QEMU Guest Agent 5.2.0
    * SPICE Agent
    * ssh 8.6p1
    * Sublime Text 4113
    * sudo 1.9.5p2
    * systemd 248
    * TeamViewer 15.21.4
    * tmate 2.4.0
    * vsftpd 3.0.3


    # Apps
    * Brother Printer SW
    * F5 VPN SW
    * Google Chrome
    * KeeWeb
    * Nextcloud
    * Rambox
    * VMware Tools


    # Tools
    * dig
    * lsof
    * nano
    * ncat
    * nmap
    * rsync
    * tcpdump
    * telnet
    * tmux
    * unzip
    * wget
    * whois
    * wireshark


    # Python modules
    * BeautifulSoup 4.1.0
    * psutil 5.8.0


    # systemd default target
    * graphical.target


    # systemd timers
    * dnf-makecache.timer
    * systemd-tmpfiles-clean.timer
    * mlocate-updatedb.timer
    * unbound-anchor.timer
    * fstrim.timer


    # systemd enabled units
    * abrt-journal-core.service
    * abrt-oops.service
    * abrt-vmcore.service
    * abrt-xorg.service
    * abrtd.service
    * accounts-daemon.service
    * anydesk.service
    * atd.service
    * auditd.service
    * avahi-daemon.service
    * bluetooth.service
    * chronyd.service
    * crond.service
    * cups.service
    * dbus-broker.service
    * firewalld.service
    * flatpak-add-fedora-repos.service
    * gdm.service
    * getty@.service
    * import-state.service
    * iscsi.service
    * libvirtd.service
    * lm_sensors.service
    * low-memory-monitor.service
    * lvm2-monitor.service
    * mcelog.service
    * mdmonitor.service
    * ModemManager.service
    * multipathd.service
    * mysqld.service
    * netcf-transaction.service
    * NetworkManager-dispatcher.service
    * NetworkManager-wait-online.service
    * NetworkManager.service
    * nfs-convert.service
    * ostree-remount.service
    * qemu-guest-agent.service
    * rngd.service
    * rpmdb-rebuild.service
    * rtkit-daemon.service
    * selinux-autorelabel-mark.service
    * smartd.service
    * sssd.service
    * switcheroo-control.service
    * systemd-oomd.service
    * systemd-resolved.service
    * teamviewerd.service
    * thermald.service
    * udisks2.service
    * upower.service
    * uresourced.service
    * vboxservice.service
    * vgauthd.service
    * vmtoolsd.service
    * vpnagentd.service
    * vsftpd.service


    # systemd mounts
    * -.mount
    * boot-efi.mount
    * boot.mount
    * dev-hugepages.mount
    * dev-mqueue.mount
    * proc-fs-nfsd.mount
    * sys-fs-fuse-connections.mount
    * sys-kernel-config.mount
    * sys-kernel-debug.mount
    * sys-kernel-tracing.mount
    * tmp.mount
    * var-lib-machines.mount
    * var-lib-nfs-rpc_pipefs.mount


    # systemd automounts
    * proc-sys-fs-binfmt_misc.automount


    # non-default users
    user                ! pw ! uid  ! gid  ! comment                                                    ! home_dir                  ! user_shell        
    --------------------+----+------+------+------------------------------------------------------------+---------------------------+-------------------
    apache              ! x  ! 48   ! 48   ! Apache                                                     ! /usr/share/httpd          ! /sbin/nologin     
    avahi               ! x  ! 70   ! 70   ! Avahi mDNS/DNS-SD Stack                                    ! /var/run/avahi-daemon     ! /sbin/nologin     
    colord              ! x  ! 983  ! 983  ! User for colord                                            ! /var/lib/colord           ! /sbin/nologin     
    dnsmasq             ! x  ! 987  ! 987  ! Dnsmasq DHCP and DNS server                                ! /var/lib/dnsmasq          ! /usr/sbin/nologin 
    fahclient           ! x  ! 977  ! 975  ! Folding@home Client                                        ! /var/lib/fahclient        ! /sbin/nologin     
    flatpak             ! x  ! 980  ! 978  ! User for flatpak system helper                             ! /                         ! /sbin/nologin     
    gdm                 ! x  ! 42   ! 42   !                                                            ! /var/lib/gdm              ! /sbin/nologin     
    geoclue             ! x  ! 985  ! 985  ! User for geoclue                                           ! /var/lib/geoclue          ! /sbin/nologin     
    gluster             ! x  ! 996  ! 992  ! GlusterFS daemons                                          ! /run/gluster              ! /sbin/nologin     
    gnome-initial-setup ! x  ! 979  ! 977  !                                                            ! /run/gnome-initial-setup/ ! /sbin/nologin     
    bash         
    mysql               ! x  ! 27   ! 27   ! MySQL Server                                               ! /var/lib/mysql            ! /bin/false        
    nagios              ! x  ! 972  ! 965  !                                                            ! /var/spool/nagios         ! /sbin/nologin     
    nginx               ! x  ! 975  ! 973  ! Nginx web server                                           ! /var/lib/nginx            ! /sbin/nologin     
    nm-openconnect      ! x  ! 995  ! 990  ! NetworkManager user for OpenConnect                        ! /                         ! /sbin/nologin     
    nm-openvpn          ! x  ! 981  ! 979  ! Default user for running openvpn spawned by NetworkManager ! /                         ! /sbin/nologin     
    ntp                 ! x  ! 38   ! 38   !                                                            ! /var/lib/ntp              ! /sbin/nologin     
    openvpn             ! x  ! 982  ! 980  ! OpenVPN                                                    ! /etc/openvpn              ! /sbin/nologin     
    pipewire            ! x  ! 997  ! 995  ! PipeWire System Daemon                                     ! /var/run/pipewire         ! /sbin/nologin     
    pkg-build           ! x  ! 976  ! 974  ! lpf local package build user                               ! /var/lib/lpf              ! /sbin/nologin     
    pulse               ! x  ! 171  ! 171  ! PulseAudio System Daemon                                   ! /var/run/pulse            ! /sbin/nologin     
    qemu                ! x  ! 107  ! 107  ! qemu user                                                  ! /                         ! /sbin/nologin     
    radvd               ! x  ! 75   ! 75   ! radvd user                                                 ! /                         ! /sbin/nologin     
    rtkit               ! x  ! 172  ! 172  ! RealtimeKit                                                ! /proc                     ! /sbin/nologin     
    saslauth            ! x  ! 993  ! 76   ! Saslauthd user                                             ! /run/saslauthd            ! /sbin/nologin     
    setroubleshoot      ! x  ! 974  ! 969  !                                                            ! /var/lib/setroubleshoot   ! /sbin/nologin     
    usbmuxd             ! x  ! 113  ! 113  ! usbmuxd user                                               ! /                         ! /sbin/nologin     
    vboxadd             ! x  ! 978  ! 1    !                                                            ! /var/run/vboxadd          ! /sbin/nologin     


    # crontabs
    01 * * * * root run-parts /etc/cron.hourly
    1   5   cron.daily      nice run-parts /etc/cron.daily
    7   25  cron.weekly     nice run-parts /etc/cron.weekly
    @monthly 45 cron.monthly        nice run-parts /etc/cron.monthly


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
