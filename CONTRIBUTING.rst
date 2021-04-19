Linuxfabrik's Check Plugin Developer Guidelines
===============================================

Monitoring of an Application 
----------------------------

Monitoring an application can be complex and produce a wide variety of data. In order to standardize the handling of threshold values on the command line, to reduce the number of command line parameters and their interdependencies and to enable independent and thus extended designs of the Grafana panels, each topic should be dealt with in a separate check.

Avoid an extensive check that covers a wide variety of aspects:

* ``myapp --action threading --warning 1500 --critical 2000``
* ``myapp --action memory-usage --warning 80 --critical 90``
* ``myapp --action deployment-status`` (warning and critical command line options not supported)

Better write three separate checks:

* ``myapp-threading --warning 1500 --critical 2000``
* ``myapp-memory-usage --warning 80 --critical 90`` 
* ``myapp-deployment-status``


Setting up your development environment
---------------------------------------

Simply clone the libraries and monitoring plugins:

.. code:: bash

    git clone https://git.linuxfabrik.ch/linuxfabrik/lib
    git clone https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins
    cd monitoring-plugins


Deliverables
------------

* The plugin itself.
* A nice 16x16 transparent PNG icon, for example based on font-awesome.
* README file explaining "How?" and Why?"
* LICENSE file
* optional: Grafana panel (see `Grafana Dashboards <#grafana-dashboards>`_)
* optional: Icinga Director Basket Config
* optional: Icinga Web 2 Grafana Module .ini file
* optional: sudoers file (see `sudoers File <#sudoers-file>`_)
* optional: ``test`` - the unittest file (see `Unit Tests <#unit-tests>`_)


Rules of Thumb
--------------

* The plugin should be "self configuring" and/or using best practise defaults, so that it runs without parameters wherever possible.
* Develop with a minimal Linux in mind.
* Develop with Icinga2 in mind.
* Avoid complicated or fancy (and therefore unreadable) Python statements.
* Comments and output should be in English only.
* If possible avoid libraries that have to be installed.
* Validate user input.
* It is not needed to execute system (shell/bash) commands by specifying their full path.
* It is ok to use temp files if needed.
* Much better: use a local SQLite database if you want to use a temp file.
* Keep in mind: Plugins have a limited runtime - typically 10 seconds max. Therefore it is great if the plugin executes fast and uses less resources (CPU time, memory etc.).
* Timeout gracefully on errors (for example ``df`` on a failed network drive) and return WARN.
* Return UNKNOWN on missing dependencies or wrong parameters.
* Mainly return WARN. Only return CRIT if the operators want to or have to wake up at night. CRIT means "react immediately".
* EAFP: Easier to ask for forgiveness than permission. This common Python coding style assumes the existence of valid keys or attributes and catches exceptions if the assumption proves false. This clean and fast style is characterized by the presence of many try and except statements.


Names, Naming Conventions, Parameters, Option Processing
--------------------------------------------------------

There are a few Nagios-compatible reserved options that should not be used for other purposes:

::

    -a, --authentication    authentication password
    -C, --community         SNMP community
    -c, --critical          critical threshold
    -h, --help              help
    -H, --hostname          hostname
    -l, --logname           login name
    -p, --password          password
    -p, --port              network port
    -t, --timeout           timeout
    -u, --url               URL
    -u, --username          username
    -V, --version           version
    -v, --verbose           verbose
    -w, --warning           warning threshold

For all other options, use long parameters only. We recommend using some of those:

::

    --activestate
    --action
    --always-ok
    --cache-expire
    --channel
    --command
    --count
    --database
    --depth
    --device
    --filename
    --filter
    --full
    --hide-ok
    --ignore
    --input
    --insecure
    --interface
    --interval
    --key
    --loadstate
    --metric
    --mode
    --mount
    --no-kthreads
    --no-proxy
    --no-summary
    --node
    --path
    --portname
    --prefix
    --severity
    --state
    --substate
    --test
    --timespan
    --trigger
    --type
    --unit
    --unitfilestate
    --username

`Parameter types <https://docs.python.org/3/library/argparse.html>`_ are usually:

* type=float
* type=int
* type=lib.args3.csv
* type=lib.args3.float_or_none
* type=lib.args3.int_or_none
* type=str (the default)
* choices=['udp', 'udp6', 'tcp', 'tcp6']
* action='store_true', action='store_false' for switches

Hints:

* For complex parameter tupels, use the ``csv`` type.
  ``--input='Name, Value, Warn, Crit'`` results in ``[ 'Name', 'Value', 'Warn', 'Crit' ]``
* For repeating parameters, use the ``append`` action. A ``default`` variable has to be a list then. ``--input=a --input=b`` results in ``[ 'a', 'b' ]``
* If you combine ``csv`` type and ``append`` action, you get a two-dimensional list: ``--repeating-csv='1, 2, 3' --repeating-csv='a, b, c'`` results in
  ``[['1', '2', '3'], ['a', 'b', 'c']]``


Threshold and Ranges
--------------------

If a threshold has to be handled as a range parameter, this is how to interpret them. Pretty much the same as stated in the `Nagios Development Guidelines <http://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT>`_.

* simple value: a range from 0 up to and including the value
* ``:``: describes a range
* empty value before or after ``:``: positive infinity
* ``~``: negative infinity
* ``@``: if range starts with "@", then alert if inside this range (including endpoints)

+--------+-------------------+-------------------+--------------------------------+
| -w, -c | OK if result is   | WARN/CRIT if      | lib.base.parse_range() returns |
+--------+-------------------+-------------------+--------------------------------+
| 10     | in (0..10)        | not in (0..10)    | (0, 10, False)                 |
+--------+-------------------+-------------------+--------------------------------+
| -10    | in (-10..0)       | not in (-10..0)   | (0, -10, False)                |
+--------+-------------------+-------------------+--------------------------------+
| 10:    | in (10..inf)      | not in (10..inf)  | (10, inf, False)               |
+--------+-------------------+-------------------+--------------------------------+
| :      | in (0..inf)       | not in (0..inf)   | (0, inf, False)                |
+--------+-------------------+-------------------+--------------------------------+
| ~:10   | in (-inf..10)     | not in (-inf..10) | (-inf, 10, False)              |
+--------+-------------------+-------------------+--------------------------------+
| 10:20  | in (10..20)       | not in (10..20)   | (10, 20, False)                |
+--------+-------------------+-------------------+--------------------------------+
| @10:20 | not in (10..20)   | in 10..20         | (10, 20, True)                 |
+--------+-------------------+-------------------+--------------------------------+
| @~:20  | not in (-inf..20) | in (-inf..20)     | (-inf, 20, True)               |
+--------+-------------------+-------------------+--------------------------------+
| @      | not in (0..inf)   | in (0..inf)       | (0, inf, True)                 |
+--------+-------------------+-------------------+--------------------------------+

So, a definition like ``--warning 2:100 --critical 1:150`` should return the states:

::

    val   0   1   2 .. 100 101 .. 150 151
    -w   WA  WA  OK     OK  WA     WA  WA
    -c   CR  OK  OK     OK  OK     OK  CR
    =>   CR  WA  OK     OK  WA     WA  CR

Another example: ``--warning 190: --critical 200:``

::

    val 189 190 191 .. 199 200 201
    -w   WA  OK  OK     OK  OK  OK
    -c   CR  CR  CR     CR  OK  OK
    =>   CR  CR  CR     CR  OK  OK

Another example: ``--warning ~:0 --critical 10``

::

    val  -2  -1   0   1 ..   910  11
    -w   OK  OK  OK  WA     WA  WA  WA
    -c   CR  CR  OK  OK     OK  OK  CR
    =>   CR  CR  OK  WA     WA  WA  CR

Have a look at ``procs`` on how to implement this.


Caching temporary data, SQLite database
---------------------------------------

Use ``cache`` if you need a simple key-value store, for example as used in ``nextcloud-version``. Otherwise, use ``db_sqlite`` as used in ``cpu-usage``.


Error Handling
--------------

* Catch exceptions using ``try``/``except``, especially in functions.
* In functions, if you have to catch exceptions, on such an exception always return ``(False, errormessage)``. Otherwise return ``(True, result)`` if the function succeeds in any way. For example, returning ``(True, False)`` means that the function has not raised an exception and its result is simply ``False``.
* A function calling a function with such an extended error handling has to return a ``(retc, result)`` tuple itself.
* In ``main()`` you can use ``lib.base.coe()`` to simplify error handling.
* Have a look at ``nextcloud-version`` for details.


Plugin Output
-------------

* Print a short concise message in the first line within the first 80 chars if possible.
* Use multi-line output for details (``msg_body``), with the most important output in the first line (``msg_header``).
* Don't print "OK".
* Print "(WARN)" or "(CRIT)" for clarification next to a specific item.
* If possible give a help text to solve the problem.
* Multiple items checked, and ...

  * ... everything ok? Print "Everything is ok." or the most important output in the first line, and optional the items and their data attached in multiple lines.
  * ... there are warnings or errors? Print "There are warnings." or "There are errors." or the most important output in the first line, and optional the items and their data attached in multiple lines.

* Use short "Units of Measurements" without white spaces:

  * Percentage: 93.2%
  * Bytes: 7B, 3.4K, M, G, T
  * Temperatures: 7.3C, 45F
  * Network: "Rx/s", "Tx/s", 17.4Mbps (Megabit per Second)
  * I/O and Throughput: 220.4MB/s (Megabyte per Second)
  * Read/Write: "R/s", "W/s", "IO/s"

* Use ISO format for date or datetime ("yyyy-mm-dd", "yyyy-mm-dd hh:mm:ss")
* Print human readable datetimes and time periods ("Up 3d 4h", "2019-12-31 23:59:59", "1.5s")


Plugin Performance Data, Perfdata
---------------------------------

"UOM" means "Unit of Measurement".

Sample::

    'label'=value[UOM];[warn];[crit];[min];[max];

``label``  doesn't need to be machine friendly, so ``Pages scanned=100;;;;;`` is as valuable as ``pages-scanned=100;;;;;``.


Suffixes::

    no unit specified - assume a number (int or float) of things (eg, users, processes, load averages)
    s - seconds (also us, ms)
    % - percentage
    B - bytes (also KB, MB, TB)
    c - a continous counter (such as bytes transmitted on an interface)

Wherever possible, prefer percentages over absolute values to assist users in comparing different systems with different absolute sizes.


PEP8 Style Guide for Python Code
--------------------------------

We recently started to use `PEP 8 -- Style Guide for Python Code <https://www.python.org/dev/peps/pep-0008/>`_.


docstring, pydoc
----------------

Not long ago we started to document our `Libraries <https://git.linuxfabrik.ch/linuxfabrik/lib>`_ using docstrings, so that calling ``pydoc lib/base.py`` works, for example.


Pylint
------

To further improve code quality, we recently started using `Pylint <https://www.pylint.org/>`_ with pure ``pylint`` for the libraries, and with ``pylint --disable=C0103,C0114,C0116`` for the plugins, on a more regular basis. The parameter disables warnings for

* non-conformance to snake_case naming style
* missing module docstring
* missing function or method docstring


isort
-----

To help sort the ``import``-statements we use ``isort``:

.. code:: bash

    # to sort all imports
    isort --recursive .

    # sort in a single plugin
    isort plugin_name


Unit Tests
----------

Implementing tests:

* | Use the ``unittest`` framework (`https://docs.python.org/2.7/library/unittest.html <https://docs.python.org/2.7/library/unittest.html>`_).
  | Within your ``test`` file, call the plugin as a bash command, capture stdout, stderr and its return code (retc), and run your assertions
   against stdout, stderr and retc.
* To test a plugin that needs to run some tools that aren't on your machine or that can't provide special output, provide stdout/stderr files in ``examples`` and a ``--test`` parameter to feed "example/stdout-file,expected-stderr,expected-retc" into your plugin.  If you get the ``--test`` parameter, skip the execution of your bash/psutil/whatever function.

Have a look at the ``fs-ro`` plugin on how to do this.

Running a complete unit test:

.. code:: bash

    # cd into the plugin directory and run:
    ./test


sudoers File
------------

If the plugin requires ``sudo``-permissions to run, please add the plugin to the ``sudoers``-files for all supported operating systems in ``assets/sudoers/``. The OS name should match the ansible variables ``ansible_facts['distribution'] + ansible_facts['distribution_major_version']`` (eg ``CentOS7``).

.. attention::

    The newline at the end is required!


Grafana Dashboards
------------------

Each Grafana panel should be meaningful, especially when comparing it to other related panels (eg memory usage and CPU usage). When sensible, there should be an additional panel with min, max, mean and last columns. This can be achieved my setting the visualization to table and using the transform > reduce functions. This is preferred to using the legend options, because they change the width of the graph, making it harder to correlate events across panels. Unfortunately, it is currently impossible to set the unit per row, so you need to make on additional panel for each unit.

When modifying existing panels or creating new panels, always work with the 'all-panel' dashboard (from ``assets/grafana/``). The title of the panels should be capitalized, the metrics should be lowercase. Be sure to create a new row named after the plugin. This field will be used for the automatic splitting into smaller dashboards later on. Therefore, the name has to match the folder/plugin name (spaces will be replaced with ``-``, ``/`` will be ignored. eg ``Network I/O`` will become ``network-io``).

As there are two options to import the Grafana dashboards (either importing via the WebGUI or provisioning, see the README for details), the Grafana dashboard also need to be exported twice.

Always make sure that there is no sensitive data in the export (eg. hostnames).


Exporting for later import via the WebGUI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Make sure all rows are collapsed
* Share dashboard (Icon right of the dashboard title)
* Export
* Export for sharing externally: yes
* Save to file: all-panels-external.json


Exporting for provisioning
~~~~~~~~~~~~~~~~~~~~~~~~~~

* Make sure all rows are collapsed
* Share dashboard (Icon right of the dashboard title)
* Export
* Export for sharing externally: no
* Save to file: all-panels-provisioning.json

Afterwards generate the dashboards for each plugin using the
``grafana-tool``:

.. code:: bash

    ./tools/grafana-tool assets/grafana/all-panels-external.json --auto --filename-postfix '.grafana-external' --generate-icingaweb2-ini
    ./tools/grafana-tool assets/grafana/all-panels-provisioning.json --auto --filename-postfix '.grafana-provisioning' --generate-icingaweb2-ini

Make sure to adjust the generated ini file if necessary.


Virtual Environments
--------------------

To allow the check plugins to activate a virtual environment as described in the README, place this at the top of the check plugin (do not forget to adjust it to the python version):

.. code-block:: python
    :caption: Example for Python 3

    import os

    activate_this = False
    venv_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'monitoring-plugins-venv3')
    if os.path.exists(venv_path):
        activate_this = os.path.join(venv_path, 'bin/activate_this.py')

    if os.getenv('MONITORING_PLUGINS_VENV3'):
        activate_this = os.path.join(os.getenv('MONITORING_PLUGINS_VENV3') + 'bin/activate_this.py')

    if activate_this and os.path.isfile(activate_this):
        exec(open(activate_this).read(), {'__file__': activate_this})
