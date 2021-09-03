Check php-status
================

Overview
--------

This plugin checks for PHP Opcache status, startup errors using ``php --version``, missing modules using ``php --modules`` or misconfigured directives using ``php --info``.

So that the check can call up the Opcache data in the context of a web server, first put the ``monitoring.php`` file to the web server's document root directory. The check can then call up additional PHP information, such as the PHP Opcache statistics. On the subject of Opcache see also:

* `Opcache Runtime Configuration <https://www.php.net/manual/en/opcache.configuration.php#ini.opcache.interned-strings-buffer>`_
* `A one-page opcache status page <https://github.com/rlerdorf/opcache-status>`_
* `Fine-Tune Your Opcache Configuration to Avoid Caching Suprises <https://tideways.com/profiler/blog/fine-tune-your-opcache-configuration-to-avoid-caching-suprises>`_.

Apache httpd config example:

.. code-block:: text

    <Location /monitoring.php>
        Require local
        # if using php-fpm, two examples:
        #SetHandler "proxy:fcgi://127.0.0.1:9000/monitoring.php"
        #SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost/monitoring.php"
    </Location>


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/php-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Callable ``monitoring.php`` (optional)"


Help
----

.. code-block:: text

    usage: php-status [-h] [-V] [--always-ok] [-c CRIT] [--config CONFIG]
                      [--module MODULES] [--url URL] [-w WARN]

    This plugin checks for PHP startup errors, missing modules and misconfigured
    php.ini directives.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold for Opcache usage as a
                            percentage. Default: >= 90
      --config CONFIG       "key=value" pairs to check (startswith), for example
                            `--config "memory_limit=128M"` (repeating)
      --module MODULES      "modulename" to check (startswith), for example
                            `--module json --module mbstring` (repeating)
      --url URL             URL to PHP monitoring script.
      -w WARN, --warning WARN
                            Set the WARN threshold for Opcache usage as a
                            percentage. Default: >= 80


Usage Examples
--------------

.. code-block:: bash

    ./php-status --url http://localhost/monitoring.php --config date.timezone=Europe/Zurich --config memory_limit=256M --module mbstring --module GD

Output:

.. code-block:: text

    PHP v7.4.22 (/etc/php.ini), Opcache Mem 28.5% used (73.0MiB/256.0MiB), Wasted 0.0% (0.0B, max. 5.0%), Keys 20.8% used (3368/16229), Hit Rate 99.9% (3.0M hits, 3.1K misses), Interned Strings 10.5% used (4.2MiB/40.0MiB, 68202 Strings), 0 OOM / 0 manual / 0 key restarts
    Key                             ! Value         
    ------------------------------- ! ------------- 
    date.timezone                   ! Europe/Zurich 
    display_errors                  ! 0             
    display_startup_errors          ! 0             
    error_reporting                 ! 22519         
    expose_php                      ! 0             
    max_execution_time              ! 30            
    memory_limit                    ! 2200M         
    post_max_size                   ! 2100M         
    upload_max_filesize             ! 2000M         
    opcache.enable                  ! True          
    opcache.interned_strings_buffer ! 48            
    opcache.max_accelerated_files   ! 16229         
    opcache.memory_consumption      ! 268435456     
    opcache.revalidate_freq         ! 86400         
    opcache.save_comments           ! True          
    opcache.validate_timestamps     ! False


States
------

If wanted, always returns OK. Otherwise returns

WARN

* on startup errors,
* if php.ini config does not match the given configs
* if a required module is missing
* on Opcache restarts due to Out of Memory (OOM)

WARN or CRIT:

* if Opcache Memory usage is above the given percentage thresholds (default 80/90%)
* if Opcache Key usage is above the given percentage thresholds (default 80/90%)
* if Opcache interned string usage is above the given percentage thresholds (default 80/90%)


Perfdata / Metrics
------------------

* php-config-errors: 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT
* php-module-errors: 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT
* php-startup-errors: 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT
* php-opcache-interned_strings_usage-free_memory: Bytes
* php-opcache-interned_strings_usage-number_of_strings: Number
* php-opcache-interned_strings_usage-percentage: %
* php-opcache-interned_strings_usage-used_memory: Bytes
* php-opcache-memory_usage-current_wasted_percentage: %
* php-opcache-memory_usage-free_memory: Bytes
* php-opcache-memory_usage-percentage: %
* php-opcache-memory_usage-used_memory: Bytes
* php-opcache-memory_usage-wasted_memory: Bytes
* php-opcache-opcache_statistics-blacklist_miss_ratio: %
* php-opcache-opcache_statistics-blacklist_misses: Number
* php-opcache-opcache_statistics-hash_restarts: Number
* php-opcache-opcache_statistics-hits: Continous Counter
* php-opcache-opcache_statistics-manual_restarts: Number
* php-opcache-opcache_statistics-misses: Continous Counter
* php-opcache-opcache_statistics-num_cached_keys-percentage: %
* php-opcache-opcache_statistics-num_cached_keys: Number
* php-opcache-opcache_statistics-num_cached_scripts: Number
* php-opcache-opcache_statistics-num_free_keys: Number
* php-opcache-opcache_statistics-oom_restarts: Number
* php-opcache-opcache_statistics-opcache_hit_rate: %


Troubleshooting
---------------

If you get a warning on

* OpCache Mem: Increase ``opcache.memory_consumption``, in megabytes. The minimum permissible value is "8", which is enforced if a smaller value is set.
* Keys: Increase ``opcache.max_accelerated_files``. The actual value used will be the first number in the set of prime numbers {223, 463, 983, 1979, 3907, 7963, 16229, 32531, 65407, 130987, 262237, 524521, 1048793} that is greater than or equal to ``opcache.max_accelerated_files``. The minimum value is 200. The maximum value is 1000000.
* Hit Rate: Cache has to warm up, so wait and see.
* Interned Strings: Increase ``opcache.interned_strings_buffer``, in megabytes. The actual value is always lower than what is configured in ``opcache.interned_strings_buffer``.
* OOM: Increase any of the above values and restart Apache or PHP-FPM.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
