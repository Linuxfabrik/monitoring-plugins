# Overview

Checks the number of currently running processes and warns on process counts or zombie process states. Only zombies that last longer than 24 hours result in a WARN, otherwise you might get flapping results, for example on a heavy-duty Apache webserver.

Why does the check most of the time shows "1 running (ps)"?

This is due to the fact that the check calls `ps` with some parameters to fetch the current process list. In other words, `ps` is in state `R` ("running") while fetching the process list.  Like `top` we take this into account and do not ignore its own call.

Process State Codes:

    procstate   shown as          meaning
    --------------------------------------------------------------------------------------------------
           D    uninterruptible   uninterruptible sleep (usually IO)
           I    sleeping          idle kernel thread
           R    running           running or runnable (on run queue)
           S    sleeping          interruptible sleep (waiting for an event to complete)
           T    stopped           stopped by job control signal
           t    stopped           stopped by debugger during the tracing
           W    paging            paging (not valid since the 2.6.xx kernel)
           X    dead              dead (should never be seen)
           Z    zombies           defunct ("zombie") process, terminated but not reaped by its parent

We recommend to run this check every minute.


# Installation and Usage

```bash
./procs
./procs --warning 250 --critical 500
./procs --help
```


# States and Perfdata

* WARN if there is at least one zombie process "living" for more than 24 hours. 
* WARN or CRIT if process count is above a given threshold.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.