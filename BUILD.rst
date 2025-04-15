Compile and Package the Linuxfabrik Monitoring Plugins
======================================================

Compiling the Linuxfabrik Monitoring Plugins allows you to completely avoid Python on the Linux or Windows target systems. With this manual, plugins can be compiled and packaged (= "built") using Nuitka on Github runners (Linux, Windows) or a self-hosted Ubuntu VM (which is compatible to the Github runner; for Linux only).


Build for Linux
---------------

The following steps describe the **manual** compilation and package building process on an Ubuntu 24.04 LTS host. The same steps have been automated using Github actions. See the `.github/workflows <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/.github/workflows/>`__ as well as the `build <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/build>`__ folder for details.

To automatically retrieve version information from outside Github, first create a Github Personal Access Token. If you are using a [classic token](https://github.com/settings/tokens/new), only the "repo:public_repo" scope is required.

To be able to perform the same steps on a local Ubuntu host as on a Github runner, we decided to minimize the use of Github actions for the Linux build process (and therefore use some build scripts), and maximize the use of Github actions on Windows. The build scripts are written in bash and make heavy use of environment variables to be compliant with the Github runners.

To build on Linux, first set environment variables for (absolute) paths, versions etc.:

.. code-block:: bash

    cat > env-file << 'EOF'
    # ---
    # User input on Github:
    export LFMP_ARCH=x86_64                                   # or "aarch64" if running on ARM64
    export LFMP_COMPILE_PLUGINS="cpu-usage feed scanrootkit"  # check-plugins to compile. leave empty to compile all
    export LFMP_PACKAGE_ITERATION=7
    export LFMP_TARGET_DISTROS="debian12 rocky9"              # "debian11 debian12 rocky8 rocky9 ubuntu2004 ubuntu2204 ubuntu2404"

    # for getting the latest version into $LFMP_VERSION
    export GITHUB_TOKEN=ghp_abc123xyz987
    export GITHUB_REPOSITORY=Linuxfabrik/monitoring-plugins
    # or set manually: export LFMP_VERSION=1.2.3.4

    # ---
    # Constants
    # use absolut paths here
    export LFMP_DIR_REPOS=/tmp/lfmp/repos
    export LFMP_DIR_COMPILED=/tmp/lfmp/compiled
    export LFMP_DIR_PACKAGED=/tmp/lfmp/packaged
    mkdir -p $LFMP_DIR_REPOS
    mkdir -p $LFMP_DIR_COMPILED
    mkdir -p $LFMP_DIR_PACKAGED
    EOF

.. code-block:: bash

    source env-file

The paths and their meanings:

* repos: the source code / git repositories
* compiled: store the compiled plugins, one-by-one
* dist: files are taken from the compiled directory and merged together, ready to be packaged
* packaged: contains the packages built by fpm

Clone the Linuxfabrik Monitoring Plugins and the Linuxfabrik Python Libraries from Github:

.. code-block:: bash

    cd $LFMP_DIR_REPOS
    git clone https://github.com/Linuxfabrik/monitoring-plugins.git


Fetch the current version from Github:

.. code-block:: bash

    source $LFMP_DIR_REPOS/monitoring-plugins/build/get-latest-version.sh
    # or set it manually: export LFMP_VERSION=1.2.3.4


Install podman:

.. code-block:: bash

    source $LFMP_DIR_REPOS/monitoring-plugins/build/install-podman.sh

From the containers perspective, every container assumes:

* Python source code is located at ``/repos/monitoring-plugins``.
* Compiled files can be put in ``/compiled``.
* The Python venv is located at ``/opt/venv``.


For each distro compile the specified plugins:

.. code-block:: bash

    # a run takes round about one minute per plugin
    source $LFMP_DIR_REPOS/monitoring-plugins/build/matrix-compile.sh

After that, $LFMP_DIR_COMPILED should look somethinglike this:

.. code-block:: text

    $LFMP_DIR_COMPILED/
    ├── debian12/
    │   ├── check-plugins/
    │   │   └── a bunch of files and directories
    │   └── ...
    ├── rocky9/
    │   └── check-plugins/
    │   └── ...
    └── ...

Install FPM, the packaging tool:

.. code-block:: bash

    source $LFMP_DIR_REPOS/monitoring-plugins/build/install-fpm.sh

Create the fpm files:

.. code-block:: bash

    source $LFMP_DIR_REPOS/monitoring-plugins/build/create-fpms.sh

Create the packages for every OS:

.. code-block:: bash

    source $LFMP_DIR_REPOS/monitoring-plugins/build/create-packages.sh


Build for Windows
-----------------

Packaging for Windows means creating both a zip and an msi file, both of which can be downloaded from https://download.linuxfabrik.ch/monitoring-plugins/. Both files are created automatically using the Github Actions workflow `Linuxfabrik: Build Windows <https://github.com/Linuxfabrik/monitoring-plugins/actions/workflows/lf-build-windows.yml>`__.

To create the msi file, we use the most recent `WiX Toolset <https://wixtoolset.org/docs/intro/>`__.

Code signing policy:

* Free code signing on Windows provided by `SignPath.io <https://signpath.io>`__, certificate by `SignPath Foundation <https://signpath.org>`__ (thank you for your support!).
* .dll, .exe, .pyd and .msi files are signed.


Compiling - Good to Know
------------------------

Platforms
~~~~~~~~~

rpm and deb OS packages
    For Red Hat Package Manager (rpm) and Debian-based package files (deb), we compile the plugins on their specific platforms and build the packages using `FPM <https://docs.linuxfabrik.ch/software/fpm.html>`__ there.

    Compiling platform for .rpm and .deb files:

    .. code-block:: text

        Target OS     ! Compiled on
        --------------+-------------------------------------
        Debian 11     ! docker.io/library/debian:11
        Debian 12     ! docker.io/library/debian:12
        RHEL 8        ! docker.io/library/rockylinux:8
        RHEL 9        ! docker.io/library/rockylinux:9
        Ubuntu 20.04  ! docker.io/library/ubuntu:20.04
        Ubuntu 22.04  ! docker.io/library/ubuntu:22.04
        Ubuntu 24.04  ! docker.io/library/ubuntu:24.04

    .. note::

        Why Rocky instead of RHEL's "ubi" container images? According to `Types of container images <https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/building_running_and_managing_containers/assembly_types-of-container-images_building-running-and-managing-containers#assembly_types-of-container-images_building-running-and-managing-containers>`__, Red Hat Universal Base images ("ubi") are built from a subset of the normal Red Hat Enterprise Linux content, so you have access to free dnf repositories for adding and updating software. A subset of the CRB repo is also available, and that's why EPEL is installable. If you need more packages, you will need to purchase a (developer) subscription or run the container on a subscribed host.

Linux Binaries
    If you just need the compiled plugins, use the binaries from the .tar or .zip file. We want to make sure that they will run almost everywhere, so for maximum compatibility between different Linux versions, these plugins are compiled on an OS platform that supports the oldest glibc, is not yet EOL, is not running SELinux (`#732 <https://github.com/Linuxfabrik/monitoring-plugins/issues/732>`__), and - if there is more than one candidate - has the latest OpenSSL version due to security fixes.

    Versions of glibc and OpenSSL (2025-01-25):

    .. code-block:: text

                         !     ! libc.so.6 ! openssl     !         !
        OS               ! EOL ! --version ! version     ! SELinux ! Usable?
        -----------------+-----+-----------+-------------+---------+--------
        CentOS 7         ! EOL ! 2.17      ! 1.0.2k-fips !    x    ! - 
        RHEL 7           ! EOL ! 2.17      ! 1.0.2k-fips !    x    ! - 
        Ubuntu 18.04 LTS ! EOL ! 2.27      ! 1.1.1       !    -    ! - 
        RHEL 8           !     ! 2.28      ! 1.1.1k      !    x    ! - 
        Debian 10        ! EOL ! 2.28      ! 1.1.1n      !    -    ! - 
        Ubuntu 20.04 LTS !     ! 2.31      ! 1.1.1f      !    -    ! x 
        Debian 11        !     ! 2.31      ! 1.1.1w      !    -    ! x current choice (2025-02)
        RHEL 9           !     ! 2.34      ! 3.0.7       !    x    ! - 
        Ubuntu 22.04 LTS !     ! 2.35      ! 3.0.2       !    -    ! - 
        Debian 12        !     ! 2.36      ! 3.0.11      !    -    ! - 
        Ubuntu 24.04 LTS !     ! 2.39      ! 3.0.13      !    -    ! - 

    Compiling platform for the plugins distributed in the .tar and .zip files:

    .. code-block:: text

        Target OS     ! Compiled on
        --------------+-------------------------------------
        Linux-general ! docker.io/library/ubuntu:20.04

Windows Binaries
    Binaries for Windows are compiled on Windows Server 2025 using MSVC 14.


pyinstaller vs. Nuitka
~~~~~~~~~~~~~~~~~~~~~~

Why Nuitka? We compiled ``disk-usage`` - once with ``pyinstaller`` and once with Nuitka. The results led us to set Nuitka as the standard compiler (sorted by runtime as of 2024-12-23):

.. code-block:: text
    :caption: disk-usage in action

    ! Platform    ! Py   ! Compiler    ! Type    ! Option1       ! Option2       ! Size in MB ! 500 runs (sec) ! VirusTotal !
    ! ----------- ! ---- ! ----------- ! ------- ! ------------- ! ------------- ! ---------- ! -------------- ! ---------- !
    ! Rocky 8     !  3.9 ! nuitka      ! mfiles  ! --standalone  !               ! 19.7       !  15.706        !            !
    ! Rocky 8     !  3.9 ! pyinstaller ! mfiles  ! --onedir      ! --noupx       ! 13.7       !  19.392        !            !
    ! WinSrv 2022 ! 3.12 ! nuitka+gcc  ! mfiles  ! --standalone  !               ! 23.4       !  29.570        !  4/72      !
    ! WinSrv 2022 ! 3.12 ! nuitka+msvc ! mfiles  ! --standalone  !               ! 22.3       !  31.560        !  2/71      !
    ! Rocky 8     !  3.9 ! nuitka      ! onefile ! --onefile     ! --standalone  !  7.9       !  33.339        !            !
    ! Rocky 8     !  3.9 ! pyinstaller ! onefile ! --onefile     ! --noupx       !  6.4       !  45.838        !            !
    ! WinSrv 2022 ! 3.12 ! pyinstaller ! mfiles  ! --onedir      !               ! 16.7       !  51.476        ! 13/71      !
    ! WinSrv 2022 ! 3.12 ! nuitka+gcc  ! onefile ! --onefile     ! --standalone  !  6.83      ! 243.167        ! 24/71      !
    ! WinSrv 2022 ! 3.12 ! nuitka+msvc ! onefile ! --onefile     ! --standalone  !  6.67      ! 253.006        ! 15/72      !
    ! WinSrv 2022 ! 3.12 ! pyinstaller ! onefile ! --onefile     !               ! 17.1       ! 462.180        !  7/72      !

One-file compilation:

* Plugin will be slower (execution results in higher cpu load), but small.
* Each plugin can be updated separately.
* Best choice where size matters.

Multiple-files compilation:

* Plugin will be fast (3x compared to one file), but big.
* You can't update just one plugin, you have to update all of them at once.

On Windows, using Nuitka in onedir mode, a typical plugin will be 30MB plus 34MB of shared global libs, while in onefile mode it will be 16MB. 100 plugins result in 3.0 GB (onedir) versus 1.6 GB (onefile). We prefer speed over file size, especially on Windows, where plugins compiled with Nuitka in onedir mode are also likely to be killed by Windows Defender with a false positive Trojan:Win32 report. On Windows, gcc vs. msvc really makes no difference.
