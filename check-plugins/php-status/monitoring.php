<?php
# 2021051201
print_r(
    json_encode(
        array_merge(
            opcache_get_status(false),
            opcache_get_configuration(),
            array(
                'php.conf' => array(
                    'php.version' => phpversion(),
                    'php.ini' => php_ini_loaded_file(),
                    )
                ),
            array(
                'php.ini' => array(
                    'date.timezone' => ini_get('date.timezone'),
                    'display_errors' => ini_get('display_errors'),
                    'error_reporting' => ini_get('error_reporting'),
                    'expose_php' => ini_get('expose_php'),
                    'max_execution_time' => ini_get('max_execution_time'),
                    'memory_limit' => ini_get('memory_limit'),
                    'post_max_size' => ini_get('post_max_size'),
                    'upload_max_filesize' => ini_get('upload_max_filesize'),
                )
            ),
        )
    )
);