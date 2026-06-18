<?php
# 2026061001
#
# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.
#
# Monitoring helper for the "php-status" check plugin. Executed inside the web
# server (PHP-FPM or mod_php) context, it returns - as JSON - PHP runtime
# information that cannot be read from the PHP CLI: OPcache status and
# configuration plus a curated set of php.ini directives. The reported OPcache
# belongs to the single PHP-FPM master process that serves this script.
#
# Deploy it so that it is only reachable locally (e.g. Apache "Require local").
# Append "?scripts=1" to also include the per-file OPcache script list (used by
# the plugin's --top output). It is omitted by default to keep the
# response small on a frequently scheduled check.

declare(strict_types=1);

/**
 * Turn a boolean-style php.ini value into a human-readable label.
 *
 * ini_get() returns false for an unknown directive, an empty string or '0' for
 * a disabled boolean directive and '1' for an enabled one.
 *
 * @param string|false $value Raw value as returned by ini_get().
 */
function ini_bool_to_label($value): string
{
    if ($value === false) {
        return 'N/A';
    }
    if ($value === '' || $value === '0' || $value === 0) {
        return 'Off';
    }
    return 'On';
}

/**
 * Translate an error_reporting bitmask into a readable expression such as
 * 'E_ALL & ~E_DEPRECATED & ~E_STRICT'. Done here (not in the plugin) because
 * the value of E_ALL depends on the PHP version, which only PHP itself knows.
 *
 * @param string|false $value Raw value as returned by ini_get('error_reporting').
 */
function error_reporting_to_label($value): string
{
    if ($value === false) {
        return 'N/A';
    }
    $level = (int) $value;
    if ($level === 0) {
        return 'Off';
    }
    // E_* bit constants, lowest bit first.
    $names = [
        'E_ERROR', 'E_WARNING', 'E_PARSE', 'E_NOTICE', 'E_CORE_ERROR',
        'E_CORE_WARNING', 'E_COMPILE_ERROR', 'E_COMPILE_WARNING', 'E_USER_ERROR',
        'E_USER_WARNING', 'E_USER_NOTICE', 'E_STRICT', 'E_RECOVERABLE_ERROR',
        'E_DEPRECATED', 'E_USER_DEPRECATED',
    ];
    $set = [];
    $missing = [];
    foreach ($names as $name) {
        if (!defined($name)) {
            continue;
        }
        $bit = constant($name);
        if ($level & $bit) {
            $set[] = $name;
        } elseif (E_ALL & $bit) {
            $missing[] = '~' . $name;
        }
    }
    // Pick the more compact form: "E_ALL & ~..." when the value is a subset of
    // E_ALL with few bits removed, otherwise list the constants that are set.
    $is_subset = (($level | E_ALL) === E_ALL);
    if ($is_subset && !$missing) {
        return 'E_ALL';
    }
    if ($is_subset && count($missing) <= count($set)) {
        return 'E_ALL & ' . implode(' & ', $missing);
    }
    return $set ? implode(' | ', $set) : (string) $level;
}

/**
 * Identify the process that serves this script, so the plugin can report which
 * PHP-FPM service and pool's OPcache was actually inspected. Linux-only (reads
 * /proc); returns whatever it can determine and omits the rest elsewhere.
 */
function server_identity(): array
{
    $identity = ['sapi' => php_sapi_name()];
    // The worker's own title reveals the pool, e.g. "php-fpm: pool www".
    $self = @file_get_contents('/proc/self/cmdline');
    if (is_string($self) && $self !== '' && preg_match('/pool (\S+)/', str_replace("\0", ' ', $self), $m)) {
        $identity['pool'] = $m[1];
    }
    // The parent's title reveals the master and its config file (the service),
    // e.g. "php-fpm: master process (/etc/php-fpm.conf)".
    $status = @file_get_contents('/proc/self/status');
    if (is_string($status) && preg_match('/^PPid:\s*(\d+)/m', $status, $m)) {
        $master = @file_get_contents('/proc/' . $m[1] . '/cmdline');
        if (is_string($master) && $master !== '') {
            $title = trim(str_replace("\0", ' ', $master));
            // Only a real PHP-FPM master carries the "master process (config)" title.
            if (strpos($title, 'master process') !== false) {
                $identity['master'] = $title;
                if (preg_match('/\(([^)]+)\)/', $title, $cfg)) {
                    $identity['config'] = $cfg[1];
                }
            }
        }
    }
    return $identity;
}

// Per-file script data is large and only needed for the plugin's --top output,
// so it is opt-in via "?scripts=1".
$include_scripts = isset($_GET['scripts']) && $_GET['scripts'] !== '' && $_GET['scripts'] !== '0';

$opcache_status = function_exists('opcache_get_status') ? opcache_get_status($include_scripts) : false;
$opcache_config = function_exists('opcache_get_configuration') ? opcache_get_configuration() : false;
$loaded_ini = php_ini_loaded_file();

$payload = [
    'server' => server_identity(),
    'opcache_status' => $opcache_status === false ? [] : $opcache_status,
    'opcache_config' => $opcache_config === false ? [] : $opcache_config,
    'php.conf' => [
        'php.version' => phpversion(),
        'php.ini' => $loaded_ini === false ? 'N/A' : $loaded_ini,
    ],
    // A curated set of commonly tuned php.ini directives.
    'php.ini' => [
        'date.timezone' => ini_get('date.timezone'),
        'default_socket_timeout' => ini_get('default_socket_timeout'),
        'display_errors' => ini_bool_to_label(ini_get('display_errors')),
        'display_startup_errors' => ini_bool_to_label(ini_get('display_startup_errors')),
        'error_reporting' => error_reporting_to_label(ini_get('error_reporting')),
        'expose_php' => ini_bool_to_label(ini_get('expose_php')),
        'html_errors' => ini_bool_to_label(ini_get('html_errors')),
        'mail.add_x_header' => ini_bool_to_label(ini_get('mail.add_x_header')),
        'max_execution_time' => ini_get('max_execution_time'),
        'max_file_uploads' => ini_get('max_file_uploads'),
        'max_input_time' => ini_get('max_input_time'),
        'max_input_vars' => ini_get('max_input_vars'),
        'memory_limit' => ini_get('memory_limit'),
        'post_max_size' => ini_get('post_max_size'),
        'realpath_cache_size' => ini_get('realpath_cache_size'),
        'realpath_cache_ttl' => ini_get('realpath_cache_ttl'),
        'serialize_precision' => ini_get('serialize_precision'),
        'session.cookie_httponly' => ini_bool_to_label(ini_get('session.cookie_httponly')),
        'session.cookie_secure' => ini_bool_to_label(ini_get('session.cookie_secure')),
        'session.gc_maxlifetime' => ini_get('session.gc_maxlifetime'),
        'session.sid_length' => ini_get('session.sid_length'),
        'session.trans_sid_tags' => ini_get('session.trans_sid_tags'),
        'SMTP' => ini_get('SMTP'),
        'smtp_port' => ini_get('smtp_port'),
        'upload_max_filesize' => ini_get('upload_max_filesize'),
    ],
];

if (!headers_sent()) {
    header('Content-Type: application/json');
}

$json = json_encode($payload);
if ($json === false) {
    // Keep the response valid JSON even if a script path contains invalid UTF-8.
    $json = json_encode(['error' => json_last_error_msg()]);
}
echo $json;
