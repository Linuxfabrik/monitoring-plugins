# Check php-status


## Overview

Checks PHP configuration and health, including startup errors, missing modules, and misconfigured php.ini directives. Optionally reads extended PHP information from a monitoring helper script (`monitoring.php`) deployed in the web server context: OPcache statistics, the largest cached scripts, and the active php.ini runtime settings (each shown next to PHP's own default whenever it deviates).

**Important Notes:**

* The `monitoring.php` helper script is optional. Without it, the plugin still reports CLI-side health (startup errors, modules, CLI php.ini), but cannot report OPcache statistics or the web server's php.ini runtime settings.
* OPcache is shared per PHP-FPM master, so a separate PHP-FPM service (a different PHP version, or a dedicated service for one app) needs its own helper and its own check. See the Background and [Deploying the monitoring.php helper](#deploying-the-monitoringphp-helper) sections.
* If the output is missing directives or whole sections, the `monitoring.php` deployed on the web server is older than the plugin. Update `monitoring.php`; the plugin only displays what the helper reports.
* The `--config` parameter uses startswith matching against `php --info` output.
* The `--module` parameter uses startswith matching against `php --modules` output.

**Data Collection:**

* Executes `php --version` to detect startup errors
* Executes `php --modules` to verify expected modules are installed
* Executes `php --info` to verify php.ini configuration values
* Optionally fetches OPcache status, the per-file OPcache script list, and the web server's php.ini runtime settings from the `monitoring.php` helper over HTTP(S)
* Requires root or sudo (the shipped sudoers drop-in permits the icinga/nagios user): reading php.ini and the FPM pool configs reliably needs root, since a non-root `php --info` returns PHP's compiled defaults instead of the configured values

### Background: PHP-FPM, pools and OPcache

This plugin reports on PHP-FPM and OPcache. The thresholds and the multi-master handling only make sense once you know how these pieces fit together, so the essentials are summarised here.

#### PHP-FPM: masters, pools and workers

PHP-FPM (FastCGI Process Manager) runs PHP as a long-lived background service, decoupled from the web server. Apache or nginx accepts the HTTP request and forwards the PHP part to FPM over a FastCGI socket; FPM executes the script and returns the result.

* A **master** process reads one configuration file, manages worker processes and never runs PHP code itself. Each `php-fpm` systemd service is one master.
* A **pool** is a named group of workers inside a master, with its own listen socket, run-as user and group, process-manager settings (`pm.max_children` and friends) and php.ini overrides. One master can run several pools, typically one per application or site, isolated from each other by user and socket.
* A **worker** is a child process that handles one request at a time. `pm.max_children` bounds how many run in parallel.

The point of all this is isolation (each app gets its own user, limits and socket), persistence (the interpreter is not forked and torn down per request) and resource control.

#### OPcache: what it is and where it applies

OPcache caches the **compiled bytecode** of PHP scripts in **shared memory**, so PHP does not re-read and re-compile the same `.php` files on every request. It is a pure performance optimization and changes no behaviour.

It is **not specific to PHP-FPM**: any persistent SAPI benefits, including Apache `mod_php`. The CLI has its own OPcache, but it is disabled by default (`opcache.enable_cli=0`) and short-lived (one process per invocation), so it rarely matters. The plugin monitors the web-server OPcache because that is the one serving your site.

The shared memory is allocated **once per master** at startup (`opcache.memory_consumption` is a system-level directive) and is **shared by every worker and every pool of that master**. Two separate masters (for example two PHP versions, or a dedicated service for one app) each have their own, separate OPcache.

#### Why one monitoring.php per master is enough

Because all pools of a master share that single OPcache, one `monitoring.php` reached through any pool of the master reports the cache for the whole master. You do not need one per pool. You do need one per **separate master**, since each master has its own cache. (The php.ini *runtime settings* the helper reports are still those of the specific pool that served it, see below.)

#### Where a php.ini applies, and per-pool overrides

A PHP process loads **one** main `php.ini`. On Debian and Ubuntu the path is per-SAPI (`/etc/php/<v>/fpm/php.ini` for FPM, `.../cli/php.ini` for the CLI, `.../apache2/php.ini` for `mod_php`), so the CLI and FPM can differ out of the box. On RHEL and clones all SAPIs share `/etc/php.ini` plus the drop-ins in `/etc/php.d/`, and the difference comes instead from the FPM pool overrides described below. Either way, `php --info` on the CLI does not show the FPM runtime values, which is why this plugin reads them through the web-server helper.

Within one FPM master, each **pool** can override php.ini directives via `php_value` / `php_flag` (the app may change them again) and `php_admin_value` / `php_admin_flag` (locked for the pool). So `memory_limit`, `display_errors` and the like can differ per pool. The "php.ini runtime settings" in the output are therefore the values of the pool that served `monitoring.php`. Separate `php.ini` files per FPM process are possible too: two separate FPM services can be started against different ini files (different version directories, or `PHP_INI_SCAN_DIR`); within one master you get per-pool overrides rather than separate files.

#### OPcache internals behind the thresholds

* **used, free, wasted.** The OPcache shared memory holds live cached scripts (used), free space, and **wasted** memory: the old bytecode of scripts that changed on disk and were recompiled (with `opcache.validate_timestamps` on).
* **cache_full and restarts.** When a new script cannot be allocated (memory or hash table full), OPcache checks `wasted / memory_consumption >= opcache.max_wasted_percentage` (default 5%). If wasted is at or above that, it **restarts**: it flushes the whole cache and recompiles everything, a brief recompile storm counted as `oom_restarts` or `hash_restarts`. If wasted is below 5%, it instead sets **cache_full** and simply stops caching new scripts, which then run uncached (recompiled) on every request. Frequent restarts mean the cache is **thrashing**: too small, or churning too much.
* **interned strings.** OPcache deduplicates identical strings (class and function names and so on) into a small buffer. When that buffer is full it returns the original, non-interned string (`/* no memory, return the same non-interned string */ return str;` in the source) and carries on. Nothing fails; the string still works, it is just no longer deduplicated, costing marginally more memory and a negligible amount of CPU. A full interned strings buffer is a lost optimization, not an error, which is why the plugin shows it but never alerts on it.
* **hit rate.** `opcache_hit_rate = hits / (hits + misses)`, and `hits` and `misses` are reset to 0 on every restart. A low value therefore usually just means the cache recently (re)started or was deployed and is still warming up, not that anything is wrong. The plugin shows it but does not alert on it; the genuine "cache too small or thrashing" signal is the restart counters. If the hit rate stays low for a long time, the cache keeps restarting: raise `opcache.memory_consumption` or `opcache.max_accelerated_files`, or review `opcache.validate_timestamps` and `opcache.revalidate_freq` (constant recompilation of files that keep changing).

#### upload_max_filesize has nothing to do with memory_limit

A persistent misconception is that uploading a large file needs a correspondingly large `memory_limit`. It does not. PHP streams a multipart file upload **straight to a temporary file on disk** (`upload_tmp_dir`) in small chunks; in the PHP source (`main/rfc1867.c`) the handler opens a temp file with `php_open_temporary_fd_ex(...)` and then `write(fd, buff, blen)` in a loop. The file never accumulates in the script's memory, which is what `memory_limit` bounds. You can run `upload_max_filesize = 2G` with `memory_limit = 128M`. What *is* related: `post_max_size` must be at least `upload_max_filesize` (the file is part of the POST body), and the upload needs **disk** space in `upload_tmp_dir`, not RAM.

### Deploying the monitoring.php helper

The `monitoring.php` helper exposes the web-server OPcache and the runtime php.ini, which the PHP CLI cannot see (see the Background). It runs inside the web server context and returns the data as JSON, which the plugin fetches over HTTP(S).

Place the file in the document root of the vhost whose PHP-FPM pool you want to monitor, and restrict access to localhost. The document root is typically `/var/www/html/` on both RHEL/clones and Debian/Ubuntu.

Apache httpd, routed to a PHP-FPM pool socket:

```text
<Location /monitoring.php>
    Require local
    # RHEL/clones default pool socket:
    SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost/var/www/html/monitoring.php"
    # Debian/Ubuntu default pool socket (adjust the PHP version):
    #SetHandler "proxy:unix:/run/php/php8.2-fpm.sock|fcgi://localhost/var/www/html/monitoring.php"
</Location>
```

```bash
./php-status --url=http://localhost/monitoring.php
```

#### Several OPcaches: one helper and one check per PHP-FPM service

Each separate PHP-FPM service has its own OPcache, so it needs its own helper route and its own check. Two vhosts, each routed to a separate PHP-FPM service (here two PHP versions on Debian):

```text
# vhost A > php8.1-fpm.service (its own OPcache)
<VirtualHost *:80>
    ServerName app1.example.com
    DocumentRoot /var/www/app1
    <Location /monitoring.php>
        Require local
        SetHandler "proxy:unix:/run/php/php8.1-fpm.sock|fcgi://localhost/var/www/app1/monitoring.php"
    </Location>
</VirtualHost>

# vhost B > php8.2-fpm.service (a separate OPcache)
<VirtualHost *:80>
    ServerName app2.example.com
    DocumentRoot /var/www/app2
    <Location /monitoring.php>
        Require local
        SetHandler "proxy:unix:/run/php/php8.2-fpm.sock|fcgi://localhost/var/www/app2/monitoring.php"
    </Location>
</VirtualHost>
```

```bash
./php-status --url=http://app1.example.com/monitoring.php --ignore-multiple-masters
./php-status --url=http://app2.example.com/monitoring.php --ignore-multiple-masters
```

The file on disk can be identical in both document roots; the socket each `<Location>` routes to is what makes each check report a different OPcache. Pass `--ignore-multiple-masters` once you cover every service with its own check, otherwise each check warns that more than one PHP-FPM master is running.

On the subject of OPcache see also:

* [OPcache Runtime Configuration](https://www.php.net/manual/en/opcache.configuration.php)
* [A one-page opcache status page](https://github.com/rlerdorf/opcache-status)
* [Fine-Tune Your OPcache Configuration to Avoid Caching Surprises](https://tideways.com/profiler/blog/fine-tune-your-opcache-configuration-to-avoid-caching-suprises)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-status> |
| Nagios/Icinga Check Name              | `check_php_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | PHP monitoring script [monitoring.php](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/php-status/assets/monitoring.php) (optional, callable via HTTP(S)) |


## Help

```text
usage: php-status [-h] [-V] [--always-ok] [-c CRIT] [--config CONFIG] [--dev]
                  [--module MODULES] [--ignore-multiple-masters] [--insecure]
                  [--no-proxy] [--timeout TIMEOUT] [--top TOP] [--url URL]
                  [-w WARN]

Checks PHP configuration and health, including startup errors, missing
modules, and misconfigured php.ini directives. Optionally reads extended PHP
information from a monitoring helper script deployed in the web server
context: OPcache statistics, the largest cached scripts, and the active
php.ini directives. Alerts on startup errors, missing modules, or insecure
settings. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for OPcache memory and key usage, in
                        percent. Default: >= None
  --config CONFIG       PHP ini "key=value" pair to check (startswith match).
                        Can be specified multiple times. Example: `--config
                        "memory_limit=128M"`
  --dev                 Development mode. Tolerates `display_errors=On` and
                        `display_startup_errors=On`.
  --module MODULES      PHP module name to check (startswith match). Can be
                        specified multiple times. Example: `--module json
                        --module mbstring`
  --ignore-multiple-masters
                        Do not warn when more than one PHP-FPM master is
                        running. Use this on hosts where you intentionally run
                        several PHP-FPM services and monitor each one with its
                        own check.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --top TOP             Number of largest OPcache scripts to list, sorted by
                        memory consumption (descending). Use `--top=0` to
                        disable. Default: 10
  --url URL             URL to the optional PHP `monitoring.php` helper
                        script. The helper runs in the context of the single
                        PHP-FPM master that serves this URL and reports only
                        that master's OPcache and php.ini settings. To check
                        several PHP-FPM services on a host, deploy one
                        monitoring.php per service and run this plugin once
                        per URL. Without it the plugin still works, but with
                        reduced accuracy. Default:
                        http://localhost/monitoring.php
  -w, --warning WARN    WARN threshold for OPcache memory and key usage, in
                        percent. Default: >= 95
```


## Usage Examples

```bash
./php-status --url=http://localhost/monitoring.php --config=date.timezone=UTC --top=3
```

Output (one PHP-FPM master, OPcache healthy). The first line is the summary; the long output adds the largest cached scripts and the active php.ini, each value shown next to PHP's own default when it deviates:

```text
monitoring.php read (fpm-fcgi). PHP-FPM services and pools: /etc/php/8.4/fpm/php-fpm.conf (pool app1, app2, www). PHP v8.4.21 (/etc/php/8.4/fpm/php.ini), Opcache Mem 6.9% used (8.9MiB/128.0MiB), Wasted 0% (0.0B, max. 5.0%), Keys 0.0% used (7/16229), Hit Rate 89.4% (76.0 hits, 9.0 misses), Interned Strings 27.6% used (2.2MiB/8.0MiB, 4792 Strings), 0 OOM / 0 hash / 0 manual restarts. No startup errors were detected. No unexpected configurations detected. All expected modules were found.

Top OPcache scripts by memory consumption:
Memory  ! Mem% ! Hits ! Script
--------+------+------+-----------------------------
14.6KiB ! 0.0% ! 43.0 ! /var/www/html/monitoring.php
14.2KiB ! 0.0% ! 12.0 ! /var/www/app1/monitoring.php
14.2KiB ! 0.0% ! 3.0  ! /var/www/app2/monitoring.php

php.ini runtime settings:
[PHP]
default_socket_timeout = 60
display_errors = Off  ; default: On
display_startup_errors = Off  ; default: On
error_reporting = E_ALL &amp; ~E_DEPRECATED
expose_php = Off  ; default: On
html_errors = On
max_execution_time = 30
max_file_uploads = 20
max_input_time = 60  ; default: -1
max_input_vars = 1000
memory_limit = 128.0MiB
post_max_size = 8.0MiB
realpath_cache_size = 4.0MiB
realpath_cache_ttl = 120
serialize_precision = -1
upload_max_filesize = 2.0MiB

[Date]
date.timezone = UTC

[mail function]
mail.add_x_header = Off
SMTP = localhost
smtp_port = 25

[Session]
session.cookie_httponly = Off  ; default: On
session.cookie_secure = Off
session.gc_maxlifetime = 1440
session.sid_length = 32
session.trans_sid_tags = a=href,area=href,frame=src,form=

[opcache]
opcache.blacklist_filename =
opcache.enable = On
opcache.enable_cli = Off
opcache.huge_code_pages = Off
opcache.interned_strings_buffer = 8.0MiB
opcache.max_accelerated_files = 10000
opcache.memory_consumption = 128.0MiB
opcache.revalidate_freq = 2
opcache.save_comments = On
opcache.validate_timestamps = On
```

On a host with several PHP-FPM masters the first line confirms the read and then warns that only one master is inspected, for example `monitoring.php read (fpm-fcgi). 2 PHP-FPM masters running, only inspecting one [WARNING]. PHP-FPM services and pools: /etc/php/8.4/fpm/php-fpm.conf (pool app1, app2, www) [inspected], /etc/php/8.4/fpm2/php-fpm.conf (pool appb) [check via /run/php/appb.sock].`


## States

* OK if there are no startup errors, all expected modules are present, the checked php.ini values match, OPcache is healthy and its memory and key usage are below the thresholds.
* WARN on PHP startup errors.
* WARN if a checked php.ini value does not match the given `--config`.
* WARN if a required `--module` is missing.
* WARN if `display_errors` or `display_startup_errors` (both tolerated with `--dev`) or `expose_php` are enabled.
* WARN if OPcache is not installed or not enabled.
* WARN if the OPcache is full, or a restart is pending or in progress.
* WARN if there are OPcache OOM or hash restarts (the cache is thrashing). Manual restarts (for example from a deploy) are shown for information only and do not alert.
* WARN or CRIT if OPcache memory usage is at or above the `--warning` / `--critical` percentage thresholds (default: 95/None).
* WARN or CRIT if OPcache key usage (cached scripts against `opcache.max_accelerated_files`) is at or above the same thresholds.
* WARN if more than one PHP-FPM master is running, since only the one serving `--url` is inspected; pass `--ignore-multiple-masters` to make this informational instead.
* The interned strings usage and the OPcache hit rate are shown for information only and never drive the check state.
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
| php-opcache-memory_usage-current_wasted-percentage | Percentage | Current wasted memory, in percent. |
| php-opcache-memory_usage-free_memory | Bytes | Free Opcache memory. |
| php-opcache-memory_usage-percentage | Percentage | Opcache memory usage, in percent. |
| php-opcache-memory_usage-used_memory | Bytes | Used Opcache memory. |
| php-opcache-memory_usage-wasted_memory | Bytes | Wasted Opcache memory. |
| php-opcache-opcache_statistics-blacklist_miss_ratio | Percentage | Blacklist miss ratio. |
| php-opcache-opcache_statistics-blacklist_misses | Number | Blacklist misses. |
| php-opcache-opcache_statistics-hash_restarts | Number | Number of restarts because of hash overflow. |
| php-opcache-opcache_statistics-manual_restarts | Number | Number of restarts scheduled by opcache_reset(). |
| php-opcache-opcache_statistics-num_cached_keys | Number | Number of cached keys. |
| php-opcache-opcache_statistics-num_cached_keys-percentage | Percentage | Cached keys usage, in percent. |
| php-opcache-opcache_statistics-num_cached_scripts | Number | Number of cached scripts. |
| php-opcache-opcache_statistics-num_free_keys | Number | Number of free keys. |
| php-opcache-opcache_statistics-oom_restarts | Number | Number of restarts because of out of memory. |
| php-opcache-opcache_statistics-opcache_hit_rate | Percentage | Opcache hit rate. |
| php-startup-errors | Number | 0 = STATE_OK, 1 = STATE_WARN, 2 = STATE_CRIT |


## Troubleshooting

### `monitoring.php could not be read`

The plugin could not fetch the helper at `--url`, so the OPcache and php.ini-runtime parts are skipped and only the CLI checks run. The message includes the exact reason. Common cases:

- `Python module "httpx" is not installed`: the plugin's Python interpreter has no `httpx`. This is the usual cause on RHEL 8 / Rocky 8, whose system Python is 3.6 while `httpx` needs Python 3.8 or newer. Install `httpx` for the interpreter the plugin actually runs under (check its shebang), for example `dnf install python3-httpx python3-h2`, or run the plugin under a newer Python that has `httpx`.
- `HTTP error "404 Not Found"`: the URL does not resolve to the deployed file. Check the vhost `DocumentRoot` against where `monitoring.php` lives.
- Connection refused or a timeout: the web server is not listening where `--url` points, or `localhost` resolves to an address (e.g. IPv6 `::1`) the vhost does not serve.

Deploy `monitoring.php` and route it to a PHP-FPM pool as shown under [Deploying the monitoring.php helper](#deploying-the-monitoringphp-helper), then confirm the URL is reachable locally with `curl <url>`.

### php.ini directives or sections are missing, or show `N/A`

The plugin only displays what `monitoring.php` reports. If directives or whole `[sections]` are missing from the "php.ini runtime settings", or the PHP version line shows `N/A`, the `monitoring.php` on the web server is older than the plugin and does not collect those values yet. Copy the current `monitoring.php` from this plugin's `assets/` directory over the deployed one and re-check.

### More than one PHP-FPM master: `only inspecting one`

Each PHP-FPM master has its own separate OPcache, so a single check only covers the master serving `--url`. The output lists every master with its pools and, for the masters it does not cover, a socket to route a separate `monitoring.php` to. Set up one check per master (one `monitoring.php` per master is enough, since pools share the OPcache). If every master is already covered by its own check, pass `--ignore-multiple-masters` to silence the warning.

### `Opcache Mem ... used` warning

Memory usage crossed `--warning` / `--critical` (percent, default 95). This is a leading indicator that the cache is filling up. A cache that has plateaued just below the threshold on a stable app is harmless; one that keeps climbing toward 100% will eventually be unable to store new scripts. Increase `opcache.memory_consumption` (megabytes, minimum 8). See "Raising opcache.memory_consumption" below for the RAM impact.

### `Opcache is full`

OPcache could not allocate room for a new script and has stopped caching new ones; uncached scripts are recompiled on every request, which is slow. Increase `opcache.memory_consumption`.

### OPcache restarts (OOM or hash)

A non-zero OOM or hash restart count means OPcache ran out of memory (OOM) or filled its script hash table (hash), then flushed and recompiled the whole cache to recover. The occasional restart after a deploy is fine; repeated restarts are thrashing. Increase `opcache.memory_consumption` for OOM restarts and/or `opcache.max_accelerated_files` for hash restarts. Manual restarts (from `opcache_reset()`, e.g. a deploy) are shown for information only and never alert.

### `Keys ... used` warning

The number of cached scripts is approaching `opcache.max_accelerated_files`; once it is reached no further scripts are cached and a hash restart follows. Increase it. The value actually used is the first prime in `{223, 463, 983, 1979, 3907, 7963, 16229, 32531, 65407, 130987, 262237, 524521, 1048793}` that is greater than or equal to the configured value (minimum 223, maximum 1048793).

### Raising opcache.memory_consumption (sizing and RAM impact)

Increasing `opcache.memory_consumption` from, say, 128 MB to 256 MB adds 128 MB **once**: the OPcache shared memory is allocated a single time per master and shared by all of its workers and pools. It does not multiply by the number of workers, and it buys fewer recompiles and restarts. This is the cheap lever.

The expensive lever is per-request memory, and it has nothing to do with OPcache. `memory_limit` bounds the memory each worker uses while running a script, and that multiplies by the number of concurrent workers. With `pm.max_children = 10` and a script that peaks at 100 MB, up to 10 x 100 MB = 1 GB of private worker memory can be in use at once, on top of the shared OPcache and each worker's base footprint. Roughly:

```text
host PHP RAM  ~  OPcache shared memory (allocated once per master)
              +  interned strings buffer
              +  pm.max_children x (worker base + per-request peak up to memory_limit)
```

So size `pm.max_children` so that `max_children x per-request peak` fits in RAM with headroom; otherwise the box swaps or the OOM killer terminates workers under load. Raising the OPcache is a small, shared, one-time cost; raising `pm.max_children` or `memory_limit` is what actually scales with traffic.

### Hit rate stays low

`opcache_hit_rate` is cumulative since the last restart and resets to 0 on every restart, so a low value right after a deploy or restart is just the cache warming up. A value that stays low for a long time means the cache keeps restarting (too small, or files keep changing): raise `opcache.memory_consumption` / `opcache.max_accelerated_files`, or review `opcache.validate_timestamps` and `opcache.revalidate_freq`. The plugin shows the hit rate but does not alert on it.

### Interned strings buffer full

Not an alert. When the buffer fills, OPcache stops deduplicating new strings but keeps working; the cost is marginally more memory and a negligible CPU hit. To reclaim it, raise `opcache.interned_strings_buffer` (megabytes).

### `Config expected but not found: date.timezone = Europe`

The default `--config` check expects `date.timezone` to start with `Europe`. On a host configured for another region this warns; pass your own expectation, for example `--config "date.timezone=UTC"`, or set the directive. Run the plugin via sudo (as the basket does): a non-root run reads PHP's compiled defaults instead of the configured php.ini, so the comparison would use the wrong values.

### `PHP Warning: PHP Startup: Unable to load dynamic library ...`

A PHP startup warning, surfaced here as a startup error: an `extension=` line in a php.ini (often a file under the `conf.d` / `mods-available` directory) points to a shared object that cannot be loaded - it is missing, built for a different PHP version, or at the wrong path. Fix or remove the offending `extension=` line, or install the missing extension package.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
