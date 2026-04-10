# Check php-status

## Overview

Checks PHP configuration and health, including startup errors, missing modules, and misconfigured php.ini directives. Optionally reads extended PHP information (Opcache statistics) from a monitoring helper script deployed in the web server context.

Apache httpd config example for the optional monitoring.php:

```text
Alias /monitoring.php /dev/null
<Location /monitoring.php>
    Require local
    # if using php-fpm, two examples:
    #SetHandler "proxy:fcgi://127.0.0.1:9000/monitoring.php"
    #SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost/monitoring.php"
</Location>
```

On the subject of Opcache see also:

* [Opcache Runtime Configuration](https://www.php.net/manual/en/opcache.configuration.php#ini.opcache.interned-strings-buffer)
* [A one-page opcache status page](https://github.com/rlerdorf/opcache-status)
* [Fine-Tune Your Opcache Configuration to Avoid Caching Suprises](https://tideways.com/profiler/blog/fine-tune-your-opcache-configuration-to-avoid-caching-suprises).

**Important Notes:**

* The `monitoring.php` helper script is optional. Without it, the plugin still works but cannot report Opcache statistics.
* The `--config` parameter uses startswith matching against `php --info` output.
* The `--module` parameter uses startswith matching against `php --modules` output.

**Data Collection:**

* Executes `php --version` to detect startup errors
* Executes `php --modules` to verify expected modules are installed
* Executes `php --info` to verify php.ini configuration values
* Optionally fetches extended Opcache data from a `monitoring.php` helper script deployed in the web server document root
* Requires root or sudo to run the PHP CLI commands

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-status> |
| Nagios/Icinga Check Name              | `check_php_status` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | PHP monitoring script [monitoring.php](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/php-status/monitoring.php) (optional, callable via HTTP(S)) |


## Help

```text
usage: php-status [-h] [-V] [--always-ok] [-c CRIT] [--config CONFIG] [--dev]
                  [--module MODULES] [--insecure] [--no-proxy]
                  [--timeout TIMEOUT] [--url URL] [-w WARN]

Checks PHP configuration and health, including startup errors, missing
modules, and misconfigured php.ini directives. Optionally reads extended PHP
information from a monitoring helper script deployed in the web server
context. Alerts on startup errors, missing modules, or insecure settings.
Requires root or sudo.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for Opcache usage, in percent. Default:
                       >= None
  --config CONFIG      PHP ini "key=value" pair to check (startswith match).
                       Can be specified multiple times. Example: `--config
                       "memory_limit=128M"`
  --dev                Development mode. Tolerates `display_errors=On` and
                       `display_startup_errors=On`.
  --module MODULES     PHP module name to check (startswith match). Can be
                       specified multiple times. Example: `--module json
                       --module mbstring`
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  --url URL            URL to the optional PHP `monitoring.php` helper script.
                       Without it the plugin still works, but with reduced
                       accuracy. Default: http://localhost/monitoring.php
  -w, --warning WARN   WARN threshold for Opcache usage, in percent. Default:
                       >= 90
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

* OK if no startup errors, all expected modules are found, configuration matches, and Opcache usage is below the thresholds.
* WARN on PHP startup errors.
* WARN if php.ini configuration does not match the given `--config` values.
* WARN if a required `--module` is missing.
* WARN if `display_errors`, `display_startup_errors`, or `expose_php` are enabled.
* WARN if Opcache is not installed or not enabled.
* WARN if Opcache restarts due to Out of Memory (OOM).
* WARN or CRIT if Opcache memory usage is above the given percentage thresholds (default: 90/None).
* WARN or CRIT if Opcache key usage is above the given percentage thresholds (default: 90/None).
* WARN or CRIT if Opcache interned string usage is above the given percentage thresholds (default: 90/None).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| php-config-errors | Number | 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT |
| php-module-errors | Number | 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT |
| php-opcache-interned_strings_usage-free_memory | Bytes | Free interned strings buffer memory. |
| php-opcache-interned_strings_usage-number_of_strings | Number | Number of interned strings. |
| php-opcache-interned_strings_usage-percentage | Percentage | Interned strings buffer usage, in percent. |
| php-opcache-interned_strings_usage-used_memory | Bytes | Used interned strings buffer memory. |
| php-opcache-memory_usage-current_wasted_percentage | Percentage | Current wasted memory, in percent. |
| php-opcache-memory_usage-free_memory | Bytes | Free Opcache memory. |
| php-opcache-memory_usage-percentage | Percentage | Opcache memory usage, in percent. |
| php-opcache-memory_usage-used_memory | Bytes | Used Opcache memory. |
| php-opcache-memory_usage-wasted_memory | Bytes | Wasted Opcache memory. |
| php-opcache-opcache_statistics-blacklist_miss_ratio | Percentage | Blacklist miss ratio. |
| php-opcache-opcache_statistics-blacklist_misses | Number | Blacklist misses. |
| php-opcache-opcache_statistics-hash_restarts | Number | Number of restarts because of hash overflow. |
| php-opcache-opcache_statistics-hits | Continous Counter | Opcache hits. |
| php-opcache-opcache_statistics-manual_restarts | Number | Number of restarts scheduled by opcache_reset(). |
| php-opcache-opcache_statistics-misses | Continous Counter | Opcache misses. |
| php-opcache-opcache_statistics-num_cached_keys | Number | Number of cached keys. |
| php-opcache-opcache_statistics-num_cached_keys-percentage | Percentage | Cached keys usage, in percent. |
| php-opcache-opcache_statistics-num_cached_scripts | Number | Number of cached scripts. |
| php-opcache-opcache_statistics-num_free_keys | Number | Number of free keys. |
| php-opcache-opcache_statistics-oom_restarts | Number | Number of restarts because of out of memory. |
| php-opcache-opcache_statistics-opcache_hit_rate | Percentage | Opcache hit rate. |
| php-startup-errors | Number | 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT |


## Troubleshooting

`OpCache Mem used warning`
Increase `opcache.memory_consumption`, in megabytes. The minimum permissible value is `8`, which is enforced if a smaller value is set.

`Keys used warning`
Increase `opcache.max_accelerated_files`. The actual value used will be the first number in the set of prime numbers `{223, 463, 983, 1979, 3907, 7963, 16229, 32531, 65407, 130987, 262237, 524521, 1048793}` that is greater than or equal to `opcache.max_accelerated_files`. The minimum value is `223`. The maximum value is `1048793`.

`Hit Rate low`
Cache has to warm up, so wait and see.

`Interned Strings used warning`
The OPcache interned strings buffer assures that repeating strings can be effectively cached. Increase `opcache.interned_strings_buffer`, in megabytes. The actual value is always lower than what is configured in `opcache.interned_strings_buffer`.

`OOM restarts warning`
Increase any of the above values and restart Apache or PHP-FPM.

`display_startup_errors - N/A`
Could happen while a PHP or Icinga update is running on your machine.

`No entry for terminal type "unknown"; using dump terminal settings.`
Maybe you are using a too old PHP version.

`PHP Warning: PHP Startup: Unable to load dynamic library ...`
Update this plugin.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
