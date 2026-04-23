# Keycloak Plugins

The Keycloak plugins query the Keycloak Admin REST API (`/admin/serverinfo`)
against the `master` realm. Tested with Keycloak 18 and later.


## Plugins in this group

* `keycloak-memory-usage`: JVM heap usage of the Keycloak server.
* `keycloak-stats`: realm, client, user and active-session counts.
* `keycloak-version`: installed Keycloak version, with an EOL check against
  the Keycloak release schedule.


## Authentication

All three plugins need a Keycloak user in the `master` realm with read access
to the Admin REST API. Reading `/admin/serverinfo` is a privileged operation,
so the user needs exactly one of the following minimal roles:

* Client role `query-groups` of the `master-realm` client (recommended, least
  privilege). In the role-mapping dialog, switch the filter from *Realm roles*
  to *Client roles* and pick the `master-realm` client to see it.
* Realm role `create-realm` on the `master` realm (fallback if the client-role
  option is not available in your workflow).

Any role of the `master-realm` client other than `impersonation` works too;
pick the narrowest one you are comfortable with.

Setup in the Admin Console (Keycloak 19 and later):

1. *Users > Add user*, set *Username* to `keycloak-monitoring`, leave *Email
   verified* off, *Create*.
2. Open the user, *Credentials > Set password*. Type the password twice,
   **turn the "Temporary" toggle off** so the password does not expire at
   first login, *Save*.
3. *Role mapping > Assign role*. Switch the filter to the `master-realm`
   client and assign `query-groups`. If you prefer the realm-role fallback,
   stay on *Realm roles* and assign `create-realm` instead.

The plugins are invoked with `--url`, `--realm master` (the default),
`--username keycloak-monitoring` and `--password`.


## Common parameters

Shared across all Keycloak plugins (run `<plugin> --help` for the full list):

* `--url`: Keycloak base URL. Default `http://127.0.0.1:8080`.
* `--realm`: realm the user authenticates against. Default `master`.
* `--client-id`: OIDC client used to obtain the admin token. Default
  `admin-cli`.
* `--username` / `--password`: credentials of the monitoring user.
* `--insecure`: skip TLS certificate verification.
* `--no-proxy`: ignore `HTTP_PROXY` / `HTTPS_PROXY`.
* `--timeout`: network timeout in seconds.


## Service Sets in the Icinga Director Basket

The shipped basket activates the Keycloak plugins through one Service Set,
assigned via the `keycloak` tag on the host:

* **Keycloak Service Set**: runs `keycloak-memory-usage`, `keycloak-stats`
  and `keycloak-version` against the monitoring user above.
