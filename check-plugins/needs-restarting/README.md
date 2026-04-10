# Check needs-restarting

## Overview

Checks for processes that were started before they or one of their dependencies were updated. Useful for detecting servers that have been patched but not yet rebooted. Requires root or sudo.

**Data Collection:**

* On Red Hat: Uses the `needs-restarting` command. First checks `needs-restarting --reboothint` (return code 1 means reboot required), then `needs-restarting` for a process list of updated services.
* On Debian: Uses `needrestart -b` if available, which reports kernel status and services needing restart. Falls back to checking `/var/run/reboot-required`.

**Compatibility:**

* Linux only


**