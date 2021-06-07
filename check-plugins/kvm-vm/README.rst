Check kvm-vm
============

Overview
--------

Check VMs on a KVM host using ``virsh list``. Needs sudo.

The state field lists what state each domain (a VM) is currently in. A domain can be in one of the following possible states:

* | ``running``
  | The domain is currently running on a CPU.

* | ``idle``
  | The domain is idle, and not running or runnable. This can be caused because the domain is waiting on IO (a traditional wait state) or has gone to sleep because there was nothing else for it to do.

* | ``paused``
  | The domain has been paused, usually occurring through the administrator running ``virsh suspend``.  When in a paused state the domain will still consume allocated resources like memory, but will not be eligible for scheduling by the hypervisor.

* | ``in shutdown``
  | The domain is in the process of shutting down, i.e. the guest operating system has been notified and should be in the process of stopping its operations gracefully.

* | ``shut off``
  | The domain is not running.  Usually this indicates the domain has been shut down completely, or has not been started.

* | ``crashed``
  | The domain has crashed, which is always a violent ending. Usually this state can only occur if the domain has been configured not to "restart on crash" (in the guest OS).

* | ``pmsuspended``
  | The domain has been suspended by guest power management, e.g. entered into s3 state.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/kvm-vm"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2"
    "Requirements",                         "command-line tool ``virsh``"


Help
----

.. code-block:: text

    usage: kvm-vm [-h] [-V] [--always-ok]

    Check VMs on a KVM host using "virsh list".

    optional arguments:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.


Usage Examples
--------------

.. code-block:: bash

    ./kvm-vm
    
Output:

.. code-block:: text

    VMs: 1 running, 15 shut_off


States
------

* CRIT if any VM is crashed.
* WARN if any VM is in state idle, paused or pmsuspended.
* Otherwise OK (even if no VM is running at all).


Perfdata / Metrics
------------------

* vm_running
* vm_idle
* vm_paused
* vm_in_shutdown
* vm_shut_off
* vm_crashed
* vm_pmsuspended


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
