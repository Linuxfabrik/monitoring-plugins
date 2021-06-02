Check ntp-offset
================

Overview
--------

This plugin checks the clock offset in milliseconds compared to ntp servers.

If ``ntpd`` is used, prints
* address of the remote peer
* reference ID (0.0.0.0 if this is unknown)
* stratum of the remote peer
* type of the peer (local, unicast, multicast or broadcast)
* when the last packet was received
* polling interval in seconds
* reachability register in octal
* and the current estimated delay, offset and dispersion of the peer

If ``chronyd`` is used, prints
* reference id
* stratum
* ref time (utc)
* system time
* last offset
* rms offset
* frequency
* residual freq
* skew
* root delay
* root dispersion
* update interval
* leap status

If ``systemd-timesyncd`` is used and ``systemd`` v239 or higher is available, prints
* server
* poll interval
* leap
* version
* stratum
* reference
* precision
* root distance
* offset
* delay
* jitter
* packet count
* frequency


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/ntp-offset"
    "Check Interval Recommendation",        "Once a minute"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, command-line tool ``ntpq``, ``chronyc`` or ``sytemd-timesyncd``"
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

    ./ntp-offset
    ./ntp-offset --warning 500 --critical 1000
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT if ntp offset is above a given threshold.


Perfdata / Metrics
------------------

* Time Offset (Milliseconds)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
