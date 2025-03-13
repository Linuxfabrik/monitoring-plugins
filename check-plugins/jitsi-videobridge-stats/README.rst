Check jitsi-videobridge-stats
=============================

Overview
--------

Returns a bunch of performance data on a Jitsi Videobridge (v2.1+) using the `REST version of the COLIBRI protocol <https://github.com/jitsi/jitsi-videobridge/blob/master/doc/rest-colibri.md>`_.

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

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/jitsi-videobridge-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: jitsi-videobridge-stats [-h] [-V] [--always-ok] [--insecure]
                                   [--no-proxy] [-p PASSWORD] [--test TEST]
                                   [--timeout TIMEOUT] [--url URL]
                                   [--username USERNAME]

    Returns a bunch of performance data on a Jitsi Videobridge using the REST
    version of the COLIBRI protocol.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      -p, --password PASSWORD
                            Jitsi API password.
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             Jitsi API URL. Default: http://localhost:8080
      --username USERNAME   Jitsi API username. Default: None


Usage Examples
--------------

.. code-block:: bash

    ./jitsi-videobridge-stats

Output:

.. code-block:: text

    2 total participants, 1 conference, Stress Level 0.00848, 75 JVM threads, 1.4Mbps download, 961.3Kbps upload


States
------

* Always returns OK.


Perfdata / Metrics
------------------

For details have a look `here <https://github.com/jitsi/jitsi-videobridge/blob/master/doc/statistics.md>`_ (not all make sense in PerfData).

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,   Description

    bit_rate_download,                          Bits per Second, "the current incoming bitrate (RTP) in kilobits per second."
    bit_rate_upload,                            Bits per Second, "the current outgoing bitrate (RTP) in kilobits per second."
    conferences,                                Number, "The current number of conferences."
    current_timestamp,                          Number, "the UTC time at which the report was generated."
    dtls_failed_endpoints,                      Continous Counter, "the total number of endpoints which failed to establish a DTLS connection."
    endpoints_sending_audio,                    Number, "current number of endpoints sending (non-silence) audio."
    endpoints_sending_video,                    Number, "current number of endpoints sending video."
    endpoints_with_spurious_remb,               Continous Counter, "total number of endpoints which have sent an RTCP REMB packet when REMB was not signaled."
    endpoints,                                  Number, "the current number of endpoints, including `octo` endpoints."
    graceful_shutdown,                          Number, "whether jitsi-videobridge is currently in graceful shutdown mode (hosting existing conferences, but not accepting new ones)."
    inactive_conferences,                       Number, "current number of conferences in which no endpoints are sending audio nor video. Note that this includes conferences which are currently using a peer-to-peer transport."
    inactive_endpoints,                         Number, "current number of endpoints in inactive conferences (see `inactive_conferences`)."
    largest_conference,                         Number, "the size of the current largest conference (counting all endpoints, including `octo` endpoints which are connected to a different jitsi-videobridge instance)"
    local_active_endpoints,                     Number, "the current number of local endpoints (not `octo`) which are in an active conference. This includes endpoints which are not sending audio or video, but are in an active conference (i.e. they are receive-only)."
    local_endpoints,                            Number, "the current number of local (non-`octo`) endpoints."
    num_eps_oversending,                        Number, "current number of endpoints to which we are oversending."
    octo_conferences,                           Number, "current number of conferences in which `octo` is enabled."
    octo_endpoints,                             Number, "current number of `octo` endpoints (connected to remove jitsi-videobridge instances)."
    octo_receive_bitrate,                       Number, "current incoming bitrate on the `octo` channel (combined for all conferences) in bits per second."
    octo_receive_packet_rate,                   Number, "current incoming packet rate on the `octo` channel (combined for all conferences) in packets per second."
    octo_send_bitrate,                          Number, "current outgoing bitrate on the `octo` channel (combined for all conferences) in bits per second."
    octo_send_packet_rate,                      Number, "current outgoing packet rate on the `octo` channel (combined for all conferences) in packets per second."
    p2p_conferences,                            Number, "current number of peer-to-peer conferences. These are conferences of size 2 in which no endpoint is sending audio not video. Presumably the endpoints are using a peer-to-peer transport at this time."
    packet_rate_download,                       Number, "current RTP incoming packet rate in packets per second."
    packet_rate_upload,                         Number, "current RTP outgoing packet rate in packets per second."
    preemptive_kfr_sent,                        Continous Counter, "total number of preemptive keyframe requests sent."
    receive_only_endpoints,                     Number, "current number of endpoints which are not sending audio nor video."
    rtt_aggregate,                              Milliseconds, "round-trip-time measured via RTCP averaged over all local endpoints with a valid RTT measurement in milliseconds."
    stress_level,                               Number, "current stress level on the bridge, with 0 indicating no load and 1 indicating the load is at full capacity (though values >1 are permitted)."
    threads,                                    Number, "current number of JVM threads."
    total_bytes_received_octo,                  Continous Counter, "total number of bytes received on the `octo` channel."
    total_bytes_received,                       Continous Counter, "total number of bytes received in RTP."
    total_bytes_sent_octo,                      Continous Counter, "total number of bytes sent on the `octo` channel."
    total_bytes_sent,                           Continous Counter, "total number of bytes sent in RTP."
    total_colibri_web_socket_messages_received, Continous Counter, "total number of messages received on a Colibri "bridge channel" messages received on a WebSocket."
    total_colibri_web_socket_messages_sent,     Continous Counter, "total number of messages sent over a Colibri "bridge channel" messages sent over a WebSocket."
    total_conference_seconds,                   Continous Counter, "total number of conference-seconds served (only updates once a conference expires)."
    total_conferences_completed,                Continous Counter, "total number of conferences completed."
    total_conferences_created,                  Continous Counter, "total number of conferences created."
    total_data_channel_messages_received,       Continous Counter, "total number of Colibri 'bridge channel' messages received on SCTP data channels."
    total_data_channel_messages_sent,           Continous Counter, "total number of Colibri 'bridge channel' messages sent over SCTP data channels."
    total_dominant_speaker_changes,             Continous Counter, "total number of times the dominant speaker in a conference changed."
    total_failed_conferences,                   Continous Counter, "total number of conferences in which no endpoints succeeded to establish an ICE connection."
    total_ice_failed,                           Continous Counter, "total number of endpoints which failed to establish an ICE connection."
    total_ice_succeeded_relayed,                Continous Counter, "total number of endpoints which connected through a TURN relay (currently broken)."
    total_ice_succeeded,                        Continous Counter, "total number of endpoints which successfully established an ICE connection."
    total_packets_dropped_octo,                 Continous Counter, "total number of packets dropped on the `octo` channel."
    total_packets_received_octo,                Continous Counter, "total number packets received on the `octo` channel."
    total_packets_received,                     Continous Counter, "total number of RTP packets received."
    total_packets_sent_octo,                    Continous Counter, "total number packets sent over the `octo` channel."
    total_packets_sent,                         Continous Counter, "total number of RTP packets sent."
    total_partially_failed_conferences,         Continous Counter, "total number of conferences in which at least one endpoint failed to establish an ICE connection."
    total_participants,                         Continous Counter, "total number of endpoints created."
    version,                                    Number, "the version of jitsi-videobridge."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
