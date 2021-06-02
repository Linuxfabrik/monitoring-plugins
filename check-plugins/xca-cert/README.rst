Check xca-cert
==============

Overview
--------

If you are using XCA by Christian Hohnstädt (an *application that is intended for creating and managing X.509 certificates, certificate requests, RSA, DSA and EC private keys, Smart-cards and CRLs*) with `"Remote Databases" feature enabled <https://hohnstaedt.de/xca/index.php/documentation/remote-databases>`_, this plugin lets you check the expiration date of any certificate within those XCA MySQL/MariaDB databases. CRLs are also taken into account.

We recommend to run this check direclty on your database host, and just once a day.

* Works with MySQL/MariaDB backend only, although XCA is supporting PostgreSQL as well.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/xca-cert"
    "Check Interval Recommendation",        "Once a day"
    "Available for",                        "Python 2"
    "Requirements",                         "Python2 module ``mysql.connector``, command-line tool ``foo``"
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

    ./xca-cert --hostname localhost --database xca --username dbuser --password dbpass --prefix xca_prefix_ --warning 14 --critical 5 
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT if a certificate expires within a given threshold.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
