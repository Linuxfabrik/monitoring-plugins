Check keycloak-stats
====================

Overview
--------

Returns some useful information about a Keycloak server using its HTTP-based API. Tested with Keycloak 18+.

Hints:

* See `Creating an API user account to monitor Keycloak <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-KEYCLOAK.rst>`_.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/keycloak-stats"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"


Help
----

.. code-block:: text

    usage: keycloak-stats [-h] [-V] [--client-id CLIENT_ID] [--insecure]
                          [--no-proxy] [-p PASSWORD] [--realm REALM]
                          [--timeout TIMEOUT] [--url URL] [--username USERNAME]

    Returns some useful information about a Keycloak server using its HTTP-based
    API. Tested with Keycloak 18+.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --client-id CLIENT_ID
                            Keycloak API Client-ID. Default: admin-cli
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      -p, --password PASSWORD
                            Keycloak API password. Default: admin
      --realm REALM         Keycloak API Realm. Default: master
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
      --url URL             Keycloak API URL. Default: http://127.0.0.1:8080
      --username USERNAME   Keycloak API username. Default: admin


Usage Examples
--------------

.. code-block:: bash

    ./keycloak-stats --username=keycloak-monitoring --password=linuxfabrik --url=http://keycloak:8080

Output ("Enabled Features" available with Keycloak 22+):

.. code-block:: text

    Up 5m 12s, running under user `keycloak`; Java v21.0.5, OpenJDK 64-Bit Server VM, /usr/lib/jvm/java-21-openjdk-21.0.5.0.11-2.el9.x86_64

    Enabled Features: 
    * ACCOUNT_API (default)
    * ACCOUNT_V3 (default)
    * ADMIN_API (default)
    * ADMIN_V2 (default)
    * AUTHORIZATION (default)
    * CIBA (default)
    * CLIENT_POLICIES (default)
    * DEVICE_FLOW (default)
    * HOSTNAME_V2 (default)
    * IMPERSONATION (default)
    * KERBEROS (default)
    * LOGIN_V2 (default)
    * ORGANIZATION (default)
    * PAR (default)
    * PERSISTENT_USER_SESSIONS (default)
    * STEP_UP_AUTHENTICATION (default)
    * WEB_AUTHN (default)

    Disabled Features: 
    * ADMIN_FINE_GRAINED_AUTHZ (preview)
    * CACHE_EMBEDDED_REMOTE_STORE (experimental)
    * CLIENT_SECRET_ROTATION (preview)
    * CLIENT_TYPES (experimental)
    * CLUSTERLESS (experimental)
    * DECLARATIVE_UI (experimental)
    * DOCKER (disabled_by_default)
    * DPOP (preview)
    * DYNAMIC_SCOPES (experimental)
    * FIPS (disabled_by_default)
    * LOGIN_V1 (deprecated)
    * MULTI_SITE (disabled_by_default)
    * OID4VC_VCI (experimental)
    * OPENTELEMETRY (preview)
    * PASSKEYS (preview)
    * RECOVERY_CODES (preview)
    * SCRIPTS (preview)
    * TOKEN_EXCHANGE (preview)
    * TRANSIENT_USERS (experimental)
    * UPDATE_EMAIL (preview)


States
------

* Always returns OK.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    uptime,                                     Seconds,            "The time the server has been running for"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
