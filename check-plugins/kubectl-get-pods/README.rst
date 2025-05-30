Check kubectl-get-pods
======================

Overview
--------

Checks the health and status of Kubernetes Pods by running ``kubectl get pods`` and parsing the results. Prints a table listing namespace, pod name, readiness, status, restart count, pod age, and IP address. Adds performance data for each pod status (Running, Pending, Failed, Succeeded, Unknown). By default, only shows pods from the current namespace. Use ``--all-namespaces`` to check across all namespaces. The plugin also stores a temporary local SQLite database during runtime (no persistent history). Results can therefore be filtered with a custom SQL ``--query`` (e.g., by namespace, pod name, or status). See the README for more details. Pending and Failed pods can trigger a WARNING or CRITICAL state (configurable via ``--severity``), while Unknown pods result in an UNKNOWN state. Intended for use with Nagios/Icinga to detect Kubernetes pod issues like stuck, failing, or unreachable pods.

For the ``--query`` parameter, the following columns can be used:

* namespace (TEXT)
* name (TEXT)
* ready (TEXT)
* status (TEXT)
* restarts (INT)
* age (INT)
* ip (TEXT)

Hints:

* OIDC-based login to Kubernetes is not yet supported by this plugin.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kubectl-get-pods"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"
    "Requirements",                         "Command-line tool ``kubectl`` (you must use a kubectl version that is within one minor version difference of your cluster. For example, a v1.32 client can communicate with v1.31, v1.32, and v1.33 control planes. Using the latest compatible version of kubectl helps avoid unforeseen issues. See `installation <https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/>`__)."
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-monitoring-plugins-kubectl-get-pods.db``"


Help
----

.. code-block:: text

    usage: kubectl-get-pods [-h] [-V] [--always-ok] [--all-namespaces]
                            [--kubeconfig KUBECONFIG] [--query QUERY]
                            [--severity {warn,crit}] [--test TEST]

    Checks the health and status of Kubernetes Pods by running `kubectl get pods`
    and parsing the results. Prints a table listing namespace, pod name,
    readiness, status, restart count, pod age, and IP address. Adds performance
    data for each pod status (Running, Pending, Failed, Succeeded, Unknown). By
    default, only shows pods from the current namespace. Use `--all-namespaces` to
    check across all namespaces. The plugin also stores a temporary local SQLite
    database during runtime (no persistent history). Results can therefore be
    filtered with a custom SQL `--query` (e.g., by namespace, pod name, or
    status). See the README for more details. Pending and Failed pods can trigger
    a WARNING or CRITICAL state (configurable via `--severity`), while Unknown
    pods result in an UNKNOWN state. Intended for use with Nagios/Icinga to detect
    Kubernetes pod issues like stuck, failing, or unreachable pods.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --all-namespaces      If present, list the requested object(s) across all
                            namespaces. Namespace in current context is ignored
                            even if specified with `--namespace`. Default: False
      --kubeconfig KUBECONFIG
                            Path to the kubeconfig file. Default:
                            /var/spool/icinga2/.kubeconfig
      --query QUERY         Provide the SQL `WHEN` statement part to narrow down
                            results. Example: `namespace = 'mynamespace' and name
                            like 'prod-%' and status != 'running'`. Have a look at
                            the README for a list of available columns. Default: 1
      --severity {warn,crit}
                            Severity for alerting. Default: crit
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./kubectl-get-pods \
        --all-namespaces \
        --kubeconfig /var/spool/icinga2/.kubeconfig \
        --query='namespace = "mynamespace" and name like "mycontainer-%"'

Output:

.. code-block:: text

        NAMESPACE   ! NAME                                ! RDY ! RSTRT ! AGE    ! IP         ! STATUS    
        ------------+-------------------------------------+-----+-------+--------+------------+--------
        mynamespace ! mycontainer-mariadb-555df66f6c-5z8h ! 1/1 ! 0     ! 1D 2h  ! 192.0.2.11 ! Running 
        mynamespace ! mycontainer-postgres-775cb466bb-qkw ! 1/1 ! 0     ! 1M 11h ! 192.0.2.12 ! Running 


States
------

* Depending on the ``--severity`` given, returns CRIT (default) or WARN if a pod is in 'Pending' or 'Failed' state,
* UNKNOWN if it is in 'Unknown' state,
* and OK in all other cases.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    failed,                                     Number,             Number of failed pods
    pending,                                    Number,             Number of pending pods
    running,                                    Number,             Number of running pods
    succeeded,                                  Number,             Number of succeeded pods
    unknown,                                    Number,             Number of unknown pods


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
