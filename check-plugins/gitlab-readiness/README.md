# Check gitlab-readiness

## Overview

Checks whether the GitLab instance is ready to accept traffic by querying the `/-/readiness` endpoint. Validates the status of all dependent services (database, Redis, Gitaly, etc.) and reports each individually. Alerts when the instance or any dependent service is not ready.

**Data Collection:**

* Queries the GitLab readiness endpoint (`/-/readiness?all=1`) via HTTP(S) to retrieve the health status of each dependent service
* Checks the following services: cache, chat, cluster_cache, cluster_shared_state, db, db_load_balancing, feature_flag, gitaly, master, queues, rate_limiting, repository_cache, sessions, shared_state, trace_chunks
* If any service reports a status other than "ok", the check alerts with the configured severity and truncates the error message to 46 characters

**Compatibility:**

* Cross-platform


**