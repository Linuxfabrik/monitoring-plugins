# Check keycloak-memory-usage

## Overview

Monitors Java heap and non-heap memory usage of a Keycloak server via its HTTP API and alerts when memory usage exceeds configurable thresholds.

**Data Collection:**

* Authenticates against the Keycloak OIDC token endpoint using client credentials (`--client-id`, `--username`, `--password`)
* Queries the Keycloak Admin REST API at `/admin/serverinfo` to retrieve `memoryInfo` (used, total, free, freePercentage)

**Compatibility:**

* Cross-platform


**