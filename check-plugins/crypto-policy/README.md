# Check crypto-policy

## Overview

Verifies that the system-wide cryptographic policy (as reported by update-crypto-policies) matches the expected setting. Returns WARN if the current policy differs from the desired one (default: "DEFAULT"). Useful for ensuring consistent TLS and cipher configurations across a fleet of servers.

**Data Collection:**

* Runs `update-crypto-policies --show` to determine the active system-wide crypto policy
* Compares the result against the expected policy name (case-insensitive)

**Compatibility:**

* Cross-platform

**Important Notes:**

* RHEL/CentOS/Fedora and other distributions that ship `update-crypto-policies`


## 