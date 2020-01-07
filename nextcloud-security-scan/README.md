todo

Runs against https://scan.nextcloud.com/, so the check itself does not need to run on the same host that serves Nextcloud. Have a look at https://scan.nextcloud.com/ for further explanation.

Takes up to 30 seconds.

Works with ownCloud, too.



Run it once a day. There is an API limit at the scan.nextcloud.com server at the /api/queue endpoint with around 100 POST requests a day (you will then run into a "403 Forbidden").

Issues: --noproxy and --insecure not implemented