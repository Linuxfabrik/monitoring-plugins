# Check gitlab-health

## Overview

Checks whether the GitLab application server is running by querying the `/-/health` endpoint. This is a lightweight probe that does not hit the database or verify other backend services. A successful response confirms that the application server is processing requests, but does not guarantee that the database or other services are ready.

**Data Collection:**

* Sends an HTTP GET request to the GitLab health endpoint (default: `http://localhost/-/health`)
* Expects the plain-text response "GitLab OK"

**Compatibility:**

* Cross-platform


**