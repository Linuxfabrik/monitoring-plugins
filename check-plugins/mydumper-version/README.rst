Check "mydumper-version"
========================

Overview
--------

This plugin lets you track whether a mydumper update is available. To check for updates, this plugin uses the Git Repo at https://github.com/maxbube/mydumper/releases. In order to compare with the current/installed version of mydumper/myloader, the check must run ``mydumper``.

We recommend to run this check once a day.

The check uses a sqlite database to cache the query result.


Installation and Usage
----------------------

.. code-block:: bash

    ./mydumper-version
    ./mydumper-version --cache-expire 8 --always-ok
    ./mydumper-version --help


States
------

* If wanted, always returns OK,
* else returns WARN if update is available.


Perfdata
--------

* mydumper-version: Float


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.

