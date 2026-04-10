# Check keycloak-stats

## Overview

Reports statistics from a Keycloak server via its HTTP API, including uptime, Java version, JVM details, and enabled/disabled feature flags. This is an informational check that always returns OK.

**Data Collection:**

* Authenticates against the Keycloak OIDC token endpoint using client credentials (`--client-id`, `--username`, `--password`)
* Queries the Keycloak Admin REST API at `/admin/serverinfo` to retrieve system information and feature flags
* Enabled/disabled features are available starting with Keycloak 22; on older versions, only disabled features are reported (from `profileInfo`)

**Compatibility:**

* Cross-platform


**