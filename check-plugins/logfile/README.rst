Check logfile
=============

Overview
--------

Scans a logfile for set of pattern or regex and alerts on the number of findings.

Use ``--warning-pattern`` or ``--warning-regex`` to limit which lines will be considered a warning.
Then use ``-warning`` to set the number of matches that will actually trigger a warning.

The same applies to the ``critical`` counterparts.

* The ``pattern`` arguments are compared using the python ``in`` operator. This is more efficient than using a regex in most cases.
* The ``regex`` arguments are compared using python regex.

With this check, you can acknowledge the warning in IcingaWeb, so that the check changes back to OK. To enable the check plugin to get the ACK status from Icinga and therefore automatically switch to OK, you have to create an Icinga API User like so:

.. code-block:: text

    object ApiUser "linuxfabrik-check-logfile" {
      password = "mysupersecretpassword"
      permissions = [
      {
        permission = "objects/query/service"
        # filter = {{ regex("^linuxfabrik-check-logfile", service.vars.logfile_windows_icinga_username ) }}
      }]
    }

If no ``--icinga-callback`` is used, the check alerts for ``--alarm-duration``.

For more complex use cases, consider using a logging server like graylog.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/logfile"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: logfile [-h] [-V] [--alarm-duration ALARM_DURATION] [--always-ok]
                   [-c CRIT] [--critical-pattern CRIT_PATTERN]
                   [--critical-regex CRIT_REGEX] --filename FILENAME
                   [--icinga-service-name ICINGA_SERVICE_NAME]
                   [--icinga-password ICINGA_PASSWORD] [--icinga-url ICINGA_URL]
                   [--icinga-username ICINGA_USERNAME] [--icinga-callback]
                   [--ignore-pattern IGNORE_PATTERN]
                   [--ignore-regex IGNORE_REGEX] [--suppress-lines] [-w WARN]
                   [--warning-pattern WARN_PATTERN] [--warning-regex WARN_REGEX]

    Scans a logfile for set of pattern or regex and alarms on the number of
    findings.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --alarm-duration ALARM_DURATION
                            How long should this check return an alarm on new
                            matches (in minutes)? This is overwritten by --icinga-
                            callback. Default: 60
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold for the number of found
                            critical matches. Default: 1
      --critical-pattern CRIT_PATTERN
                            Any line containing this pattern will count as a
                            critical.
      --critical-regex CRIT_REGEX
                            Any line matching this python regex will count as a
                            critical.
      --filename FILENAME   Set the path of the logfile.
      --icinga-service-name ICINGA_SERVICE_NAME
                            Unique name of the service using this check within
                            Icinga. Take it from the `__name` service attribute,
                            for example `icinga-server!my-service-name`.
      --icinga-password ICINGA_PASSWORD
                            Icinga API password.
      --icinga-url ICINGA_URL
                            Icinga API URL, for example https://icinga-
                            server:5665.
      --icinga-username ICINGA_USERNAME
                            Icinga API username.
      --icinga-callback     Get the service acknowledgement from Icinga. This
                            overwrites --alarm-duration. Default: False
      --ignore-pattern IGNORE_PATTERN
                            Any line containing this pattern will be ignored.
      --ignore-regex IGNORE_REGEX
                            Any line matching this python regex will be ignored.
      --suppress-lines      Suppress the found lines in the output, only report
                            the number of findings.
      -w WARN, --warning WARN
                            Set the warning threshold for the number of found
                            warning matches. Default: 1
      --warning-pattern WARN_PATTERN
                            Any line containing this pattern will count as a
                            warning.
      --warning-regex WARN_REGEX
                            Any line matching this python regex will count as a
                            warning.


Usage Examples
--------------

.. code-block:: bash

    cat > /tmp/test-logfile << 'EOF'
    test0
    test1
    warning
    test2
    test3
    error1
    error2
    test4
    EOF

    ./logfile --filename=/tmp/test-logfile --critical-pattern='error' --warning-pattern='warn'

Output:

.. code-block:: text

    Scanned 8 lines, 1 warning match, 2 critical matchs

    Warning matches:
    * warning

    Critical matches:
    * error1
    * error2|'scanned_lines'=8;;;; 'warn_matches'=1;1;;; 'crit_matches'=2;1;;;


States
------

* WARN or CRIT if number of users is above a given threshold.


Perfdata / Metrics
------------------

* ``scanned_lines``: Total number of scanned lines in this run.
* ``warn_matches``: Number of warning matches found in those lines.
* ``crit_matches``: Number of critical matches found in those lines.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
