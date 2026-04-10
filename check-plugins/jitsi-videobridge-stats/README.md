# Check jitsi-videobridge-stats


## Overview

Monitors Jitsi Videobridge performance via the COLIBRI REST API. Reports conference count, participant count, video channels, bitrates, packet rates, and other bridge metrics.

**Important Notes:**

* Jitsi Videobridge v2.1+
* This check always returns OK. It is designed purely as a metrics collector for graphing dashboards.
* DTLS = Datagram Transport Layer Security, MUC = Multi-User Channel
* For a discussion on how many users Jitsi supports, see [here](https://community.jitsi.org/t/maximum-number-of-participants-on-a-meeting-on-meet-jit-si-server/22273/2) and [here](https://community.jitsi.org/t/update-on-maximum-number-of-participants-on-jitsi/97695/2)

**Data Collection:**

* Queries the `/colibri/stats` endpoint on the Jitsi Videobridge private REST interface
* The [private REST interface must be activated first](https://github.com/jitsi/jitsi-videobridge/blob/master/doc/rest.md)
* All `total_*` values are reported as continuous counters (uom `c`) so that graphing tools like Grafana can display rates over time correctly
* For details on the statistics, see the [Jitsi Videobridge statistics documentation](https://github.com/jitsi/jitsi-videobridge/blob/master/doc/statistics.md)


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/jitsi-videobridge-stats> |
| Nagios/Icinga Check Name              | `check_jitsi_videobridge_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: jitsi-videobridge-stats [-h] [-V] [--always-ok] [--insecure]
                               [--no-proxy] [-p PASSWORD] [--test TEST]
                               [--timeout TIMEOUT] [--url URL]
                               [--username USERNAME]

Monitors Jitsi Videobridge performance via the COLIBRI REST API. Reports
conference count, participant count, video channels, bitrates, packet rates,
and other bridge metrics.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  -p, --password PASSWORD
                        Jitsi API password.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             Jitsi API URL. Default: http://localhost:8080
  --username USERNAME   Jitsi API username. Default: None
```


## Usage Examples

```bash
./jitsi-videobridge-stats
```

Output:

```text
2 total participants, 1 conference, Stress Level 0.00848, 75 JVM threads, 1.4Mbps download, 961.3Kbps upload
```


## States

* Always returns OK.
* `--always-ok` has no additional effect since the check never alerts.


## Perfdata / Metrics

For details see the [Jitsi Videobridge statistics documentation](https://github.com/jitsi/jitsi-videobridge/blob/master/doc/statistics.md).

| Name | Type | Description |
|----|----|----|
| bit_rate_download | Bits per Second | Current incoming bitrate (RTP) in kilobits per second. |
| bit_rate_upload | Bits per Second | Current outgoing bitrate (RTP) in kilobits per second. |
| conferences | Number | Current number of conferences. |
| current_timestamp | Number | UTC time at which the report was generated. |
| dtls_failed_endpoints | Continuous Counter | Total number of endpoints which failed to establish a DTLS connection. |
| endpoints | Number | Current number of endpoints, including octo endpoints. |
| endpoints_sending_audio | Number | Current number of endpoints sending (non-silence) audio. |
| endpoints_sending_video | Number | Current number of endpoints sending video. |
| endpoints_with_spurious_remb | Continuous Counter | Total number of endpoints which sent an RTCP REMB packet when REMB was not signaled. |
| graceful_shutdown | Number | Whether the bridge is in graceful shutdown mode (1 = yes). |
| inactive_conferences | Number | Current number of conferences with no endpoints sending audio or video. |
| inactive_endpoints | Number | Current number of endpoints in inactive conferences. |
| largest_conference | Number | Size of the current largest conference (all endpoints including octo). |
| local_active_endpoints | Number | Current number of local endpoints in an active conference. |
| local_endpoints | Number | Current number of local (non-octo) endpoints. |
| num_eps_oversending | Number | Current number of endpoints to which the bridge is oversending. |
| octo_conferences | Number | Current number of conferences with octo enabled. |
| octo_endpoints | Number | Current number of octo endpoints (connected to remote bridges). |
| octo_receive_bitrate | Number | Current incoming bitrate on the octo channel in bits per second. |
| octo_receive_packet_rate | Number | Current incoming packet rate on the octo channel in packets per second. |
| octo_send_bitrate | Number | Current outgoing bitrate on the octo channel in bits per second. |
| octo_send_packet_rate | Number | Current outgoing packet rate on the octo channel in packets per second. |
| p2p_conferences | Number | Current number of peer-to-peer conferences. |
| packet_rate_download | Number | Current RTP incoming packet rate in packets per second. |
| packet_rate_upload | Number | Current RTP outgoing packet rate in packets per second. |
| preemptive_kfr_sent | Continuous Counter | Total number of preemptive keyframe requests sent. |
| receive_only_endpoints | Number | Current number of endpoints not sending audio or video. |
| rtt_aggregate | Milliseconds | Round-trip time averaged over all local endpoints with a valid RTT measurement. |
| stress_level | Number | Current stress level on the bridge (0 = no load, 1 = full capacity, values > 1 permitted). |
| threads | Number | Current number of JVM threads. |
| total_bytes_received | Continuous Counter | Total number of bytes received in RTP. |
| total_bytes_received_octo | Continuous Counter | Total number of bytes received on the octo channel. |
| total_bytes_sent | Continuous Counter | Total number of bytes sent in RTP. |
| total_bytes_sent_octo | Continuous Counter | Total number of bytes sent on the octo channel. |
| total_colibri_web_socket_messages_received | Continuous Counter | Total number of Colibri bridge channel messages received on a WebSocket. |
| total_colibri_web_socket_messages_sent | Continuous Counter | Total number of Colibri bridge channel messages sent over a WebSocket. |
| total_conference_seconds | Continuous Counter | Total number of conference-seconds served (updates once a conference expires). |
| total_conferences_completed | Continuous Counter | Total number of conferences completed. |
| total_conferences_created | Continuous Counter | Total number of conferences created. |
| total_data_channel_messages_received | Continuous Counter | Total number of Colibri bridge channel messages received on SCTP data channels. |
| total_data_channel_messages_sent | Continuous Counter | Total number of Colibri bridge channel messages sent over SCTP data channels. |
| total_dominant_speaker_changes | Continuous Counter | Total number of times the dominant speaker changed in a conference. |
| total_failed_conferences | Continuous Counter | Total number of conferences in which no endpoint established an ICE connection. |
| total_ice_failed | Continuous Counter | Total number of endpoints which failed to establish an ICE connection. |
| total_ice_succeeded | Continuous Counter | Total number of endpoints which successfully established an ICE connection. |
| total_ice_succeeded_relayed | Continuous Counter | Total number of endpoints which connected through a TURN relay. |
| total_packets_dropped_octo | Continuous Counter | Total number of packets dropped on the octo channel. |
| total_packets_received | Continuous Counter | Total number of RTP packets received. |
| total_packets_received_octo | Continuous Counter | Total number of packets received on the octo channel. |
| total_packets_sent | Continuous Counter | Total number of RTP packets sent. |
| total_packets_sent_octo | Continuous Counter | Total number of packets sent over the octo channel. |
| total_partially_failed_conferences | Continuous Counter | Total number of conferences in which at least one endpoint failed an ICE connection. |
| total_participants | Continuous Counter | Total number of endpoints created. |
| version | Number | The version of jitsi-videobridge as float. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
