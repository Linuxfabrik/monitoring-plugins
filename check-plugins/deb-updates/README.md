# Check deb-updates

## Overview

Checks for available APT package updates on Debian, Ubuntu, and compatible systems. Reports the number of pending updates and upgrades, and alerts when updates are available. This check only lists updates and never actually installs anything. Requires root or sudo.

**Data Collection:**

* Runs `sudo apt-get update --quiet 2` to refresh the package cache
* Runs `apt list --upgradable` to determine available updates
* Stores the results in a local SQLite database for flexible querying via `--query`
* Optionally filters for security-critical updates only (`--only-critical`), matching packages from `*-security` repositories

**Compatibility:**

* Cross-platform


**