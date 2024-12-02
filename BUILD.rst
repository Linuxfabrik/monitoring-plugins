Compiling the Linuxfabrik Monitoring Plugins
============================================

HOWTO build / compile / make the Linuxfabrik Monitoring Plugins, package them for Linux (rpm or deb) or for Windows (exe).


Compiling and Building for Linux
--------------------------------

.. note::

    You can find the pre-built OS packages at https://repo.linuxfabrik.ch/monitoring-plugins/.

The Linuxfabrik Monitoring Plugins are compiled with ``pyinstaller`` while the OS installation packages are built afterwards with `FPM <https://docs.linuxfabrik.ch/software/fpm.html>`_. This allows us to completely avoid Python on the target systems.

Which targets we compile for:

* rpm for RHEL 8+
* deb for Debian 11+, Ubuntu 20+
* tar and zip

    We want to make sure that the plugins run almost everywhere. For maximum compatibility between different Linux versions, the plugins for the .zip/tar.gz file are therefore compiled on an OS platform that supports the oldest glibc, is not yet EOL, and - if there is more than one candidate - has the latest OpenSSL version due to security fixes.

    .. code-block:: text

        OS                     | libc.so.6 --version | openssl version | Compiling platform
        -----------------------+---------------------+---------------- +-------------------
        CentOS 7 (EOL)         | 2.17                | 1.0.2k-fips     | until 2024-06-30
        Ubuntu 18.04 LTS (EOL) | 2.27                | 1.1.1           |
        Rocky 8                | 2.28                | 1.1.1k          | current
        Debian 10 (EOL)        | 2.28                | 1.1.1n          |
        Ubuntu 20.04 LTS       | 2.31                | 1.1.1f          |
        Debian 11              | 2.31                | 1.1.1w          |
        Rocky 9                | 2.34                | 3.0.7           |
        Ubuntu 22.04 LTS       | 2.35                | 3.0.2           |
        Debian 12              | 2.36                | 3.0.11          |
        Ubuntu 24.04 LTS       | 2.39                | 3.0.13          |

Currently not implemented:

* apk (= Alpine; because of errors while running ``fpm -s deb -t apk linuxfabrik-monitoring-plugins.deb`` and ``fpm -s rpm -t apk linuxfabrik-monitoring-plugins.rpm``)
* FreeBSD (because of errors while running ``fpm -s deb -t freebsd linuxfabrik-monitoring-plugins.deb`` and ``fpm -s rpm -t freebsd linuxfabrik-monitoring-plugins.rpm``)
* pacman (= Arch Linux; because of errors while running ``fpm -s deb -t pacman linuxfabrik-monitoring-plugins.deb``, ``fpm -s rpm -t pacman linuxfabrik-monitoring-plugins.rpm`` and ``fpm -t pacman -p linuxfabrik-monitoring-plugins.pkg.tar.zst``)

Not tested:

* OpenSUSE

Currently the compilation and build process is done automatically using GitHub Actions. Have a look at the `Linux Build CI/CD <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/.github/workflows/linux-build.yml>`_ and the `build scripts <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/build>`_.

Note that we are not building new containers, because we always want the latest package versions.
If we wanted to speed up the workflow, we could try to build a container with all the tools we need, and then just update the container every time the workflow is triggered. However, since the workflow currently only runs for git tags (and maybe nightly builds in the future), the duration of the workflow is not very important to us.


Compiling for Windows
---------------------

Done automatically per `Nuitka CI/CD <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/.github/workflows/nuitka-compile.yml>`_.
