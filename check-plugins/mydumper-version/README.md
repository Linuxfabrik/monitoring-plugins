# Check mydumper-version

## Overview

Checks whether a newer version of mydumper/myloader is available by comparing the locally installed version against the latest release from the GitHub API.

**Data Collection:**

* Runs `mydumper --version` locally to determine the installed version
* Queries the GitHub releases API for the latest version of `mydumper/mydumper`
* Caches the latest version information locally to reduce API calls (default: 24 hours)

**Compatibility:**

* Cross-platform

**Important Notes:**

* Requires `mydumper` to be installed and available in the system PATH


## 