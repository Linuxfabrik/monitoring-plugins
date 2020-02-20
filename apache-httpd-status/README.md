Tested with Apache/2.4.6 (CentOS). Have a look at https://httpd.apache.org/docs/2.4/mod/mod_status.html

* workers_closing: "C" Closing connection
* workers_dns: "D" DNS Lookup
* workers_finishing: "G" Gracefully finishing
* workers_idle: "I" Idle cleanup of worker
* workers_keepalive: "K" Keepalive (read)
* workers_logging: "L" Logging
* workers_open: "." Open slot with no current process
* workers_reading: "R" Reading Request
* workers_replying: "W" Sending Reply
* workers_starting: "S" Starting up
* workers_total: the total amount of possible worker threads
* workers_waiting: "_" Waiting for Connection


# Known Issues and Limitations

* Warn on "G" workers only after a certain period of time.
