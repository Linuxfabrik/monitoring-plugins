# Check file-count

## Overview

Counts the number of files matching a glob pattern and alerts when the count exceeds the configured thresholds. Can filter by modification time range, restrict to files or directories only, and supports SMB shares.

**Data Collection:**

* Uses Python's `pathlib.Path.glob()` for local files and `lib.smb` for SMB shares
* Applies `os.stat()` once per item to determine type and modification time, minimizing syscalls
* When both `--warning` and `--critical` thresholds are simple numeric values, the check breaks early once the threshold is exceeded (to save time and resources on directories with millions of files)

**Compatibility:**

* Cross-platform: Linux and Windows


**