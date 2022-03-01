Check wildfly-non-xa-datasource-stats
=====================================

Overview
--------

This check plugin returns metrics of Non-XA datasources of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23+.

The check recognizes if a datasource does not support statistics.

To create a monitoring user, do this:

.. code-block:: bash

    /opt/wildfly/bin/add-user.sh 

.. code-block:: text

    What type of user do you wish to add? 
     a) Management User (mgmt-users.properties) 
     b) Application User (application-users.properties)
    (a): a

    Enter the details of the new user to add.
    Using realm 'ManagementRealm' as discovered from the existing property files.
    Username : wildfly-monitoring
    Password : 
    Re-enter Password : 
    What groups do you want this user to belong to? (Please enter a comma separated list, or leave blank for none)[  ]: 
    About to add user 'wildfly-monitoring' for realm 'ManagementRealm'
    Is this correct yes/no? yes
    Is this new user going to be used for one AS process to connect to another AS process? 
    e.g. for a slave host controller connecting to the master or for a Remoting connection for server to server Jakarta Enterprise Beans calls.
    yes/no? no

To enable database statistics:

* Open the WildFly Admin Console
* Go to Configuration > Subsystems > Datasources & Drivers > Datasources
* Select your datasource
* Click on View > Tab Attributes > Edit "Statistics Enabled"


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-non-xa-datasource-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: wildfly-non-xa-datasource-stats [-h] [-V] [--always-ok]
                                          [--critical CRIT]
                                          [--datasource DATASOURCE]
                                          [--instance INSTANCE]
                                          [--mode {standalone,domain}]
                                          [--node NODE] -p PASSWORD
                                          [--timeout TIMEOUT] [--url URL]
                                          --username USERNAME [--warning WARN]

    Returns metrics about Non-XA Datasources of a Wildfly/JBossAS over HTTP.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --critical CRIT       Set the critical threshold.
      --datasource DATASOURCE
                            The name of a specific datasource (repeating).
                            Default: None
      --instance INSTANCE   The instance (server-config) to check if running in
                            domain mode.
      --mode {standalone,domain}
                            The mode the server is running.
      --node NODE           The node (host) if running in domain mode.
      -p PASSWORD, --password PASSWORD
                            WildFly API password.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             WildFly API URL. Default: http://localhost:9990
      --username USERNAME   WildFly API username. Default: wildfly-monitoring
      --warning WARN        Set the warning threshold.



Usage Examples
--------------

.. code-block:: bash

    # return stats on all datasources
    ./wildfly-non-xa-datasource-stats --username wildfly-monitoring --password password --url http://wildfly:9990 --warning 80 --critical 90

    # return stats on specific datasources
    ./wildfly-non-xa-datasource-stats --username wildfly-monitoring --password password --url http://wildfly:9990 --warning 80 --critical 90 --datasource MyFirstDS --datasource MySecondDS

Output:

.. code-block:: text

    MyFirstDS: 0.0% active used (0/20), 0.0% max used (0/20); Statistics are not enabled for data source MySecondDS


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if active or max used datapool connections are above certain thresholds (default 80/90%).


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    non-xa-ds-<name>-active,                    Number,             The number of active connections. Each of the connections is either in use by an application or available in the pool.
    non-xa-ds-<name>-active-pct                 Percentage,         ``non-xa-ds-<name>-active / non-xa-ds-<name>-available * 100``
    non-xa-ds-<name>-available,                 Number,             The number of available connections in the pool.
    non-xa-ds-<name>-blockingfailurecount,      Number
    non-xa-ds-<name>-createdcount,              Number,             The number of connections created.
    non-xa-ds-<name>-destroyedcount,            Number,             The number of connections destroyed.
    non-xa-ds-<name>-idlecount,                 Number
    non-xa-ds-<name>-inusecount,                Number,             The number of connections currently in use.
    non-xa-ds-<name>-maxused,                   Number,             The maximum number of connections used.
    non-xa-ds-<name>-maxused-pct,               Percentage,         ``non-xa-ds-<name>-maxused / non-xa-ds-<name>-available * 100``
    non-xa-ds-<name>-maxwaitcount,              Number,             The maximum number of requests waiting for a connection at the same time.
    non-xa-ds-<name>-waitcount,                 Number,             The number of requests that had to wait for a connection.

Also have a look at https://access.redhat.com/documentation/en-us/jboss_enterprise_application_platform/6.2/html/administration_and_configuration_guide/datasource_statistics.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
