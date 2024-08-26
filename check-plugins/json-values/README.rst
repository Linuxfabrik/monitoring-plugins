Check json-values
=================

Overview
--------

This check parses a flat json array from a file or url and simply returns the message, state and perfdata from the json.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/json-values"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``PySmbClient``, ``smbprotocol``"


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

    options:
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

    ./json-values --url=http://example.com/example.json --message-key=message --state-key=state --perfdata-key=perfdata

    cat > /tmp/example.json2 << 'EOF'
    {
        "state": 2,
        "message": "This is a test message",
        "perfdata": "'cpu-usage'=5.6%;80;90;0;100"
    }
    EOF
    ./json-values --filename=/tmp/example.json

Output:

.. code-block:: text

    This is a test message|'cpu-usage'=5.6%;80;90;0;100


States
------

* Exits with the state from the json array.


Perfdata / Metrics
------------------

Returns the perfdata from the json array.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
