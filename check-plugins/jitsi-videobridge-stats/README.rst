Check jitsi-videobridge-stats
=============================

Overview
--------

Checks the number of participants on a Jitsi Videobridge (v2.1+) and returns a bunch of performance data using the `REST version of the COLIBRI protocol <https://github.com/jitsi/jitsi-videobridge/blob/master/doc/rest-colibri.md>`.

The `statistics <https://github.com/jitsi/jitsi-videobridge/blob/master/doc/statistics.md>`_ are available through the ``/colibri/stats`` endpoint on the *private* REST interface that `must be activated first <https://github.com/jitsi/jitsi-videobridge/blob/master/doc/rest.md>`_.

The check does not convert the ``total`` values into discrete values. Instead, all totals are reported as "continous counters", otherwise the duration of the conferences will not be displayed nicely on the timeline, for example.

For a discussion on how many users Jitsi support see `here1 <https://community.jitsi.org/t/maximum-number-of-participants-on-a-meeting-on-meet-jit-si-server/22273/2>`_, `here2 <https://community.jitsi.org/t/update-on-maximum-number-of-participants-on-jitsi/97695/2>`_ and `here3 <https://meetrix.io/blog/webrtc/jitsi/how-many-users-does-jitsi-support.html>`_ 

Hints:

* DTLS: Datagram Transport Layer Security
* MUC: Multi-User Channel


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/jitsi-videobridge-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: jitsi-videobridge-stats [-h] [-V] [--always-ok] [-c CRIT]
                                   [-p PASSWORD] [--test TEST]
                                   [--timeout TIMEOUT] [--url URL]
                                   [--username USERNAME] [-w WARN]

    Checks the number of participants on a Jitsi Videobridge and reports a bunch
    of performance data.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold for the number of participants.
                            Default: >= 100
      -p PASSWORD, --password PASSWORD
                            Jitsi API password.
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             Jitsi API URL. Default: http://localhost:8080
      --username USERNAME   Jitsi API username. Default: None
      -w WARN, --warning WARN
                            Set the WARN threshold for the number of participants.
                            Default: >= 25


Usage Examples
--------------

.. code-block:: bash

    ./jitsi-videobridge-stats --warning 25 --critical 100

Output:

.. code-block:: text

    2 participants in 1 conference (2 participants in the largest conference), 2 Video Channels, Stress Level 0.00848, 75 JVM threads, 1.4Mbps download, 961.3Kbps upload


States
------

* WARN or CRIT if the current number of participants exceeds the specified thresholds.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    bit_rate_download,                          Bits per Second,    "The total incoming and outgoing (respectively) bitrate for the video bridge in kilobits per second."
    bit_rate_upload,                            Bits per Second,    "The total incoming and outgoing (respectively) bitrate for the video bridge in kilobits per second."
    conferences,                                Number,             "The current number of conferences."
    dtls_failed_endpoints,                      Number,             
    endpoints_sending_audio,                    Number,             
    endpoints_sending_video,                    Number,             
    endpoints_with_high_outgoing_loss,          Number,             
    inactive_conferences,                       Number,             
    inactive_endpoints,                         Number,             
    incoming_loss,                              Number,             
    largest_conference,                         Number,             "The number of participants in the largest conference currently hosted on the bridge."
    local_active_endpoints,                     Number,             
    muc_clients_configured,                     Number,             
    muc_clients_connected,                      Number,             
    mucs_configured,                            Number,             
    mucs_joined,                                Number,             
    outgoing_loss,                              Number,             
    overall_loss,                               Number,             
    p2p_conferences,                            Number,             
    participants,                               Number,             "The current number of participants."
    receive_only_endpoints,                     Number,             
    rtt_aggregate,                              Milliseconds,       "An average value (in milliseconds) of the RTT across all streams."
    stress_level,                               Number,             
    threads,                                    Number,             "The number of Java threads that the video bridge is using."
    videochannels,                              Number,             "The current number of video channels."
    version,                                    Number,             
    total_colibri_web_socket_messages_received, Continous Counter,  "The total number messages received and sent through COLIBRI web sockets."
    total_colibri_web_socket_messages_sent,     Continous Counter,  "The total number messages received and sent through COLIBRI web sockets."
    total_conference_seconds,                   Continous Counter,  "The sum of the lengths of all completed conferences, in seconds."
    total_conferences_created,                  Continous Counter,  "The total number of conferences created on the bridge."
    total_data_channel_messages_received,       Continous Counter,  "The total number messages received and sent through data channels."
    total_data_channel_messages_sent,           Continous Counter,  "The total number messages received and sent through data channels."
    total_dominant_speaker_changes,             Continous Counter,  
    total_failed_conferences,                   Continous Counter,  "The total number of failed conferences on the bridge. A conference is marked as failed when all of its channels have failed. A channel is marked as failed if it had no payload activity."
    total_ice_failed,                           Continous Counter,  
    total_ice_succeeded,                        Continous Counter,  
    total_ice_succeeded_relayed,                Continous Counter,  
    total_ice_succeeded_tcp,                    Continous Counter,  
    total_loss_controlled_participant_seconds,  Continous Counter,  "The total number of participant-seconds that are loss-controlled."
    total_loss_degraded_participant_seconds,    Continous Counter,  "The total number of participant-seconds that are loss-degraded."
    total_loss_limited_participant_seconds,     Continous Counter,  "The total number of participant-seconds that are loss-limited."
    total_partially_failed_conferences,         Continous Counter,  "The total number of partially failed conferences on the bridge. A conference is marked as partially failed when some of its channels has failed. A channel is marked as failed if it had no payload activity."

For details have a look `here <https://github.com/jitsi/jitsi-videobridge/blob/master/doc/statistics.md#implementation>`_.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
