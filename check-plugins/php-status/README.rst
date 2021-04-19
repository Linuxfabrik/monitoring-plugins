Check "php-status"
==================

Overview
--------

This plugin checks for PHP startup errors using ``php --version``, missing modules using ``php --modules`` or misconfigured directives using ``php --info``.

We recommend to run this check every 8 hours.


Installation and Usage
----------------------

.. code-block:: bash

    ./php-status
    ./php-status --config date.timezone=Europe/Zurich --config memory_limit=256M --module mbstring --module GD


States
------

* If wanted, always returns OK,
* else return WARN on startup errors,
* and/or returns WARN if php.ini config does not match the given configs,
* and/or returns WARN if a desired module is missing


Perfdata
--------

* php-config-errors: 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT
* php-module-errors: 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT
* php-startup-errors: 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.

