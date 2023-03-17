Check wildfly-memory-pool-usage
===============================

Overview
--------

This check plugin monitors the memory pool usage of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23+.

`How is the java memory pool divided? <https://stackoverflow.com/questions/1262328/how-is-the-java-memory-pool-divided>`_

    **Heap memory** is the runtime data area from which the Java VM allocates memory for all class instances and arrays. The heap may be of a fixed or variable size. The garbage collector is an automatic memory management system that reclaims heap memory for objects.

    * PS Eden Space: The pool from which memory is initially allocated for most objects.
    * PS Tenured Generation or PS Old Gen: The pool containing objects that have existed for some time in the survivor space
    * PS Survivor Space: The pool containing objects that have survived the garbage collection of the Eden space.

    **Non-heap memory** includes a method area shared among all threads and memory required for the internal processing or optimization for the Java VM. It stores per-class structures such as a runtime constant pool, field and method data, and the code for methods and constructors. The method area is logically part of the heap but, depending on the implementation, a Java VM may not garbage collect or compact it. Like the heap memory, the method area may be of a fixed or variable size. The memory for the method area does not need to be contiguous.

    * Code Cache: The HotSpot Java VM also includes a code cache, containing memory that is used for compilation and storage of native code.
    * Permanent Generation: The pool containing all the reflective data of the virtual machine itself, such as class and method objects. With Java VMs that use class data sharing, this generation is divided into read-only and read-write areas.
    * Compressed Class Space
    * Metaspace

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


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-memory-pool-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: wildfly-memory-pool-usage [-h] [-V] [--always-ok]
                                     [--instance INSTANCE]
                                     [--mode {standalone,domain}] [--node NODE]
                                     -p PASSWORD [--timeout TIMEOUT] [--url URL]
                                     --username USERNAME

    Checks the memory pool usage of a Wildfly/JBossAS over HTTP.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
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


Usage Examples
--------------

.. code-block:: bash

    ./wildfly-memory-pool-usage --username wildfly-monitoring --password password --url http://wildfly:9990

Output:

.. code-block:: text

    Everything is ok.

    name                   ! Type     ! Usage used / committed / max   ! Collection used / committed/ max 
    -----------------------+----------+--------------------------------+----------------------------------
    Code_Cache             ! NON_HEAP ! 37.6MiB / 38.1MiB / 240.0MiB   ! N/A                              
    Metaspace              ! NON_HEAP ! 124.6MiB / 137.4MiB / 256.0MiB ! N/A                              
    Compressed_Class_Space ! NON_HEAP ! 16.7MiB / 20.1MiB / 248.0MiB   ! N/A                              
    Eden_Space             ! HEAP     ! 28.3MiB / 43.8MiB / 136.5MiB   ! 0.0B / 43.8MiB / 136.5MiB        
    Survivor_Space         ! HEAP     ! 86.0KiB / 5.4MiB / 17.1MiB     ! 86.0KiB / 5.4MiB / 17.1MiB       
    Tenured_Gen            ! HEAP     ! 65.7MiB / 109.0MiB / 341.4MiB  ! 65.4MiB / 81.8MiB / 341.4MiB


States
------

* WARN if memory pool instance is invalid.
* WARN if usage of the instance of a memory pool exceeded a threshold in any way.
* WARN if usage of the instance of a memory pool collection exceeded a threshold in any way.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    memory-pool-<name>-usage-committed          Bytes,              "Amount of memory that is reserved at the operating system level for the JVM process at the moment."
    memory-pool-<name>-usage-init,              Bytes,              "The initial amount of memory that the JVM requested from the operating system at startup. Controlled by the ``-Xms`` cli option."
    memory-pool-<name>-usage-max                Bytes,              "Maximum amount of memory that the JVM will ever try to request / allocate from the operating system. Controlled by the ``-Xmx`` cli option."
    memory-pool-<name>-usage-used               Bytes,              "Amount of memory that is actually in use, so the memory consumed by all objects including the objects that are not reachable but haven't been garbaged collected yet. Can be lower than init."
    memory-pool-<name>-collection-usage-committed, Bytes,           "Only if 'Collection Usage' is enabled."
    memory-pool-<name>-collection-usage-init,   Bytes,              "Only if 'Collection Usage' is enabled."
    memory-pool-<name>-collection-usage-max,    Bytes,              "Only if 'Collection Usage' is enabled."
    memory-pool-<name>-collection-usage-used,   Bytes,              "Only if 'Collection Usage' is enabled."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
