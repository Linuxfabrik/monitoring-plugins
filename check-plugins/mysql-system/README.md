# Check mysql-system

## Overview

Checks system requirements and kernel settings specifically for MySQL/MariaDB, including swap configuration, open file limits, and other OS-level parameters that affect database performance and stability. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):get_kernel_info(), v1.9.8.

**Data Collection:**

* Counts open ports using `psutil` (if available)
* Reads Linux kernel parameters via `sysctl`
* Does not need access to MySQL/MariaDB itself

**Compatibility:**

* On Windows there are no kernel settings that can be checked


**