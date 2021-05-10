Check "php-fpm-status"
======================

Overview
--------

This check collects information from the PHP-FPM pool status page and alerts on certain overuse. In addition, a table is printed which contains each pool process in the status "Running" (which information relates to the current request that is being served).

We recommend running this check every minute.


Installation and Usage
----------------------

Requirements:

* Activate the status page ``/fpm-status`` in ``/etc/php-fpm.d/<poolname>.conf`` (or an URL like ``/<poolname>-status`` or similar).
* Configure your webserver to serve this URL, grant access from localhost only.

After that:

.. code-block:: bash

    ./php-fpm-status
    ./php-fpm-status --url http://localhost/fpm-status --warning 80 --warning-maxchildren 10 --critical-slowreq 3
    ./php-fpm-status --help

Output::

    Pool www (dynamic): 47/55 reqs in queue (85.5%) [WARNING], 3x max children reached [WARNING], 42 slow requests [WARNING], 129k connections, 10.3 req/s, 23 processes (3 active, 20 idle), Up 3h 28m (since 2021-05-08 09:18:11)

    PID     Reqs ReqDur Request URI           ContLen AuthUser         
    ---     ---- ------ -----------           ------- --------         
    1818627 5785 6h 23m /nextcloud/remote.php -       user@example.org 
    1821973 5062 5h 14m /nextcloud/remote.php -       user@example.org 
    1823283 5092 3m 40s /nextcloud/index.php  252.0B  -

The columns mean:

* PID: the PID of the process
* Requests: the number of requests the process has served
* ReqDur: the duration of the requests
* Request URI: the request URI with the query string
* ContLen: the content length of the request (or '-' if not POST)
* AuthUser: the user (PHP_AUTH_USER) (or '-' if not set);


States
------

* WARN or CRIT on queue usage over certain thresholds (default 80/90%)
* WARN or CRIT if numer of max children is over certain thresholds (default 1/100)
* WARN or CRIT if numer of slow queries is over certain thresholds (default 1/100)


Perfdata
--------

* accepted conn: the number of request accepted by the pool
* active processes: the number of active processes
* idle processes: the number of idle processes
* listen queue len: the size of the socket queue of pending connections
* listen queue: the number of request in the queue of pending connections
* max children reached: number of times, the process limit has been reached, when pm tries to start more children (works only for pm 'dynamic' and 'ondemand')
* queue usage: the number of request in the queue of pending connections, in %
* req per sec: the number of request accepted by the pool divided by number of seconds since FPM has started
* slow requests: the number of slow requests
* up: number of seconds since FPM has started


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
