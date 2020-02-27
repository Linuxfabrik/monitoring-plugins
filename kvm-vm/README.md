# Overview

We recommend to run this check every 15 minutes.

The State field lists what state each domain is currently in. A domain
can be in one of the following possible states:


- ``running``

  The domain is currently running on a CPU

- ``idle``

  The domain is idle, and not running or runnable.  This can be caused
  because the domain is waiting on IO (a traditional wait state) or has
  gone to sleep because there was nothing else for it to do.

- ``paused``

  The domain has been paused, usually occurring through the administrator
  running ``virsh suspend``.  When in a paused state the domain will still
  consume allocated resources like memory, but will not be eligible for
  scheduling by the hypervisor.

- ``in shutdown``

  The domain is in the process of shutting down, i.e. the guest operating system
  has been notified and should be in the process of stopping its operations
  gracefully.

- ``shut off``

  The domain is not running.  Usually this indicates the domain has been
  shut down completely, or has not been started.

- ``crashed``

  The domain has crashed, which is always a violent ending.  Usually
  this state can only occur if the domain has been configured not to
  "restart on crash" (in the guest OS).

- ``pmsuspended``

  The domain has been suspended by guest power management, e.g. entered
  into s3 state.


# Installation and Usage

```bash
./0-example --help
```


# States and Perfdata


# Known Issues and Limitations


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
