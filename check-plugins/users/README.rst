Check "users"
=============

Overview
--------

Counts how many users are currently logged in, both via tty (on Windows: Console) and pts (on Linux: typically ssh, on Windows: RDP). Also counts the disconnected users on Windows (closed connections without logging out).

Linux Know-How:

* A *tty* is a native terminal device, the backend is either hardware or kernel emulated.
* A *pty* (pseudo terminal device) is a terminal device which is emulated by applications such as network login services (ssh, rlogin, telnet), terminal emulators such as xterm, script, screen, tmux, unbuffer, and expect.
* A *pts* is a psuedo terminal slave part of a *pty*.

We recommend to run this check every minute, and use ``--critical 1,20`` (Linux) and ``--critical 1,50,3`` (Windows) if running on hardware.


Installation and Usage
----------------------

Requirements:

* ``w`` on Linux
* ``query users`` on Windows

.. code-block:: bash

    ./users
    ./users --help

    # on Linux:
    ./users --warning '1, 20' --critical '1, 20'

    # On Windows:
    ./users --warning '1, 20, 1' --critical 'None, 50, 5'

Output (Linux)::

    TTY: 1 [WARNING], PTS: 0

    12:08:59 up 1 day,  5:18,  1 user,  load average: 2.18, 1.64, 1.33
    USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
    markus.f :0        Mon06   ?xdm?   6:02m  0.03s /usr/libexec/gdm-x-session --run-script /usr/bin/gnome-session|'tty'=1;1;;0; 'pts'=0;50;;0;


States
------

* WARN or CRIT if number of users is above a given threshold.


Perfdata
--------

* tty: Number of TTY users on Linux, Number of Console users on Windows.
* pty: Number of PTY users on Linux (for example ssh), Number of RDP users on Windows.
* disc: Number of disconnect users (on Windows only).


Credits, License
----------------

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.