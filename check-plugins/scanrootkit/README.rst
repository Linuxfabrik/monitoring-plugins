Check scanrootkit
=================

Overview
--------

This monitoring plugin scans for round about 100 rootkits, from "55808 Trojan - Variant A" to "ZK Rootkit". New rootkit definitions can be easily added by dropping a `scanrootkit-<name>` YAML file into the `assets` folder.

Rootkit YAML file structure, example taken from ``assets/scanrootkit-kbeast.yml``:

.. code-block:: yaml

    # human-readable name of the rootkit
    name: 'KBeast Rootkit'
    files:
      # list of files that identify the rootkit
      - '/usr/_h4x_/ipsecs-kbeast-v1.ko'
      - '/usr/_h4x_/_h4x_bd'
      - '/usr/_h4x_/acctlog'
    dirs:
      # list of directories that identify the rootkit
      - '/usr/_h4x_'
    ksyms:
      # list of items in the kernel symbols file that identify the rootkit
      - 'h4x_delete_module'
      - 'h4x_getdents64'
      - 'h4x_kill'
      - 'h4x_open'
      - 'h4x_read'
      - 'h4x_rename'
      - 'h4x_rmdir'
      - 'h4x_tcp4_seq_show'
      - 'h4x_write'

Feel free to add more rootkit definitions by submitting a pull request.

Credits:

* This check plugin is heavily inspired by the `Rootkit Hunter Project <https://rkhunter.sourceforge.net/>`_, which unfortunately seems to be inactive since 2018. :-( Therefore, we have taken all the rkhunter rootkit definitions, translated them to YAML and made them available with this check plugin.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/scanrootkit"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"
    "3rd Party Python modules",             "``pyyaml``"


Help
----

.. code-block:: text

    usage: scanrootkit [-h] [-V] [--severity {warn,crit}]

    This monitoring plugin scans for round about 100 rootkits, from "55808 Trojan
    - Variant A" to "ZK Rootkit". New rootkit definitions can easily be added by
    dropping a `scanrootkit-<name>` YAML file into the `assets` folder.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --severity {warn,crit}
                            Severity for alerts. One of "warn" or "crit". Default:
                            crit


Usage Examples
--------------

.. code-block:: bash

    ./scanrootkit

Output:

.. code-block:: text

    1 rootkit item found. [CRITICAL]
    * CiNIK Worm (Slapper.B variant): /tmp/.cinik (File)


States
------

* WARN or CRIT if rootkit items are found, depending on the severity (default: CRIT)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    rootkit_items,                              Number,             The number of rootkit items found on the system.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits: `Rootkit Hunter Project <https://rkhunter.sourceforge.net/>`_: We took the rootkit definitions and ported them into separate YAML files.
