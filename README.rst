Python-based Monitoring Plugins Collection
==========================================

This Enterprise Class Plugin Collection provides a bundle of more than eighty Python based plugins for Icinga, Naemon, Nagios, Shinken, Sensu, and other monitoring applications. Each plugin is a stand-alone command line tool that provides a specific type of check. Typically, your monitoring software runs these plugins to determine the current status of hosts and services on your network.

All plugins are tested on CentOS 7+ (Minimal), Fedora 30+ and Ubuntu Server 16+ - and some on Microsoft Windows, too.

If you

- search for plugins that are all written in Python only (your main system language on RHEL/CentOS)
- want to have an easy look into the source code of the plugins
- want to use plugins that are fast, reliable and mainly focused on CentOS and Icinga2
- want to use plugins that all behave uniform and report the same (for example "used") in a short and precise manner, on Linux as well as on Windows
- want to use plugins out of the box with some kind of auto-discovery, that use useful defaults and only throw CRITs where it is absolutely necessary
- are happy about plugins that provide some additional information to help you troubleshoot your system
- want to use plugins that try to avoid 3rd party dependencies wherever possible

... then these plugins might be for you.


Donate
------

|Donate|


Python
------

Python2
~~~~~~~

All plugins are first written in Python 2 (suffixed by "2"), because ...

- in a datacenter environment (where these plugins are mainly used) the ``python == python2`` side is still more popular. - in CentOS 7, Python 2.7 is the default (Python3 became available in CentOS 7.8).
- in CentOS 8, there is no default. You just need to specify whether you want Python 3 or 2.
- support for Python 2 has ended, but not in CentOS 8 (Python 2 remains available in CentOS 8 until the late 2020's decade - for further details have a look at `https://developers.redhat.com/blog/2018/11/14/python-in-rhel-8/ <https://developers.redhat.com/blog/2018/11/14/python-in-rhel-8/>`_).

Our plugins call Python 2 using ``#!/usr/bin/env python2``.


Python3
~~~~~~~

There are already some Python 3 plugins available (suffixed by "3"; currently mainly for Windows). Check out the "Plugin Fact Sheet" at the end of this document.

Our plugins call Python 3 using ``#!/usr/bin/env python3``.



Libraries
~~~~~~~~~

We try to avoid dependencies on 3rd party libraries wherever possible. If we have to use additional libraries for various reasons, we stick to official versions. Have a look at the plugin's README or the "Plugin Fact Sheet" at the end of this document.

We make use of our own libraries, which you can find `here <https://git.linuxfabrik.ch/linuxfabrik/lib>`_. See "Installation" below or "Setting up your development environment" in :doc:`CONTRIBUTING` for instructions on using it with the plugins.



Roadmap
-------

* Every plugin is available fpr Python2 and Python3.
* Every plugin is also tested on Windows.
* Provide a unit test for every plugin.
* Automate the testing pipeline.


Installation
------------

Requirements
~~~~~~~~~~~~

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

Fedora
    - Required: Install Python2, for example by using ``dnf install python2``
    - After that, most of the plugins will run out of the box.
    - Optional: Install 3rd party Python modules if a plugin requires them.
      Example: ``dnf install python2-psutil``

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

As the required `lib <https://git.linuxfabrik.ch/linuxfabrik/lib>`_ is a separate git repo, we need to make sure to deploy the plugins and the library correctly.

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
   |-- lib
   |   |-- base2.py
   |   |-- globals2.py
   |   |-- ...
   |-- ...

To make the deployment easier, we deploy the monitoring plugins and libraries using `ansible <https://www.ansible.com/>`_. You can take a look at our `monitoring-plugins role <https://git.linuxfabrik.ch/linuxfabrik-ansible/roles/monitoring-plugins>`_.



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

You can check which check plugins require ``sudo``-permissions to run by looking at the respective ``sudoers`` file for your operating system in ``assets/sudoers/`` or by looking at the "Plugin Fact Sheet".

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

    python2 -m virtualenv --system-site-packages monitoring-plugins-venv2
    python3 -m venv --system-site-packages monitoring-plugins-venv3

If you prefer to place the virtual environment somewhere else, you can point the ``MONITORING_PLUGINS_VENV2`` or ``MONITORING_PLUGINS_VENV3`` environment variable to your virtual environment. This takes precedence to the virtual environment above.

.. caution::

    Make sure the ``bin/activate_this.py`` file is owned by root and not writeable by any other user, as it is executed by the check plugins (where some are executed using sudo).


Reporting Issues
----------------

For now, there are two ways:

1. Send an email to info[at]linuxfabrik[dot]ch, describing your problem
2. Create an account on `https://git.linuxfabrik.ch <https://git.linuxfabrik.ch>`_ and `submit an issue <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/issues/new>`_.


Check Plugin Fact Sheet
-----------------------

Have a look at the ``check-plugin-fact-sheet.csv``.


.. |Donate| image:: https://img.shields.io/badge/Donate-PayPal-green.svg
   :target: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7AW3VVX62TR4A&source=url
