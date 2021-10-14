Check json-values
=================

Overview
--------

This check parses a flat json array from a file or url and simply returns the message, state and perfdata from the json.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/json-values"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: json-values [-h] [-V] [--always-ok] [--filename FILENAME] [--insecure]
                       [--message-key MESSAGE_KEY] [--no-proxy]
                       [--password PASSWORD] [--perfdata-key PERFDATA_KEY]
                       [--state-key STATE_KEY] [--timeout TIMEOUT] [-u URL]
                       [--username USERNAME]

    This check parses a flat json array from a file or url and simply returns the
    message, state and perfdata from the json.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --filename FILENAME   Set the url of the json file. This is mutually
                            exclusive with -u / --url.
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --message-key MESSAGE_KEY
                            Name of the json array key containing the output
                            message. Default: message
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   SMB Password.
      --perfdata-key PERFDATA_KEY
                            Name of the json array key containing the perfdata.
                            Default: perfdata
      --state-key STATE_KEY
                            Name of the json array key containing the state.
                            Default: state
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -u URL, --url URL     Set the url of the json file, either starting with
                            "http://", "https://" or "smb://". This is mutually
                            exclusive with --filename.
      --username USERNAME   SMB Username.


Usage Examples
--------------

.. code-block:: bash

    ./json-values --url=http://example.com/json.out --message-key=output --state-key=state --perfdata-key=perfdata
    ./json-values --filename=/tmp/json.out
    
Output:

.. code-block:: text

    TODO


States
------

* Exits with the state from the json array.


Perfdata / Metrics
------------------

Returns the perfdata from the json array.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
