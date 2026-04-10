# Check moodle-version

## Overview

Checks whether the installed Moodle version is end-of-life (EOL) by comparing the local version against the endoflife.date API. Optionally alerts on available major, minor, or patch releases (each independently configurable).

**Data Collection:**

* Reads the installed Moodle version from `version.php` in the local Moodle installation directory (default: `/var/www/html/moodle`)
* Queries the endoflife.date API for the latest EOL and release information
* Caches API responses in a local SQLite database to reduce network calls

**Compatibility:**

* Cross-platform

**Important Notes:**

* Requires local file system access to the Moodle installation directory


## 