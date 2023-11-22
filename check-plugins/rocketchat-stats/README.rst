Check rocketchat-stats
=======================

Overview
--------

This plugin lets you track statistics about a Rocket.Chat server.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rocketchat-stats"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "Requires a user with strong password and 'view-statistics' permission (only)."


Help
----

.. code-block:: text

    usage: rocketchat-stats [-h] [-V] -p PASSWORD [--url URL] --username USERNAME

    This plugin allows you to track statistics about a Rocket.Chat server,
    structured in the same way as on the https://rocket.chat/admin/info page.
    Requires a user with a strong password and (only) "view-statistics"
    permission.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -p PASSWORD, --password PASSWORD
                            Rocket.Chat API password.
      --url URL             Rocket.Chat API URL. Default:
                            http://localhost:3000/api/v1
      --username USERNAME   Rocket.Chat API username. Default: rocket-stats



Usage Examples
--------------

.. code-block:: bash

    ./rocketchat-stats --username rocket-stats --password linuxfabrik --url http://rocket.chat:3000/api/v1
    
Output:

.. code-block:: text

    8/325 users online, 295.2K msgs, 6.3K uploads, 4.3GiB upload total size, v6.4.7
    * Users: 325 total, 8 online, 0 busy, 1 away, 316 offline
    * Types and Distribution: 9 connected, 223 activated users, 0 activated guests, 100 deactivated users, 2 Rocket.Chat app users
    * Total Uploads: 6285, 4.3GiB size
    * Total Rooms: 672 rooms, 1 channel, 96 private groups, 440 direct msg rooms, 0 discussions, 135 omnichannel rooms
    * Total Messages: 295.2K, 829 threads, 5 in channels, 178.3K in priv groups, 115.0K in direct msg, 1.9K in omnichannel


States
------

* Always returns OK.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    rc_activeGuests,                            Number,             Types and Distribution: Activated Guests
    rc_activeUsers,                             Number,             Types and Distribution: Activated Users
    rc_appUsers,                                Number,             Types and Distribution: Rocket.Chat App Users
    rc_awayUsers,                               Number,             Users: Away
    rc_busyUsers,                               Number,             Users: Busy
    rc_nonActiveUsers,                          Number,             Types and Distribution: Deactivated Users
    rc_offlineUsers,                            Number,             Users: Offline
    rc_onlineUsers,                             Number,             Users: Online
    rc_totalChannelMessages,                    Number,             Total Messages: Messages in Channels
    rc_totalChannels,                           Number,             Total Rooms: Channels
    rc_totalConnectedUsers,                     Number,             Types and Distribution: Connected
    rc_totalDirect,                             Number,             Total Rooms: Direct Message Rooms
    rc_totalDirectMessages,                     Number,             Total Messages: Messages in Direct Messages
    rc_totalDiscussions,                        Number,             Total Rooms: Discussions
    rc_totalLivechat,                           Number,             Total Rooms: Omnichannel Rooms
    rc_totalLivechatMessages,                   Number,             Total Messages: Messages in Omnichannel
    rc_totalMessages,                           Number,             Total Messages: Messages
    rc_totalPrivateGroupMessages,               Number,             Total Messages: Messages in Private Groups
    rc_totalPrivateGroups,                      Number,             Total Rooms: Private Groups
    rc_totalRooms,                              Number,             Total Rooms: Rooms
    rc_totalThreads,                            Number,             Total Messages: Threads
    rc_totalUsers,                              Number,             Users: Total
    rc_uploadsTotal,                            Number,             Uploads: Total Uploads
    rc_uploadsTotalSize,                        Bytes,              Uploads: Total Upload Size


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
