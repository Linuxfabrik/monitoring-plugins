Name:           linuxfabrik-monitoring-plugins
Version:        %{lf_version}
Release:        %{lf_release}%{?dist}
Summary:        The Linuxfabrik Monitoring Plugins Collection
License:        Unlicense
URL:            https://github.com/Linuxfabrik/monitoring-plugins
Vendor:         Linuxfabrik GmbH, Zurich, Switzerland
Packager:       info@linuxfabrik.ch

Source0:        https://github.com/Linuxfabrik/monitoring-plugins/archive/refs/tags/v%{version}.tar.gz
Source1:        vendor.tar.gz

BuildRequires:  make
BuildRequires:  checkpolicy, selinux-policy-devel

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

# Build SELinux support
mkdir selinux
cp assets/selinux/%{name}.te selinux

pushd selinux
make --file %{_datadir}/selinux/devel/Makefile
install --directory %{buildroot}%{_datadir}/selinux/packages
install --preserve-context --mode 0644 linuxfabrik-monitoring-plugins.pp %{buildroot}%{_datadir}/selinux/packages
popd

%post selinux
if [ "$1" -le "1" ]; then
    # First install
    semodule --install %{_datadir}/selinux/packages/linuxfabrik-monitoring-plugins.pp 2>/dev/null || :
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
    semodule --install %{_datadir}/selinux/packages/linuxfabrik-monitoring-plugins.pp 2>/dev/null || :
fi

%files
%{_libdir}/%{name}/venv/
%{_libdir}/nagios/plugins/
%{_sysconfdir}/sudoers.d/%{name}
%license LICENSE.txt

%files selinux
%{_datadir}/selinux/packages/linuxfabrik-monitoring-plugins.pp

%changelog
