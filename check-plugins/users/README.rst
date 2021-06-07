Check users
===========

Overview
--------

Counts how many users are currently logged in, both via tty (on Windows: Console) and pts (on Linux: typically ssh, on Windows: RDP). Also counts the disconnected users on Windows (closed connections without logging out).

Hints:

* A *tty* is a native terminal device, the backend is either hardware or kernel emulated.
* A *pty* (pseudo terminal device) is a terminal device which is emulated by applications such as network login services (ssh, rlogin, telnet), terminal emulators such as xterm, script, screen, tmux, unbuffer, and expect.
* A *pts* is a pseudo terminal slave part of a *pty*.
* If running on hardware, use ``--critical 1,20`` (Linux) and ``--critical 1,50,3`` (Windows).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/users"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``; ``w`` on Linux, ``query users`` on Windows"


Help
----

.. code-block:: text

    usage: users3 [-h] [-V] [-c CRIT] [-w WARN]

    Counts how many users are currently logged in, both via tty (on Windows:
    Console) and pts (on Linux: typically ssh, on Windows: RDP). Also counts the
    disconnected users on Windows (closed connections without logging out).

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -c CRIT, --critical CRIT
                            Set the critical threshold for logged in tty/pts
                            users, in the format "3,10". On Windows, you can
                            additionally set it for disconnected users, in the
                            format "3,10,1". Default: [None, None, None]
      -w WARN, --warning WARN
                            Set the warning threshold for logged in tty/pts users,
                            in the format "1,5". On Windows, you can additionally
                            set it for disconnected users, in the format "1,5,10".
                            Default: [1, 20, 1]


Usage Examples
--------------

.. code-block:: bash

    # on Linux:
    ./users --warning '1, 20' --critical '1, 20'

    # On Windows:
    ./users --warning '1, 20, 1' --critical 'None, 50, 5'

Output:

.. code-block:: text

    TTY: 1 [WARNING], PTS: 0

    USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
    markus.f :0         Mon06   ?xdm?  6:02m  0.03s /usr/libexec/gdm-x-session --run-script /usr/bin/gnome-session


States
------

* WARN or CRIT if number of users is above a given threshold.


Perfdata / Metrics
------------------

* tty: Number of TTY users on Linux, Number of Console users on Windows.
* pty: Number of PTY users on Linux (for example ssh), Number of RDP users on Windows.
* disc: Number of disconnect users (on Windows only).


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
