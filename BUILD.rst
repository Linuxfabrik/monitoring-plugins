Compiling the Linuxfabrik Monitoring Plugins
============================================

HOWTO build / compile / make the Linuxfabrik Monitoring Plugins, package them for Linux (rpm or deb) or for Windows (exe).


Compiling and Building for Linux
--------------------------------

.. note::

    You can find the pre-built OS packages at https://repo.linuxfabrik.ch/monitoring-plugins/.

The Linuxfabrik Monitoring Plugins are compiled with ``pyinstaller`` while the OS installation packages are built afterwards with `FPM <https://docs.linuxfabrik.ch/software/fpm.html>`_. This allows us to completely avoid Python on the target systems.

What this HOWTO covers:

* rpm for RHEL 7+
* deb for Debian 10+, Ubuntu 18+
* tar
* zip

Currently not implemented:

* apk (= Alpine; because of errors while running ``fpm -s deb -t apk linuxfabrik-monitoring-plugins.deb`` and ``fpm -s rpm -t apk linuxfabrik-monitoring-plugins.rpm``)
* FreeBSD (because of errors while running ``fpm -s deb -t freebsd linuxfabrik-monitoring-plugins.deb`` and ``fpm -s rpm -t freebsd linuxfabrik-monitoring-plugins.rpm``)
* pacman (= Arch Linux; because of errors while running ``fpm -s deb -t pacman linuxfabrik-monitoring-plugins.deb``, ``fpm -s rpm -t pacman linuxfabrik-monitoring-plugins.rpm`` and ``fpm -t pacman -p linuxfabrik-monitoring-plugins.pkg.tar.zst``)

Not tested:

* OpenSUSE

Currently the compilation and build process is done automatically using GitHub Actions. Have a look at the `Linux Build CI/CD <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/.github/workflows/linux-build.yml>`_ and the `build scripts <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/build>`_.

Note that we are not building new containers because we always want the most up-to-date package versions.
If we need to speed up the workflow, one could try to build a container with all the required tools, and then just run an update in the container every time the workflow is triggered.
However, since the workflow currently only runs for git tags (and maybe nightly builds in the future), the workflow duration is not very important for us.


Compiling for Windows
---------------------

Done automatically per `Nuitka CI/CD <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/.github/workflows/nuitka-compile.yml>`_.
