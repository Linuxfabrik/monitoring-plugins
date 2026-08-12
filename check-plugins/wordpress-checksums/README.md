# Check wordpress-checksums


## Overview

Verifies the files of a local WordPress installation against the checksums wordpress.org publishes for the installed release, and reports every file that was modified, added or removed since. Covers the core and every plugin from the plugin directory. Alerts when a file does not match, which on a server nobody has hand-patched means the installation was tampered with. Supports extended reporting via `--lengthy`.

This is the check that notices a web shell dropped into `wp-includes/`, a core file with an injected redirect, or a plugin whose code was swapped out. It answers a different question than the two other WordPress checks: `wordpress-version` says whether the installed release is still supported, `wordpress-security-scan` says whether that release has publicly known vulnerabilities, and this one says whether the files on disk are still the files that were released.

**Important Notes:**

* A finding is not proof of a compromise, and a clean result is not proof of the opposite. A file can differ because somebody patched it by hand, because a deployment rewrote it, or because an editor left a stray newline. Treat a finding as a question to answer, not as a verdict. Equally, an attacker who also controls the checksum comparison is not caught by it, and everything outside the verified scope below is not covered at all.
* Not everything is verified. Themes have no published checksums anywhere, so they are outside the scope entirely, as are uploads, must-use plugins, drop-ins and anything else below `wp-content/`. Commercial plugins and plugins installed from outside the wordpress.org plugin directory have no published checksums either; they are named in the output and `--no-checksum-data-severity` decides whether that alerts.
* Old releases cannot be verified. The core is covered from 3.6 in English and from 3.7 at the earliest in other languages. Below that, wordpress.org publishes nothing to compare against, and the check says so instead of reporting a clean result. See [`Not verified: core`](#not-verified-core) for the release table and what to do about it.
* The locale matters and is read automatically. wordpress.org ships one release per language, and a German release carries several hundred files an English one does not. The check reads the locale from the same place WordPress reads it, so a localized installation is held to the list it was actually built from.
* The installation root is only partly covered. `wp-admin/` and `wp-includes/` are verified completely, including files that do not belong there. In the installation root only the files wordpress.org lists are compared, and a file found there that is not on the list is never reported: the root is shared with the web server, the site's own files and the deployment tooling.
* Six files are excluded on purpose. `wp-config.php` holds the credentials and is written per installation. `.htaccess` is rewritten by WordPress whenever the permalink structure changes, and `.maintenance` exists only during an update. `readme.html` and `license.txt` are documentation and are routinely deleted as a hardening step, which must not read as a damaged installation. `index.php` is copied and edited by WordPress's own procedure for serving a site from a subdirectory. Inside a plugin, `readme.txt` and `readme.md` are excluded for the same kind of reason: the plugin directory rewrites them without the plugin itself changing.
* `index.php` is the exception worth knowing about. It is the only one of the six that WordPress's own updater does check, and it is a classic place to hide a backdoor, so a modified one goes unreported here. No parameter brings it back, because the file is outside the compared set rather than being filtered out of the findings. On an installation that is not served from a subdirectory, compare it by hand: it holds one `require` line and nothing else.
* A plugin bundled with the core is allowed to differ from the plugin directory's copy. WordPress ships Akismet and Hello Dolly along with the core, and its copy is not always byte-for-byte the one the directory publishes under the same version number. A file matching either of the two was published by wordpress.org and is not a finding. Where the core list is missing, the two cannot be told apart and the plugin is reported as unverifiable instead.
* First run of the day is the slow one. The published checksums are cached locally for a day, so only the first run per release fetches them. A stock installation is verified in well under a second afterwards.
* The run as a whole has a network budget, not just each single request. One request is made per component, so on a host that cannot reach wordpress.org the check would otherwise wait `--timeout` seconds per component and be killed by the monitoring agent before printing anything. `--total-timeout` caps the lot at 45 seconds by default, which is below the timeout the shipped Director command grants the check. Components not reached within the budget are reported as unqueried, exactly like a failed request. Raise both together on an installation with many plugins on a slow link.
* wordpress.org being unreachable does not empty the cache. The check then verifies against the expired copy and says so on its own line below the result, together with how old the data is. The digests of a released version never change, so what it verified is still correct; what is missing is knowledge of anything released since. `--unreachable-severity` decides whether an outage alerts, and it is a separate parameter from `--no-checksum-data-severity` on purpose: one gap is a broken egress rule, the other is a commercial plugin nobody publishes checksums for.
* The check is part of the WordPress Service Set, so tagging a host `wordpress` activates it. It needs no per-instance parameter as long as the installation lies below the default `--path`.

**Data Collection:**

Two sources are compared:

* The installation below `--path`. The check reads `wp-includes/version.php` for the core version and the locale, and the plugin headers below `wp-content/plugins/` for the installed plugins and their versions. It then hashes every file within the scope described above. No database connection, no HTTP request against the site itself, and no `wp-cli`.
* The digests wordpress.org publishes, from `api.wordpress.org` for the core and from `downloads.wordpress.org` for each plugin. Both are open endpoints and need no account. Answers are cached in a local SQLite database per release, so an update fetches its own digests once and the runs after it are served locally.

A plugin is looked up under the slug it names itself in its `Plugin URI` header, not under its directory name. The two are usually the same, but not for a single-file plugin: `hello.php`, shipped with every WordPress, is `hello-dolly` in the plugin directory.

Findings can be narrowed from both ends. `--match` keeps only what matches, `--ignore` drops what matches, and both are Python regular expressions tested against `<component>/<path>`, where the component is `core` or the plugin's slug. `--ignore='^my-plugin/'` therefore accepts one component and `--ignore='^akismet/akismet\.php$'` one file. Where the filters leave no finding at all, the check reports "Nothing checked." and `--no-match-severity` decides whether that alerts.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wordpress-checksums> |
| Nagios/Icinga Check Name              | `check_wordpress_checksums` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | Read access to the WordPress installation; outbound HTTPS to `api.wordpress.org` and `downloads.wordpress.org` |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-wordpress-checksums.db` |


## Help

```text
usage: wordpress-checksums [-h] [-V] [--always-ok]
                           [--cache-expire CACHE_EXPIRE] [--ignore IGNORE]
                           [--insecure] [--lengthy] [--match MATCH]
                           [--no-checksum-data-severity {ok,warn,crit,unknown}]
                           [--no-match-severity {ok,warn,crit,unknown}]
                           [--no-perfdata] [--no-proxy] [--path PATH]
                           [--severity {ok,warn,crit}] [--timeout TIMEOUT]
                           [--total-timeout TOTAL_TIMEOUT]
                           [--unreachable-severity {ok,warn,crit,unknown}]

Verifies the files of a local WordPress installation against the checksums
wordpress.org publishes for the installed release, and reports every file that
was modified, added or removed since. Covers the core and every plugin from
the plugin directory. Alerts when a file does not match, which on a server
nobody has hand-patched means the installation was tampered with. Supports
extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. The published checksums of
                        a released version never change, so this is about how
                        often wordpress.org is asked, not about how current
                        the answer is. Default: 1440
  --ignore IGNORE       Ignore files whose path matches this Python regular
                        expression. Matched against `<component>/<path>`,
                        where the component is `core` or the plugin's slug.
                        Case-sensitive by default; use `(?i)` for case-
                        insensitive matching. Can be specified multiple times.
                        Example: `--ignore="^my-plugin/"` to accept one
                        component. Example:
                        `--ignore="^akismet/akismet\.php$"` to accept one file
                        that was patched by hand.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Only check files whose path matches this Python
                        regular expression. Matched against
                        `<component>/<path>`, where the component is `core` or
                        the plugin's slug. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times. If both `--match` and `--ignore` are
                        given, an item must match `--match` AND not match
                        `--ignore` to be reported (include first, exclude
                        second). Example: `--match="^core/"` to look at the
                        core alone. Example: `--match="\.php$"` to look at the
                        PHP files alone.
  --no-checksum-data-severity {ok,warn,crit,unknown}
                        State to report when no published checksums are
                        available for a component and it could not be
                        verified. The check still verifies everything it has
                        checksums for, but a clean result then only covers
                        those components, not the ones it had to skip. Applies
                        where wordpress.org publishes nothing for a component,
                        which is a permanent property of that component and
                        nothing to fix on this host. A component wordpress.org
                        could not be asked about is a different case and
                        follows --unreachable-severity. Default: ok
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --path PATH           Local path to your WordPress installation, typically
                        within your Webserver's Document Root. Default:
                        /var/www/html/wordpress
  --severity {ok,warn,crit}
                        Severity for alerting. Applies to a file that does not
                        match its published checksum. Raise it to `crit` on an
                        installation nobody hand-patches, where a mismatch can
                        only mean the files were tampered with. Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Applies to a single
                        request. The run as a whole is bounded by --total-
                        timeout. Default: 8 (seconds)
  --total-timeout TOTAL_TIMEOUT
                        Seconds the run may spend asking wordpress.org, across
                        all requests. One request is made per component, so a
                        host that cannot reach wordpress.org would otherwise
                        wait --timeout seconds per component and be killed by
                        the monitoring agent before it printed anything.
                        Components not reached within the budget are reported
                        as unqueried, the same way a failed request is. Keep
                        it below the timeout the monitoring agent grants the
                        check. Raise it on an installation with many plugins
                        on a slow link. Default: 45 (seconds)
  --unreachable-severity {ok,warn,crit,unknown}
                        State to report when the online source is unreachable.
                        What is used instead - bundled offline data, a cached
                        copy, or nothing at all - is named in the output, and
                        a clean result then only covers what that fallback
                        could confirm. Covers both a component verified
                        against an expired cached copy and one that could not
                        be verified at all for want of one. Raise it where the
                        host is expected to reach wordpress.org, so a broken
                        egress rule or an expired proxy credential surfaces
                        instead of quietly reducing what the check covers.
                        Default: ok

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/wordpress-checksums/
```


## Usage Examples

A stock installation, nothing to report:

```bash
./wordpress-checksums --path=/var/www/html/wordpress
```

```text
No checksum violations found. WordPress v6.8.2 (en_US). 2834 files verified in 3 of 3 components.
```

The same installation after somebody got in:

```bash
./wordpress-checksums --path=/var/www/html/wordpress
```

```text
2 modified, 2 added, 1 missing [WARNING]. WordPress v6.8.2 (en_US). 2833 files verified in 3 of 4 components.
Not verified: acme-premium. wordpress.org publishes no checksums for this component, so nothing in the result above applies to it. A plugin ends up here when it is commercial or was installed from outside the wordpress.org plugin directory. Nothing to fix on this host; compare it against the vendor's own download where it has to be covered.

Component ! File                    ! Issue    ! State
----------+-------------------------+----------+----------
core      ! wp-includes/version.php ! modified ! [WARNING]
core      ! wp-admin/about.php      ! missing  ! [WARNING]
core      ! wp-includes/x.php       ! added    ! [WARNING]
akismet   ! akismet.php             ! modified ! [WARNING]
akismet   ! shell.php               ! added    ! [WARNING]
```

With `--lengthy`, showing the full path and the leading digits of both digests:

```bash
./wordpress-checksums --path=/var/www/html/wordpress --lengthy
```

```text
2 modified, 2 added, 1 missing [WARNING]. WordPress v6.8.2 (en_US). 2833 files verified in 3 of 4 components.
Not verified: acme-premium. wordpress.org publishes no checksums for this component, so nothing in the result above applies to it. A plugin ends up here when it is commercial or was installed from outside the wordpress.org plugin directory. Nothing to fix on this host; compare it against the vendor's own download where it has to be covered.

Component ! File                    ! Issue    ! Expected         ! Found            ! State
----------+-------------------------+----------+------------------+------------------+----------
core      ! wp-includes/version.php ! modified ! c1bf1b3c16693292 ! c1643191c3f55d9e ! [WARNING]
core      ! wp-admin/about.php      ! missing  ! -                ! -                ! [WARNING]
core      ! wp-includes/x.php       ! added    ! -                ! -                ! [WARNING]
akismet   ! akismet.php             ! modified ! 95027ba5326398e3 ! 04b6b1aa32757d32 ! [WARNING]
akismet   ! shell.php               ! added    ! -                ! -                ! [WARNING]
```

An installation that was defaced wholesale. The table stops after 50 rows and says how many findings are left:

```bash
./wordpress-checksums --path=/var/www/html/wordpress
```

```text
1893 modified, 12 added [WARNING]. WordPress v6.8.2 (en_US). 2834 files verified in 3 of 3 components.

Component ! File                    ! Issue    ! State
----------+-------------------------+----------+----------
core      ! wp-admin/about.php      ! modified ! [WARNING]
[...]
... and 1855 more findings.
```

Accepting one file that was patched by hand, and raising the rest to CRITICAL:

```bash
./wordpress-checksums --path=/var/www/html/wordpress --ignore='^akismet/akismet\.php$' --severity=crit
```

```text
1 modified [CRITICAL]. WordPress v6.8.2 (en_US). 2834 files verified in 3 of 3 components.

Component ! File                    ! Issue    ! State
----------+-------------------------+----------+-----------
core      ! wp-includes/version.php ! modified ! [CRITICAL]
```

wordpress.org unreachable, verified against the cached copy:

```bash
./wordpress-checksums --path=/var/www/html/wordpress
```

```text
No checksum violations found. WordPress v6.8.2 (en_US). 2834 files verified in 3 of 3 components.
wordpress.org is unreachable, all 3 components verified against cached data that expired 3D ago.
```


## States

* WARNING if at least one file within the verified scope was modified, added or is missing. Configurable with `--severity`: `crit` for an installation nobody hand-patches, `ok` to keep the check reporting without alerting. `ok` is offered here where other checks only offer `warn` and `crit`, because it silences the file findings alone and leaves `--no-checksum-data-severity` free to keep alerting on a component that could not be verified. `--always-ok` cannot make that distinction, it silences the whole check.
* OK if every verified file matches what wordpress.org published, or matches the copy the core release shipped for a bundled plugin.
* By default OK when wordpress.org publishes no checksums for a component, so it could not be verified at all. `--no-checksum-data-severity` raises that to `warn`, `crit` or `unknown`. This is the permanent case: a commercial plugin, one from outside the plugin directory, or a core release predating the checksum archive.
* By default OK with "Nothing checked." when `--match` or `--ignore` filtered every finding away. `--no-match-severity` raises that to `warn`, `crit` or `unknown`. An installation that simply matches its published checksums is reported as clean instead, so the two cases stay distinguishable. A filtered run still emits every metric and still reports an unverifiable component, so `--no-checksum-data-severity` and `--unreachable-severity` keep working and a dashboard shows a zero rather than a gap.
* By default OK when wordpress.org could not be reached, whether an expired cached copy filled in or the component stayed unverified. `--unreachable-severity` raises that to `warn`, `crit` or `unknown`. This is the fixable case, so it is graded apart from the one above: raise it where the host is expected to reach wordpress.org and a broken egress rule should surface instead of quietly reducing what the check covers. The output says on its own line which of the two happened, and how long ago the cached copy ran out, which is how long wordpress.org has been out of reach.
* UNKNOWN if `--path` holds no WordPress installation, meaning no readable `wp-includes/version.php` below it.
* UNKNOWN if not a single checksum could be obtained, from wordpress.org or from the cache, so nothing at all was compared. The reason is part of the message, including the case where `--total-timeout` ran out before anything could be asked. This is deliberately not an OK: a check that could not run says nothing about the installation, and a green result would claim otherwise.
* Always OK with `--always-ok`.

The table lists at most 50 findings and states how many were left out. That is a display limit only: the state is determined by every finding, and the performance data counts them all. A defaced installation would otherwise produce thousands of lines that Icinga stores and mails on with every notification.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| components_unverified | Number | Components that could not be verified, either because nothing is published for them or because wordpress.org could not be queried. The core counts as a component here. |
| core_added | Number | Files below `wp-admin/` or `wp-includes/` that the release never shipped. |
| core_missing | Number | Files the release shipped and the installation no longer has. |
| core_modified | Number | Verified core files whose content does not match the published checksum. |
| files_checked | Number | Files compared against a published checksum in this run. |
| plugins_added | Number | Files inside a plugin directory that the plugin never shipped. |
| plugins_missing | Number | Files a plugin shipped and the installation no longer has. |
| plugins_modified | Number | Verified plugin files whose content does not match the published checksum. |


## Troubleshooting

### No WordPress installation found below `--path`

```text
No WordPress installation below "/path/to/wordpress". Point --path at the directory holding wp-includes/ and wp-content/.
```

Either `--path` points somewhere else than the installation root, or the monitoring user cannot read it. The check looks for `wp-includes/version.php` below the given path, the same file WordPress reads its own version from, so point `--path` at the directory holding `wp-includes/` and `wp-content/`. On a permission problem, grant the monitoring user read access to the document root rather than running the check as root.

### A file is reported as modified that nobody touched

Some deployments rewrite files as they install them: a build step that strips comments, a `git` checkout with `core.autocrlf` translating line endings, or an opcache preloader writing back into the tree. Compare the file against a fresh download of the same release to see what actually differs, and where the change is a property of the deployment rather than of the site, accept it with `--ignore`.

The other common cause is a plugin that updates itself in place while keeping its version header. The published checksums are for the version the plugin declares, so a plugin that shipped a fix without bumping its version does not match any published list.

### `Could not obtain any checksums to verify against, so nothing was checked`

Nothing could be fetched and nothing was cached, so the check had nothing to compare the installation against. The rest of the line names the reason, and there are three common ones.

`Python module "httpx" is not installed` means the plugins are running against a Python that does not carry their dependencies. That happens on a source install, where the dependencies are a separate step. Install them from the lockfile matching the host's Python, as the user that runs the checks, following the "Installing the Python dependencies" section of [INSTALL.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/INSTALL.md). The packaged installations ship their own venv and are not affected.

A `URL error` or a timeout means the host cannot reach `api.wordpress.org` and `downloads.wordpress.org` over HTTPS. Check the egress rules and, where the monitoring agent's environment points at a proxy that cannot reach the internet, pass `--no-proxy`.

`ran out of the 45s that --total-timeout grants a run` means the same thing seen from the other side: the requests were not refused, they were not answered in time, and the budget for the whole run was used up before the remaining components could be asked about. See "The first run takes too long" below.

Once a single run has succeeded, the cache carries the check over a later outage, and it then reports how long ago the cached copy ran out instead of failing. That number is how long the outage has been going on, not the age of the digests, which never change once a release is published. `--unreachable-severity` decides whether an outage alerts at all; it defaults to OK.

### `Not verified: core`

wordpress.org publishes nothing for this release, so there is nothing to hold the installation to and the rest of the result says nothing about the core. Either the release predates the checksum archive, or the version in `wp-includes/version.php` is not one wordpress.org ever released. `wordpress-version` says which of the two it is. Where the release is simply too old, updating is the fix; there is nothing to configure here.

The archive does not reach all the way back, and how far it does depends on the language, since wordpress.org ships one release per language:

| Installation | Core verifiable from |
|----|----|
| English (`en_US`) | 3.6 |
| German, Spanish, Italian | 3.7 |
| Dutch | 3.9 |
| French | 4.3 |

Other languages sit somewhere in the same range; there is no announced cut-off, only what the archive happens to hold. Every release below these is long end-of-life, so a host this applies to has a more pressing problem than an unverifiable checksum, which is what `wordpress-version` is for. Plugins from the plugin directory are unaffected, since their checksums are published per plugin release and not per WordPress release.

On such a release, the plugins the core bundles cannot be decided either. WordPress ships Akismet and Hello Dolly, their content differs from the copy the plugin directory publishes under the same version, and only the core list says which of the two applies. Without it they are reported as unverifiable rather than as modified, so a stock installation does not produce a finding nobody can act on.

The same line naming a plugin instead means that plugin is commercial or was installed from outside the wordpress.org plugin directory. That is a permanent property of the plugin and nothing to fix on the host: either accept the gap, or compare the plugin against the vendor's own download yourself. `--no-checksum-data-severity` decides whether an unverifiable component alerts at all; it defaults to OK.

### Everything below `wp-content/` is reported as not verified

That is the scope, not a fault. Themes and uploads have no published checksums anywhere, and only plugins from the wordpress.org plugin directory can be verified at all. Where a commercial plugin matters enough to be watched, verify it separately against the vendor's own release artifact.

### The check is slow on the first run of the day

The published checksums are fetched once per release and then served from the local cache for a day. The first run after an update, or after `--cache-expire` elapsed, pays for the fetch; the runs after it do not. Where the check has to stay fast even then, raise `--cache-expire`, since the digests of a released version never change.

### The first run takes too long

```text
wordpress.org could not be queried for 12 of 40 components (acme-forms, ...): ran out of the 45s that --total-timeout grants a run.
```

The run spends one request per component, and the budget for all of them together is `--total-timeout`. An installation with dozens of plugins on a slow link runs out of it on the first run after an update, when nothing is cached yet. The components that were reached are verified normally; the rest are reported as unqueried and are picked up by the next run, which starts with their neighbours already cached.

Raise `--total-timeout` and the Director command timeout together. The command timeout has to stay above it, or the monitoring agent kills the check before it can print anything at all:

```yml
overwrites:
  '["Command"]["cmd-check-wordpress-checksums"]["timeout"]': 120
```

Where individual requests are the problem rather than their number, `--timeout` is the one to raise; where a proxy is in the way, `--no-proxy` is usually faster than raising anything.

### `wordpress.org is unreachable`

The check could not refresh the checksums and fell back to the copy it already had. Verify that the host can reach `api.wordpress.org` and `downloads.wordpress.org` over HTTPS, and pass `--no-proxy` where the proxy environment of the monitoring agent points somewhere that cannot. The result behind the notice is still valid; only anything released during the outage is unknown to the check.

The notice is OK by default, on the reasoning that a check verifying against week-old digests is still verifying. Set `--unreachable-severity=warn` where an outage is not supposed to pass unnoticed.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
