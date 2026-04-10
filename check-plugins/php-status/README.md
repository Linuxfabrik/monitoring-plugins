# Check php-status

## Overview

Checks PHP configuration and health, including startup errors, missing modules, and misconfigured php.ini directives. Optionally reads extended PHP information (Opcache statistics) from a monitoring helper script deployed in the web server context.

**Data Collection:**

* Executes `php --version` to detect startup errors
* Executes `php --modules` to verify expected modules are installed
* Executes `php --info` to verify php.ini configuration values
* Optionally fetches extended Opcache data from a `monitoring.php` helper script deployed in the web server document root
* Requires root or sudo to run the PHP CLI commands

**Important Notes:**

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
* The `monitoring.php` helper script is optional. Without it, the plugin still works but cannot report Opcache statistics.
* The `--config` parameter uses startswith matching against `php --info` output.
* The `--module` parameter uses startswith matching against `php --modules` output.

**Compatibility:**

* Linux only


## 