# Check diacos

## Overview

Checks availability and response time of an [ID DIACOS](https://www.id-suisse-ag.ch/loesungen/abrechnung/id-diacos/) installation by performing a full login, diagnosis search, and logout cycle. Alerts if the total response time exceeds the configured thresholds. Useful for monitoring the health of DIACOS medical billing systems.

ID DIACOS is a coding software for accurate and fast invoicing in hospitals, allowing clinical services to be documented quickly and reliably within fee-payment systems such as G-DRG, SWISS-DRG, and EBM.

**Data Collection:**

* Performs three sequential API calls against the ID DIACOS REST API (`/axis2/idlogikrest`):
  1. `user.Login` - authenticates with the provided licence and user name, returns a session ID
  2. `classification.SearchDiagnoses` - performs a diagnosis search using configurable parameters
  3. `user.Logoff` - terminates the session
* Measures the total runtime across all three calls
* Each API call reports its own `totalTimeMillis` from the server response

**Compatibility:**

* Cross-platform


**