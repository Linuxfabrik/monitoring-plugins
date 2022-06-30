Check wsdl
=============

Overview
--------

This plugin checks for a matching string in the XML response after a basic auth to a WSDL URL.

Hints:

* At the moment only basic auth is supported


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wsdl"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``lxml``

Help
----

.. code-block:: text

    usage: wsdl [-h] [--always-ok] [-V] [--no-proxy] --service-url SERVICE_URL --service-user SERVICE_USER --service-pass SERVICE_PASS [--timeout TIMEOUT]
		 --expect EXPECT --xpath XPATH

    This plugin checks for a matching string in the XML response after a basic auth to a WSDL URL.

    optional arguments:
      -h, --help            show this help message and exit
      --always-ok           Always return OK.
      -V, --version         show program's version number and exit
      --no-proxy            Do not use a proxy. Default: False
      --service-url SERVICE_URL
			    http/https url to WSDL
      --service-user SERVICE_USER
			    http/https user name for basic auth
      --service-pass SERVICE_PASS
			    http/https password for basic auth
      --timeout TIMEOUT     Network timeout in seconds. Default: 5 (seconds)
      --expect EXPECT       The value we expect to find in the expaths location
      --xpath XPATH         XPath query to compare with --expect. The result must point to a single value (attribute or node content). Lists/arrays are not
			    supported.    usage: example [-h] [-V]
			

Usage Examples
--------------

.. code-block:: bash

    ./wsdl --service-user USER --service-pass ***** --service-url https://host:port/path/to/WSDL --xpath //wsdl:portType/wsdl:operation/wsdl:input/@message --expect tns:XYZ

Output:

.. code-block:: text

    [OK] expected match found


States
------

* Always returns OK.
* CRIT if any condition.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich/Switzerland <https://www.linuxfabrik.ch>`_; originally written by Simon Wunderlin and adapted by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
