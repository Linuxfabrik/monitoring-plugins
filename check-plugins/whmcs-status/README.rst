Check whmcs-status
==================

Overview
--------

WHMCS (Web Host Manager Complete Solution) is a billing, support and automation platform designed primarily for web hosting companies and service providers. This check plugin returns the health status of a WHMCS server via its HTTP-based API, using the `GetHealthStatus API endpoint <https://developers.whmcs.com/api-reference/gethealthstatus/>`_.

Configuring API acceess and creating an API user in WHMCS is a bit tedious. First, allow IP Addresses to connect to WHMCS:

* Open https://whmcs.example.com/path/to/whmcs-admin/configgeneral.php#tab=10), Tab Security
* API IP Access Restriction > Add IP of the hosts accessing the API

Then create an administrator role with "API Access":

* Open https://whmcs.example.com/path/to/whmcs-admin/configadminroles.php
* Add New Role Group: "API Role Group"
* Grant "API Acccess" and save changes

Create an Administrator User with Role "API Access":

* Open https://whmcs.example.com/path/to/whmcs-admin/configadmins.php
* Add New Administrator
* Administrator Role: API Role Group
* First Name: WHMCS
* Last Name: Monitoring
* Username: whmcs-monitoring
* Password: set a password

Create API Credentials:

* Open https://whmcs.example.com/path/to/whmcs-admin/configapicredentials.php
* API Roles > Create API Role:

    * Role Name: GetHealthStatus
    * Allowed API Actions: Servers > GetHealthStatus

* API Credentials > Generate New API Credential

    * Admin User: WHMCS Monitoring
    * API Role(s): GetHealthStatus

Note the api_identifier and the api_secret. You will need both to configure this plugin.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/whmcs-status"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: whmcs-status [-h] [-V] --identifier IDENTIFIER [--insecure]
                        [--no-proxy] [-p PASSWORD] --secret SECRET
                        [--timeout TIMEOUT] [--url URL] [--username USERNAME]

    Returns the health status of a WHMCS server using its HTTP-based API.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --identifier IDENTIFIER
                            WHMCS API identifier. Default: None
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      -p, --password PASSWORD
                            HTTP basic auth password.
      --secret SECRET       WHMCS API secret. Default: None
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
      --url URL             WHMCS API URL. Default: http://127.0.0.1:8080
      --username USERNAME   HTTP basic auth username.


Usage Examples
--------------

.. code-block:: bash

    ./whmcs-status --identifier=myidentifier --secret=linuxfabrik --url=https://whmcs.example.com

Output:

.. code-block:: text

    There are 4 messages, ordered by severity.

    * WHMCS: Please upgrade to the latest version: 8.12.0 You can learn about performing an upgrade in our documentation. [WARNING]
    * WHMCS: Module debugging is currently enabled. We recommend that you disable this when you finish debugging. Continuous use may degrade performance. For more information, see our documentation. [WARNING]
    * WHMCS: We have detected that your WHMCS installation is currently using the default template names for one or more of the active templates. If you have made any customisations, we strongly recommend creating a custom template directory to avoid losing your customisations the next time you upgrade.You are currently using a default template in the following locations:CartPlease review our documentation on making a custom theme for help doing this. [WARNING]
    * PHP: Your PHP version 8.1.31 is supported by WHMCS. Your PHP version does not receive regular updates but is the latest supported by WHMCS. (info)


States
------

* WARN if messages with a status greater than "info" are returned.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
