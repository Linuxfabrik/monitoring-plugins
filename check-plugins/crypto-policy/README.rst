Check crypto-policy
===================

Overview
--------

Checks the system's current crypto policy against a desired one, and returns a warning on a non-match. If ``--policy`` is ommited, we suppose crypto policy is ``DEFAULT``.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/crypto-policy"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: crypto-policy [-h] [-V] [--always-ok] [--policy CRYPTO_POLICY]

    Checks the current crypto policy against a desired one, and returns a warning
    on a non-match.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --policy CRYPTO_POLICY
                            The expected crypto policy (full name), for example
                            "FUTURE" (case-insensitive). Default: DEFAULT


Usage Examples
--------------

.. code-block:: bash

    ./crypto-policy --policy FUTURE
    
Output:

.. code-block:: text

    Crypto policy is "DEFAULT" (as expected).


States
------

* WARN if crypto policy is not as expected.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
