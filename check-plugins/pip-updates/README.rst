Check pip-updates
=================

Overview
--------

This plugin lets you track if updates for python packages installed via ``pip`` are available. May take more than 10 seconds to execute. For a detailed help on all parameters, have a look at ``man pip3-list``.

Hints:

* Requires ``pip`` v20.3+.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/pip-updates"
    "Check Interval Recommendation",        "Once a week"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "``pip`` v20.3+"


Help
----

.. code-block:: text

    usage: pip-updates [-h] [-V] [--always-ok] [-c CRIT] [--exclude EXCLUDE]
                       [--extra-index-url EXTRA_INDEX_URL]
                       [--find-links FIND_LINKS] [--index-url INDEX_URL] [--local]
                       [--no-index] [--not-required] [--pre] [--test TEST]
                       [--user] [--virtualenv VIRTUALENV] [-w WARN]

    Checks if there are outdated Python packages, installed via `pip`.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c, --critical CRIT   Set the critical threshold for the number of pending
                            updates. Default: 100
      --exclude EXCLUDE     Exclude specified package from the output.
      --extra-index-url EXTRA_INDEX_URL
                            Extra URLs of package indexes to use in addition to
                            --index-url. Should follow the same rules as --index-
                            url.
      --find-links FIND_LINKS
                            If a URL or path to an html file, then parse for links
                            to archives such as sdist (.tar.gz) or wheel (.whl)
                            files. If a local path or file:// URL that's a
                            directory, then look for archives in the directory
                            listing. Links to VCS project URLs are not supported.
      --index-url INDEX_URL
                            Base URL of the Python Package Index. This should
                            point to a repository compliant with PEP 503 (the
                            simple repository API) or a local directory laid out
                            in the same format.
      --local               If in a virtualenv that has global access, do not list
                            globally-installed packages.
      --no-index            Ignore package index (only looking at --find-links
                            URLs instead).
      --not-required        List packages that are not dependencies of installed
                            packages.
      --pre                 Include pre-release and development versions. By
                            default, pip only finds stable versions.
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --user                Only output packages installed in user-site.
      --virtualenv VIRTUALENV
                            Path to the virtualenv that will be activated before
                            checking for updates. Example: `/opt/sphinx-
                            venv/bin/activate`
      -w, --warning WARN    Set the warning threshold for the number of pending
                            updates. Default: 10


Usage Examples
--------------

.. code-block:: bash

    ./pip-updates --virtualenv /path/to/my/venv/bin/activate --local --exclude boto3 --exclude pip

Output:

.. code-block:: text

    venv /path/to/my/venv/bin/activate. pip is complaining about something or about itself, but most of the packages are up to date. 2 outdated packages. Executed command: `source /path/to/my/venv/bin/activate && pip list --outdated --format=json --exclude=boto3 --exclude=pip --local`

    Package  ! Version ! Latest  ! Type  
    ---------+---------+---------+-------
    botocore ! 1.29.41 ! 1.29.78 ! wheel 
    pyspnego ! 0.7.0   ! 0.8.0   ! wheel


States
------

* If wanted, always returns OK,
* else returns WARN or CRIT if updates are available.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    pip_outdated_packages,                      Number,             Number of pending updates.


Troubleshooting
---------------

This indicates that your version of ``pip`` is below 20.3:

.. code-block:: text

    Traceback (most recent call last):
      File "/usr/lib/python3/dist-packages/pip/_internal/cli/base_command.py", line 143, in main
        status = self.run(options, args)
      File "/usr/lib/python3/dist-packages/pip/_internal/commands/list.py", line 138, in run
        packages = self.get_outdated(packages, options)
      File "/usr/lib/python3/dist-packages/pip/_internal/commands/list.py", line 149, in get_outdated
        dist for dist in self.iter_packages_latest_infos(packages, options)
      File "/usr/lib/python3/dist-packages/pip/_internal/commands/list.py", line 150, in <listcomp>
        if dist.latest_version > dist.parsed_version
    TypeError: '>' not supported between instances of 'Version' and 'Version'

So simply upgrade by using ``pip3 install --upgrade pip``.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
