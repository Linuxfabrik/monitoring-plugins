# Check deb-lastactivity

## Overview

Checks how long ago the last APT package manager activity occurred (install, update, or remove). Alerts if no package management activity has happened within the configured thresholds (default: WARN after 90 days, CRIT after 365 days). Useful for detecting servers that have not been patched in a long time.

**Data Collection:**

* Runs `dpkg-query --show --showformat='${db-fsys:Last-Modified} ${Package}\n'` to retrieve the last modification timestamp for each installed package
* Uses the most recent timestamp across all packages as the "last activity" time

**Compatibility:**

* Cross-platform


**