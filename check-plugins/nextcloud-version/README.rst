Check nextcloud-version
=======================

Overview
--------

This plugin lets you track if Nextcloud server updates are available.

To check for updates, this plugin could, but does *not* use

* the Git Repo at https://github.com/nextcloud/server/releases
* the downloads at https://download.nextcloud.com/server/releases
* the downloads at https://updates.nextcloud.com/customers/YOUR-SUBSCRIPTION-KEY

Instead it uses the internal ``occ update:check`` command, assuming that the *updatenotification* app is installed and enabled. The check has to run on the Nextcloud server itself and needs access to the Nextcloud installation directory.

In detail, it fires these two commands:

.. code-block:: bash

    # check if internet connection is available
    sudo -u \#48 /path/to/nextcloud/occ config:list

    # check if Nextcloud thinks that everything is up to date
    sudo -u \#48 /path/to/nextcloud/occ update:check



Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "App ``updatenotification`` must be enabled"


Help
----

.. code-block:: text

    usage: nextcloud-version [-h] [-V] [--always-ok] [--path PATH]

    This plugin lets you track if Nextcloud server updates are available.

    optional arguments:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --path PATH    Local path to your Nextcloud installation, typically within
                     your Webserver's Document Root. Default:
                     /var/www/html/nextcloud


Usage Examples
--------------

.. code-block:: bash

    ./nextcloud-version --path /var/www/html/nextcloud
    
Output:

.. code-block:: text

    Nextcloud v20.0.10.2 is up to date


States
------

* If wanted, always returns OK,
* else returns WARN if update is available.


Perfdata / Metrics
------------------

There is no perfdata.


Troubleshooting
---------------

sudo: unknown user: #-1, sudo: error initializing audit plugin sudoers_audit
    Nextcloud installation was not found.

There are no commands defined in the "update" namespace.
    Nextcloud app ``updatenotification`` is not enabled.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
