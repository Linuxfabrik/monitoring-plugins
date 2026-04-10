# Check axenita-stats

## Overview

Monitors the health and performance of an Axenita/Achilles installation by querying four API endpoints: ReadModel state, active user sessions, build information, and maintenance mode status. Alerts if any endpoint returns an error, if the ReadModel initialization is incomplete, or if maintenance mode is active. Axenita Praxissoftware is powered by Axonlab / Axon Lab AG.

**Data Collection:**

* Queries four Axenita/Achilles REST API endpoints:
    * `/api/admin/readmodel/state` - ReadModel initialization state, current step, total steps, and duration
    * `/api/admin/user-info/number-of-current-sessions` - logged-in users and active sessions
    * `/api/build-info` - version and build timestamp
    * `/api/login/maintenance-state-active` - maintenance mode status

**Compatibility:**

* Cross-platform

**Important Notes:**

* Requires network access to the Axenita/Achilles API (default: `http://localhost:10000/achilles/ar`)


## 