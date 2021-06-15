Check dummy
===========

Overview
--------

This check just returns the given message, state and perfdata. It comes in handy when trying to pass Icinga DSL to the dummy command via the Icinga Director, as this is not currently possible with the Icinga built-in dummy command.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/dummy"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: dummy [-h] [--always-ok] [-V] [--message MESSAGE]
                 [--state {ok,warn,crit,unk}] [--perfdata PERFDATA]

    This check just returns the given message, state and perfdata.

    optional arguments:
      -h, --help            show this help message and exit
      --always-ok           Always returns OK.
      -V, --version         show program's version number and exit
      --message MESSAGE     The message to return.
      --state {ok,warn,crit,unk}
                            The state to return (ok, warn, crit, unk).
      --perfdata PERFDATA   The perfdata to return, formatted according to the
                            nagios guidelines.


Usage Examples
--------------

.. code-block:: bash

    ./dummy --state crit --message 'Lorem ipsum'
    
Output:

.. code-block:: text

    Lorem ipsum


States
------

* Given state, or UNKNOWN if none is given


Perfdata / Metrics
------------------

* Given perfdata, or none


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
