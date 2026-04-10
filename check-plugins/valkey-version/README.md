# Check valkey-version

## Overview

Checks the installed Valkey version against the endoflife.date API and alerts if the version is end-of-life or if newer releases are available. The check must run on the Valkey server itself, as it uses `valkey-server --version` to determine the installed version.

**Data Collection:**

* Executes `valkey-server --version` locally to determine the installed version
* Queries the [endoflife.date API](https://endoflife.date/api/valkey.json) to fetch EOL dates and latest available versions
* Caches API responses in a SQLite database to reduce network calls

**Compatibility:**

* Cross-platform

**Important Notes:**

* Tested with Valkey 7.2 and 8.0


## 