# Check grassfish-players

## Overview

Monitors Grassfish digital signage players via the Grassfish API. Lists players whose data transfer is overdue, whose last access exceeds the configured threshold, or who are unlicensed. The player list can be filtered. Requires a Grassfish hostname and API token. Supports extended reporting via `--lengthy`.

**Data Collection:**

* Queries the Grassfish API (`/gv2/webservices/API` by default) to retrieve all player data
* Players can be filtered by `--box-id` (regex), `--box-state`, `--custom-id` (regex), `--is-installed`, `--is-licensed`, and `--transfer-status`
* By default, only players in "activated" state are checked
* Only players with warnings are shown in the table output (truncated to 10 entries)

**Compatibility:**

* Cross-platform


**