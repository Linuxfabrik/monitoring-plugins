How to install the Linuxfabrik Monitoring Plugins Collection
============================================================

What to choose when
-------------------

In general, you have two options:

* Using the compiled plugins (available as OS packages, EXE files or simple archives).
* Using the plugins from the source code (requires Python runtime).

.. csv-table::
    :header-rows: 1
    :widths: 10, 60, 30

    OS, Motivation, Install
    Linux,  "Want to use my OS's package manager and have distro that uses rpm/deb package formats","Package from `Linuxfabrik's Repo Server <https://repo.linuxfabrik.ch>`_"
    Linux,  "Don't want to use my OS's package manager or have distro that uses package formats other than rpm/deb and can't run Python 3.6+",Binaries from .tar or .zip file on `Linuxfabrik's Download Server <https://download.linuxfabrik.ch/monitoring-plugins/>`_
    Linux,  "Want to use the latest development version and Python 3.6+ available", `Source code variant from GitHub <https://github.com/Linuxfabrik/monitoring-plugins/tree/main>`_
    Windows,"Want to use EXE files",Binaries in ``/windows`` on `Linuxfabrik's Download Server <https://download.linuxfabrik.ch/monitoring-plugins/windows/>`_
    Windows,"Want to use the latest development version and Python 3.6+ available", `Source code variant from GitHub <https://github.com/Linuxfabrik/monitoring-plugins/tree/main>`_

FAQ:

* | Q: What is your recommendation?
  | A: Use the OS's package manager to install the packages from the Linuxfabrik's Repo Server.

* | Q: Do the OS packages have external dependencies?
  | A: No.

* | Q: Can I overwrite specific plugins with its source code variant, if all other plugins are installed by the OS package manager?
  | A: Of course. Just don't forget to install the libs either.


Linux
-----

Installing using OS Package Manager (recommended)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We provide repositories for RPM and DEB packages. Have a look at `repo.linuxfabrik.ch <https://repo.linuxfabrik.ch/monitoring-plugins>`_ for the installation instructions for your distro.

We currently just provide packages for released versions of Linuxfabrik's Monitoring Plugins, not for the current main (development) branch.


Installing using Binaries from an Archive
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For other distros, or if you don't want to use your package manager, you can unpack the compiled binaries to a folder of your choice (normally ``/usr/lib64/nagios/plugins``) by using one of these files:

* `tar <https://download.linuxfabrik.ch/monitoring-plugins/tar>`_
* `zip <https://download.linuxfabrik.ch/monitoring-plugins/zip>`_


sudoers
~~~~~~~

On Linux, some check plugins require ``sudo``-permissions to run. To do this, we provide ``sudoers`` files for various operating system families in ``monitoring-plugins/assets/sudoers``, for example ``RedHat.sudoers``. You need to place this file in ``/etc/sudoers.d/`` on the target host. The file name is compatible to `ansible_facts['os_family'] <https://github.com/ansible/ansible/blob/37ae2435878b7dd76b812328878be620a93a30c9/lib/ansible/module_utils/facts.py#L267>`_.

Currently available:

* ``Debian.sudoers``: for Debian, Raspbian, Ubuntu
* ``RedHat.sudoers``: for Alma, Amazon, Ascendos, CentOS, CloudLinux, Fedora, OEL, OracleLinux, OVS, PSBM, RedHat, Rocky Linux, Scientific, SLC, XenServer
* ``Suse.sudoers``: for openSUSE, SLED, SLES, SLES_SAP, SuSE

Currently not implemented:

* ``AIX.sudoers``: for AIX
* ``Alpine.sudoers``: for Alpine
* ``Archlinux.sudoers``: for Archlinux, Manjaro
* ``Darwin.sudoers``: for MacOSX
* ``FreeBSD.sudoers``: for FreeBSD
* ``Gentoo.sudoers``: for Funtoo, Gentoo
* ``HPUX.sudoers``: for HPUX
* ``Mandrake.sudoers``: for Mandrake, Mandriva
* ``Slackware.sudoers``: for Slackware
* ``Solaris.sudoers``: for Nexenta, OmniOS, OpenIndiana, SmartOS, Solaris

**Note**: We are always using the path ``/usr/lib64/nagios/plugins/`` on all Linux OS, even if ``nagios-plugins-all`` installs itself to ``/usr/lib/nagios/plugins/``. This is because adding a command with ``sudo`` in Icinga Director, one needs to use the full path of the plugin. See the following `GitHub issue <https://github.com/Icinga/icingaweb2-module-director/issues/2123>`_.


Windows
-------

Installation
~~~~~~~~~~~~

Simply download the latest zip file containing all plugins from https://download.linuxfabrik.ch/monitoring-plugins/windows/latest.zip and unzip it to ``c:/programdata/icinga2/usr/lib64/nagios/plugins/``. If you want to upgrade, simply overwrite your installation directory.

.. note::

    `According to Microsoft <https://docs.microsoft.com/en-us/windows/win32/win_cert/certification-requirements-for-windows-desktop-apps#10-apps-must-install-to-the-correct-folders-by-default>`_, program files belong under %programfiles% instead of %programdata%, because under the latter, even non-admins have write permissions. This may allow a local attacker to gain admin rights by manipulating these files (swapping, modifying, adding). Nevertheless, the Icinga agent puts its files in ``c:\programdata\icinga2``. This is why we also recommend to use this directory.


Microsoft Windows Defender
~~~~~~~~~~~~~~~~~~~~~~~~~~

Depending on your signature versions or the healthiness of your signature cache, the Microsoft Windows Defender might classify a check as malicious (for example our ``service.exe``). Please follow the steps below to clear cached detections and obtain the latest malware definitions.

1. Open command prompt as administrator and change directory to ``c:\program files\windows defender``
2. Run ``MpCmdRun.exe -removedefinitions -dynamicsignatures``
3. Run ``MpCmdRun.exe -SignatureUpdate``


Python: Run from Source Code
----------------------------

You may use this if nothing from the above fits your needs.

If you run the Linuxfabrik check plugins directly from source (which is no problem at all), you need to install Python 3 on the remote host. The plugins work with at least Python 3.6, but some of them (currently ``disk-io``) will only run if Python 3.8+ is available.


Installation
~~~~~~~~~~~~

Goal: After installing/copying, the directory on the remote host should look like this:

.. code-block:: text

    /path/to/plugins (normally /usr/lib64/nagios/plugins)
    |-- about-me
    |-- disk-smart
    |-- ...
    |-- lib
    |   |-- base.py
    |   |-- ...
    |-- ...

We describe one way to do so. Do whatever you have to do to get to this.

Get the monitoring check plugins from our Git repository to your local machine or deployment host:

.. code-block:: bash

    # https://github.com/Linuxfabrik/monitoring-plugins/releases
    RELEASE=2022072001

.. code-block:: bash

    git clone https://github.com/Linuxfabrik/monitoring-plugins.git
    cd monitoring-plugins
    git checkout tags/$RELEASE
    cd ..

The check plugins require the `Linuxfabrik Python libraries <https://github.com/linuxfabrik/lib>`_, in the same version. The libraries are in a separate Git repository, as we also use them in other projects.

.. code-block:: bash

    git clone https://github.com/Linuxfabrik/lib.git
    cd lib
    git checkout tags/$RELEASE
    cd ..

Copy the libraries onto the remote host to ``/usr/lib64/nagios/plugins/lib``, and copy some or all Python check plugins to ``/usr/lib64/nagios/plugins``, for example by doing the following on your deployment host:

.. code-block:: bash

    REMOTE_USER=root
    REMOTE_HOST=192.0.2.74
    SOURCE_LIBS=/path/to/lib
    SOURCE_PLUGINS=/path/to/monitoring-plugins/check-plugins
    TARGET_DIR=/usr/lib64/nagios/plugins

    ssh $REMOTE_USER@$REMOTE_HOST "mkdir -p $TARGET_DIR/lib"
    scp $SOURCE_LIBS/* $REMOTE_USER@$REMOTE_HOST:$TARGET_DIR/lib/
    for f in $(find $SOURCE_PLUGINS -maxdepth 1 -type d); do f=$(basename $f); scp $SOURCE_PLUGINS/$f/$f $REMOTE_USER@$REMOTE_HOST:$TARGET_DIR/$f; done

We try to avoid dependencies on 3rd party OS- or Python-libraries wherever possible. If we need to use additional libraries for various reasons (for example `psutil <https://psutil.readthedocs.io/en/latest/>`_), we stick with official versions. Some plugins use some of the following 3rd-party python libraries, so the easiest way is to install these as well, using your package manager, pip or whatever (depends on your environment):

.. code-block:: bash

    pip3 install --upgrade pip
    pip3 install --requirement requirements.txt

To make SELinux happy, after installing from source, run:

.. code-block:: bash

    restorecon -Fvr /usr/lib64/nagios
    setsebool -P nagios_run_sudo on


Ansible
-------

We also provide a Monitoring-Plugins Role within our `LFOps Ansible Collection <https://galaxy.ansible.com/linuxfabrik/lfops>`_. This Ansible role deploys the Linuxfabik Monitoring Plugins and the corresponding Monitoring Plugin Library to ``/usr/lib64/nagios/plugins/`` and ``/usr/lib64/nagios/plugins/lib`` respectively, allowing them to be easily executed by a monitoring system.

