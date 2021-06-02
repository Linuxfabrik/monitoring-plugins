Python-based Monitoring Plugins Collection
==========================================

This Enterprise Class Plugin Collection offers a package of more than a hundred Python-based, Nagios-compatible check plugins for Icinga, Naemon, Nagios, OP5, Shinken, Sensu and other monitoring applications. Each plugin is a stand-alone command line tool that provides a specific type of verification. Typically, your monitoring software will run these plugins to determine the current status of hosts and services on your network.

If you're looking for monitoring plugins that ...

* are only written in Python (your main system language on RHEL / CentOS)
* ensure easy access to the source code
* are fast, reliable and use few system resources
* uniformly and consistently report the same metrics briefly and precisely (for example "used"), both on Linux and on Windows
* use out of the box some sort of automatic detection using useful default settings
* trigger WARNs and CRITs only where absolutely necessary
* provide additional information on troubleshooting where possible
* avoid dependencies on additional system libraries where possible

... then these plugins could be something for you. 

All plugins are tested on CentOS 7+ (Minimal), Fedora 30+, Ubuntu Server 16+  and (some of them on) Microsoft Windows. Check out the ``check-plugin-fact-sheet.csv`` for further details.


Donate
------

|Donate|


Human Readable Numbers
----------------------

This is how we convert and append symbols to large numbers in a human-readable format (according to Wikipedia `Names of large numbers <https://en.wikipedia.org/w/index.php?title=Names_of_large_numbers&section=5#Extensions_of_the_standard_dictionary_numbers>`_ and other).

.. csv-table::
    :header-rows: 1
    
    Value,        Symbol, Origin,     Type,            Description
    1000^1,       K,      ,           Number,          Thousand
    1000^2,       M,      SI Symbol,  Number,          'Million / Million (US, Canada and modern British (short scale) / Traditional European (Peletier) (long scale))'
    1000^3,       G,      SI Symbol,  Number,          'Billion / Milliard (US, Canada and modern British (short scale) / Traditional European (Peletier) (long scale))'
    1000^4,       T,      SI Symbol,  Number,          'Trillion / Billion (US, Canada and modern British (short scale) / Traditional European (Peletier) (long scale))'
    1000^5,       P,      SI Symbol,  Number,          'Quadrillion / Billiard (US, Canada and modern British (short scale) / Traditional European (Peletier) (long scale))'
    1000^6,       E,      SI Symbol,  Number,          'Quintillion / Trillion (US, Canada and modern British (short scale) / Traditional European (Peletier) (long scale))'
    1000^7,       Z,      SI Symbol,  Number,          'Sextillion / Trilliard (US, Canada and modern British (short scale) / Traditional European (Peletier) (long scale))'
    1000^8,       Y,      SI Symbol,  Number,          'Septillion / Quadrillion (US, Canada and modern British (short scale) / Traditional European (Peletier) (long scale))'
    1024^1,       KiB,    ISQ Symbol, Bytes,           Kibibytes (used in Output)
    1024^2,       MiB,    ISQ Symbol, Bytes,           Mebibytes (used in Output)
    1024^3,       GiB,    ISQ Symbol, Bytes,           Gibibytes (used in Output)
    1024^4,       TiB,    ISQ Symbol, Bytes,           Tebibytes (used in Output)
    1024^5,       PiB,    ISQ Symbol, Bytes,           Pebibytes (used in Output)
    1024^6,       EiB,    ISQ Symbol, Bytes,           Exbibytes (used in Output)
    1024^7,       ZiB,    ISQ Symbol, Bytes,           Zebibytes (used in Output)
    1024^8,       YiB,    ISQ Symbol, Bytes,           Yobibytes (used in Output)
    1000^1,       KB,     other,      Bytes,           Kilobytes
    1000^2,       MB,     other,      Bytes,           Megabytes
    1000^3,       GB,     other,      Bytes,           Gigabytes
    1000^4,       TB,     other,      Bytes,           Terrabytes
    1000^5,       PB,     other,      Bytes,           Petabytes
    1000^6,       EB,     other,      Bytes,           Exabytes
    1000^7,       ZB,     other,      Bytes,           Zetabytes
    1000^8,       YB,     other,      Bytes,           Yottabytes
    1000^1,       Kbps,   other,      Bits per Second, Kilobits
    1000^2,       Mbps,   other,      Bits per Second, Megabits
    1000^3,       Gbps,   other,      Bits per Second, Gigabits
    1000^4,       Tbps,   other,      Bits per Second, Terrabits
    1000^5,       Pbps,   other,      Bits per Second, Petabits
    1000^6,       Ebps,   other,      Bits per Second, Exabits
    1000^7,       Zbps,   other,      Bits per Second, Zetabits
    1000^8,       Ybps,   other,      Bits per Second, Yottabits
    1..59,        s,      other,      Time,            Seconds
    60,           m,      other,      Time,            Minutes
    60*60,        h,      other,      Time,            Hours
    60*60*24,     D,      other,      Time,            Days
    60*60*24*7,   W,      other,      Time,            Weeks
    60*60*24*30,  M,      other,      Time,            Months
    60*60*24*365, Y,      other,      Time,            Years


Libraries
---------

We make use of our own libraries, which you can find `here <https://git.linuxfabrik.ch/linuxfabrik/lib>`_. See "Installation" below for instructions on using it with the plugins.

We try to avoid dependencies on 3rd party OS- or Python-libraries wherever possible. If we have to use additional libraries for various reasons, we stick to official versions.


Roadmaps
--------

Monitoring-Plugins
~~~~~~~~~~~~~~~~~~

* Migrate every Plugin to Python 3.
* Provide a meaningful Grafana-Panel (where it makes sense).
* Compile plugins for Windows (where it makes sense).
* Provide a (unit) test for the majority of the plugins.
* Automate the testing pipeline.


Python 2 vs Python 3
~~~~~~~~~~~~~~~~~~~~

2021-12-31:

* We will stop maintaining the Python 2-based checks on December 31, 2021, focusing on Python 3 only.


2021-03-20:

* All checks are currently available for Python 2.
* We are migrating them step by step to Python 3, currently around 30% of the checks are also available for Python 3.

The Python 2-based plugins use ``#!/usr/bin/env python2``, whereas the Python 3-based plugins use ``#!/usr/bin/env python3``. 



Installation
------------

Requirements
~~~~~~~~~~~~

Fedora
    - Required: Install Python2, for example by using ``dnf install python2``
    - After that, most of the plugins will run out of the box.
    - Optional: Install 3rd party Python modules if a plugin requires them.
      Example: ``dnf install python2-psutil``

CentOS 8
    - Required: Install Python2, for example by using ``dnf install python2``
    - After that, most of the plugins will run out of the box.
    - Optional: Install 3rd party Python modules if a plugin requires them.
      Some of those modules are found in the EPEL repo. Example:
      ``dnf install epel-release; dnf install python2-psutil``

CentOS 7
    - Most of the plugins will run out of the box.
    - Optional: Install 3rd party Python modules if a plugin requires them.
      Some of those modules are found in the EPEL repo. Example:
      ``yum install epel-release; yum install python2-psutil``

Ubuntu 20
    - Most of the plugins will run out of the box.
    - Optional: Install 3rd party Python modules if a plugin requires them.
      Example: ``apt install python-psutil``

Ubuntu 16
    - Required: Install Python2, for example by using ``apt install python-minimal``
    - After that, most of the plugins will run out of the box.
    - Optional: Install 3rd party Python modules if a plugin requires them.
      Example: ``apt install python-psutil``

Windows
    tbd



Installation on Linux
~~~~~~~~~~~~~~~~~~~~~

As the required `lib <https://git.linuxfabrik.ch/linuxfabrik/lib>`_ is a separate git repo, we need to make sure to deploy the plugins and the libraries correctly.

In the following example, we will deploy everything to ``/usr/lib64/nagios/plugins/`` on the remote server ``monitoring-server``:

.. code:: bash

    # first, make sure the target directory exists
    ssh monitoring-server
    mkdir -p /usr/lib64/nagios/plugins/lib
    exit

Install the libraries:

.. code:: bash

    # on your local administrator machine
    git clone https://git.linuxfabrik.ch/linuxfabrik/lib
    cd lib
    # for python2
    scp *2.py monitoring-server:/usr/lib64/nagios/plugins/lib/
    # for python3
    scp *3.py monitoring-server:/usr/lib64/nagios/plugins/lib/

Install some or all plugins:

.. code:: bash

    # on your local administrator machine
    git clone https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins
    cd monitoring-plugins
    # copy a selection of plugins to the remote server
    # for python2
    scp check-plugins/about-me/about-me2 /usr/lib64/nagios/plugins/about-me
    scp check-plugins/disk-smart/disk-smart2 /usr/lib64/nagios/plugins/disk-smart
    # for python3
    scp check-plugins/about-me/about-me3 /usr/lib64/nagios/plugins/about-me
    scp check-plugins/disk-smart/disk-smart3 /usr/lib64/nagios/plugins/disk-smart

Your directory on ``monitoring-server`` should now look like this:

.. code:: bash

   /usr/lib64/nagios/plugins/
   |-- about-me
   |-- disk-smart
   |-- ...
   |-- lib
   |   |-- base2.py
   |   |-- globals2.py
   |   |-- ...
   |-- ...

To make the deployment easier, we provide an `ansible  monitoring-plugins role <https://git.linuxfabrik.ch/linuxfabrik-ansible/roles/monitoring-plugins>`_.


Configuration
-------------

Icinga (Icingaweb, Icinga Director)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For each check, you have to create an Icinga Command, and use this within a Service Template, a Service Set and/or a Single Service.

Example for creating a command for ``cpu-usage`` using Icinga Director (Icinga Director > Commands > Commands):

Tab "Command"

* Add a ``Plugin Check Command``
* Command name: ``cmd-check-cpu-usage``
* Command: ``/usr/lib64/nagios/plugins/cpu-usage``
* Button ``Add``

Tab "Arguments"

* run ``/usr/lib64/nagios/plugins/cpu-usage --help`` to get a list of all arguments
* create those you want to be customizable:

    * Argument name ``--always-ok``, Value type: String, Condition (set_if): ``$cpu_usage_always_ok$``
    * Argument name ``--count``, Value type: String, Value: ``$cpu_usage_count$``
    * Argument name ``--critical``, Value type: String, Value: ```$cpu_usage_critical$``
    * Argument name ``--warning``, Value type: String, Value: ```$cpu_usage_warning$``

Tab "Fields"

* Label "CPU Usage: Count", Field name "cpu_usage_count", Mandatory "n"
* Label "CPU Usage: Critical", Field name "cpu_usage_critical", Mandatory "n"
* Label "CPU Usage: Warning", Field name "cpu_usage_warning", Mandatory "n"


sudoers
~~~~~~~

You can check which check plugins require ``sudo``-permissions to run by looking at the respective ``sudoers`` file for your operating system in ``assets/sudoers/`` or by looking at the "Plugin Fact Sheet" CSV.

You need to place the ``sudoers`` file in ``/etc/sudoers.d/`` on the remote server. For example:

.. code:: bash

    cd monitoring-plugins/assets/sudoers/
    scp CentOS7.sudoers monitoring-server:/etc/sudoers.d/monitoring-plugins

Side note: We are also using the path ``/usr/lib64/nagios/plugins/`` for other OSes, even if ``nagios-plugins-all`` installs itself to ``/usr/lib/nagios/plugins/`` there. This is because when adding a command with ``sudo`` in Icinga Director, one needs to use the full path of the plugin. See the following `GitHub issue <https://github.com/Icinga/icingaweb2-module-director/issues/2123>`_.


Grafana Dashboards
~~~~~~~~~~~~~~~~~~

There are two options to import the Grafana dashboards. You can either import them via the WebGUI or use provisioning.

When importing via the WebGUI simply import the ``plugin-name.grafana-external.json`` file.

If you want to use provisioning, take a look at `Grafana Provisioning <https://grafana.com/docs/grafana/latest/administration/provisioning/>`_.
Beware that you also need to provision the datasources if you want to use provisioning for the dashboards.

Creating Custom Grafana Dashboards
    If you want to create a custom dashboards that contains a different selection of panels, you can do so using the ``tools/grafana-tool`` utility.

    .. code:: bash

        # interactive usage
        ./tools/grafana-tool assets/grafana/all-panels-external.json
        ./tools/grafana-tool assets/grafana/all-panels-provisioning.json

        # for more options, see
        ./tools/grafana-tool --help

Virtual Environment
~~~~~~~~~~~~~~~~~~~

If you want to use a virtual environment for python, you can create one in the same directory as the check-plugins.

.. code-block:: bash

    cd /usr/lib64/nagios/plugins
    python2 -m virtualenv --system-site-packages monitoring-plugins-venv2
    python3 -m venv --system-site-packages monitoring-plugins-venv3

If you prefer to place the virtual environment somewhere else, you can point the ``MONITORING_PLUGINS_VENV2`` or ``MONITORING_PLUGINS_VENV3`` environment variable to your virtual environment. This takes precedence to the virtual environment above.

.. caution::

    Make sure the ``bin/activate`` file is owned by root and not writeable by any other user, as it is executed by the check plugins (where some are executed using sudo).


Reporting Issues
----------------

For now, there are two ways:

1. Send an email to info[at]linuxfabrik[dot]ch, describing your problem
2. Create an account on `https://git.linuxfabrik.ch <https://git.linuxfabrik.ch>`_ and `submit an issue <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/issues/new>`_.

