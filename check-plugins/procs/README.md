# Check "procs" - Overview

Checks the number of currently running processes and warns on process counts.

Process State Codes are summarized:

    procstate   shown as/grouped  meaning
    --------------------------------------------------------------------------------------------------
           D    uninterruptible   uninterruptible sleep (usually IO)
           R    running           running or runnable (on run queue)
           I    sleeping          idle kernel thread
           S    sleeping          interruptible sleep (waiting for an event to complete)
           T    stopped           stopped by job control signal
           t    stopped           stopped by debugger during the tracing
           W    paging            paging (not valid since the 2.6.xx kernel)
           X    dead              dead (should never be seen)
           Z    zombies           defunct ("zombie") process, terminated but not reaped by its parent

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* `ps`

```bash
./procs --no-kthreads --always-ok
./procs --warning 2:100 --critical 1:150 --command httpd
./procs --help
```


# States

* WARN or CRIT if process count is above a given threshold.


# Perfdata

* `procs`: Total number of processes.
* `procs_sleeping`
* `procs_running`
* `procs_uninterruptible`
* `procs_zombies`
* `procs_stopped`
* `procs_paging`
* `procs_dead`


# Example Output

    352 tasks, 3 zombies (1x virt-manager, 1x firefox, 1x Privileged Cont), 349 sleeping|'procs'=352;;;0; 'procs_sleeping'=349;;;0; 'procs_running'=3;;;0; 'procs_uninterruptible'=0;;;0; 'procs_zombies'=0;;;0; 'procs_stopped'=0;;;0; 'procs_dead'=0;;;0;


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
