Icinga Director
===============

Installing the Plugins
----------------------

Single / specific Plugins
~~~~~~~~~~~~~~~~~~~~~~~~~

By importing Baskets
    For each check, we provide an Icinga Director Basket that contains at least the Command definition and a matching Service Template (for example, ``check-plugins/cpu-usage/icingaweb2-module-director/cpu-usage.json``). Import this:

    * either via the WebGUI using Icinga Director > Configuration Baskets > Upload, select the latest entry in the Snapshots tab and restore it
    * or via ``icingacli director basket restore < cpu-usage.json -v``

    Now use the new commands within Service Templates, Service Sets and/or a Single Services.

By defining them manually
    If you want to define plugins manually, this is how to do it (example).

    Create a command for "cpu-usage" in Icinga Director > Commands > Commands:

    * Click "+Add", choose Command type: ``Plugin Check Command``
    * Command name: ``cmd-check-cpu-usage``
    * Command: ``/usr/lib64/nagios/plugins/cpu-usage``
    * Timeout: set it according to hints in the check's README (usually ``10`` seconds)
    * Click the "Add" button

    Tab "Arguments":

    * Run ``/usr/lib64/nagios/plugins/cpu-usage --help`` to get a list of all arguments.
    * Create those you want to be customizable:

        * Argument name ``--always-ok``, Value type: String, Condition (set_if): ``$cpu_usage_always_ok$``
        * Argument name ``--count``, Value type: String, Value: ``$cpu_usage_count$``
        * Argument name ``--critical``, Value type: String, Value: ``$cpu_usage_critical$ ``
        * Argument name ``--warning``, Value type: String, Value: ``$cpu_usage_warning$ ``

    Tab "Fields":

    * Label "CPU Usage: Count", Field name "cpu_usage_count", Mandatory "n"
    * Label "CPU Usage: Critical", Field name "cpu_usage_critical", Mandatory "n"
    * Label "CPU Usage: Warning", Field name "cpu_usage_warning", Mandatory "n"


All Plugins (Linuxfabrik Icinga Director Configuration)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To use the Linuxfabrik Icinga Director configuration, including host templates, notification templates and predefined service sets, you need to *generate* a single Icinga Director basket file containing the baskets for each check plus `all-the-rest.json <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/icingaweb2-module-director/all-the-rest.json>`_. Use `tools/basket-join <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/tools/basket-join>`_ to do this.

Create the Icinga Director Basket JSON file:

* If you are using our `Fork of the Icinga Director <https://github.com/Linuxfabrik/icingaweb2-module-director>`_, which introduced uuids, you can use the following command:

    .. code-block:: bash

        ./tools/basket-join

* If you are NOT using our `Fork of the Icinga Director <https://github.com/Linuxfabrik/icingaweb2-module-director>`_, create a basket without uuids:

    .. code-block:: bash

        ./tools/basket-join
        ./tools/remove-uuids --input-file icingaweb2-module-director-basket.json --output-file icingaweb2-module-director-basket-no-uuids.json

Import the resulting ``icingaweb2-module-director-basket.json``:

* either via the WebGUI using *Icinga Director > Configuration Baskets > Upload*, select the latest entry in the Snapshots tab and restore it
* or via ``icingacli director basket restore < icingaweb2-module-director-basket.json -v``.

If you get the error message ``File 'icingaweb2-module-director-basket.json' exeeds the defined ini size.``, adjust your PHP and/or MariaDB/MySQL settings (as described in `Cant Upload Director Basket <https://github.com/Icinga/icingaweb2-module-director/issues/2458>`_): 

* PHP: increase ``upload_max_filesize`` and ``post_max_size`` (if you use PHP-FPM, don't forget to restart this service).
* MariaDB/MySQL: increase ``max_allowed_packet``.

If you did not name your master zone ``master`` during the initial ``icinga2 node wizard``, find and replace ``"zone": "master"`` with ``"zone": "your-master-zone-name"`` in the ``icingaweb2-module-director-basket.json`` file.


Linuxfabrik's Icinga Director Concept
-------------------------------------

Assigning Services to Hosts
~~~~~~~~~~~~~~~~~~~~~~~~~~~

In general, all of our services are in a service set, which is then applied to a host. This is done using a tag from the ``tag_list``, for example the ``OS - RHEL 8 Basic Service Set`` is applied to all hosts that have the ``rhel8`` tag set.

For some services it does not make sense to create a set, for example when monitoring an external website using ``tpl-service-url``. In this case you can create a single service on that host.


Criticality
~~~~~~~~~~~

To manage notifications we use a custom variable called ``criticality``. This variable is present on both services and hosts and is used to determine if and during what time period a notification is sent.

A criticality of ``A`` will send a notification 7x24, ``B`` during business hours (5x12) and ``C`` never.

The criticality of the host limits the notifications that the host's services can send. This means that if you have a host with criticality ``B`` and a service on that host with criticality ``A`` has a problem, the notification will only be sent during business hours.

We try to provide reasonable default criticalities in the service templates. This means that in most cases, when adding a new host, it is sufficient to set the host criticality.

Host notifications:

.. csv-table::
    :header-rows: 1
    :widths: auto

    Host Criticality, Result
    ``A``, sent during 7x24
    ``B``, sent during 5x12
    ``C``, not sent


Service notifications:

.. csv-table::
    :header-rows: 1
    :widths: auto

    Host Criticality, Service Criticality, Result
    ``A``, ``A``, sent during 7x24
    ``A``, ``B``, sent during 5x12
    ``A``, ``C``, not sent

    ``B``, ``A``, sent during 5x12
    ``B``, ``B``, sent during 5x12
    ``B``, ``C``, not sent

    ``C``, ``A``, not sent
    ``C``, ``B``, not sent
    ``C``, ``C``, not sent

Note: for the criticality to work as described here, you have to use the notification rules provided in ``assets/icingaweb2-module-director/all-the-rest.json``.
