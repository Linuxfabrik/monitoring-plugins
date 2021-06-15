Check dmesg
===========

Overview
--------

Checks the Kernel Ring Buffer for emerg, alert, crit and err messages using ``dmesg``, and if the parameter ``--severity`` has not been ommitted, always returns CRIT if something is found.

Some very common dmesg messages are ignored, for example ``Assuming drive cache: write through`` (should be a debug message) or ``ioctl error in smb2_get_dfs_refer rc=-5`` (a bug as stated in https://access.redhat.com/solutions/3496971).

Be aware that the reported timestamps could be inaccurate. The time source used for dmesg is not updated after system SUSPEND/RESUME. Timestamps are adjusted according to current delta between boottime and monotonic clocks, this works only for messages printed after last resume.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/dmesg"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: dmesg [-h] [-V] [--always-ok] [--severity {warn,crit}] [--test TEST]

    Checks dmesg for emerg, alert, crit and err messages. Executes `dmesg
    --level=emerg,alert,crit,err --ctime `. If you fixed the issues (or just want
    to clear them), use `dmesg --clear` to clear the Kernel Ring Buffer Messages.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --severity {warn,crit}
                            Severity for alerting. One of "warn" or "crit".
                            Default: crit
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./dmesg 
    
Output:

.. code-block:: text

    5 errors in Kernel Ring Buffer.

    [Mon May 31 18:27:14 2021] x86/cpu: SGX disabled by BIOS
    [Sat Jun  5 18:49:50 2021] ACPI Error: Thread 2495397888 cannot release Mutex [ECMX] acquired by thread 1817575424 (20210105/exmutex-378)
    [Sat Jun  5 18:49:50 2021] ACPI Error: Aborting method \_SB.PCI0.LPCB.ECDV._Q66 due to previous error (AE_AML_NOT_OWNER) (20210105/psparse-529)
    [Tue Jun  8 18:54:41 2021] usb usb2-port1: Cannot enable. Maybe the USB cable is bad?
    [Tue Jun  8 18:54:41 2021] usb usb2-port1: unable to enumerate USB device


States
------

* CRIT or state given by ``--severity`` if any of emerg, alert, crit and err messages in dmesg are found.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
