Notes on all Keycloak Plugins
=============================

Authentication
--------------

To check against the API,

* Create a new user 'keycloak-monitoring' in your 'master' realm,
* Assign a permanent password (Credentials tab),
* remove the default role(s) (Role Mappings tab)
* and assign ONE of the "master" realm roles except "impersonation". We recommend the "query-groups" role or, if not available, the "create-realm" role. (Tab: Role Mappings)
