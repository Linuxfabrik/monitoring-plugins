Check about-me
==============

Overview
--------

Reports a quick overview about the host dimensions, its IP addresses (if the Python module ``netifaces`` is installed) and deployed software:

* Software: lists well-known packages installed by your package manager
* Apps (if any): manually installed software that resides in ``/home``, ``/opt`` and ``/var/www/html``
* Tools (if any): tools like dig, wget etc., normally not installed on a minimal server system
* Python Modules: reports version of installed Python modules some of our checks depend on
* OS: system information

Plugin execution may take up to 30 seconds, depending on the amount or type of installed software.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/about-me"
    "Check Interval Recommendation",        "Once a day or once a week"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Python module ``psutil``, Python module ``netifaces`` (optional)"


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

    8 CPUs, 15.2GiB RAM, 1 Disk (nvme0n1 953.9G) - IP 10.80.32.231/24, Pub 212.51.138.220 - Software: Apache httpd 2.4.48, Docker/Podman 3.2.3, Docker Compose 1.28.6, Firefox 90.0.2, gcc 11.1.1, g++ 11.1.1, Git 2.31.1, Glances 3.1.4.1, Java openjdk 11.0.11 2021-04-20, LibreOffice 7.1.5.2, MySQL 8.0.26, Node 14.17.0, npm 6.14.13, OpenSSL 1.1.1k, OpenVPN 2.5.3, Perl 5.32.1, PHP 7.4.21, pip 21.0.1, Python mapped to 3.9.6, Python2 2.7.18, Python3 3.9.6, Sublime Text 4113, TeamViewer  15.20.3, tmate 2.4.0, vsftpd 3.0.3 - Apps: VMware Tools, Brother Printer SW, F5 VPN SW, Google Chrome, KeeWeb, Rambox, Nextcloud - Tools: dig, lsof, nano, ncat, nmap, rsync, tcpdump, telnet, unzip, wget, whois, wireshark - Python modules: BeautifulSoup 4.9.3, mysql.connector 2.2.9, psutil 5.8.0 - OS: Linux-5.13.4-200.fc34.x86_64-x86_64-with-glibc2.33


States
------

* Always returns OK.


Perfdata / Metrics
------------------

* cpu: Number of CPUs
* ram: Size of memory
* disks: Number of disks
* only Python 2 variant of this check: osversion: as a Number. "Fedora 33" becomes "33", "CentOS 7.4.1708" becomes "741708" - to see when an update happened


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
