How to install the Linuxfabrik Monitoring Plugins Collection
============================================================

In general, you have two options:

* Using the compiled plugins (available as OS packages or simple archives).
* Using the plugins from the source code (requires Python).


Linux: Using your OS Package Manager
------------------------------------

We currently don't provide a repository server yet, so to install the latest release, you have to install the plugins like so:

.. code-block:: bash

    # .rpm package - for RHEL 7+ and compatible
    sudo yum -y install https://download.linuxfabrik.ch/monitoring-plugins/rpm/linuxfabrik-monitoring-plugins.rpm

.. code-block:: bash

    # .deb package - for Debian 9+, Ubuntu 16.04+ and compatible
    curl --location --remote-name https://download.linuxfabrik.ch/monitoring-plugins/deb/linuxfabrik-monitoring-plugins.deb
    sudo apt -y install ./linuxfabrik-monitoring-plugins.deb

We just provide packages for released versions of Linuxfabrik's Monitoring Plugins, not for the current main (development) branch.


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


Linux: Using Binaries from an Archive
-------------------------------------

For other distros, or if you don't want to use your package manager, you can unpack the compiled binaries to a folder of your choice, which is normally ``/usr/lib64/nagios/plugins``, by using one of these files:

* `linuxfabrik-monitoring-plugins.tar <https://download.linuxfabrik.ch/monitoring-plugins/tar/linuxfabrik-monitoring-plugins.tar>`_
* `linuxfabrik-monitoring-plugins.zip <https://download.linuxfabrik.ch/monitoring-plugins/zip/linuxfabrik-monitoring-plugins.zip>`_


Python: Run from Source Code
----------------------------

You may use this if nothing from the above fits your needs.

If you run the Linuxfabrik check plugins directly from source (which is no problem at all), you need to install Python 3 on the remote host. The plugins work with at least Python 3.6, but some of them (currently ``disk-io``) will only run if Python 3.8+ is available.


Virtual Environment (optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to use a virtual environment for Python, you could create one in the same directory as the check-plugins.

.. code-block:: bash

    cd /usr/lib64/nagios/plugins
    python3 -m venv --system-site-packages monitoring-plugins-venv3

If you prefer to place the virtual environment somewhere else, you can point the ``MONITORING_PLUGINS_VENV3`` environment variable to your virtual environment. This takes precedence over the virtual environment above.

.. warning::

    Make sure the ``bin/activate_this.py`` file is owned by root and not writeable by any other user, as it is executed by the check plugins (where some are executed using ``sudo``).


Installation
~~~~~~~~~~~~

Goal: After installing/copying, the directory on the remote host should look like this:

.. code-block:: text

    /path/to/plugins (normally /usr/lib64/nagios/plugins)
    |-- about-me
    |-- disk-smart
    |-- ...
    |-- lib
    |   |-- base3.py
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

The check plugins require the `Linuxfabrik Python libraries <https://github.com/linuxfabrik/lib>`_. The libraries are in a separate Git repository, as we also use them in other projects.

.. code-block:: bash

    git clone https://github.com/Linuxfabrik/lib.git
    cd lib
    git checkout tags/$RELEASE
    cd ..

Copy the libraries onto the remote host to ``/usr/lib64/nagios/plugins/lib``, and copy some or all Python check plugins to ``/usr/lib64/nagios/plugins`` while removing the Python version suffix, for example by doing the following on your deployment host:

.. code-block:: bash

    REMOTE_USER=root
    REMOTE_HOST=192.0.2.74
    PYVER=3
    SOURCE_LIBS=/path/to/lib
    SOURCE_PLUGINS=/path/to/monitoring-plugins/check-plugins
    TARGET_DIR=/usr/lib64/nagios/plugins

    ssh $REMOTE_USER@$REMOTE_HOST "mkdir -p $TARGET_DIR/lib"
    scp $SOURCE_LIBS/* $REMOTE_USER@$REMOTE_HOST:$TARGET_DIR/lib/
    for f in $(find $SOURCE_PLUGINS -maxdepth 1 -type d); do f=$(basename $f); scp $SOURCE_PLUGINS/$f/$f$PYVER $REMOTE_USER@$REMOTE_HOST:$TARGET_DIR/$f; done

We try to avoid dependencies on 3rd party OS- or Python-libraries wherever possible. If we need to use additional libraries for various reasons (for example `psutil <https://psutil.readthedocs.io/en/latest/>`_), we stick with official versions. Some plugins use some of the following 3rd-party python libraries, so the easiest way is to install these as well, using your package manager, pip or whatever (depends on your environment):

* BeautifulSoup4 (bs4)
* psutil
* PyMySQL (pymysql.cursors - on RHEL, use ``yum install python36-mysql``, ``dnf install python3-mysql`` or similar)
* smbprotocol (smbprotocol.exceptions)
* vici


Ansible
-------

We also provide a Monitoring-Plugins Role within our `LFOps Ansible Collection <https://galaxy.ansible.com/linuxfabrik/lfops>`_. This Ansible role deploys the Linuxfabik Monitoring Plugins and the corresponding Monitoring Plugin Library to ``/usr/lib64/nagios/plugins/`` and ``/usr/lib64/nagios/plugins/lib`` respectively, allowing them to be easily executed by a monitoring system.

