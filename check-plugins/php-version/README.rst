Check "php-version"
===================

Overview
--------

This plugin lets you track if a PHP update is available. To check for updates, this plugin uses https://www.php.net/releases/index.php. To compare against the current/installed version of PHP, the check calls ``php --version``.

We recommend to run this check once a day.

The check uses a sqlite database to cache its query result.


Installation and Usage
----------------------

.. code-block:: bash

    ./php-version


States
------

* If wanted, always returns OK,
* else returns WARN if update is available.


Perfdata
--------

* php-version: as a float. "7.4.16" becomes "7.416".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.

