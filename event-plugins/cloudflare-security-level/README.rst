Event-Plugin cloudflare-security-level
======================================

Overview
--------

Event Plugin: Changes the security level for a zone at Cloudflare to "under_attack" if state of the service - from which this event plugin was called - changes to CRITICAL (even in SOFT state). Changes to "medium" when the state is OK. If the zone/site is in "Under Attack Mode", Cloudflare will display a JavaScript challenge when you visit this website. This event plugin is useful, for example, when the Apache httpd status check reports overuse.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Event Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/dummy"
    "Check Interval Recommendation",        "Event Plugin: On state change"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Python module ``requests``"


Help
----

.. code-block:: text

    usage: cloudflare-security-level [-h] [-V] --key KEY --servicestate
                                     {OK,WARNING,CRITICAL,UNKNOWN} --username
                                     USERNAME --zone-id ZONE_ID

    Event Plugin: Changes the security level for a zone at Cloudflare to
    "under_attack" if state of the service - from which this event plugin was
    called - changes to CRITICAL (even in SOFT state). Changes to "medium" when
    the state is OK. If the zone/site is in "Under Attack Mode", Cloudflare will
    display a 5sec Delay when you visit this website. This event plugin is useful,
    for example, when the Apache httpd status check reports overuse.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --key KEY             Cloudflare API Key
      --servicestate {OK,WARNING,CRITICAL,UNKNOWN}
                            The current Icinga state of the service.
      --username USERNAME   Cloudflare API Username (Email Address)
      --zone-id ZONE_ID     Cloudflare API Zone Identifier (from Cloudflare Portal
                            > Home > Choose your site > Overview)


Usage Examples
--------------

.. code-block:: bash

    # enables Cloudflare "Under Attack Mode" for two zones
    ./cloudflare-security-level --servicestate CRITICAL --key 1234 --username info@linuxfabrik.ch --zone-id 0815 --zone-id 4711

    # disables Cloudflare "Under Attack Mode"
    ./cloudflare-security-level --servicestate OK --key 1234 --username info@linuxfabrik.ch --zone-id 0815 --zone-id 4711


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
