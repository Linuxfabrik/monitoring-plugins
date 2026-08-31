Name:           linuxfabrik-monitoring-plugins
Version:        %{lf_version}
Release:        %{lf_release}%{?dist}
Summary:        The Linuxfabrik Monitoring Plugins Collection
License:        Unlicense
URL:            https://github.com/Linuxfabrik/monitoring-plugins
Vendor:         Linuxfabrik GmbH, Zurich, Switzerland
Packager:       info@linuxfabrik.ch

# Do not emit /usr/lib/.build-id/XX/YY... ELF build-id symlinks into
# the main package. RPM installs one such symlink for every shared
# object in the bundled venv, and the build-id hash is computed from
# the .so content, so two independent RPMs that happen to ship the
# same upstream binary (e.g. one also carrying a copy of libpython or
# of a compiled Python extension like charset_normalizer) end up
# fighting over the same symlink path and `dnf install` aborts with
# a file conflict. Setting `_build_id_links` to `none` tells rpmbuild
# to skip the symlink creation while leaving the rest of the package
# build untouched. See issue #979 for the conflict against azure-cli
# and Microsoft VS Code microsoft/vscode#116105 for the same
# workaround (merged 2021) against the same class of problem between
# `code` and `code-insiders`.
%define _build_id_links none

Source0:        https://github.com/Linuxfabrik/monitoring-plugins/archive/refs/tags/v%{version}.tar.gz
Source1:        vendor.tar.gz

BuildRequires:  make

BuildRequires:  checkpolicy, policycoreutils, selinux-policy-devel

Recommends:     %{name}-selinux = %{version}-%{release}

%if 0%{rhel} < 9
%define python_build_deps python39, python39-devel, python39-pip
%define python_deps python39
%else
%define python_build_deps python3 >= 3.9, python3-devel, python3-pip
%define python_deps python3 >= 3.9
%endif

BuildRequires: %{python_build_deps}
Requires: %{python_deps}


%description
This Enterprise Class Check Plugin Collection offers a bunch of Nagios-compatible check plugins for Icinga, Naemon, Nagios, OP5, Shinken, Sensu and other monitoring applications. Each plugin is a stand-alone command line tool that provides a specific type of check. Typically, your monitoring software will run these check plugins to determine the current status of hosts and services on your network.

%package        selinux
Summary:        SELinux support for Linuxfabrik's Monitoring Plugin Collection
Requires:       %{name} = %{version}-%{release}
Requires(post): policycoreutils, %{name}
Requires(preun): policycoreutils, %{name}
Requires(postun): policycoreutils

%description selinux
This package adds SELinux enforcement to the Linuxfabrik Monitoring Plugin Collection.

%prep
%setup -b 1 -T -n vendor
%setup -q -n monitoring-plugins

%install
install --directory %{buildroot}%{_libdir}/nagios/plugins

$LFMP_PYTHON -m venv %{buildroot}%{_libdir}/%{name}/venv

LFMP_DIR_SOURCES=%{_builddir} \
LFMP_VENV_PIP=%{buildroot}%{_libdir}/%{name}/venv/bin/pip \
bash build/install-vendor.sh

# Fix absolute paths in venv
find %{buildroot}%{_libdir}/%{name}/venv -type f -exec sed --in-place 's|%{buildroot}|/|g' {} \;

LFMP_DIR_TARGET=%{buildroot}%{_libdir}/nagios/plugins bash build/install-plugins.sh

# Fix plugin shebangs
find %{buildroot}%{_libdir}/nagios/plugins \
    -maxdepth 1 \
    -type f \
    -exec sed --in-place '1s|^#!.*|#!%{_libdir}/%{name}/venv/bin/python|' {} \;

# Install monitoring plugin sudoers
install --directory --mode 0750 %{buildroot}%{_sysconfdir}/sudoers.d
install --mode 0440 --no-target-directory assets/sudoers/RedHat.sudoers %{buildroot}%{_sysconfdir}/sudoers.d/%{name}

# The Defaults that keep the plugin calls out of the authentication log ship next to the rules
# rather than in /etc/sudoers.d, because whether they belong on a host depends on the sudo
# implementation it runs: sudo-rs knows none of them and warns about each on every sudo call by
# any user. %post puts the file in place where the classic sudo from sudo.ws runs.
install --directory %{buildroot}%{_datadir}/%{name}/sudoers
install --mode 0440 --no-target-directory assets/sudoers/RedHat-logging.sudoers %{buildroot}%{_datadir}/%{name}/sudoers/RedHat-logging.sudoers

# Install bash completion. It goes to the legacy directory on purpose: bash-completion
# sources that one at shell startup, while its own completions directory is loaded lazily
# by command name, which would need one file per plugin and would collide with the files
# bash-completion ships for the plugins named after a real command (ping, uptime, ...).
install --directory %{buildroot}%{_sysconfdir}/bash_completion.d
install --mode 0644 --no-target-directory assets/bash-completion/linuxfabrik-monitoring-plugins.bash %{buildroot}%{_sysconfdir}/bash_completion.d/%{name}

# Build SELinux support
mkdir selinux
cp assets/selinux/%{name}.te selinux

pushd selinux
%if 0%{?rhel} >= 10
# Pin the modular policy version instead of taking whatever the build host's checkmodule
# defaults to. On EL10 that default is 24, which only libsepol 3.10 and newer can read back,
# while a host still on the GA libsepol 3.8 refuses the module with "policydb module version
# 24 does not match my version range 4-22". The sub-package then installs and loads nothing.
# 22 is the highest that GA libsepol accepts, newer ones read it just as well, and the policy
# below uses nothing that needs a later version.
# Verified against libsepol 3.8 on Rocky 10.0 and libsepol 3.10 on Rocky 10.1.
checkmodule -M -m -c 22 -o %{name}.mod %{name}.te
semodule_package -o %{name}.pp -m %{name}.mod
%else
make --file %{_datadir}/selinux/devel/Makefile
%endif
install --directory %{buildroot}%{_datadir}/selinux/packages
install --preserve-context --mode 0644 linuxfabrik-monitoring-plugins.pp %{buildroot}%{_datadir}/selinux/packages
popd

%define sudoers_logging_src %{_datadir}/%{name}/sudoers/RedHat-logging.sudoers
%define sudoers_logging_dest %{_sysconfdir}/sudoers.d/%{name}-logging

# Without the Defaults in the companion drop-in, a single check costs five entries in the
# authentication log, the sudo command line plus the PAM session being opened and closed, and a
# monitored host runs dozens of checks a minute. It is placed here rather than packaged into
# /etc/sudoers.d so that a host running sudo-rs, which knows none of those settings and warns
# about each of them on every sudo call by any user, does not get it - and loses it again if it
# changed implementation since the last transaction. The name carries no dot on purpose: sudo
# skips a file in /etc/sudoers.d whose name holds one.
%post
if command -v sudo >/dev/null 2>&1 && sudo --version 2>/dev/null | head -1 | grep -qi 'sudo-rs'; then
    rm -f %{sudoers_logging_dest}
# A host carrying no sudo at all has no authentication log to quiet down, and no visudo
# either, which the check below would otherwise report as a failure of a file that is fine.
elif command -v visudo >/dev/null 2>&1 && [ -f %{sudoers_logging_src} ]; then
    # A broken drop-in in /etc/sudoers.d locks every user out of sudo, so it is checked first.
    if visudo -cf %{sudoers_logging_src} >/dev/null 2>&1; then
        install -m 0440 -o root -g root %{sudoers_logging_src} %{sudoers_logging_dest}
        restorecon %{sudoers_logging_dest} 2>/dev/null || :
    else
        echo "%{name}: %{sudoers_logging_src} failed the visudo check, leaving %{sudoers_logging_dest} alone" >&2
    fi
fi

%postun
if [ "$1" -eq "0" ]; then
    # Uninstall. The file sits outside the package's own file list, so rpm does not take it.
    rm -f %{sudoers_logging_dest}
fi

# The scriptlets never fail the transaction, but they no longer hide why they did
# not do their job: a module that cannot be loaded used to leave behind a package
# that looks installed and does nothing at all. `nagios_run_sudo` and the file
# contexts below `%{_libdir}/nagios/plugins` come from the distribution's nagios
# policy, which EL10 does not carry, so both calls are allowed to do nothing.
%post selinux
if [ "$1" -le "1" ]; then
    # First install
    semodule --install %{_datadir}/selinux/packages/linuxfabrik-monitoring-plugins.pp || \
        echo "%{name}-selinux: could not load the SELinux policy module, see above" >&2
    setsebool -P nagios_run_sudo on || :
    restorecon -r %{_libdir}/nagios/plugins || :
fi

%preun selinux
if [ "$1" -lt "0" ]; then
    # Uninstall
    semodule --remove linuxfabrik-monitoring-plugins 2>/dev/null || :
    setsebool -P nagios_run_sudo off || :
fi

%postun selinux
if [ "$1" -ge "1" ]; then
    # Upgrade
    semodule --install %{_datadir}/selinux/packages/linuxfabrik-monitoring-plugins.pp || \
        echo "%{name}-selinux: could not load the SELinux policy module, see above" >&2
fi

%files
%{_libdir}/%{name}/venv/
%{_libdir}/nagios/plugins/
%{_sysconfdir}/bash_completion.d/%{name}
%{_sysconfdir}/sudoers.d/%{name}
%{_datadir}/%{name}/sudoers/
%license LICENSE

%files selinux
%{_datadir}/selinux/packages/linuxfabrik-monitoring-plugins.pp

%changelog
