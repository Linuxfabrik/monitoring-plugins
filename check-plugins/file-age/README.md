# Check file-age

## Overview

Checks the time since last modification of one or more files or directories. Supports glob patterns (including recursive), SMB shares, and optional aggregation (mean or median) across all matched files. Can also alert on the number of files within a specific age range. Requires root or sudo.

**Data Collection:**

* Uses Python's `pathlib.Path.glob()` for local files and `lib.smb` for SMB shares
* Follows symbolic links
* Reads the `st_mtime` attribute from each file or directory
* Supports filtering by `--only-files` or `--only-dirs`
* Files that disappear during the check (e.g. temporary files) are silently skipped

**Compatibility:**

* Cross-platform: Linux and Windows


**