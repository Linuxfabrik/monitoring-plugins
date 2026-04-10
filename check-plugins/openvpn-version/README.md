# Check openvpn-version

## Overview

Checks the installed OpenVPN version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Executes `openvpn --version` (at the configured `--path`) to determine the installed version
* Queries the endoflife.date API at `https://endoflife.date/api/openvpn.json` to compare against known EOL dates and available releases
* Caches the API response in a local SQLite database to reduce network requests

**Compatibility:**

* Linux systems with OpenVPN installed

**Important Notes:**

* The check must run on the machine running OpenVPN itself to detect the installed version


## 