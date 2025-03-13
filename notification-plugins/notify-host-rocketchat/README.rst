Notification notify-service-rocketchat
======================================


Overview
--------

Sends service notifications using the RocketChat API.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Notification Plugin Download",         "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/notification-plugins/notify-service-rocketchat"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: notify-host-rocketchat [-h] --datetime DATETIME --host-displayname
                                  HOST_DISPLAYNAME [--host-output HOST_OUTPUT]
                                  --host-state HOST_STATE [--hostname HOSTNAME]
                                  [--icingaweb2-url ICINGAWEB2_URL]
                                  [--notification-author NOTIFICATION_AUTHOR]
                                  [--notification-comment NOTIFICATION_COMMENT]
                                  [--rocketchat-mentions ROCKETCHAT_MENTIONS]
                                  --rocketchat-url ROCKETCHAT_URL [-V]

    Sends host notifications using the RocketChat API.

    options:
      -h, --help            show this help message and exit
      --datetime DATETIME   Set the message timestamp.
      --host-displayname HOST_DISPLAYNAME
                            Set the display name of the host.
      --host-output HOST_OUTPUT
                            Set the host output.
      --host-state HOST_STATE
                            Set the host state.
      --hostname HOSTNAME   Set the hostname.
      --icingaweb2-url ICINGAWEB2_URL
                            Set the Icinga Web 2 URL, for example
                            "https://example.com/icingaweb2".
      --notification-author NOTIFICATION_AUTHOR
                            Set the author of the comment.
      --notification-comment NOTIFICATION_COMMENT
                            Set the comment.
      --rocketchat-mentions ROCKETCHAT_MENTIONS
                            Set the Rocket.Chat Mentions (repeating).
      --rocketchat-url ROCKETCHAT_URL
                            Set the Rocket.Chat Webhook API URL.
      -V, --version         show program's version number and exit


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
