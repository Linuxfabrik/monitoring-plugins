# Check pip-updates

## Overview

Checks for outdated Python packages installed via pip. Reports the number of packages with available updates and lists them with current and latest versions.

**Data Collection:**

* Executes `python3 -m pip list --outdated --format=json` to get the list of outdated packages
* Optionally sources a virtualenv activate script before checking
* Supports all standard pip options for index URLs, exclusions, and package filtering
* May take more than 10 seconds to execute depending on the number of installed packages and network latency

**Compatibility:**

* Linux only

**Important Notes:**

* Requires `pip` v20.3+


## 