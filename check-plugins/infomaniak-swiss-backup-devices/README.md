# Check infomaniak-swiss-backup-devices

## Overview

Checks each backup device (slot) across all Infomaniak Swiss Backup products via the Infomaniak API. Alerts when storage usage exceeds the configured thresholds or when a device reports an error state. Devices can be filtered by customer, name, tag, or user.

**Data Collection:**

* Queries the Infomaniak API for all Swiss Backup products and their device slots
* Requires a Bearer Token with scope "swiss-backup" from Infomaniak
* Output table is sorted by the "Tags" column

**Compatibility:**

* Cross-platform


**