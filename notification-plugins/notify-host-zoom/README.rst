Notification notify-host-zoom
================================


Overview
--------
Sends notifications for hosts using the Zoom Incoming Webhook API.

For this to work the `Incoming Webhook (by Zoom) <https://marketplace.zoom.us/apps/eH_dLuquRd-VYcOsNGy-hQ>`_ app needs to be installed.
Then create a new Connection using ``/inc connect <connectionName>`` (according to `the documentation <https://zoomappdocs.docs.stoplight.io/incoming-webhook-chatbot#configuring-the-incoming-webhook-chatbot>`_).

Note: We do not send markdown as this is currently not supported by the Incoming Webhook app. Zoom also displays the message differently depending on the Operating System. This can for example lead to missing newlines.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Notification Plugin Download",         "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/notification-plugins/notify-host-zoom"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: notify-host-zoom [-h] [-V] [--datetime DATETIME]
                             [--host-displayname HOST_DISPLAYNAME]
                             [--host-output HOST_OUTPUT] [--host-state HOST_STATE]
                             [--hostname HOSTNAME]
                             [--icingaweb2-url ICINGAWEB2_URL]
                             [--notification-author NOTIFICATION_AUTHOR]
                             [--notification-comment NOTIFICATION_COMMENT] --token
                             TOKEN --url URL

    Sends notifications for hosts using the Zoom Incoming Webhook API.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --datetime DATETIME   Set the message timestamp ($icinga.short_date_time$).
      --host-displayname HOST_DISPLAYNAME
                            Set the display name of the host
                            ($host.display_name$).
      --host-output HOST_OUTPUT
                            Set the host output ($host.output$).
      --host-state HOST_STATE
                            Set the host state ($host.state$).
      --hostname HOSTNAME   Set the hostname ($host.name$).
      --icingaweb2-url ICINGAWEB2_URL
                            Set the Icinga Web 2 URL, for example
                            "https://example.com/icingaweb2".
      --notification-author NOTIFICATION_AUTHOR
                            Set the author of the comment ($notification.author$).
      --notification-comment NOTIFICATION_COMMENT
                            Set the comment ($notification.comment$).
      --token TOKEN         Set the Zoom verification token.
      --url URL             Set the URL of the Zoom Incoming Webhook API.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
