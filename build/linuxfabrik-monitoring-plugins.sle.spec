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

BuildRequires:	python311, python311-devel, python311-pip
Requires:       python311


%description
This Enterprise Class Check Plugin Collection offers a bunch of Nagios-compatible check plugins for Icinga, Naemon, Nagios, OP5, Shinken, Sensu and other monitoring applications. Each plugin is a stand-alone command line tool that provides a specific type of check. Typically, your monitoring software will run these check plugins to determine the current status of hosts and services on your network.

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

%files
%{_libdir}/%{name}/venv/
%{_libdir}/nagios/plugins/
%{_sysconfdir}/sudoers.d/%{name}
%license LICENSE.txt

%changelog
