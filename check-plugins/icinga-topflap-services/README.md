# Check icinga-topflap-services

## Overview

Detects fast-flapping Icinga services by counting state changes per service within a configurable lookback interval. Queries the IcingaDB event history and alerts when any service exceeds the configured number of state changes.

**Data Collection:**

* Fetches data from the IcingaDB event history via the IcingaWeb2 REST API using HTTP Basic authentication
* Groups events by host and service, then counts state changes per service within the lookback window
* Uses a temporary SQLite database to store and aggregate event data per check run (dropped and recreated each run)
* Credentials can be provided via command-line parameters or a password INI file (command-line takes precedence)

**Compatibility:**

* Cross-platform


**