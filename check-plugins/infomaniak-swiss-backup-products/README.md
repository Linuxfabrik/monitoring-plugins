# Check infomaniak-swiss-backup-products

## Overview

Checks Infomaniak Swiss Backup product details via the Infomaniak API. Alerts when products are locked, maintenance window is active, or storage quota is exceeded. Products can be filtered by customer or tag.

**Data Collection:**

* Queries the Infomaniak API for all Swiss Backup product details
* Requires a Bearer Token from Infomaniak
* Output table is sorted by the "Tags" column
* In the table output, the column header "Dev" means the number of devices created, "Maint." stands for "Maintenance", and "Busy" corresponds to the API field `has_operation_in_progress`

**Compatibility:**

* Cross-platform


**