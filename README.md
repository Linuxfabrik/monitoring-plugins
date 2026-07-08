<h1 align="center">
  <a href="https://linuxfabrik.ch" target="_blank">
    <picture>
      <img width="600" src="https://download.linuxfabrik.ch/monitoring-plugins/assets/img/linuxfabrik-monitoring-check-plugins-teaser.png">
    </picture>
  </a>
  <br />
  Linuxfabrik Monitoring Plugins
</h1>
<p align="center">
  230+ monitoring plugins for Icinga, Nagios & friends. Python 3.9+, all platforms. Smart defaults, auto-discovery, consistent cross-platform metrics, minimal dependencies. 
  <span>&#8226;</span>
  <b>made by <a href="https://linuxfabrik.ch/">Linuxfabrik</a></b>
</p>
<div align="center" markdown>

![GitHub Stars](https://img.shields.io/github/stars/linuxfabrik/monitoring-plugins)
[![Star History Chart](https://api.star-history.com/svg?repos=Linuxfabrik/monitoring-plugins&type=Date)](https://star-history.com/#Linuxfabrik/monitoring-plugins&Date)
![GitHub](https://img.shields.io/github/license/linuxfabrik/monitoring-plugins)
![Version](https://img.shields.io/github/v/release/linuxfabrik/monitoring-plugins?sort=semver)
![Python](https://img.shields.io/badge/Python-3.9+-3776ab)
![Platforms](https://img.shields.io/badge/Platforms-All%20Platforms-informational)
![GitHub Issues](https://img.shields.io/github/issues/linuxfabrik/monitoring-plugins)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/9892/badge)](https://www.bestpractices.dev/projects/9892)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/Linuxfabrik/monitoring-plugins/badge)](https://scorecard.dev/viewer/?uri=github.com/Linuxfabrik/monitoring-plugins)
[![GitHubSponsors](https://img.shields.io/github/sponsors/Linuxfabrik?label=GitHub%20Sponsors)](https://github.com/sponsors/Linuxfabrik)
[![PayPal](https://img.shields.io/badge/Donate-PayPal-ff6600)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7AW3VVX62TR4A&source=url)

</div>

<br />


# The Linuxfabrik Monitoring Plugins Collection

Nagios-compatible check plugins for Icinga, Naemon, Nagios and any other monitoring system that speaks the Nagios plugin API. Each plugin is a stand-alone CLI that reports one type of check: fast, consistent across platforms, minimal dependencies, reasonable defaults so WARN and CRIT only fire when it really matters.

> If these plugins help you monitoring your datacenter, your VMs or your applications, please give it a star.

Written in Python, released into the public domain under the [UNLICENSE](https://unlicense.org/). Runs on any platform with Python 3.9+ (Linux, Windows, macOS, FreeBSD). For Windows we also ship pre-compiled binaries, so Python is not required on the target.


## Documentation

Full documentation is available at [linuxfabrik.github.io/monitoring-plugins](https://linuxfabrik.github.io/monitoring-plugins/). It is automatically built and deployed on every push to `main`.

For a visual tour of what plugins look like in Icinga Web 2, see [POSTER.md](POSTER.md).


## Try it Live

A public demo with the plugins wired into Icinga Web 2 and Grafana:
[icinga-demo.linuxfabrik.ch](https://icinga-demo.linuxfabrik.ch/).


## Installation

**On Linux**, install with the one-liner. It registers our signed package repository and installs the package:

```bash
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash
```

**On Windows**, download [lfmp-latest.signed-packaged.windows.x86_64.zip](https://download.linuxfabrik.ch/monitoring-plugins/lfmp-latest.signed-packaged.windows.x86_64.zip), extract the signed MSI it contains and run it (double-click or `msiexec /i lfmp-*.msi /qn`).

Then run a plugin directly to verify it works, for example on Linux:

```text
$ /usr/lib64/nagios/plugins/cpu-usage
5.1% - user: 3.0%, system: 1.0%, irq: 0.5%, softirq: 0.5%
guest: 0.0%, guest_nice: 0.0%, iowait: 0.0%, nice: 0.0%, steal: 0.0%
ctx_switches: 8.5G, interrupts: 6.8G, soft_interrupts: 1.7G|'cpu-usage'=5.1%;80;90;0;100 ...
```

Every plugin supports `--help` and prints its version with `--version`.

For more installation paths, see [INSTALL.md](INSTALL.md): the LFOps Ansible role for fleets (Linux and Windows), the source install for running the latest state in production, air-gapped and per-distribution setups, sudoers drop-ins and SELinux.

Plugins that share setup steps:

* [Keycloak plugins](PLUGINS-KEYCLOAK.md)
* [MySQL / MariaDB plugins](PLUGINS-MYSQL.md)
* [Rocket.Chat plugins](PLUGINS-ROCKETCHAT.md)
* [WildFly / JBoss EAP plugins](PLUGINS-WILDFLY.md)


## OS Compatibility

| Family            | Tested releases                                       | Notes                              |
| ----------------- | ----------------------------------------------------- | ---------------------------------- |
| Debian            | 11 (bullseye), 12 (bookworm), 13 (trixie)             |                                    |
| RHEL and clones   | Rocky 8, Rocky 9, Rocky 10                            | Also Alma, CentOS Stream, Oracle.  |
| SLE / openSUSE    | SLE 15.5                                              | SLE 15 requires SP5.               |
| Ubuntu            | 20.04 (focal), 22.04 (jammy), 24.04 (noble)           | 26.04 packages are built as well.  |
| Windows           | Windows Server 2016 and later, Windows 10 and later   | Shipped as signed MSI, x86_64.     |

Other Linux distributions run the plugins fine as long as Python 3.9 or newer is available; you just lose the pre-built native packages.


## Icinga, Grafana, Nagios

* **Icinga Director**: import the shipped basket (Host Templates, Service Templates, ~150 Service Sets, Time Periods, Notifications). See [ICINGA.md](ICINGA.md).
* **Grafana**: per-plugin dashboards under `check-plugins/<plugin>/grafana/`, provisioned with Grizzly today. See [GRAFANA.md](GRAFANA.md).
* **Plain Nagios, Naemon, Shinken, Sensu**: plugins emit standard Nagios plugin output and perfdata. Drop them into `/usr/lib64/nagios/plugins/` and reference them from your `command` definitions. Hosts, services and notifications stay in your existing configuration.


## Conventions


### Human-Readable Units

Byte sizes use IEC (KiB, MiB, GiB, powers of 2) so values match what the shell shows. Large numbers, times, and bits-per-second follow their own conventions. The full unit reference is in [UNITS.md](UNITS.md).


### Thresholds and Ranges

Where a check supports thresholds, `--warning` / `--critical` follow the [Nagios plugin format](https://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT) (`start:end`, `~` for negative infinity, `@` to invert). The full threshold reference with examples is in [THRESHOLDS.md](THRESHOLDS.md).


## Parameter Handling

When you call a plugin directly from a shell, two things can trip you up. Through Icinga Director the rules are different (no `=` allowed, plus Icinga's own `$$` macro escaping); see the Parameter Handling section in [ICINGA.md](ICINGA.md).

A value that starts with `-` is read by `argparse` as another option, so the plugin reports an unknown argument. Glue the value to its parameter instead of separating it with a space: long parameters as `./file-age --warning=-60:3600` (not `--warning -60:3600`), short parameters as `./file-age -w-60:3600`.

A value that contains shell-special characters such as `$`, `*`, spaces or parentheses must be wrapped in single quotes so the shell passes it through to the plugin literally. This matters for regex parameters like `--match` and `--ignore`, for example `./dmesg --ignore='error$'`. Single quotes do not help with the leading-`-` case, because that is an `argparse` rule and not a shell one; use the glue form above.


## FAQ

Q: **All pipe characters `|` in the output of any plugin are replaced with `!`. Why?**

A: We have to. The output syntax of Nagios plugins is fixed and not very flexible:

```
Output lines | Performance data
```

So the `|` character is reserved to separate plugin output from performance data. There is no way to escape it - so we have to replace it with `!`.


Q: **Can I overwrite specific plugins with its source code variant, if all other plugins are installed by the OS package manager?**

A: Of course. Just don't forget to install the libs either.


Q: **Do the OS packages have external dependencies?**

A: No.


Q: **Do the plugins also handle proxy environment variables like `HTTP_PROXY`?**

A: Yes, `HTTP_PROXY`, `HTTPS_PROXY`, `http_proxy` and `https_proxy` are automatically used by the Linuxfabrik monitoring plugins if they are set.


Q: **How can I remove the performance data after the `|` from the check output?**

A: In Bash, use `/usr/lib64/nagios/plugins/check-command | cut -f1 -d'|'`


## Troubleshooting

For installation-related issues (sudoers drop-ins, SELinux, Windows `0x80070005` under the Icinga Agent) see [INSTALL.md](INSTALL.md). For Icinga-specific quirks (passing `http_proxy` through Icinga, escaping special characters like `$` and leading `-` in Director-dispatched parameters) see [ICINGA.md](ICINGA.md).

Q: **A log-reading check (`logfile`, `mysql-logfile`, `openvpn-client-list`) exits UNKNOWN with "Refusing to read ...: resolved path is outside the allowed log directory". How do I monitor a log stored elsewhere?**

A: These checks run as root via sudo, so they only open files inside `/var/log` (`mysql-logfile` also allows `/var/lib/mysql`). This prevents a compromised monitoring account from turning the check into an arbitrary root file read (e.g. `--filename=/etc/shadow`). To monitor a log that lives outside `/var/log`, make it reachable *inside* `/var/log` with a bind mount, then point the check at the path under `/var/log`:

```bash
mount --bind /opt/myapp/logs /var/log/myapp
```

Persist it across reboots with an `/etc/fstab` entry:

```text
/opt/myapp/logs  /var/log/myapp  none  bind  0 0
```

Use a bind mount, not a symlink. The check resolves the path with `realpath()` before opening it, which follows symlinks: a symlink `/var/log/myapp` pointing to `/opt/myapp/logs` therefore resolves back to `/opt/myapp/logs`, lands outside `/var/log`, and is rejected. A bind mount is not a symlink, so the path stays `/var/log/myapp` and passes the check while still reading the real file. And because only root can create a bind mount, an attacker on the monitoring account cannot use one to escape the confinement.

Q: **After an update, I get "Operational Error: no such column: ..., state UNKNOWN". On the next run, this disappears. What happened?**

A: Some check plugins require SQLite database files to cache data or to calculate data over time. After an update it is possible that the check plugin uses a new schema, but the database file on disk hasn't been updated (we don't implement database migrations). So in case of an "OperationalError", which happens for example when the plugin tries to INSERT into an outdated table, the database library simply deletes the sqlite database file. It will then be recreated from scratch by the plugin on the next run, with the updated database structure.


Q: **On Windows, sometimes Windows Defender randomly kills a plugin. Why?**

A: Depending on your signature versions or the healthiness of your signature cache, the Microsoft Windows Defender might classify a check as malicious (for example our `service.exe`). Please follow the steps below to clear cached detections and obtain the latest malware definitions.

1. Open command prompt as administrator and change directory to `c:\program files\windows defender`
2. Run `MpCmdRun.exe -removedefinitions -dynamicsignatures`
3. Run `MpCmdRun.exe -SignatureUpdate`


## Reporting Issues

1. [Submit an issue](https://github.com/Linuxfabrik/monitoring-plugins/issues/new/choose) (preferred).
2. [Contact us](https://www.linuxfabrik.ch/en/contact) by email or web form and describe your problem.

For vulnerabilities, follow the private disclosure process in [SECURITY.md](SECURITY.md).


## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for check-plugin developer guidelines, coding conventions, and the basket / Grafana deliverables. The [example plugin](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/example/example) is the reference skeleton.

Compiling and packaging (RPM, DEB, Windows MSI, Code Signing) is documented in [BUILD.md](BUILD.md). Helper scripts under `tools/` (basket generation, docs build, unit-test and linter runners) are described in [TOOLS.md](TOOLS.md).


## Support the Project

Enterprise support, including an SLA and custom plugin development, is available via a [Service Contract](https://www.linuxfabrik.ch/en/products/service-support).

If these plugins help you, consider a donation via
[GitHub Sponsors](https://github.com/sponsors/Linuxfabrik) or
[PayPal](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7AW3VVX62TR4A&source=url).
Past sponsors are listed in [SPONSORS.md](SPONSORS.md); community quotes in
[TESTIMONIALS.md](TESTIMONIALS.md). Sharing the project on social media, in
blog posts or via the [Show and tell category](https://github.com/Linuxfabrik/monitoring-plugins/discussions/categories/show-and-tell)
on GitHub Discussions is always welcome.

There is no fixed roadmap. Milestones are driven by customer needs and by contributors' time.
