# Check apache-httpd-version

## Overview

Checks the installed Apache httpd version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Detects the installed Apache httpd version by running `httpd -v` (RHEL) or `apache2 -v` (Debian-based systems)
* Queries the [endoflife.date API](https://endoflife.date/api/apache.json) to determine EOL status and available releases
* Caches the API response in a local SQLite database to reduce network calls

**Compatibility:**

* Cross-platform

**Important Notes:**

* Runs on all systems where the Apache binary is named either `httpd` or `apache2`
* Must run on the Apache httpd server itself to detect the installed version


## 