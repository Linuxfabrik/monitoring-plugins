Check xml
=========

Overview
--------

This plugin checks for a matching string in a XML document, fetched via http(s). Simple XPath syntax, prefix namespaces (important for testing WSDL responses) and HTTP Basic Auth are supported.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/xml"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``lxml``"


Help
----

.. code-block:: text

    usage: xml [-h] [-V] [--always-ok] [--expect EXPECT] [--namespace NAMESPACES]
               [--no-proxy] [--password PASSWORD] [--timeout TIMEOUT] --url URL
               [--username USERNAME] --xpath XPATH

    This plugin checks for a matching string in a XML document, fetched via
    http(s). Simple XPath syntax, prefix namespaces and HTTP Basic Auth are
    supported.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always return OK.
      --expect EXPECT       String to expect in the xpath's location. If ommitted,
                            just checks if the XPath exists.
      --namespace NAMESPACES
                            If your XPath expression uses namespace prefixes, you
                            must define them in a prefix mapping. This parameter
                            expects a mapping for the namespace prefix used in the
                            XPath expression to namespace URI (repeatable). For
                            example like so: --namespace="prefix1:https://schemas.
                            xmlsoap.org/prefix1/" --namespace="prefix2:https://sch
                            emas.xmlsoap.org/prefix2/"
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   Password (HTTP Basic Auth).
      --timeout TIMEOUT     Network timeout in seconds. Default: 7 (seconds)
      --url URL             WSDL Endpoint URL. Default: None
      --username USERNAME   Username (HTTP Basic Auth).
      --xpath XPATH         XPath to query. The result must point to a single
                            value (attribute or node content). Lists/arrays are
                            not supported.


Usage Examples
--------------

Check if node ``/note/heading`` exists in XML:

.. code-block:: bash

    ./xml3 --url https://www.w3schools.com/xml/note.xml --xpath /note/heading

Output:

.. code-block:: text

    Everything is ok.

Search for string "emi" in XML tag ``<note><heading>``:

.. code-block:: bash

    ./xml3 --url https://www.w3schools.com/xml/note.xml --xpath /note/heading --expect emi

Output:

.. code-block:: text

    Everything is ok, "emi" found in result "Reminder".

Search for a string in a WSDL definition (here you have to deal with namespace prefixes):

.. code-block:: bash

    ./xml3 --url 'https://www.xignite.com/xCurrencies.asmx?wsdl' \
        --xpath /wsdl:definitions/wsdl:documentation \
        --namespace wsdl:http://schemas.xmlsoap.org/wsdl/ \
        --expect 'exchange information'

Output:

.. code-block:: text

    Everything is ok, "exchange information" found in result "Provide real-time currency foreign exchange information and calculations.".


States
------

* WARN if node is not found (empty result).
* WARN is expected text is not found in XML tag text representation.
* UNKNOWN on XML parsing errors, wrong namespace syntax, xpath errors or text search within non-text tags.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich/Switzerland <https://www.linuxfabrik.ch>`_; originally written by Simon Wunderlin and adapted by Dominik Riva, Universitätsspital Basel/Switzerland
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
