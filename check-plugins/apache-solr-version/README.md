# Check apache-solr-version

## Overview

Checks the installed Apache Solr version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Detects the installed Apache Solr version by running `<path> version` (default path: `/opt/solr/bin/solr`)
* Queries the [endoflife.date API](https://endoflife.date/api/solr.json) to determine EOL status and available releases
* Caches the API response in a local SQLite database to reduce network calls

**Compatibility:**

* Cross-platform

**Important Notes:**

* Must run on the Apache Solr server itself to detect the installed version


## 