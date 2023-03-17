Check journald-query
====================

Overview
--------

Query the systemd journal and alert on any events found. For help on any of the journalctl-specific parameters, have a look at ``man journalctl``.

How to use the check:

* The idea is to always look for the *bad* entries in the journal. Define a journalctl query that returns results only for error cases, and also only for a specific application, for example.
* The check takes a number of the parameters known from ``journalctl``. These can be fed with the same values as in the original. For details see the man page of ``journalctl``.
* So feed the parameters you used to filter your messages with ``journalctl`` to this check. As soon as results are returned, the check plugin alerts with the desired severity.
* If no ``--priority`` is given, the check uses the range ``--priority=emerg..err``.
* If no unit or user unit is specified, the check looks for errors in the units present on the most common Linux systems, which are thus found after a fresh installation. To get an idea of which services are handled, have a look at the source code (search for ``units = [``).

Hint:

* If the initial execution of the check takes more than 10 seconds, the journal is probably too large (which can be checked with the plugin `journal-usage <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/journald-usage>`_). In this case it is recommended to "vacuum" the journal first.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/journald-query"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: journald-query [-h] [-V] [--always-ok] [--facility FACILITY]
                          [--identifier IDENTIFIER]
                          [--ignore-pattern IGNORE_PATTERN]
                          [--ignore-regex IGNORE_REGEX] [--priority PRIORITY]
                          [--severity {warn,crit}] [--since SINCE] [--test TEST]
                          [--unit UNIT] [--user-unit USER_UNIT]

    Query the systemd journal and alert on any events found. Only logs for the
    current boot will be shown. For help on any of the journalctl-specific
    parameters, see `man journalctl`.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --facility FACILITY   journalctl: Filter output by syslog facility. Takes a
                            comma-separated list of numbers or facility names.
                            Default: None
      --identifier IDENTIFIER
                            journalctl: Show messages for the specified syslog
                            identifier. Default: None
      --ignore-pattern IGNORE_PATTERN
                            Any line containing this pattern on the MESSAGE field
                            will be ignored (must be lowercase; repeating).', So,
                            unlike `journalctl`, you can easily use strings to
                            ignore certain messages.
      --ignore-regex IGNORE_REGEX
                            Any line matching this Python regex on the MESSAGE
                            field will be ignored (must be lowercase; repeating).
                            So, unlike `journalctl`, you can easily use regular
                            expressions to ignore certain messages.
      --priority PRIORITY   journalctl: Filter output by message priorities or
                            priority ranges. Default: emerg..err
      --severity {warn,crit}
                            Severity for alerts if journalctl returns results. One
                            of "warn" or "crit". Default: warn
      --since SINCE         journalctl: Start showing entries on or newer than the
                            specified date. Default: >= -24h
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --unit UNIT           journalctl: Show messages for the specified systemd
                            unit UNIT|PATTERN. This parameter can be specified
                            multiple times. Default: None
      --user-unit USER_UNIT
                            journalctl: Show messages for the specified user
                            session unit. This parameter can be specified multiple
                            times.


Usage Examples
--------------

Simple call that checks the most common system services for errors of any kind:

.. code-block:: bash

    ./journald-query

Output:

.. code-block:: text

    27 events. Latest event at 2022-07-28 15:08:04 from systemd-resolved, level err: `Failed to send hostname reply: Transport endpoint is not connected` [WARNING]. 
    Attention: Table below is shortened and just shows the 5 newest and the 5 oldest messages.

    Timestamp           ! Unit             ! Prio ! Message                                                                                                                                   
    --------------------+------------------+------+-------------------------------------------------------------------------------------------------------------------------------------------
    2022-07-28 15:08:04 ! systemd-resolved ! err  ! Failed to send hostname reply: Transport endpoint is not connected                                                                        
    2022-07-28 09:27:03 ! dnf-makecache    ! err  ! Failed to start dnf makecache.                                                                                                            
    2022-07-28 09:10:55 ! session-c1.scope ! err  ! GLib-GObject: g_object_unref: assertion 'G_IS_OBJECT (object)' failed                                                                     
    2022-07-28 09:10:51 ! user@1000        ! err  ! Failed to start Application launched by gnome-session-binary.                                                                             
    2022-07-28 09:10:51 ! user@1000        ! err  ! Failed to start Application launched by gnome-session-binary.                                                                             
    2022-07-27 20:36:52 ! user@1000        ! err  ! Ignoring duplicate name 'org.freedesktop.FileManager1' in service file '/usr/share//dbus-1/services/org.freedesktop.FileManager1.service' 
    2022-07-27 20:36:36 ! user@1000        ! err  ! Ignoring duplicate name 'org.freedesktop.FileManager1' in service file '/usr/share//dbus-1/services/org.freedesktop.FileManager1.service' 
    2022-07-27 20:36:36 ! user@1000        ! err  ! Ignoring duplicate name 'org.freedesktop.FileManager1' in service file '/usr/share//dbus-1/services/org.freedesktop.FileManager1.service' 
    2022-07-27 20:36:34 ! user@1000        ! err  ! Ignoring duplicate name 'org.freedesktop.FileManager1' in service file '/usr/share//dbus-1/services/org.freedesktop.FileManager1.service' 
    2022-07-27 20:36:34 ! user@1000        ! err  ! Ignoring duplicate name 'org.freedesktop.FileManager1' in service file '/usr/share//dbus-1/services/org.freedesktop.FileManager1.service' 

    Use `journalctl --reverse --priority=emerg..err --since=-24h` as a starting point for debugging. Be aware of the fact that you might see even more messages then, as we apply a lot of unit filters to only get messages from basic system services.
    The full command used was:
    journalctl --reverse --priority=emerg..err --since=-24h --quiet --output=json --unit="accounts-daemon.service" --unit="acpid.service" --unit="apparmor.service" --unit="apport.service" --unit="auditd.service" --unit="cron.service" --unit="crond.service" --unit="dbus.service" --unit="dracut-*.service" --unit="haveged.service" --unit="ifplugd.service" --unit="ifup@*.service" --unit="init.scope" --unit="irqbalance.service" --unit="iscsid.service" --unit="lvm2-*.service" --unit="lxcfs.service" --unit="mdadm.service" --unit="network.service" --unit="NetworkManager*.service" --unit="open-iscsi.service" --unit="polkit.service" --unit="polkitd.service" --unit="qemu-guest-agent.service" --unit="rsyslog.service" --unit="session-*.scope" --unit="snapd*.service" --unit="ssh.service" --unit="sshd*.service" --unit="sssd.service" --unit="sysstat.service" --unit="systemd-*.service" --unit="user@*.service"

Explicitly search for error messages in the Apache httpd unit only:

.. code-block:: bash

    # --ignore parameter value must be lowercase
    ./journald-query --unit=httpd --priority=emerg..err --severity=crit --ignore-regex='mod_qos.*: access denied, invalid request line'

Output:

.. code-block:: text

    994 events. Latest event at 2022-07-28 18:00:04 from httpd, level err: `[proxy_fcgi:error] [pid 896:tid 929] [client 127.0.0.1:50256] AH01071: Got error 'Primary script unknown'` [CRITICAL].
    Attention: Table below is shortened and just shows the 5 newest and the 5 oldest messages.

    Timestamp           ! Unit  ! Prio ! Message                                                                                                   
    --------------------+-------+------+-----------------------------------------------------------------------------------------------------------
    2022-07-28 18:00:04 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 929] [client 127.0.0.1:50256] AH01071: Got error 'Primary script unknown' 
    2022-07-28 17:59:55 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 927] [client 127.0.0.1:57732] AH01071: Got error 'Primary script unknown' 
    2022-07-28 17:59:04 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 945] [client 127.0.0.1:53908] AH01071: Got error 'Primary script unknown' 
    2022-07-28 17:58:55 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 943] [client 127.0.0.1:56074] AH01071: Got error 'Primary script unknown' 
    2022-07-28 17:58:04 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 936] [client 127.0.0.1:44684] AH01071: Got error 'Primary script unknown' 
    2022-07-28 09:45:55 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 947] [client 127.0.0.1:52536] AH01071: Got error 'Primary script unknown' 
    2022-07-28 09:45:04 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 940] [client 127.0.0.1:53256] AH01071: Got error 'Primary script unknown' 
    2022-07-28 09:44:55 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 938] [client 127.0.0.1:44544] AH01071: Got error 'Primary script unknown' 
    2022-07-28 09:44:04 ! httpd ! err  ! [proxy_fcgi:error] [pid 897:tid 904] [client 127.0.0.1:40142] AH01071: Got error 'Primary script unknown' 
    2022-07-28 09:43:55 ! httpd ! err  ! [proxy_fcgi:error] [pid 896:tid 931] [client 127.0.0.1:34050] AH01071: Got error 'Primary script unknown' 

    The full command used was:
    journalctl --reverse --priority=emerg..err --since=-24h --quiet --output=json --unit="httpd.service"


States
------

* Depending on the given ``--severity``, returns WARN (default) or CRIT if any entries are found.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    journald-query,                             Continous Counter,  Number of events found in journald


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
