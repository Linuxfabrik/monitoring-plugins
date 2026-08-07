<?php
/**
 * The base configuration for WordPress, reduced to what this check reads.
 */

define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'wordpress' );
define( 'DB_PASSWORD', 'linuxfabrik' );
define( 'DB_HOST', 'localhost' );

define( 'WP_HOME', 'https://www.example.com' );
define( 'WP_SITEURL', 'https://www.example.com' );

$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
