/usr/lib64/nagios/plugins/nextcloud-stats --url https://myserver:8443/ocs/v2.php/apps/serverinfo/api/v1/info --username myuser --password mypassword

Run every 5 minutes.
Takes approx. 1 to 2 seconds.

Only throws a warning if app updates are available.

Inspired by: https://github.com/BornToBeRoot/check_nextcloud



