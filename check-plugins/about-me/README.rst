Check about-me
==============

Overview
--------

Reports a quick overview about the host dimensions and installed software. Plugin execution may take up to 30 seconds, depending on the amount or type of installed software.

* Software: packages installed using ``yum``
* Apps (if any): manual installed software that resides in ``/home``, ``/opt`` and ``/var/www/html``
* Tools (if any): tools like dig, wget etc., normally not installed on a CentOS minimal system
* Python Modules: reports version of installed Python modules some of our checks depend on
* OS: system information


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/about-me"
    "Check Interval Recommendation",        "Once a day or once a week"
    "Available for",                        "Python 2, Python 3"


Help
----

.. code-block:: text

    usage: about-me2 [-h] [-V]

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

    8 CPUs, 15.2GiB RAM, 1 Disk (953.9G) - Software: Apache httpd 2.4.46, Docker/Podman 3.1.2, Docker Compose 1.27.4, Firefox 88.0.1, Git 2.31.1, Glances 3.1.4.1, Java openjdk 11.0.11 2021-04-20, LibreOffice 7.0.6.2, MySQL 8.0.25, Node 14.16.1, npm 6.14.12, OpenSSL 1.1.1k, Perl 5.32.1, PHP 7.4.19, pip 20.2.2, Python mapped to 3.9.5, Python2 2.7.18, Python3 3.9.5, Sublime Text 4107, TeamViewer  15.17.6, tmate 2.4.0 - Apps: VMware Tools, Brother Printer SW, F5 VPN SW, Google Chrome, KeeWeb, Rambox, Nextcloud - Tools: dig, lsof, nano, ncat, nmap, rsync, tcpdump, telnet, unzip, wget, whois, wireshark - Python modules: BeautifulSoup 4.9.3, mysql.connector 2.2.9, psutil 5.7.2 - OS: Linux-5.12.6-200.fc33.x86_64-x86_64-with-glibc2.32|'cpu'=8;;;0; 'ram'=16340357120B;;;0; 'disks'=1;;;0;


States
------

* Always returns OK.


Perfdata / Metrics
------------------

* cpu: Number of CPUs
* ram: Size of memory
* disks: Number of disks
* osversion: as a Number. "Fedora 33" becomes "33", "CentOS 7.4.1708" becomes "741708" - to see when an update happened (only Python 2 variant of this check)


Credits, License
----------------

* Authors: ``Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>``_
* License: The Unlicense, see ``LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>``_.
