# Check php-fpm-status

## Overview

Monitors PHP-FPM pool performance via the status page. Reports active processes, listen queue depth, idle workers, request rates, and uptime per pool. Also lists currently running processes with their request details.

**Data Collection:**

* Fetches JSON data from the PHP-FPM status page (`?json&full`)
* Per-process details (PID, request duration, URI, script, etc.) are shown for processes in "Running" state
* The monitoring request itself is excluded from the process list
* Supports extended reporting via `--lengthy`, which adds columns for process state, start time, and content length

**Compatibility:**

* Cross-platform

**Important Notes:**

* Requires a configured PHP-FPM status page (e.g. `pm.status_path = /fpm-status` in `/etc/php-fpm.d/<poolname>.conf`)
PHP-FPM config example:
```text
; PHP-FPM Config
pm.status_path = /fpm-status
```
```text
# Apache Config
Alias /fpm-status /dev/null
<LocationMatch "/fpm-status">
    Require local
    ProxyPass unix:/run/php-fpm/www.sock|fcgi://localhost/fpm-status
</LocationMatch>
```


## 