# Check strongswan-connections

## Overview

Checks IPSec connection states on a strongSwan VPN gateway by connecting to the charon daemon via the VICI (Versatile IKE Control Interface) socket. Reports IKE SA and CHILD SA states, re-authentication/re-keying timers, and traffic counters. "EST" in the output means "Established".

**Data Collection:**

* Connects to the VICI socket (default: `/run/strongswan/charon.vici`) to enumerate configured and active connections
* Iterates over all IKE SAs and their CHILD SAs, collecting state, timing, and traffic data
* `--lengthy` provides additional columns: established time, IKE version, local/remote endpoints, encryption/integrity details, and per-child local/remote traffic selectors

**Important Notes:**

* strongSwan with VICI interface (swanctl); tested with VICI protocol versions 5.7 and 5.9
* Must be run locally on the strongSwan host (needs access to the VICI socket)
* Requires root or sudo

**Compatibility:**

* Cross-platform


## 