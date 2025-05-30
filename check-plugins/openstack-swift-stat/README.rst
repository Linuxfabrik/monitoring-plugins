Check openstack-swift-stat
==========================

Overview
--------

The OpenStack Object Store project, known as Swift, offers cloud storage software so that you can store and retrieve lots of data with a simple API. This monitoring plugin displays and checks information for a Swift account and depending Swift containers.

You have to provide a path to an rc file to authenticate. A working rc file might look like this:

.. code-block:: text

    export OS_AUTH_URL=https://linuxfabrik.cloud/identity/v3
    export OS_IDENTITY_API_VERSION=3
    export OS_INTERFACE=public
    export OS_PROJECT_DOMAIN_NAME=default
    export OS_PROJECT_ID=492a82d9-003a-4f52-8891-406eb19d0573
    export OS_PROJECT_NAME=MYPROJECT
    export OS_REGION_NAME=default
    export OS_USER_DOMAIN_NAME=default
    export OS_USERNAME=MYUSER
    OS_PASSWORD='linuxfabrik'
    [ -z "$OS_PASSWORD" ] && read -e -p "Please enter your OpenStack Password for project $OS_PROJECT_NAME as user $OS_USERNAME: " OS_PASSWORD
    export OS_PASSWORD


Hints:

* Might take more than 10 seconds to execute.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openstack-swift-stat"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"
    "3rd Party Python modules",             "``python-swiftclient``, ``python-keystoneclient``"


Help
----

.. code-block:: text

    usage: openstack-swift-stat [-h] [-V] [--always-ok] [-c CRIT]
                                [--rc-file RC_FILE] [--test TEST] [-w WARN]

    The OpenStack Object Store project, known as Swift, offers cloud storage
    software so that you can store and retrieve lots of data with a simple API.
    This monitoring plugin displays and checks information for a Swift account and
    depending containers.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      -c, --critical CRIT  CRIT when only so many GiB are available. Default: <=
                           10
      --rc-file RC_FILE    Specifies a rc file to read connection parameters like
                           OS_USERNAME from (instead of specifying them on the
                           command line), for example
                           `/var/spool/icinga2/.openstack.cnf`. Default:
                           /var/spool/icinga2/.openstack.cnf
      --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                           stderr-file,expected-retc".
      -w, --warning WARN   WARN when only so many GiB are available. Default: <=
                           50


Usage Examples
--------------

.. code-block:: bash

    openstack-swift-stat --rc-file /var/spool/icinga2/rc/.openstack-myproject.rc

Output:

.. code-block:: text

    Account: 4 containers, 2.8M objects, 5.4TiB used, 90.9TiB quota

    Container ! Items  ! Quota    ! Used           ! Free              
    ----------+--------+----------+----------------+-------------------
    01        ! 2.4M   ! 0.0B     ! 2.2TiB         !                   
    02        ! 324.4K ! 3.1TiB   ! 3.1TiB (99.5%) ! 17.2GiB [WARNING] 
    03        ! 107.7K ! 0.0B     ! 111.8GiB       !                   
    04        ! 2.0    ! 204.9GiB ! 2.0GiB (1.0%)  ! 202.9GiB          


States
------

* If a quota is set on a container, alerts when there are only a few GB left, as specified by the ``--warning`` and ``--critical`` parameters.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    <container-name>_items,                     Number,             Number of items in Swift container
    <container-name>_used,                      Bytes,              Usage in Bytes


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
