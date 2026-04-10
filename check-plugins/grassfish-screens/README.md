# Check grassfish-screens

## Overview

Checks if screens attached to Grassfish digital signage players are on or off via the Grassfish API. The player list can be filtered by box state, customer ID, or custom ID. Requires a Grassfish hostname and API token. Alerts when screens are unexpectedly off. Supports extended reporting via `--lengthy`.

**Data Collection:**

* Queries the Grassfish API (`/gv2/webservices/API` by default) to retrieve all player data, then fetches screen status for each matching player via the `Players/<id>/Screens` endpoint
* Screen data is cached locally to reduce API load (configurable via `--cache-expire`, default: 8 hours)
* A screen is considered "off" when its last update exceeds the `--warning` threshold
* Players can be filtered by `--box-id` (regex), `--box-state`, `--custom-id` (regex), `--is-installed`, `--is-licensed`, and `--transfer-status`
* By default, only players in "activated" state are checked
* Only players with screen warnings are shown in the table output (truncated to 20 entries)

**Compatibility:**

* Cross-platform


**