# Check file-size

## Overview

Checks file sizes against configurable thresholds using human-readable units (e.g. 25M, 1G). Supports glob patterns and SMB shares. Directories are skipped because their reported size is not meaningful across filesystems. Alerts when any file exceeds the configured size thresholds. Requires root or sudo.

**Data Collection:**

* Uses Python's `glob.iglob()` for local files and `lib.smb` for SMB shares
* Follows symbolic links
* Reads `st_size` from `os.stat()` for each matched file
* Directories are silently skipped

**Compatibility:**

* Cross-platform: Linux and Windows


**