# Check python-version

## Overview

Checks the installed Python version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Executes `python3 --version` locally to determine the installed version
* Queries the endoflife.date API to get the EOL date and latest available releases
* Caches the API response in a local SQLite database to avoid excessive requests

**Compatibility:**

* Linux only

**Important Notes:**

* Must run on the server where Python is installed


## 