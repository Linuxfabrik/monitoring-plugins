Check enextcloud-version
========================

Overview
--------

This plugin lets you track if Nextcloud server updates are available.

To check for updates, this plugin does *not* use
* the Git Repo at https://github.com/nextcloud/server/releases
* the downloads at https://download.nextcloud.com/server/releases
* the downloads at https://updates.nextcloud.com/customers/YOUR-SUBSCRIPTION-KEY

Instead it uses the internal ``occ update:check`` command, assuming that the *updatenotification* app is installed and enabled. The check has to run on the Nextcloud server itself and needs access to the Nextcloud installation directory.

"sudo: unknown user: #-1, sudo: error initializing audit plugin sudoers_audit"
    Nextcloud installation was not found.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/nextcloud-version"
    "Check Interval Recommendation",        "Once a day"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Python module ``psutil``, command-line tool ``foo``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"
    "Perfdata compatible with Prometheus",  "Yes"


Help
----

.. code-block:: text

    usage: example [-h] [-V]

    Example Check.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./nextcloud-version --path /var/www/html/nextcloud
    ./nextcloud-version --path /var/www/html/nextcloud --always-ok
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* If wanted, always returns OK,
* else returns WARN if update is available.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
