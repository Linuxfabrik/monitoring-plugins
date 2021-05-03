Check "example"
===============

Overview
--------

A working Linuxfabrik monitoring plugin, written in Python 2 and Python 3, as a basis / showcase for
further development.


Installation and Usage
----------------------

.. code-block:: bash

    ./example
    ./example --warning 80 --critical 90 --always-ok
    ./example --help

Output::

    84% used [WARNING]|'usage_percent'=84%;80;90;0;100


States
------

* WARN on usage > 80%
* CRIT on usage > 90%


Perfdata
--------

* usage_percent: Usage in percent


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
