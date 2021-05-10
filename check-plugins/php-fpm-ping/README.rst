Check "php-fpm-ping"
====================

Overview
--------

This check fetches the ping monitoring page of PHP-FPM. This could be used to test from outside that FPM is alive and responding, to create a graph of FPM availability, or to trigger alerts for the operating team (24/7).

We recommend running this check every minute.


Installation and Usage
----------------------

Requirements:

* Activate the ping page ``/fpm-ping`` in ``/etc/php-fpm.d/<poolname>.conf`` (or similar).
* Configure your webserver to serve this URL, grant access from localhost only.

After that:

.. code-block:: bash

    ./php-fpm-ping
    ./php-fpm-ping --url http://localhost/fpm-ping --response pong --severity crit
    ./php-fpm-ping --help

Output::

    pong


States
------

* WARN or CRIT if output is not identical to ``--response`` (default: "pong"), depending on the given severity (default: WARN)


Perfdata
--------

ping:

* 0 (= STATE_OK) if response is as expected
* 1 (STATE_WARN) or 2 (STATE_CRIT) otherwise


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
