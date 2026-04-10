# Check grassfish-licenses

## Overview

Monitors available Grassfish digital signage licenses via the Grassfish API. Alerts when no more licenses of any type are available. Requires a Grassfish hostname and API token.

**Data Collection:**

* Queries the Grassfish API (`/gv2/webservices/API` by default) to retrieve all license types and their availability
* Reports total, used, and available license counts per type

**Compatibility:**

* Cross-platform


**