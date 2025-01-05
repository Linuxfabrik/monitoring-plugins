Check restic-stats
==================

``restic-stats`` walks multiple snapshots in a repository and accumulates statistics about the data stored therein. It reports on the number of unique files and their sizes, according to one of the counting modes as given by the ``--mode`` flag.

It operates on all snapshots matching the selection criteria or all snapshots if nothing is specified.

Some modes make more sense over just a single snapshot, while others are useful across all snapshots, depending on what you are trying to calculate. The modes are:

* blobs-per-file: A combination of files-by-contents and raw-data.
* files-by-contents: Counts total size of files, where a file is considered unique if it has unique contents.
* raw-data: Counts the size of blobs in the repository, regardless of how many files reference them.
* restore-size: Counts the size of the restored files. (default)

Refer to the `online manual <https://restic.readthedocs.io/en/latest/index.html>`_ for more details about restic.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/restic-stats"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: restic-stats [-h] [-V] [--host HOST]
                        [--mode {restore-size,files-by-contents,blobs-per-file,raw-data}]
                        [--password-file PASSWORD_FILE] [--path PATH] --repo REPO
                        [--tag TAG] [--test TEST]

    Walk multiple snapshots in a repository and accumulate statistics about the
    data stored therein. It reports on the number of unique files and their sizes,
    according to one of the counting modes as given by the --mode flag.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --host HOST           Only consider snapshots for this host (can be
                            specified multiple times).
      --mode {restore-size,files-by-contents,blobs-per-file,raw-data}
                            Counting mode. Default: restore-size
      --password-file PASSWORD_FILE
                            File to read the repository password from
      --path PATH           Only consider snapshots for this path (can be
                            specified multiple times).
      --repo REPO           Repository location
      --tag TAG             Only consider snapshots which include this taglist in
                            the format `tag[,tag,...]` (can be specified multiple
                            times).
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".


Usage Examples
--------------

Stats about snapshots for host www.example.com:

.. code-block:: bash

    ./restic-stats --repo=/path/to/restic-repo --password-file=/path/to/restic-pwd --host=www.example.com

Output:

.. code-block:: text

    242.0 files, 433.7KiB size (total stats in restore-size mode over all snapshots)


States
------

* Always returns OK.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,               Type,       Description                                           
    total_file_count,   Number,     "Number of unique files, according to one of the counting modes as given by the ``--mode`` flag"
    total_size,         Number,     "Size of unique files, according to one of the counting modes as given by the ``--mode`` flag"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
