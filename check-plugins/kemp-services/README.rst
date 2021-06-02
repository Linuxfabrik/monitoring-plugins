Check kemp-services
===================

Overview
--------

Kemp is a virtual load balancer (https://kemptechnologies.com).
This check warns on any virtual service which is marked as down, using the REST API.

Hints:

* Use ``--filter`` to only check services that contain a certain string in their NickName.
* Use ``--state`` to choose which state should be returned.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/example"
    "Check Interval Recommendation",        "Once a minute"
    "Available for",                        "Python 2"
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

	./kemp-services --hostname localhost --username user --password password
	./kemp-services --hostname localhost --username user --password password --filter PROD
	./kemp-services --hostname localhost --username user --password password --filter PROD --state crirt

Output:

.. code-block:: text

	TODO


States
------

* WARN (default) if any virtual service is marked as down.


Perfdata / Metrics
------------------

There is no perfdata.                                                                             


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
