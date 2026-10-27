# Check nextcloud-version


## Overview

Checks the installed Nextcloud version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable. Requires root or sudo.

**Important Notes:**

* The check must run locally on the Nextcloud server because it reads the version from the installation directory.

**Data Collection:**

* Runs Nextcloud `occ config:list` to read the installed version (default: `/var/www/html/nextcloud`, configurable via `--path`)
* Runs `occ` with PHP as the account that owns `config/config.php`. When the check runs as root through its [sudoers entry](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers), it switches to that account with `sudo`, which therefore has to be installed. When it already runs as that account, for example as root with a `config.php` that belongs to root, it does without `sudo`
* Compares against the [endoflife.date API](https://endoflife.date/api/nextcloud.json) to determine EOL status and available updates
* Caches endoflife.date responses locally for 24 hours to reduce external requests


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-version> |
| Nagios/Icinga Check Name              | `check_nextcloud_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: nextcloud-version [-h] [-V] [--always-ok] [--check-major]
                         [--check-minor] [--check-patch] [--insecure]
                         [--no-perfdata] [--no-proxy]
                         [--offset-eol OFFSET_EOL] [--path PATH]
                         [--proxy PROXY] [--timeout TIMEOUT]
                         [--unreachable-severity {ok,warn,crit,unknown}]

Checks the installed Nextcloud version against the endoflife.date API and
alerts if the version is end-of-life or if newer major, minor, or patch
releases are available. By default, alerts 30 days before the official EOL
date. The offset is configurable. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --check-major         Alert when a new major release is available, even if
                        the current version is not yet EOL. Example: running
                        v26 (not yet EOL) and v27 is available.
  --check-minor         Alert when a new major.minor release is available,
                        even if the current version is not yet EOL. Example:
                        running v26.2 (not yet EOL) and v26.3 is available.
  --check-patch         Alert when a new major.minor.patch release is
                        available, even if the current version is not yet EOL.
                        Example: running v26.2.7 (not yet EOL) and v26.2.8 is
                        available.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --offset-eol OFFSET_EOL
                        Alert n days before ("-30") or after an EOL date ("30"
                        or "+30"). Default: -30 days
  --path PATH           Local path to the Nextcloud installation, typically
                        the web server document root. Default:
                        /var/www/html/nextcloud
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --unreachable-severity {ok,warn,crit,unknown}
                        State to report when the online source is unreachable.
                        What is used instead - bundled offline data, a cached
                        copy, or nothing at all - is named in the output, and
                        a clean result then only covers what that fallback
                        could confirm. Default: ok

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/nextcloud-version/
```


## Usage Examples

```bash
./nextcloud-version --path=/var/www/html/nextcloud
```

Output:

```text
Nextcloud v22.1.7 (EOL 2022-07-01 -30d [WARNING], major 27.1.2 available, minor 22.2.10 available)
```


## States

The end-of-life verdict, the `--check-major` / `--check-minor` / `--check-patch` alerts, `--offset-eol`, `--always-ok` and what happens when endoflife.date cannot be reached work the same way in every endoflife.date-based version plugin. They are described in [Version Plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-version/).

* WARN if `occ` does not answer within `--timeout`.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| nextcloud-version | Number | Installed Nextcloud version as float. Each component is padded to three digits: "23.0.12" becomes "23.000012", the four-part "30.0.2.2" becomes "30.000002002". |


## Troubleshooting

### `sudo` is not installed

`Command "sudo" not found (No such file or directory). Install it, or make sure it is in the PATH of the account running this.`

`config/config.php` belongs to an account other than the one running the check, so the check switches to that account with `sudo`. Install it, for example with `dnf install sudo` or `apt install sudo`.


### Could not read the configuration below the installation

``Could not read the configuration below `/var/www/html/nextcloud`: PHP ended with rc=1. Run `php occ status` in `/var/www/html/nextcloud` as the owner of `config/config.php` to see why.``

Most often the check runs neither as root nor as the owner of `config/config.php`, and `sudo` refuses to switch to that account because it has no rule for the monitoring user. The supplied check command calls the check with `/usr/bin/sudo` and needs the matching [sudoers entry](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers); restore both if they were changed. If the check already runs as root, follow the message: `php occ status` as the owner of `config.php` shows what PHP complains about.


### Refusing an installation another account can change

`Refusing "/var/www/nextcloud": something below it can be changed by an account other than root and the trusted owners, or cannot be examined.`

`occ` runs as the owner of `config/config.php` and loads code from the whole installation, `console.php`, `lib/`, `3rdparty/`, `config/*.config.php` and every app directory `apps_paths` names, including those outside the installation. Every file and directory there therefore has to belong to root or that account, and no other user or group may write to it. The message does not name the offending object, because the account running the check may not be allowed to see it. Only `occ` and `config/config.php` themselves are named, for example `Refusing "/var/www/nextcloud/occ": "/var/www/nextcloud/occ" is writable by everyone.` Neither needs the execute bit, since the check runs `occ` through PHP; `0644` and `0755` both work, as long as no other user or group can write to the file. As root, list the candidates with (the data directory is skipped, adjust `apache` to the owner of `config.php`):

```bash
find /var/www/nextcloud -path /var/www/nextcloud/data -prune -o \( \( ! -user root ! -user apache \) -o -perm -o+w -o \( -perm -g+w ! -group root ! -group apache \) \) -print
getfacl --recursive --skip-base --absolute-names /var/www/nextcloud 2>/dev/null | grep '^# file'
```

Repeat both for every app directory outside the installation, such as `/var/lib/nextcloud/apps` on Fedora, together with its parent directories. A `config.php` that belongs to root, as `config_is_read_only` allows, makes `occ` run as root; then all of this has to belong to root.

## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
