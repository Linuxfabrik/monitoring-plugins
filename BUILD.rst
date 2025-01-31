Compiling the Linuxfabrik Monitoring Plugins
============================================

HOWTO build / compile / make the Linuxfabrik Monitoring Plugins, package them for Linux (rpm or deb) and for Windows (exe).


Compiling on Linux
------------------

.. note::

    * OS installation packages can be found at https://repo.linuxfabrik.ch/monitoring-plugins/
    * Tar and zip files containing the compiled binaries can be found at https://download.linuxfabrik.ch/monitoring-plugins/

The Linuxfabrik monitoring plugins are compiled using Nuitka. This allows us to completely avoid Python on the target systems.

For Red Hat Package Manager (RPM) and Debian-based package files, we compile the plugins on specific platforms and build the packages using `FPM <https://docs.linuxfabrik.ch/software/fpm.html>`_ there.

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

    Why Rocky instead of RHEL's "ubi" container images? According to `Types of container images <https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/building_running_and_managing_containers/assembly_types-of-container-images_building-running-and-managing-containers#assembly_types-of-container-images_building-running-and-managing-containers>`_, Red Hat Universal Base images ("ubi") are built from a subset of the normal Red Hat Enterprise Linux content, so you have access to free dnf repositories for adding and updating software. A subset of the CRB repo is also available, and that's why EPEL is installable. If you need more packages, you will need to purchase a (developer) subscription or run the container on a subscribed host.

If you only need the compiled plugins, we want to make sure that they will run almost everywhere. For maximum compatibility between different Linux versions, the plugins are therefore compiled on an OS platform that supports the oldest glibc, is not yet EOL, is not running SELinux (`#732 <https://github.com/Linuxfabrik/monitoring-plugins/issues/732>`_), and - if there is more than one candidate - has the latest OpenSSL version due to security fixes. The binaries are distributed as .tar.gz and .zip files.

Versions of glibc and OpenSSL (2025-01-25):

.. code-block:: text

    OS               ! EOL ! libc.so.6 --version ! openssl version
    -----------------+-----+---------------------+----------------
    CentOS 7         ! EOL ! 2.17                ! 1.0.2k-fips    
    RHEL 7           ! EOL ! 2.17                ! 1.0.2k-fips    
    Ubuntu 18.04 LTS ! EOL ! 2.27                ! 1.1.1          
    RHEL 8           !     ! 2.28                ! 1.1.1k         
    Debian 10        ! EOL ! 2.28                ! 1.1.1n         
    Ubuntu 20.04 LTS !     ! 2.31                ! 1.1.1f         current choice
    Debian 11        !     ! 2.31                ! 1.1.1w         
    RHEL 9           !     ! 2.34                ! 3.0.7          
    Ubuntu 22.04 LTS !     ! 2.35                ! 3.0.2          
    Debian 12        !     ! 2.36                ! 3.0.11         
    Ubuntu 24.04 LTS !     ! 2.39                ! 3.0.13         

Compiling platform for the plugins distributed in the .tar.gz and .zip files:

.. code-block:: text

    Target OS     ! Compiled on
    --------------+-------------------------------------
    Linux-general ! docker.io/library/ubuntu:20.04


pyinstaller vs. Nuitka
----------------------

We compiled ``disk-usage`` - once with ``pyinstaller`` and once with Nuitka. The details of how we did this are given below, **but the results led us to set Nuitka as the standard compiler**. The results, sorted by runtime as of 2024-12-23:

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

On Windows, using Nuitka in onedir mode, a typical plugin will be 30MB plus 34MB of shared global libs, while in onefile mode it will be 16MB. 100 plugins result in 3.0 GB (onedir) versus 1.6 GB (onefile). We prefer speed over file size, especially on Windows, where plugins compiled with Nuitka in onedir mode are likely to be killed by Windows Defender with a false positive Trojan:Win32 report. On Windows, gcc vs. msvc really makes no difference, but gcc is much easier to automate and saves tons of resources.


Build on Rocky 8
~~~~~~~~~~~~~~~~

Update and install Python 3.9:

.. code-block:: bash

    dnf -y update && reboot

.. code-block:: bash

    dnf -y install glibc binutils ncdu
    dnf -y install python39 python39-devel

Get the plugins:

.. code-block:: bash

    dnf -y install git
    cd
    git clone https://github.com/Linuxfabrik/monitoring-plugins.git
    git clone https://github.com/Linuxfabrik/lib.git

Compile using PyInstaller:

.. code-block:: bash

    python3.9 -m venv --system-site-packages /opt/venvs/pyinstaller
    source /opt/venvs/pyinstaller/bin/activate

    python3.9 -m pip install --upgrade pip
    python3.9 -m pip install pyinstaller

    cd
    cd monitoring-plugins
    python3.9 -m pip install --requirement requirements.txt --require-hashes

    # compile with pyinstaller
    cd check-plugins/disk-usage

    # pyinstaller, multiple files, noupx
    pyinstaller \
        --clean \
        --distpath /tmp/pyinst/dist/onedir \
        --workpath /tmp/pyinst/work \
        --specpath /tmp/pyinst/spec \
        --noconfirm \
        --noupx \
        --onedir \
        disk-usage
    time for i in {1..500}; do /tmp/pyinst/dist/onedir/disk-usage/disk-usage; done
    ncdu /tmp/pyinst/dist/onedir

    # pyinstaller, one file, noupx
    pyinstaller \
        --clean \
        --distpath /tmp/pyinst/dist/onefile \
        --workpath /tmp/pyinst/work \
        --specpath /tmp/pyinst/spec \
        --noconfirm \
        --noupx \
        --onefile \
        disk-usage
    time for i in {1..500}; do /tmp/pyinst/dist/onefile/disk-usage; done
    ncdu /tmp/pyinst/dist/onefile

    deactivate

Compile using Nuitka:

.. code-block:: bash

    dnf -y install patchelf ccache

    python3.9 -m venv --system-site-packages /opt/venvs/nuitka
    source /opt/venvs/nuitka/bin/activate

    python3.9 -m pip install --upgrade pip
    python3.9 -m pip install nuitka

    cd
    cd monitoring-plugins
    python3.9 -m pip install --requirement requirements.txt --require-hashes

    # compile with nuitka
    cd check-plugins/disk-usage

    # nuitka, multiple files, noupx
    python3.9 -m nuitka \
        --company-name='https://www.linuxfabrik.ch' \
        --assume-yes-for-downloads \
        --output-dir=/tmp/nuitka/onedir \
        --remove-output \
        --standalone \
        disk-usage
    time for i in {1..500}; do /tmp/nuitka/onedir/disk-usage.dist/disk-usage.bin; done
    ncdu /tmp/nuitka/onedir

    # nuitka, one file, noupx
    python3.9 -m nuitka \
        --company-name='https://www.linuxfabrik.ch' \
        --assume-yes-for-downloads \
        --output-dir=/tmp/nuitka/onefile \
        --remove-output \
        --standalone \
        --onefile \
        disk-usage
    time for i in {1..500}; do /tmp/nuitka/onefile/disk-usage.bin; done
    ncdu /tmp/nuitka

    deactivate


Build on Windows Server 2022
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Download and install Python 3.12. As of 2024-12-23: *Sorry, non-MSVC is not currently supported with Python 3.13+, due to differences in layout internal structures of Python.*

Download Microsoft Visual C++ 14.0+:

* Open https://visualstudio.microsoft.com/downloads/
* Tools for Visual Studio > Build Tools for Visual Studio 20xx > Download
* Start the downloaded file
* Tab "Workloads":

    * Activate "Desktop development with C++"" aktivieren, choose oldest "Windows 10 SDK"
    * Activate "Visual Studio extension development"; on the right, choose "MSVC v143 - VS 2022 ..."

.. code-block:: text

    mkdir c:\temp

Create a "runtime measurement" script in Powershell:

.. code-block:: text
    :caption: c:\temp\measure.ps1

    # Define the program
    $program = ".\disk-usage.exe"

    # Run the program 500 times and measure the time
    $results = 1..500 | ForEach-Object {
        Measure-Command { & $program } | Select-Object -ExpandProperty TotalMilliseconds
    }

    # Output the timings
    $results | ForEach-Object { Write-Host "Run: $_ ms" }

    # Calculate and output the average and total time
    $averageTime = ($results | Measure-Object -Average).Average
    $totalTime = ($results | Measure-Object -Sum).Sum
    Write-Host "Average Time: $averageTime ms"
    Write-Host "Total Time for 500 runs: $totalTime ms"

To measure the runtime in Powershell later, run for example:

.. code-block:: text

    # measure runtime in Powershell
    cd c:\temp\msvc.onedir\disk-usage.dist\
    C:\temp\measure.ps1

Mount the Monitoring Plugins from the Git repo on your Linux machine (assuming you're using RDP):

.. code-block:: text

    net use m: \\tsclient\_\home\$USER\git\linuxfabrik\monitoring-plugins
    m:

Setup Python on Windows:

.. code-block:: text

    python.exe -m pip install --upgrade pip wheel setuptools
    python.exe -m pip install --upgrade ordered-set Nuitka pyinstaller
    python.exe -m pip install --requirement requirements.txt --require-hashes

Compile using Nuitka+MSVC:

.. code-block:: text

    python -m nuitka \
        --assume-yes-for-downloads \
        --output-dir=c:\temp\msvc.onedir   \
        --remove-output \
        --standalone \
        --msvc=latest \
        check-plugins\disk-usage\disk-usage

    python -m nuitka \
        --assume-yes-for-downloads \
        --output-dir=c:\temp\msvc.onefile  \
        --remove-output \
        --standalone \
        --msvc=latest \
        --onefile \
        check-plugins\disk-usage\disk-usage

Compile using Nuitka+gcc:

.. code-block:: text

    python -m nuitka \
        --assume-yes-for-downloads \
        --output-dir=c:\temp\mingw.onedir  \
        --remove-output \
        --standalone \
        --mingw64 \
        check-plugins\disk-usage\disk-usage

    python -m nuitka \
        --assume-yes-for-downloads \
        --output-dir=c:\temp\mingw.onefile \
        --remove-output \
        --standalone \
        --mingw64 \
        --onefile \
        check-plugins\disk-usage\disk-usage

Compile using pyinstaller:

.. code-block:: text

    c:
    pyinstaller \
        --clean \
        --distpath c:\temp\pyinst.onedir\dist\onedir \
        --workpath c:\temp\pyinst.onedir\work \
        --specpath c:\temp\pyinst.onedir\spec \
        --noconfirm \
        --onedir \
        m:\check-plugins\disk-usage\disk-usage

    pyinstaller \
        --clean \
        --distpath c:\temp\pyinst.onefile\dist\onefile \
        --workpath c:\temp\pyinst.onefile\work \
        --specpath c:\temp\pyinst.onefile\spec \
        --noconfirm \
        --onefile \
        m:\check-plugins\disk-usage\disk-usage


CI/CD
-----

Currently the compilation and build process is done automatically using GitHub Actions. See the `CI/CD <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/.github/workflows/>`_ folder for details.
