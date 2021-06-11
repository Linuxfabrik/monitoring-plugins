Python-based Monitoring Check Plugins Collection
================================================

This Enterprise Class Check Plugin Collection offers a package of more than a hundred Python-based, Nagios-compatible check plugins for Icinga, Naemon, Nagios, OP5, Shinken, Sensu and other monitoring applications. Each plugin is a stand-alone command line tool that provides a specific type of verification. Typically, your monitoring software will run these check plugins to determine the current status of hosts and services on your network.

These monitoring check plugins

* are only written in Python (your main system language on RHEL / CentOS)
* ensure easy access to the source code
* are fast, reliable and use as few system resources as possible 
* uniformly and consistently report the same metrics briefly and precisely (for example "used"), both on Linux and on Windows
* use out of the box some sort of automatic detection using useful default settings
* trigger WARNs and CRITs only where absolutely necessary
* provide additional information on troubleshooting where possible
* avoid dependencies on additional system libraries where possible

All check plugins are tested on CentOS 7+ (Minimal), Fedora 30+, Ubuntu Server 16+  and (some of them on) Microsoft Windows.

|Donate|


Human Readable Numbers
----------------------

Check Plugin Output: This is how we convert and append symbols to large numbers in a human-readable format (according to Wikipedia `Names of large numbers <https://en.wikipedia.org/w/index.php?title=Names_of_large_numbers&section=5#Extensions_of_the_standard_dictionary_numbers>`_ and other).

.. csv-table::
    :header-rows: 1
    
    Value,        Symbol, Origin,     Type,            Description
    1000^1,       K,      ,           Number,          Thousand
    1000^2,       M,      SI Symbol,  Number,          "Million :sup:`1` / Million :sup:`2`"
    1000^3,       G,      SI Symbol,  Number,          "Billion :sup:`1` / Milliard :sup:`2`"
    1000^4,       T,      SI Symbol,  Number,          "Trillion :sup:`1` / Billion :sup:`2`"
    1000^5,       P,      SI Symbol,  Number,          "Quadrillion :sup:`1` / Billiard :sup:`2`"
    1000^6,       E,      SI Symbol,  Number,          "Quintillion :sup:`1` / Trillion :sup:`2`"
    1000^7,       Z,      SI Symbol,  Number,          "Sextillion :sup:`1` / Trilliard :sup:`2`"
    1000^8,       Y,      SI Symbol,  Number,          "Septillion :sup:`1` / Quadrillion :sup:`2`"
    1024^1,       KiB,    ISQ Symbol, Bytes,           Kibibytes :sup:`3`
    1024^2,       MiB,    ISQ Symbol, Bytes,           Mebibytes :sup:`3`
    1024^3,       GiB,    ISQ Symbol, Bytes,           Gibibytes :sup:`3`
    1024^4,       TiB,    ISQ Symbol, Bytes,           Tebibytes :sup:`3`
    1024^5,       PiB,    ISQ Symbol, Bytes,           Pebibytes :sup:`3`
    1024^6,       EiB,    ISQ Symbol, Bytes,           Exbibytes :sup:`3`
    1024^7,       ZiB,    ISQ Symbol, Bytes,           Zebibytes :sup:`3`
    1024^8,       YiB,    ISQ Symbol, Bytes,           Yobibytes :sup:`3`
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

* 1: US, Canada and modern British (short scale)
* 2: Traditional European (Peletier) (long scale)
* 3: Used in output


A few words about Python
------------------------

Python 2 vs Python 3
~~~~~~~~~~~~~~~~~~~~

All check plugins are currently available for Python 2. We are gradually migrating them to Python 3 by 2021-12-31 (at 2021-06 approx. 50% are done). The Python 2 check plugins have the suffix "2", the Python 3 plugins have the suffix "3".

The Python 2-based check plugins use ``#!/usr/bin/env python2``, while the Python 3-based check plugins use ``#!/usr/bin/env python3``. 


Virtual Environment
~~~~~~~~~~~~~~~~~~~

If you want to use a virtual environment for Python (we recommend that), you could create one in the same directory as the check-plugins.

.. code-block:: bash

    cd /usr/lib64/nagios/plugins
    python2 -m virtualenv --system-site-packages monitoring-plugins-venv2
    python3 -m venv --system-site-packages monitoring-plugins-venv3

If you prefer to place the virtual environment somewhere else, you can point the ``MONITORING_PLUGINS_VENV2`` or ``MONITORING_PLUGINS_VENV3`` environment variable to your virtual environment. This takes precedence over the virtual environment above.

.. caution::

    Make sure the ``bin/activate`` file is owned by root and not writeable by any other user, as it is executed by the check plugins (where some are executed using ``sudo``).


Libraries
~~~~~~~~~

We use our own `libraries, which you find in a separate Git repository <https://git.linuxfabrik.ch/linuxfabrik/lib>`_.

We try to avoid dependencies on 3rd party OS- or Python-libraries wherever possible. If we need to use additional libraries for various reasons (for example `psutils <https://psutil.readthedocs.io/en/latest/>`_), we stick with official versions. We recommend installing these in the above mentioned check plugin virtual environment.


Running the Check Plugins on Linux
----------------------------------

Installation
~~~~~~~~~~~~

Install Python 2 (currently preferred) or Python 3 on the client.

Get our monitoring check plugins and the associated libraries from Linuxfabrik's GitLab server:

.. code:: bash

    cd /tmp
    
    curl --output monitoring-plugins.tar.gz https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/archive/master/monitoring-plugins-master.tar.gz
    curl --output lib.tar.gz https://git.linuxfabrik.ch/linuxfabrik/lib/-/archive/master/lib-master.tar.gz

    tar xf lib.tar.gz
    tar xf monitoring-plugins.tar.gz

Prepare the directory tree:

.. code:: bash

    mkdir -p /usr/lib64/nagios/plugins/lib

Copy the libraries to ``/usr/lib64/nagios/plugins/lib``:

.. code:: bash

    \cp /tmp/lib-master/*.py /usr/lib64/nagios/plugins/lib

Copy some or all Python 2 (or Python 3) check plugins to ``/usr/lib64/nagios/plugins``, and remove the Python version suffix, for example by doing the following:

.. code:: bash

    cd /tmp/monitoring-plugins-master/check-plugins
    for check in $(find -maxdepth 2 -name '*2')
    do
        dir=$(dirname $check)
        file=${dir:2}
        \cp $check /usr/lib64/nagios/plugins/$file
    done

That's it. After that your directory on the client should now look like this:

.. code:: bash

   /usr/lib64/nagios/plugins/
   |-- about-me
   |-- disk-smart
   |-- ...
   |-- lib
   |   |-- base2.py
   |   |-- base3.py
   |   |-- globals2.py
   |   |-- ...
   |-- ...

.. tipp::

    There is also an `ansible  monitoring-plugins role <https://git.linuxfabrik.ch/linuxfabrik-ansible/roles/monitoring-plugins>`_ available.


sudoers
~~~~~~~

Some check plugins require ``sudo``-permissions to run. To do this, we provide a ``sudoers`` file for your operating system in ``monitoring-plugins/assets/sudoers``, for example ``CentOS8.sudoers``. You need to place this file in ``/etc/sudoers.d/`` on the client.

.. note::

    We are always using the path ``/usr/lib64/nagios/plugins/`` on all Linux OS, even if ``nagios-plugins-all`` installs itself to ``/usr/lib/nagios/plugins/`` there. This is because adding a command with ``sudo`` in Icinga Director, one needs to use the full path of the plugin. See the following `GitHub issue <https://github.com/Icinga/icingaweb2-module-director/issues/2123>`_.


Upgrade
~~~~~~~

* Overwrite ``/usr/lib64/nagios/plugins/lib`` with the new libraries.
* Overwrite ``/usr/lib64/nagios/plugins`` with the new plugins.
* Copy the new sudoers file to ``/etc/sudoers.d/``
* Delete all SQLite database files (``*.db``) in ``/tmp``.


Running the Check Plugins on Windows
------------------------------------

TODO


Icinga
------

Configuration in Icinga Director
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For each check, you have to create an Icinga Command. We show this using the "cpu-usage" check plugin.

Create a command for ``cpu-usage`` using Icinga Director: Icinga Director > Commands > Commands

* Link "+Add", ``Plugin Check Command``
* Command name: ``cmd-check-cpu-usage``
* Command: ``/usr/lib64/nagios/plugins/cpu-usage``
* Button "Add"

Tab "Arguments":

* Run ``/usr/lib64/nagios/plugins/cpu-usage --help`` to get a list of all arguments.
* Create those you want to be customizable:

    * Argument name ``--always-ok``, Value type: String, Condition (set_if): ``$cpu_usage_always_ok$``
    * Argument name ``--count``, Value type: String, Value: ``$cpu_usage_count$``
    * Argument name ``--critical``, Value type: String, Value: ```$cpu_usage_critical$``
    * Argument name ``--warning``, Value type: String, Value: ```$cpu_usage_warning$``

Tab "Fields":

* Label "CPU Usage: Count", Field name "cpu_usage_count", Mandatory "n"
* Label "CPU Usage: Critical", Field name "cpu_usage_critical", Mandatory "n"
* Label "CPU Usage: Warning", Field name "cpu_usage_warning", Mandatory "n"

Now use this command within a Service Template, a Service Set and/or a Single Service.


Grafana
-------

There are two options to import the Grafana dashboards. You can either import them via the WebGUI or use provisioning.

When importing via the WebGUI simply import the ``plugin-name.grafana-external.json`` file.

If you want to use provisioning, take a look at `Grafana Provisioning <https://grafana.com/docs/grafana/latest/administration/provisioning/>`_.
Beware that you also need to provision the datasources if you want to use provisioning for the dashboards.

If you want to create a custom dashboards that contains a different selection of panels, you can do so using the ``tools/grafana-tool`` utility.

.. code:: bash

    # interactive usage
    ./tools/grafana-tool assets/grafana/all-panels-external.json
    ./tools/grafana-tool assets/grafana/all-panels-provisioning.json

    # for more options, see
    ./tools/grafana-tool --help


Roadmap
--------

Next steps (beside maintaining and writing new check plugins):

* Migrate every Plugin to Python 3.
* Provide a meaningful Grafana-Panel (where it makes sense).
* Compile check plugins for Windows using ``nuitka`` (where it makes sense).
* Provide a (unit) test for the majority of the check plugins (where it makes sense).
* Automate the testing pipeline (CentOS, Ubuntu, Debian, OpenSUSE, Windows).


Reporting Issues
----------------

For now, there are two ways:

1. Send an email to info[at]linuxfabrik[dot]ch, describing your problem
2. Create an account on `https://git.linuxfabrik.ch <https://git.linuxfabrik.ch>`_ and `submit an issue <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/issues/new>`_.







.. |Donate| image:: https://img.shields.io/badge/Donate-PayPal-green.svg
   :target: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7AW3VVX62TR4A&source=url
