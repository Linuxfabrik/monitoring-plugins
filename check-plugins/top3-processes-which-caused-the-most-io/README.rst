Check top3-processes-which-caused-the-most-io
=============================================

Overview
--------

Displays the top 3 processes which cause the most IO.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/top3-processes-which-caused-the-most-io"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: top3-processes-which-caused-the-most-io [-h] [-V]

    Displays the top 3 processes which cause the most IO.

    optional arguments:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./top3-processes-which-caused-the-most-io
    
Output:

.. code-block:: text

    1. systemd: 37.5GiB/24.2GiB (r/w), 2. firefox: 2.4GiB/11.4GiB (r/w), 3. nextcloud: 1.3GiB/5.4GiB (r/w)


States
------

* Always returns OK.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
* Credits: `psutil Documentation <https://psutil.readthedocs.io/en/release-5.3.0/>`_
