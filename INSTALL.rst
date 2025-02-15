How to install the Linuxfabrik Monitoring Plugins Collection
============================================================

.. csv-table::
    :header-rows: 1

    Platform, Install, When, Installation Instructions
    Linux, "rpm/deb package (**recommended**)", "Want to use OS package manager and have distro that uses rpm/deb package formats", See `<https://repo.linuxfabrik.ch>`_
    Linux, "Binaries from tar/zip", "Don't want to use OS package manager or have distro that uses package formats other than rpm/deb and can't run Python 3.9+", "See *Installation on Linux* in this document"
    Linux, "Source Code", "Want to use the latest development version and Python 3.9+ available", "See *Run from Source* in this document"
    Windows,"Binaries from msi (**recommended**)","Want to use OS package manager", "Get the msi file from `Linuxfabrik's Download Server <https://download.linuxfabrik.ch/monitoring-plugins/windows>`_ and run it."
    Windows,"Binaries from zip","Don't want to use OS package manager", "Get the zip file from `Linuxfabrik's Download Server <https://download.linuxfabrik.ch/monitoring-plugins/linux>`_ and unpack it to a folder of your choice, usually ``C:\ProgramData\icinga2\usr\lib64\nagios\plugins``"
    Windows, "Source Code", "Want to use the latest development version and Python 3.9+ available", "See *Run from Source* in this document"
    Any, "Using Ansible", "Want to automate the installation process", "See the `LFOps Ansible Role linuxfabrik.lfops.monitoring_plugins <https://github.com/Linuxfabrik/lfops/tree/main/roles/monitoring_plugins>`_"


.. _installation_on_linux:

Installation on Linux
---------------------

* Get the tar or zip file from `Linuxfabrik's Download Server <https://download.linuxfabrik.ch/monitoring-plugins/linux>`_ and unpack it to a folder of your choice, usually ``/usr/lib64/nagios/plugins``

* On Linux, some check plugins require ``sudo``-permissions to run. To do this, we provide ``sudoers`` files for various operating system families in ``monitoring-plugins/assets/sudoers``, for example ``RedHat.sudoers``. The file name is compatible to `ansible_facts['os_family'] <https://github.com/ansible/ansible/blob/37ae2435878b7dd76b812328878be620a93a30c9/lib/ansible/module_utils/facts.py#L267>`_. You need to place this file in ``/etc/sudoers.d/`` on the target host.

    Currently available:

    * ``Debian.sudoers``: for Debian, Raspbian, Ubuntu
    * ``RedHat.sudoers``: for Alma, Amazon, Ascendos, CentOS, CloudLinux, Fedora, OEL, OracleLinux, OVS, PSBM, RedHat, Rocky Linux, Scientific, SLC, XenServer
    * ``Suse.sudoers``: for openSUSE, SLED, SLES, SLES_SAP, SuSE


Run from Source
---------------

If you run the Linuxfabrik check plugins directly from source (which is no problem at all), you need to install Python 3.9+ on the remote host. We describe one way to do so. Do whatever you have to do to get to this.

Get the monitoring check plugins from our Git repository to your local machine or deployment host:

.. code-block:: bash

    # https://github.com/Linuxfabrik/monitoring-plugins/releases
    RELEASE=1.2.3.4

.. code-block:: bash

    git clone https://github.com/Linuxfabrik/monitoring-plugins.git
    cd monitoring-plugins
    git checkout tags/$RELEASE
    cd ..

Copy some or all Python check plugins to ``/usr/lib64/nagios/plugins``, for example by doing the following on your deployment host:

.. code-block:: bash

    REMOTE_USER=root
    REMOTE_HOST=192.0.2.74
    SOURCE_PLUGINS=/path/to/monitoring-plugins/check-plugins
    TARGET_DIR=/usr/lib64/nagios/plugins

    ssh $REMOTE_USER@$REMOTE_HOST "mkdir -p $TARGET_DIR/lib"
    for f in $(find $SOURCE_PLUGINS -maxdepth 1 -type d); do f=$(basename $f); scp $SOURCE_PLUGINS/$f/$f $REMOTE_USER@$REMOTE_HOST:$TARGET_DIR/$f; done

After installing/copying, the directory on the remote host should look like this:

.. code-block:: text

    /path/to/plugins (normally /usr/lib64/nagios/plugins)
    |-- about-me
    |-- disk-smart
    |-- ...
    |-- lib
    |   |-- base.py
    |   |-- ...
    |-- ...

We try to avoid dependencies on 3rd party OS- or Python-libraries wherever possible. If we need to use additional libraries for various reasons (for example `psutil <https://psutil.readthedocs.io/en/latest/>`_), we stick with official versions. Some plugins use some of the following 3rd-party python libraries, so the easiest way is to install these as well, using your package manager, pip or whatever (depends on your environment):

.. code-block:: bash

    python3 -m pip install --upgrade pip
    python3 -m pip install --requirement requirements.txt --require-hashes

To make SELinux happy, after installing from source, run:

.. code-block:: bash

    restorecon -Fvr /usr/lib64/nagios
    setsebool -P nagios_run_sudo on
