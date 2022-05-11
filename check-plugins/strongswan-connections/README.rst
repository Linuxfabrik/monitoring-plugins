Check strongswan-connection
===========================

Overview
--------

This Nagios/Icinga monitoring plugin checks IPSec connection states. It connects to the vici plugin in libcharon using the "Versatile IKE Control Interface" (VICI) to monitor the IKE daemon "charon". The most prominent user of the VICI interface is strongSwan/swanctl.

Hints:

* Must be running locally on the server hosting 'charon' to be able to check IPSec connection states.
* "EST" means "Established".


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/strongswan-connection"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3"
    "Requirements",                         "Python module ``vici``"


Help
----

.. code-block:: text

    usage: strongswan-connections [-h] [-V] [--always-ok] [--lengthy]
                                  [--socket SOCKET] [--test TEST]

    Checks IPSec connection states in libcharon using the Versatile IKE Control
    Interface (VICI) to monitor the IKE daemon 'charon'. The most prominent user
    of the VICI interface is strongSwan/swanctl.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit
      --always-ok      Always returns OK.
      --lengthy        Extended reporting.
      --socket SOCKET  Path to Versatile IKE Control Interface (VICI) Socket.
                       Default: /var/run/charon.vici
      --test TEST      For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                       file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./strongswan-connections

Output:

.. code-block:: text

    Everything is ok.

    Conn.     ! State ! Re-Authentication   ! Child     ! Mode:State       ! Re-Keying           ! Expires             ! Rx       ! Tx       
    ----------+-------+---------------------+-----------+------------------+---------------------+---------------------+----------+----------
    example   ! EST   ! 2022-05-11 13:36:24 ! example   ! TUNNEL:INSTALLED ! 2022-05-11 11:02:36 ! 2022-05-11 11:12:53 ! 0.0B     ! 0.0B     
    acme      ! EST   ! 2022-05-11 14:57:14 ! acme1     ! TUNNEL:INSTALLED ! 2022-05-11 14:03:57 ! 2022-05-11 15:02:29 ! 1.3MiB   ! 997.0KiB 
    acme      ! EST   ! 2022-05-11 14:57:14 ! acme2     ! TUNNEL:INSTALLED ! 2022-05-11 13:38:36 ! 2022-05-11 15:10:18 ! 633.2KiB ! 634.5KiB

.. code-block:: bash

    ./strongswan-connections --socket /run/strongswan/charon.vici --lengthy

Output:

.. code-block:: text

    Everything is ok.

    Conn.     ! State ! Established         ! Re-Authentication   ! IKE ! Local               ! Remote             ! Encryption/Integrity/Pseudo Random/DH                     ! Child     ! Mode:State       ! Local         ! Remote        ! Prot:Encryption/Integrity/DH                ! Installed           ! Re-Keying           ! Expires             ! Rx       ! Tx       
    ----------+-------+---------------------+---------------------+-----+---------------------+--------------------+-----------------------------------------------------------+-----------+------------------+---------------+---------------+---------------------------------------------+---------------------+---------------------+---------------------+----------+----------
    example   ! EST   ! 2022-05-11 06:08:24 ! 2022-05-11 13:36:24 ! v2  ! 198.51.100.246:500  ! 203.0.113.226:500  ! AES_CBC-256/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/ECP_256   ! example   ! TUNNEL:INSTALLED ! 192.0.2.0/24  ! 10.0.11.0/24  ! ESP:AES_GCM_16-256/None/ECP_256             ! 2022-05-11 10:06:53 ! 2022-05-11 11:02:36 ! 2022-05-11 11:12:53 ! 0.0B     ! 0.0B     
    acme      ! EST   ! 2022-05-10 15:03:43 ! 2022-05-11 14:57:14 ! v2  ! 198.51.100.246:4500 ! 203.0.113.28:4500  ! AES_CBC-256/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_1536 ! acme1     ! TUNNEL:INSTALLED ! 192.0.2.0/24  ! 172.16.0.0/16 ! ESP:AES_CBC-256/HMAC_SHA2_256_128/MODP_1536 ! 2022-05-11 06:14:29 ! 2022-05-11 14:03:57 ! 2022-05-11 15:02:29 ! 1.2MiB   ! 934.5KiB 
    acme      ! EST   ! 2022-05-10 15:03:43 ! 2022-05-11 14:57:14 ! v2  ! 198.51.100.246:4500 ! 203.0.113.28:4500  ! AES_CBC-256/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_1536 ! acme2     ! TUNNEL:INSTALLED ! 192.0.99.0/24 ! 172.16.0.0/16 ! ESP:AES_CBC-256/HMAC_SHA2_256_128/MODP_1536 ! 2022-05-11 06:22:18 ! 2022-05-11 13:38:36 ! 2022-05-11 15:10:18 ! 599.7KiB ! 601.2KiB


States
------

* WARN if there are no active connections at all.
* WARN if configured connections != active connections.
* WARN if any child is not connected.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    <connname>_established,                     Seconds,            Seconds the IKE_SA has been established
    <connname>_rekey-time,                      Seconds,            Seconds before IKE_SA gets rekeyed
    <connname>_<childname>_bytes-in,            Bytes,              Number of input bytes processed
    <connname>_<childname>_bytes-out,           Bytes,              Number of output bytes processed
    <connname>_<childname>_install-time,        Seconds,            Seconds the CHILD_SA has been installed
    <connname>_<childname>_life-time,           Seconds,            Seconds before CHILD_SA expires
    <connname>_<childname>_rekey-time,          Seconds,            Seconds before CHILD_SA gets rekeyed


Troubleshooting
---------------

[Errno 2] No such file or directory
    Check the path to ``charon.vici``, and specify ``--socket`` accordingly.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
