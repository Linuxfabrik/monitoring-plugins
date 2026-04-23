# Rocket.Chat Plugins

The Rocket.Chat plugins talk to the Rocket.Chat REST API. They need a user
that holds the `view-statistics` permission (the stats API is not public).


## Plugins in this group

* `rocketchat-stats`: total and active users, online users, channels,
  messages, uploads and file-storage usage.
* `rocketchat-version`: installed Rocket.Chat version, EOL check.


## Authentication

Create a dedicated Rocket.Chat user with permission to read statistics. How
you grant the permission depends on the edition.


### Rocket.Chat Enterprise Edition

Custom roles are an Enterprise feature. In the admin area (top-left avatar
menu > *Administration*):

1. *Permissions > New Role*: name `stats`, scope `Users`, grant only the
   `View Statistics` permission, *Save*.
2. *Users > New*: username `rocket-stats`, assign a password manually, add
   the `stats` role under *Roles*, *Save*.


### Rocket.Chat Community Edition

CE does not allow creating custom roles through the UI; you repurpose a
built-in role instead.

* **Simple**: create `rocket-stats` with the built-in `admin` role.
  Overprivileged but one step.
* **Narrower**: in *Administration > Permissions*, tick `View Statistics` on
  the built-in `bot` role, then create `rocket-stats` with the `bot` role.
  The `bot` role also exempts the user from rate limits, which is acceptable
  for a monitoring account.


### Invoking the Plugins

The plugins are then called with `--url` (e.g.
`https://rocketchat.example.com/api/v1`), `--username=rocket-stats` and
`--password`.


## Common parameters

Shared across both Rocket.Chat plugins (run `<plugin> --help` for the full
list):

* `--url`: Rocket.Chat API base URL. Default
  `http://localhost:3000/api/v1`.
* `--username` / `--password`: credentials of the monitoring user.
* `--insecure`: skip TLS certificate verification.
* `--no-proxy`: ignore `HTTP_PROXY` / `HTTPS_PROXY`.
* `--timeout`: network timeout in seconds.


## Service Sets in the Icinga Director Basket

The shipped basket activates both Rocket.Chat plugins through one Service
Set, assigned via the `rocketchat` tag on the host:

* **Rocket.Chat Service Set**: runs `rocketchat-stats` and
  `rocketchat-version` against the `stats` user above.
