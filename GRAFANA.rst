Importing the Grafana Dashboards and Panels
===========================================

There are two options to import the Grafana dashboards. You can either import them via the WebGUI or use provisioning.

When importing via the WebGUI simply import the ``plugin-name.grafana-external.json`` file.

If you want to use provisioning, take a look at `Grafana Provisioning <https://grafana.com/docs/grafana/latest/administration/provisioning/>`_. Beware that you also need to provision the datasources if you want to use provisioning for the dashboards.

If you want to create a custom dashboards that contains a different selection of panels, you can do so using the ``tools/grafana-tool`` utility.

.. code-block:: bash

    # interactive usage
    ./tools/grafana-tool assets/grafana/all-panels-external.json
    ./tools/grafana-tool assets/grafana/all-panels-provisioning.json

    # for more options, see
    ./tools/grafana-tool --help
