# Check gitlab-liveness

## Overview

Checks whether the GitLab application server is alive by querying the `/-/liveness` endpoint. This probe detects deadlocked Rails controllers caused by multi-threading issues. A successful response confirms that no controllers are deadlocked.

**Data Collection:**

* Sends an HTTP GET request to the GitLab liveness endpoint (default: `http://localhost/-/liveness`)
* Expects a JSON response containing a "status" field and no "error" field

**Compatibility:**

* Cross-platform


**