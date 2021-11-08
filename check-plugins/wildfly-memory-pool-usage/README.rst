Check wildfly-memory-pool-usage
===============================

Overview
--------

This check plugin monitors the memory pool usage of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.

`How is the java memory pool divided? <https://stackoverflow.com/questions/1262328/how-is-the-java-memory-pool-divided>`_

    The heap memory is the runtime data area from which the Java VM allocates memory for all class instances and arrays. The heap may be of a fixed or variable size. The garbage collector is an automatic memory management system that reclaims heap memory for objects.

    * Eden Space: The pool from which memory is initially allocated for most objects.
    * Survivor Space: The pool containing objects that have survived the garbage collection of the Eden space.
    * Tenured Generation or Old Gen: The pool containing objects that have existed for some time in the survivor space

    Non-heap memory includes a method area shared among all threads and memory required for the internal processing or optimization for the Java VM. It stores per-class structures such as a runtime constant pool, field and method data, and the code for methods and constructors. The method area is logically part of the heap but, depending on the implementation, a Java VM may not garbage collect or compact it. Like the heap memory, the method area may be of a fixed or variable size. The memory for the method area does not need to be contiguous.

    * Permanent Generation: The pool containing all the reflective data of the virtual machine itself, such as class and method objects. With Java VMs that use class data sharing, this generation is divided into read-only and read-write areas.

    * Code Cache: The HotSpot Java VM also includes a code cache, containing memory that is used for compilation and storage of native code.

Memory usage on "Survivor" spaces like ``PS_Survivor_Space`` is ignored.

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
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/wildfly-memory-pool-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: wildfly-memory-pool-usage3 [-h] [-V] [--always-ok] [--critical CRIT]
                                      [--instance INSTANCE]
                                      [--mode {standalone,domain}] [--node NODE]
                                      -p PASSWORD [--timeout TIMEOUT] [--url URL]
                                      --username USERNAME [--warning WARN]

    Checks the memory pool usage of a Wildfly/JBossAS over HTTP.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --critical CRIT       Set the critical threshold.
      --instance INSTANCE   The instance (server-config) to check if running in
                            domain mode.
      --mode {standalone,domain}
                            The mode the server is running.
      --node NODE           The node (host) if running in domain mode.
      -p PASSWORD, --password PASSWORD
                            WildFly API password.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             WildFly API URL. Default: http://localhost:9990
      --username USERNAME   WildFly API username. Default: wildfly-admin
      --warning WARN        Set the warning threshold.


Usage Examples
--------------

.. code-block:: bash

    ./wildfly-memory-pool-usage --username wildfly-monitoring --password password --url http://wildfly:9990 --warning 80 --critical 90

Output:

.. code-block:: text

    8 Memory Pools checked, everything is ok.

    Heap:
    * G1_Eden_Space - Memory used: 0.0% (39.0MiB of unlimited), 45.0MiB committed
    * G1_Old_Gen - Memory used: 4.01% (20.5MiB of 512.0MiB max.), 29.0MiB committed
    * G1_Survivor_Space - Memory used: 0.0% (2.7MiB of unlimited), 3.0MiB committed

    Non-Heap:
    * CodeHeap_non-nmethods - Memory used: 23.53% (1.3MiB of 5.6MiB max.), 2.4MiB committed
    * Compressed_Class_Space - Memory used: 2.45% (5.1MiB of 208.0MiB max.), 5.6MiB committed
    * CodeHeap_profiled_nmethods - Memory used: 9.45% (11.1MiB of 117.2MiB max.), 12.2MiB committed
    * CodeHeap_non-profiled_nmethods - Memory used: 3.54% (4.2MiB of 117.2MiB max.), 4.2MiB committed
    * Metaspace - Memory used: 16.95% (43.4MiB of 256.0MiB max.), 44.6MiB committed


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if memory usage is above certain thresholds (default 80/90 %). Memory usage on "Survivor" spaces like ``PS_Survivor_Space`` is ignored.
* WARN if WildFly reports ``usage-threshold-exceeded == TRUE``


Perfdata / Metrics
------------------

* memory-pool-<name>-committed: Returns the amount of memory in bytes that is committed for the Java virtual machine to use. This amount of memory is guaranteed for the Java virtual machine to use.
* memory-pool-<name>-max: Returns the maximum amount of memory in bytes that can be used for memory management. This method returns -1 if the maximum memory size is undefined. This amount of memory is not guaranteed to be available for memory management if it is greater than the amount of committed memory. The Java virtual machine may fail to allocate memory even if the amount of used memory does not exceed this maximum size.
* memory-pool-<name>-used: The amount of used memory in bytes.
* memory-pool-<name>-used-percent: in percent


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
