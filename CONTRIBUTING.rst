Linuxfabrik's Check Plugin Developer Guidelines
===============================================

Monitoring of an Application
----------------------------

Monitoring an application can be complex and produce a wide variety of data. In order to standardize the handling of threshold values on the command line, to reduce the number of command line parameters and their interdependencies and to enable independent and thus extended designs of the Grafana panels, each topic should be dealt with in a separate check (following the Linux mantra: "one tool, one task").

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

    git clone git@github.com:Linuxfabrik/lib.git
    git clone git@github.com:Linuxfabrik/monitoring-plugins.git


Deliverables
------------

* The plugin itself.
* A nice 16x16 transparent PNG icon, for example based on font-awesome (not in Git, will be put for download on https://download.linuxfabrik.ch).
* README file explaining "How?" and Why?"
* LICENSE file
* if Windows: see `Compiling for Windows <#compiling-for-windows>`_
* optional: ``test`` - the unittest file (see `Unit Tests <#unit-tests>`_)
* optional: Grafana panel (see `Grafana Dashboards <#grafana-dashboards>`_)
* optional: Icinga Director Basket Config
* optional: Icinga Web 2 Grafana Module .ini file
* optional: sudoers file (see `sudoers File <#sudoers-file>`_)


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
* Use RFC `5737 <https://datatracker.ietf.org/doc/html/rfc5737>`_, `3849 <https://datatracker.ietf.org/doc/html/rfc3849>`_, `7042 <https://datatracker.ietf.org/doc/html/rfc7042#section-2.1.1>`_ and `2606 <https://datatracker.ietf.org/doc/html/rfc2606>`_ in examples / documentation:

    * IPv4 Addresses: ``192.0.2.0/24``, ``198.51.100.0/24``, ``203.0.113.0/24``
    * IPv6 Addresses: ``2001:DB8::/32``
    * MAC Addresses: ``00-00-5E-00-53-00 through 00-00-5E-00-53-FF`` (unicast), ``01-00-5E-90-10-00 through 01-00-5E-90-10-FF`` (multicast)
    * Domains: ``*.example``, ``example.com``


Bytes vs. Unicode
-----------------

Short:

* Use ``txt3.to_text()`` and ``txt3.to_bytes()``.

The theory:

* Data coming into your plugins must be bytes, encoded with ``UTF-8``.
* Decode incoming bytes as soon as possible (best within the libraries), producing unicode.
* **Use unicode throughout your plugin.**
* When outputting data, use library functions, they should do output conversions for you. Library functions like ``base.oao`` or ``url.fetch_json`` will take care of the conversion to and from bytes.

See https://nedbatchelder.com/text/unipain.html for details.


Names, Naming Conventions, Parameters, Option Processing
--------------------------------------------------------

The plugin name should match the following regex: ``^[a-zA-Z0-9\-\_]*$``. This allows the plugin name to be used as the grafana dashboard uid (according to `here <https://github.com/grafana/grafana/blob/552ecfeda320a422bfc7ca9978c94ffea887134a/pkg/util/shortid_generator.go#L11>`_).

There are a few Nagios-compatible reserved options that should not be used for other purposes:

.. code-block:: text

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

For all other options, use long parameters only. Separate words using a ``-``. We recommend using some of those:

.. code-block:: text

    --activestate
    --alarm-duration
    --always-ok
    --argument
    --authtype
    --cache-expire
    --command
    --community
    --config
    --count
    --critical
    --critical-count
    --critical-cpu
    --critical-maxchildren
    --critical-mem
    --critical-pattern
    --critical-regex
    --critical-slowreq
    --database
    --datasource
    --date
    --device
    --donor
    --filename
    --filter
    --full
    --hide-ok
    --hostname
    --icinga-callback
    --icinga-password
    --icinga-service-name
    --icinga-url
    --icinga-username
    --idsite
    --ignore
    --ignore-pattern
    --ignore-regex
    --input
    --insecure
    --instance
    --interface
    --interval
    --ipv6
    --key
    --latest
    --lengthy
    --loadstate
    --message
    --message-key
    --metric
    --mib
    --mibdir
    --mode
    --module
    --mount
    --no-kthreads
    --no-proxy
    --no-summary
    --node
    --only-dirs
    --only-files
    --password
    --path
    --pattern
    --perfdata
    --perfdata-key
    --period
    --port
    --portname
    --prefix
    --privlevel
    --response
    --service
    --severity
    --snmp-version
    --starttype
    --state
    --state-key
    --status
    --substate
    --suppress-lines
    --task
    --team
    --test
    --timeout
    --timerange
    --token
    --trigger
    --type
    --unit
    --unitfilestate
    --url
    --username
    --version
    --virtualenv
    --warning
    --warning-count
    --warning-cpu
    --warning-maxchildren
    --warning-mem
    --warning-pattern
    --warning-regex
    --warning-slowreq

`Parameter types <https://docs.python.org/3/library/argparse.html>`_ are usually:

* ``type=float``
* ``type=int``
* ``type=lib.args3.csv``
* ``type=lib.args3.float_or_none``
* ``type=lib.args3.int_or_none``
* ``type=str`` (the default)
* ``choices=['udp', 'udp6', 'tcp', 'tcp6']``
* ``action='store_true'``, ``action='store_false'`` for switches

Hints:

* For complex parameter tupels, use the ``csv`` type.
  ``--input='Name, Value, Warn, Crit'`` results in ``[ 'Name', 'Value', 'Warn', 'Crit' ]``
* For repeating parameters, use the ``append`` action. A ``default`` variable has to be a list then. ``--input=a --input=b`` results in ``[ 'a', 'b' ]``
* If you combine ``csv`` type and ``append`` action, you get a two-dimensional list: ``--repeating-csv='1, 2, 3' --repeating-csv='a, b, c'`` results in ``[['1', '2', '3'], ['a', 'b', 'c']]``
* If you want to provide default values together with ``append``, in ``parser.add_argument()``, leave the ``default`` as ``None``. If after ``main:parse_args()`` the value is still ``None``, put the desired default list (or any other object) there. The primary purpose of the parser is to parse the commandline - to figure out what the user wants to tell you. There's nothing wrong with tweaking (and checking) the ``args`` Namespace after parsing. (According to https://bugs.python.org/issue16399)


Git Commits
-----------

* Commit messages must start with "plugin-name: " and clearly and precisely state what has changed. Example: ``about-me: Should be able to run even if psutil is or cannot be installed``.
* If there is an issue, the commit message must consist of the issue title followed by "(fix #issueno)", for example: ``about-me: Add OpenVPN (fix #341)``.
* For the first commit, use the message ``Add <plugin-name>``.


Threshold and Ranges
--------------------

If a threshold has to be handled as a range parameter, this is how to interpret them. Pretty much the same as stated in the `Nagios Development Guidelines <http://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT>`_.

* simple value: a range from 0 up to and including the value
* empty value after ``:``: positive infinity
* ``~``: negative infinity
* ``@``: if range starts with "@", then alert if inside this range (including endpoints)

Examples:

.. csv-table:: 
    :header-rows: 1

    "-w, -c",     OK if result is    ,   WARN/CRIT if      
    10      ,     in (0..10)         ,   not in (0..10)    
    -10     ,     in (-10..0)        ,   not in (-10..0)   
    10:     ,     in (10..inf)       ,   not in (10..inf)  
    :       ,     in (0..inf)        ,   not in (0..inf)   
    ~:10    ,     in (-inf..10)      ,   not in (-inf..10) 
    10:20   ,     in (10..20)        ,   not in (10..20)   
    @10:20  ,     not in (10..20)    ,   in 10..20         
    @~:20   ,     not in (-inf..20)  ,   in (-inf..20)     
    @       ,     not in (0..inf)    ,   in (0..inf)       

So, a definition like ``--warning 2:100 --critical 1:150`` should return the states:

.. code-block:: text

    val   0   1   2 .. 100 101 .. 150 151
    -w   WA  WA  OK     OK  WA     WA  WA
    -c   CR  OK  OK     OK  OK     OK  CR
    =>   CR  WA  OK     OK  WA     WA  CR

Another example: ``--warning 190: --critical 200:``

.. code-block:: text

    val 189 190 191 .. 199 200 201
    -w   WA  OK  OK     OK  OK  OK
    -c   CR  CR  CR     CR  OK  OK
    =>   CR  CR  CR     CR  OK  OK

Another example: ``--warning ~:0 --critical 10``

.. code-block:: text

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
* Print "[WARNING]" or "[CRITICAL]" for clarification next to a specific item using ``lib.base3.state2str()``.
* If possible give a help text to solve the problem.
* Multiple items checked, and ...

    * ... everything ok? Print "Everything is ok." or the most important output in the first line, and optional the items and their data attached in multiple lines.
    * ... there are warnings or errors? Print "There are warnings." or "There are errors." or the most important output in the first line, and optional the items and their data attached in multiple lines.

* Based on parameters etc. nothing is checked at the end? Print "Nothing checked."
* Wrong username or password? Print "Failed to authenticate."

* Use short "Units of Measurements" without white spaces, including these terms:

    * Bits: use ``base.bits2human()``
    * Bytes: use ``base.bytes2human()``
    * I/O and Throughput: ``base.bytes2human() + '/s'`` (Byte per Second)
    * Network: "Rx/s", "Tx/s", use ``base.bps2human()``
    * Numbers: use ``base.number2human()``
    * Percentage: 93.2%
    * Read/Write: "R/s", "W/s", "IO/s"
    * Seconds, Minutes etc.: use ``base.seconds2human()``
    * Temperatures: 7.3C, 45F.

* Use ISO format for date or datetime ("yyyy-mm-dd", "yyyy-mm-dd hh:mm:ss")
* Print human readable datetimes and time periods ("Up 3d 4h", "2019-12-31 23:59:59", "1.5s")


Plugin Performance Data, Perfdata
---------------------------------

"UOM" means "Unit of Measurement".

Sample:

.. code-block:: text

    'label'=value[UOM];[warn];[crit];[min];[max];

``label``  doesn't need to be machine friendly, so ``Pages scanned=100;;;;;`` is as valuable as ``pages-scanned=100;;;;;``.


Suffixes:

.. code-block:: text

    no unit specified - assume a number (int or float) of things (eg, users, processes, load averages)
    s - seconds (also us, ms etc.)
    % - percentage
    B - bytes (also KB, MB, TB etc.). Bytes preferred, they are exact.
    c - a continous counter (such as bytes transmitted on an interface [so instead of 'B'])

Wherever possible, prefer percentages over absolute values to assist users in comparing different systems with different absolute sizes.


PEP8 Style Guide for Python Code
--------------------------------

We use `PEP 8 -- Style Guide for Python Code <https://www.python.org/dev/peps/pep-0008/>`_ (where it makes sense).


docstring, pydoc
----------------

We document our `Libraries <https://git.linuxfabrik.ch/linuxfabrik/lib>`_ using docstrings, so that calling ``pydoc lib/base.py`` works, for example.


PyLint
------

To further improve code quality, we use `PyLint <https://www.pylint.org/>`_ like so:

* Libs: ``pylint mylib.py``
* Monitoring Plugins: ``pylint --disable='invalid-name, missing-function-docstring, missing-module-docstring' plugin-name``

Have a look at `PyLint's message codes <http://pylint-messages.wikidot.com/all-codes>`_.


isort
-----

To help sort the ``import``-statements we use ``isort``:

.. code:: bash

    # to sort all imports
    isort --recursive .

    # sort in a single plugin
    isort plugin-name


Unit Tests
----------

Implementing tests:

* | Use the ``unittest`` framework (`https://docs.python.org/2.7/library/unittest.html <https://docs.python.org/2.7/library/unittest.html>`_).
  | Within your ``test`` file, call the plugin as a bash command, capture stdout, stderr and its return code (retc), and run your assertions
   against stdout, stderr and retc.
* To test a plugin that needs to run some tools that aren't on your machine or that can't provide special output, provide stdout/stderr files in ``examples`` and a ``--test`` parameter to feed "example/stdout-file,expected-stderr,expected-retc" into your plugin.  If you get the ``--test`` parameter, skip the execution of your bash/psutil/whatever function.

For example, have a look at the ``fs-ro`` plugin on how to do this.

Running a complete unit test:

.. code:: bash

    # cd into the plugin directory and run the Python 3 based test:
    ./test3


sudoers File
------------

If the plugin requires ``sudo``-permissions to run, please add the plugin to the ``sudoers``-files for all supported operating systems in ``assets/sudoers/``. The OS name should match the ansible variables ``ansible_facts['distribution'] + ansible_facts['distribution_major_version']`` (eg ``CentOS7``). Use symbolic links to prevent duplicate files.

.. attention::

    The newline at the end is required!


Compiling for Windows
---------------------

To allow running the check plugins under Windows without installing Python, compile the check plugins using `nuitka <https://nuitka.net/>`_. For this, you need a Windows Machine with Python 3 and Nutika installed (see the `official installation guide <https://nuitka.net/doc/user-manual.html#installation>`_, we recommend using ``pip`` for its simplicity).

Use the `Linuxfabrik lfops monitoring-plugins role <https://github.com/Linuxfabrik/lfops/tree/main/roles/monitoring_plugins>`_:

.. code-block:: bash

   ansible-playbook --inventory inventory linuxfabrik.lfops.monitoring_plugins --tags monitoring_plugins,monitoring_plugins:nuitka_compile --extra-vars 'monitoring_plugins__windows_variant=python monitoring_plugins__repo_version=main' --limit windows-machine

To let the Ansible role know which check-plugin to compile for Windows, create an empty `.windows` file in the check-plugin folder.

Then copy ``C:\\nuitka-compile-temp`` to a Linux Machine and zip it:

.. code-block:: bash

    cd /path/to/nuitka-compile-temp
    mkdir output
    for dir in */; do
        echo $dir
        file=$(basename $dir | sed 's/.dist//')
        cp -rv $dir* output
    done

    cd output
    zip -r ../monitoring-plugins.zip .

Rename the ``monitoring-plugins.zip`` to the correct version.


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

Afterwards generate the dashboards for each plugin using the
``grafana-tool``:

.. code:: bash

    ./tools/grafana-tool assets/grafana/all-panels-external.json --auto --filename-postfix '.grafana-external' --generate-icingaweb2-ini

Make sure to adjust the generated ini file if necessary.


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

    ./tools/grafana-tool assets/grafana/all-panels-provisioning.json --auto --filename-postfix '.grafana-provisioning' --generate-icingaweb2-ini

Make sure to adjust the generated ini file if necessary.


Icinga Director Basket Config
-----------------------------

Each plugin should provide its required Director config in form of a Director basket. The basket usually contains at least one Command, one Service Template and some associated Datafields. The rest of the Icinga Director configuration (Host Templates, Service Sets, Notification Templates, Tag Lists, etc) can be placed in the ``assets/icingaweb2-module-director/all-the-rest.json`` file.

The Icinga Director Basket for one or all plugins can be created using the ``check2basket`` tool. Note that the tool can only create baskets of Python 3 plugins.

.. important:

    **Always review the basket before committing.**


Create a Basket File from Scratch
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After writing a new check called ``new-check``, generate a basket file using:

.. code-block::

    ./tools/check2basket --plugin-file check-plugins/new-check/new-check3

The basket will be saved as ``check-plugins/new-check/icingaweb2-module-director/new-check.json``. Inspect the basket, paying special attention to:

* Command: ``timeout``
* ServiceTemplate: ``check_interval``
* ServiceTemplate: ``enable_notifications``
* ServiceTemplate: ``enable_perfdata``
* ServiceTemplate: ``max_check_attempts``
* ServiceTemplate: ``retry_interval``


Fine-tune a Basket File
~~~~~~~~~~~~~~~~~~~~~~~

**Never directly edit a basket.** If adjustments must be made to the basket, create a YML/YAML config file for ``check2basket``.

For example, to set the timeout to 30s, to enable notifications and some other options, the config in ``check-plugins/new-check/icingaweb2-module-director/new-check.yml`` should look as follows:

.. code-block:: yml

    ---
    variants:
      - linux

    overwrites:
      '["Command"]["cmd-check-new-check"]["command"]': '/usr/bin/sudo /usr/lib64/nagios/plugins/new-check'
      '["Command"]["cmd-check-new-check"]["timeout"]': 30
      '["ServiceTemplate"]["tpl-service-new-check"]["check_command"]': 'cmd-check-new-check-sudo'
      '["ServiceTemplate"]["tpl-service-new-check"]["check_interval"]': 3600
      '["ServiceTemplate"]["tpl-service-new-check"]["enable_notifications"]': true
      '["ServiceTemplate"]["tpl-service-new-check"]["enable_perfdata"]': true
      '["ServiceTemplate"]["tpl-service-new-check"]["max_check_attempts"]': 5
      '["ServiceTemplate"]["tpl-service-new-check"]["retry_interval"]': 30
      '["ServiceTemplate"]["tpl-service-new-check"]["use_agent"]': false

Then, re-run ``check2basket`` to apply the overwrites:

.. code-block::

    ./tools/check2basket --plugin-file check-plugins/new-check/new-check3

If a parameter was added, changed or deleted in the plugin, simply re-run the ``check2basket`` to update the basket file.


Basket File for different OS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``check2basket`` tool also offers to generate so-called ``variants`` of the checks (different flavours of the check command call to run on different operating systems):

* ``linux``: This is the default, and will be used if no other variant is defined. It generates a ``cmd-check-...``, ``tpl-service-...`` and the associated datafields.
* ``windows``: Generates a ``cmd-check-...-windows``, ``cmd-check-...-windows-python``, ``tpl-service-...-windows`` and the associated datafields.
* ``sudo``: Generates a ``cmd-check-...-sudo`` importing the ``cmd-check-...``, but with ``/usr/bin/sudo`` prepended to the command, and a ``tpl-service...-sudo`` importing the ``tpl-service...``, but with the ``cmd-check-...-sudo`` as the check command.
* ``no-agent``: Generates a ``tpl-service...-no-agent`` importing the ``tpl-service...``, but with command endpoint set to the Icinga2 master.

Specify them in the ``check-plugins/new-check/icingaweb2-module-director/new-check.yml`` configuration as follows:

.. code-block:: yml

    ---
    variants:
      - linux
      - sudo
      - windows
      - no-agent


Create Basket Files for all Check Plugins
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To run ``check2basket`` against all checks, for example due to a change in the ``check2basket`` script itself, use:

.. code-block:: bash

    ./tools/check2basket --auto


Service Sets
~~~~~~~~~~~~

If you want to create a Service Set, edit ``assets/icingaweb2-module-director/all-the-rest.json`` and append the definition using JSON. Provide new unique GUIDs. Do a syntax check using ``cat assets/icingaweb2-module-director/all-the-rest.json | jq`` afterwards.



Virtual Environments
--------------------

To allow the check plugins to activate a virtual environment as described in the README, place this at the top of the check plugin (do not forget to adjust it to the python version):

.. code-block:: python

    import os

    # considering a virtual environment
    ACTIVATE_THIS = False
    venv_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'monitoring-plugins-venv3')
    if os.path.exists(venv_path):
        ACTIVATE_THIS = os.path.join(venv_path, 'bin/activate_this.py')

    if os.getenv('MONITORING_PLUGINS_VENV3'):
        ACTIVATE_THIS = os.path.join(os.getenv('MONITORING_PLUGINS_VENV3') + 'bin/activate_this.py')

    if ACTIVATE_THIS and os.path.isfile(ACTIVATE_THIS):
        exec(open(ACTIVATE_THIS).read(), {'__file__': ACTIVATE_THIS}) # pylint: disable=W0122

