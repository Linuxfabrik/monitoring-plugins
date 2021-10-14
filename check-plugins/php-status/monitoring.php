<?php
# 2021072601

function return_bytes($size_str) {
    switch (substr ($size_str, -1)) {
        case 'M': case 'm': return (int)$size_str * 1048576;
        case 'K': case 'k': return (int)$size_str * 1024;
        case 'G': case 'g': return (int)$size_str * 1073741824;
        default: return $size_str;
    }
}

function return_off_on($val) {
    // A boolean ini value of "off" will be returned by init_get() as an empty string or "0" 
    // while a boolean ini value of "on" will be returned as "1".
    // Returns false if the configuration option doesn't exist.
    if ($val === FALSE) {
        return 'N/A';
    }
    if ($val == '' or $val == 0) {
        return 'Off';
    }
    if ($val == 1) {
        return 'On';
    }
    return 'undefined';
}

print_r(
    json_encode(
        array_merge(
            array('opcache_status' => function_exists('opcache_get_status') ? opcache_get_status(false) : []),
            array('opcache_config' => function_exists('opcache_get_configuration') ? opcache_get_configuration() : []),
            array('php.conf' => array(
                    'php.version' => phpversion(),
                    'php.ini' => php_ini_loaded_file()
                    )
                ),
            array('php.ini' => array(
                    'date.timezone' => ini_get('date.timezone'),
                    'display_errors' => return_off_on(ini_get('display_errors')),
                    'display_startup_errors' => return_off_on(ini_get('display_startup_errors')),
                    'error_reporting' => ini_get('error_reporting') ? ini_get('error_reporting') : 'N/A',
                    'expose_php' => return_off_on(ini_get('expose_php')),
                    'max_execution_time' => ini_get('max_execution_time'),
                    'memory_limit' => ini_get('memory_limit'),
                    'post_max_size' => ini_get('post_max_size'),
                    'upload_max_filesize' => ini_get('upload_max_filesize')
                )
            )
        ) // array_merge
    ) // json_encode
);
