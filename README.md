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
<div align="center">

![GitHub Stars](https://img.shields.io/github/stars/linuxfabrik/monitoring-plugins)
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

Written in Python, released into the public domain under the [UNLICENSE](https://unlicense.org/). Runs on any platform with Python 3.9+ (Linux, Windows, macOS, FreeBSD). For Windows we also ship pre-compiled binaries, so Python is not required on the target.


## Documentation

Full documentation is at [linuxfabrik.github.io/monitoring-plugins](https://linuxfabrik.github.io/monitoring-plugins/). It is rebuilt and deployed on every push to `main`, so the docs site is always in sync with this repository.


## Try it Live

A public demo with the plugins wired into Icinga Web 2 and Grafana:
[icinga-demo.linuxfabrik.ch](https://icinga-demo.linuxfabrik.ch/). The
[introduction on our blog](https://www.linuxfabrik.ch/en/blog/icinga-demo-linuxfabrik-ch)
has the credentials and suggestions on what to click on first.


## Quick Start

After [installing](#installation), run a plugin directly to verify it works:

```text
$ /usr/lib64/nagios/plugins/cpu-usage --warning=80 --critical=90
18.6% - user: 13.1%, system: 4.5%, irq: 0.5%, softirq: 0.5%
guest: 0.0%, guest_nice: 0.0%, iowait: 0.0%, nice: 0.0%, steal: 0.0%
ctx_switches: 8.4G, interrupts: 6.8G, soft_interrupts: 1.7G|'cpu-usage'=18.6%;80;90;0;100 ...
```

Every plugin supports `--help` and prints its version with `--version`.


## OS Compatibility

| Family            | Tested releases                                       | Notes                              |
| ----------------- | ----------------------------------------------------- | ---------------------------------- |
| Debian            | 11 (bullseye), 12 (bookworm), 13 (trixie)             |                                    |
| RHEL and clones   | Rocky 8, Rocky 9, Rocky 10                            | Also Alma, CentOS Stream, Oracle.  |
| SLE / openSUSE    | SLE 15.5                                              | SLE 15 requires SP5.               |
| Ubuntu            | 20.04 (focal), 22.04 (jammy), 24.04 (noble)           | 26.04 packages are built as well.  |
| Windows           | Windows Server 2016 and later, Windows 10 and later   | Shipped as signed MSI, x86_64.     |

Other Linux distributions run the plugins fine as long as Python 3.9 or newer is available; you just lose the pre-built native packages.


## Installation

The recommended path is our package repository for Linux (RPM/DEB) and the signed MSI for Windows. See [INSTALL.md](INSTALL.md) for per-distribution commands, the source-tarball and Git paths, sudoers drop-ins and SELinux bits.


## Icinga, Grafana, Nagios

* **Icinga Director**: import the shipped basket (Host Templates, Service Templates, ~150 Service Sets, Time Periods, Notifications). See [ICINGA.md](ICINGA.md).
* **Grafana**: per-plugin dashboards under `check-plugins/<plugin>/grafana/`, provisioned with Grizzly today. See [GRAFANA.md](GRAFANA.md).
* **Plain Nagios, Naemon, Shinken, Sensu**: plugins emit standard Nagios plugin output and perfdata. Drop them into `/usr/lib64/nagios/plugins/` and reference them from your `command` definitions. Hosts, services and notifications stay in your existing configuration.


## Plugin Index

230+ plugins. The documentation site lists all of them alphabetically with full help text and perfdata reference: <https://linuxfabrik.github.io/monitoring-plugins/>. Plugins that share setup steps are grouped:

* [Keycloak plugins](PLUGINS-KEYCLOAK.md)
* [MySQL / MariaDB plugins](PLUGINS-MYSQL.md)
* [Rocket.Chat plugins](PLUGINS-ROCKETCHAT.md)
* [WildFly / JBoss EAP plugins](PLUGINS-WILDFLY.md)

For a visual tour of what plugins look like in Icinga Web 2, see [POSTER.md](POSTER.md).


## Conventions


### Threshold and Ranges

If a check supports Nagios ranges, they can be used as follows:

* Simple value: a range from 0 up to and including the value.
* A range is as defined on [nagios-plugins.org](https://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT): `start:end`, start and end point inclusive on a numeric scale, with possibly negative or positive infinity.
* Empty value after `:`: positive infinity.
* `~`: negative infinity.
* `@`: inverts the whole expression. A range prefixed with `@` alerts when the value is *inside* the range (endpoints included).

Examples:

| -w, -c    | OK if result is     | WARN/CRIT if        |
| --------- | ------------------- | ------------------- |
| 10        | in (0..10)          | not in (0..10)      |
| -10       | in (-10..0)         | not in (-10..0)     |
| 10:       | in (10..inf)        | not in (10..inf)    |
| :         | in (0..inf)         | not in (0..inf)     |
| ~:10      | in (-inf..10)       | not in (-inf..10)   |
| 10:20     | in (10..20)         | not in (10..20)     |
| @10:20    | not in (10..20)     | in 10..20           |
| @~:20     | not in (-inf..20)   | in (-inf..20)       |
| @         | not in (0..inf)     | in (0..inf)         |


### Human-Readable Units

Byte sizes use IEC (KiB, MiB, GiB, powers of 2) so values match what the shell shows. Large numbers, times, and bits-per-second follow their own conventions. The full unit reference is in [UNITS.md](UNITS.md).


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

Q: **A plugin exits UNKNOWN with `sudo: a password is required` or `not allowed to execute`.**

A: The plugin needs elevated privileges (typical for `dmesg`, `disk-smart`, journald, and others) but the Icinga user has no sudo rule for it. Install the matching sudoers drop-in from `assets/sudoers/` (`Debian.sudoers` or `RedHat.sudoers`) into `/etc/sudoers.d/`, as described in the Post-Install section of [INSTALL.md](INSTALL.md). The RPM and DEB packages already drop this in for you.


Q: **A plugin reports an unknown argument when I pass a value starting with `-`.**

A: argparse treats a value that starts with `-` as another option. Glue the value to the parameter instead of separating with a space:

* Long parameters: `./file-age --warning=-60:3600` (not `--warning -60:3600`).
* Short parameters: `./file-age -w-60:3600` (no space, no escape).

For the related Icinga-specific variant (where Icinga Director cannot be told to use `=`), see the FAQ entry "Negative values for plugin arguments cause problems in Icinga" below.


Q: **After an update, I get "Operational Error: no such column: ..., state UNKNOWN". On the next run, this disappears. What happened?**

A: Some check plugins require SQLite database files to cache data or to calculate data over time. After an update it is possible that the check plugin uses a new schema, but the database file on disk hasn't been updated (we don't implement database migrations). So in case of an "OperationalError", which happens for example when the plugin tries to INSERT into an outdated table, the database library simply deletes the sqlite database file. It will then be recreated from scratch by the plugin on the next run, with the updated database structure.


Q: **Icinga does not seem to pass the environment variable `http_proxy` to the plugins. What am i doing wrong?**

This has nothing to do with the Linuxfabrik monitoring plugins - the Icinga configuration needs to be adjusted here. You need to do some additional configuration to make custom environment variables generally available. According to [this Icinga community post](https://community.icinga.com/t/environments-for-all-check-commands/9092) you need to set them in `/etc/icinga2/icinga2.conf`:

```
template CheckCommand default {
  env.http_proxy = "http://username:password@proxy.example.com:port"
  env.https_proxy = "http://username:password@proxy.example.com:port"
}
```

If you are also using `sudo` to call some plugins from within Icinga, you will also need to set this in your `/etc/sudoers.d/whatever.sudoers`:

```
Defaults env_keep += "http_proxy https_proxy"
```

Pro tips:

* Note that you can't set environment variables in Icinga Director. Even if you are only using the Icinga Director, follow the steps above.
* Environment variables with the same name in both `/etc/environment` and `/etc/icinga2/icinga2.conf` will be overwritten by `/etc/icinga2/icinga2.conf`.


Q: **Negative values for plugin arguments cause problems in Icinga.**

A: As of 2024-11, Icinga still passes parameter values to plugins without a leading `=`. This causes plugins to assume that parameters starting with negative values are additional but unknown arguments. In Icinga this can be avoided by prefixing the first minus sign of a value with a backslash `\`, which is later removed by the [base.py](https://github.com/Linuxfabrik/lib/blob/main/base.py) library (v2024112001+, v2.0.0.0+). So just use `\-60` or `\-60:-3600` instead of `-60` or `-60:-3600` (see [#789](https://github.com/Linuxfabrik/monitoring-plugins/issues/789)).


Q: **On Windows, some plugins result in `0x80070005 (E_ACCESSDENIED)`.**

A: When using the plugins in Icinga: [According to the Icinga documentation](https://icinga.com/docs/icinga-2/latest/doc/06-distributed-monitoring/#agent-setup-on-windows-configuration-wizard) the Icinga Agent runs as the `Network Service` user by default. This may result in `0x80070005 (E_ACCESSDENIED)` messages for some plugins. In this case, [use JEA Profiles for Icinga for Windows](https://icinga.com/docs/icinga-for-windows/latest/doc/130-JEA/01-JEA-Profiles/) and see [installing JEA for Windows](https://icinga.com/docs/icinga-for-windows/latest/doc/130-JEA/02-Installation/).


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

See [CONTRIBUTING.md](CONTRIBUTING.md) for check-plugin developer guidelines, coding conventions, and the basket / Grafana deliverables. The [example plugin](check-plugins/example/example) is the reference skeleton.

Compiling and packaging (RPM, DEB, Windows MSI, Code Signing) is documented in [BUILD.md](BUILD.md).


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
