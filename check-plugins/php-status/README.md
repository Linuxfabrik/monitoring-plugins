# Check php-status

## Overview

This plugin checks for PHP Opcache status, startup errors using `php --version`, missing modules using `php --modules` or misconfigured directives using `php --info`. Needs sudo.

So that the check can call up the Opcache data in the context of a web server, first put the `monitoring.php` file to the web server's document root directory.

Apache httpd config example:

```text
Alias /monitoring.php /dev/null
<Location /monitoring.php>
    Require local
    # if using php-fpm, two examples:
    #SetHandler "proxy:fcgi://127.0.0.1:9000/monitoring.php"
    #SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost/monitoring.php"
</Location>
```

The check can then call up additional PHP information, such as the PHP Opcache statistics.

On the subject of Opcache see also:

* [Opcache Runtime Configuration](https://www.php.net/manual/en/opcache.configuration.php#ini.opcache.interned-strings-buffer)
* [A one-page opcache status page](https://github.com/rlerdorf/opcache-status)
* [Fine-Tune Your Opcache Configuration to Avoid Caching Suprises](https://tideways.com/profiler/blog/fine-tune-your-opcache-configuration-to-avoid-caching-suprises).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-status> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | PHP monitoring script [monitoring.php](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/php-status/monitoring.php) (optional, callable via HTTP(S)) |


## Help

```text
usage: php-status [-h] [-V] [--always-ok] [-c CRIT] [--config CONFIG] [--dev]
                  [--module MODULES] [--insecure] [--no-proxy]
                  [--timeout TIMEOUT] [--url URL] [-w WARN]

This plugin checks for PHP startup errors, missing modules and misconfigured
php.ini directives.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  Set the CRIT threshold for Opcache usage as a
                       percentage. Default: >= None
  --config CONFIG      "key=value" pairs to check (startswith), for example
                       `--config "memory_limit=128M"` (repeating)
  --dev                Be more tolerant in development environments: Allow
                       `display_errors=On` and `display_startup_errors=On`.
  --module MODULES     "modulename" to check (startswith), for example
                       `--module json --module mbstring` (repeating)
  --insecure           This option explicitly allows to perform "insecure" SSL
                       connections. Default: False
  --no-proxy           Do not use a proxy. Default: False
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  --url URL            URL to optional PHP `monitoring.php` script. The plugin
                       will work, but its accuracy will be reduced if the
                       `monitoring.php` file cannot be fetched via HTTP(S).
                       Default: http://localhost/monitoring.php
  -w, --warning WARN   Set the WARN threshold for Opcache usage as a
                       percentage. Default: >= 90
```


## Usage Examples

```bash
./php-status --url http://localhost/monitoring.php --config date.timezone=Europe/Zurich --config memory_limit=256M --module mbstring --module GD
```

Output:

```text
Everything is ok. PHP v8.3.26 (/etc/php.ini), Opcache Mem 59.2% used (75.8MiB/128.0MiB),
Wasted 0% (0.0B, max. 5.0%), Keys 78.4% used (6245/7963), Hit Rate 100.0% (13.5M hits, 3.3K misses),
Interned Strings 61.8% used (12.4MiB/20.0MiB, 130787 Strings), 0 OOM / 0 manual / 0 key restarts,
No startup errors were detected. No unexpected configurations detected. All expected modules were
found.

Key                             ! Value                            
--------------------------------+----------------------------------
date.timezone                   ! Europe/Zurich                    
default_socket_timeout          ! 10                               
display_errors                  ! Off                              
display_startup_errors          ! Off                              
error_reporting                 ! 22519                            
expose_php                      ! Off                              
max_execution_time              ! 3600                             
max_file_uploads                ! 100                              
max_input_time                  ! -1                               
memory_limit                    ! 1024M                            
post_max_size                   ! 16M                              
SMTP                            ! localhost                        
upload_max_filesize             ! 10000M                           
opcache.blacklist_filename      ! /etc/php-zts.d/opcache*.blacklist
opcache.enable                  ! True                             
opcache.enable_cli              ! True                             
opcache.huge_code_pages         ! False                            
opcache.interned_strings_buffer ! 20                               
opcache.max_accelerated_files   ! 7963                             
opcache.memory_consumption      ! 128.0MiB                         
opcache.revalidate_freq         ! 60                               
opcache.save_comments           ! True                             
opcache.validate_timestamps     ! True
```


## States

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


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| php-config-errors | Number | 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT |
| php-module-errors | Number | 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT |
| php-startup-errors | Number | 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT |
| php-opcache-interned_strings_usage-free_memory | Bytes |  |
| php-opcache-interned_strings_usage-number_of_strings | Number |  |
| php-opcache-interned_strings_usage-percentage | Percentage |  |
| php-opcache-interned_strings_usage-used_memory | Bytes |  |
| php-opcache-memory_usage-current_wasted_percentage | Percentage |  |
| php-opcache-memory_usage-free_memory | Bytes |  |
| php-opcache-memory_usage-percentage | Percentage |  |
| php-opcache-memory_usage-used_memory | Bytes |  |
| php-opcache-memory_usage-wasted_memory | Bytes |  |
| php-opcache-opcache_statistics-blacklist_miss_ratio | Percentage |  |
| php-opcache-opcache_statistics-blacklist_misses | Number |  |
| php-opcache-opcache_statistics-hash_restarts | Number | number of restarts because of hash overflow |
| php-opcache-opcache_statistics-hits | Continous Counter |  |
| php-opcache-opcache_statistics-manual_restarts | Number | number of restarts scheduled by opcache_reset() |
| php-opcache-opcache_statistics-misses | Continous Counter |  |
| php-opcache-opcache_statistics-num_cached_keys-percentage | Percentage |  |
| php-opcache-opcache_statistics-num_cached_keys | Number |  |
| php-opcache-opcache_statistics-num_cached_scripts | Number |  |
| php-opcache-opcache_statistics-num_free_keys | Number |  |
| php-opcache-opcache_statistics-oom_restarts | Number | number of restarts because of out of memory |
| php-opcache-opcache_statistics-opcache_hit_rate | Percentage |  |


## Troubleshooting

If you get a warning on

* OpCache Mem used: Increase `opcache.memory_consumption`, in megabytes. The minimum permissible value is `8`, which is enforced if a smaller value is set.
* Keys used: Increase `opcache.max_accelerated_files`. The actual value used will be the first number in the set of prime numbers `{223, 463, 983, 1979, 3907, 7963, 16229, 32531, 65407, 130987, 262237, 524521, 1048793}` that is greater than or equal to `opcache.max_accelerated_files`. The minimum value is `223`. The maximum value is `1048793`.
* Hit Rate: Cache has to warm up, so wait and see.
* Interned Strings used: The OPcache interned strings buffer assures that repeating strings can be effectively cached. Increase `opcache.interned_strings_buffer`, in megabytes. The actual value is always lower than what is configured in `opcache.interned_strings_buffer`.
* OOM: Increase any of the above values and restart Apache or PHP-FPM.
* display_startup_errors - N/A: Could happen while a PHP or Icinga update is running on your machine.
* `No entry for terminal type "unknown"; using dump terminal settings.`: maybe you are using a too old PHP version.

Warning on Startup errors like `PHP Warning:  PHP Startup: Unable to load dynamic library 'gd' ...` etc. for no reason?

* Update this plugin.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
