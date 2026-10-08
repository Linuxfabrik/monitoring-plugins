# Contributing


## Linuxfabrik Standards

The following standards apply to all Linuxfabrik repositories.


### Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).


### Issue Tracking

Open issues are tracked on GitHub Issues in the respective repository. In addition to the GitHub default labels (`bug`, `documentation`, `duplicate`, `enhancement`, `good first issue`, `help wanted`, `invalid`, `question`, `wontfix`), the following project-specific labels are used:

| Label | Use for |
|---|---|
| `build` | Packaging, build scripts, distribution artifacts. |
| `ci/cd` | Continuous integration, GitHub Actions workflows, release automation, test automation. |
| `dependencies` | Pull requests opened by Dependabot. |
| `github_actions` | Pull requests that update GitHub Actions workflow definitions or pinned action SHAs. |
| `python` | Pull requests that update Python dependencies. |

When opening a new issue, attach the label that matches the area of work. The `build` and `ci/cd` labels mirror the conventional commit scopes used in the same areas (`fix(build): ...`, `chore(ci/cd): ...`).


### Pre-commit

Some repositories use [pre-commit](https://pre-commit.com/) for automated linting and formatting checks. If the repository contains a `.pre-commit-config.yaml`, install [pre-commit](https://pre-commit.com/#install) and configure the hooks after cloning:

```bash
pre-commit install
```

The hooks only see staged files, so a file nobody edits is never checked. Running them over everything with `pre-commit run --all-files` is therefore a repository-wide rewrite, and it belongs in a commit of its own: the last one arrived inside an unrelated change and its damage surfaced weeks later. The `Linuxfabrik: Apply pre-commit hooks repository-wide` workflow does that run whenever the hook configuration changes and opens a pull request for it, so there is normally nothing left to do by hand.


### Commit Messages

Commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification:

```
<type>(<scope>): <subject>
```

If there is a related issue, append `(fix #N)`:

```
<type>(<scope>): <subject> (fix #N)
```

`<type>` must be one of:

- `chore`: Changes to the build process or auxiliary tools and libraries
- `docs`: Documentation only changes
- `feat`: A new feature
- `fix`: A bug fix
- `perf`: A code change that improves performance
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `style`: Changes that do not affect the meaning of the code (whitespace, formatting, etc.)
- `test`: Adding missing tests


### Changelog

Document all changes in `CHANGELOG.md` following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Sort entries within sections alphabetically.

The audience is a Linux system engineer with 30 seconds to decide whether an update is worth it. That reader needs four answers: which plugins are new, what behaves differently or is no longer evaluated, what is gone, and which bugs and security holes are closed. Write for that reader:

* **What goes where.** `Breaking Changes` covers everything that requires manual work after the update. `Added` covers new plugins and new tools, nothing else. `Changed` covers changed behaviour, including a parameter that now produces a different result, is deprecated, or is no longer evaluated. `Removed` covers dropped plugins, parameters, service sets and metrics. `Fixed` covers bugs, `Security` covers closed holes with their GHSA link.
* **What stays out.** New parameters and options on existing plugins, help text, README and `DESCRIPTION` wording, Grafana dashboards and Director service sets that ship with a new plugin, lockfile and pin bumps, Dependabot and pre-commit configuration, GitHub Actions bumps, test infrastructure and refactorings without a visible effect. An administrator looks a parameter up in the plugin's README when a concrete use case calls for it.
* **Relevance test.** Before writing an entry, answer what it changes for an administrator running the plugins on Icinga, Nagios or Shinken, and whether it makes the update worth doing. No answer, no entry. Two entries that fail the test: "installer: a source install no longer prints Python `RuntimeWarning` messages about tarfile extraction on RHEL 9 family hosts" and "cloudflare-security-level: no longer requires the `requests` Python module". Dependency, import and packaging internals stay out until an installation visibly succeeds or fails because of them. `Tools:` and `Build, CI/CD:` are almost always a single line or none at all; bundle several tool changes into one entry.
* **Nothing under `Changed`, `Fixed` or `Breaking Changes` for a plugin that the same section lists under `Added`.** Nobody has ever seen it in a release, so it has no changed behaviour, no bug and no migration. This also applies to family wildcards: drop the entry when the family consists of new plugins only, and narrow it to the already released ones otherwise (`huawei-dorado-*` instead of `huawei-dorado-*, huawei-pacific-*`). Check which plugins are really new against the last tag instead of trusting the existing section.
* **Grafana and Icinga Director only when the administrator has to act.** Re-import a dashboard, activate a service set, repair a broken import. A dashboard that comes with a new plugin is not an entry.
* **Lead with highlights.** Begin every release section with two to four sentences of running text, directly below the version heading and above the first `###` section. Cover what drives the update decision, including any manual step it requires. No bullet list, no issue links, no repetition of the individual entries. A release with only a handful of entries does not need one, since the entries themselves already fit on a screen.
* **State the change before its scope.** Up to five affected components keep the `component: what changed` form. From six on, put the statement first and close it with a family wildcard (`huawei-dorado-*`, `mysql-*`, `all *-version checks`, `all plugins`) instead of listing every component in parentheses. These broad entries come first in their subsection, ahead of the alphabetically sorted per-component entries.
* **One entry per component and topic, one sentence each.** Several fixes to the same plugin are bundled into one sentence instead of being listed one by one. `Added`, `Changed` and `Fixed` say what an administrator notices. Root cause, reproduction steps, defaults and internal reasoning belong in the commit body and the issue. Aim for one line of about 120 characters.
* **No documentation links inside an entry.** Issue, pull request and GHSA references only.
* **Migration instructions only under `Breaking Changes`.** Wording such as "rename x to y" or "set z to restore the previous behaviour" anywhere else means the entry sits in the wrong section. Entries under `Breaking Changes` may run longer than one sentence.

A release section starts like this:

```markdown
## [v6.1.0] - 2026-09-15

**Highlights:** Two long-standing sources of false alarms are gone, and container workloads are now covered. Cumulative counters are reported as rates instead of totals, so any dashboard built on them has to be re-imported.

### Added
```


### Changelog Groups

Within a subsection, entries are grouped by the part of the project they belong to. Use a plain heading line ending in a colon, followed by a blank line and the entries. Group headings are, in this order:

* `Monitoring Plugins:`
* `Notification Plugins:`
* `Event Plugins:`
* `Icinga Director:`
* `Grafana:`
* `Assets:`
* `Tools:`

Omit a group that has no entries, and do not invent new ones.


### Language

Code, comments, commit messages, and documentation must be written in English.


### CI Supply Chain

GitHub Actions in `.github/workflows/` are pinned by commit SHA, not by tag. Dependabot's `github-actions` ecosystem keeps these pins up to date.

Python packages installed via `pip` inside workflows follow a two-tier policy:

- `pre-commit` is installed from a hash-pinned requirements file at `.github/pre-commit/requirements.txt`, generated with `pip-compile --allow-unsafe --generate-hashes --strip-extras` from `.github/pre-commit/requirements.in`. Dependabot's `pip` ecosystem watches that directory and maintains both files.
- Every other tool a workflow installs with `pip` (`ansible-builder`, `build`, `mkdocs`, `pdoc`, `ruff`, `tox`, ...) follows the same model: a version pin in `.github/<name>/requirements.in`, a hash-pinned `requirements.txt` generated from it the same way, `pip install --require-hashes --requirement .github/<name>/requirements.txt` in the workflow, and a Dependabot `pip` entry for that directory. Dependabot does not read `run:` lines, so a version pinned there (`package==X.Y.Z`) is never updated, and a Scorecard `pipCommand not pinned by hash` finding on it is a real one.


### Coding Conventions

- Sort variables, parameters, lists, and similar items alphabetically where possible.
- Always use long parameters when using shell commands.
- Use RFC [5737](https://datatracker.ietf.org/doc/html/rfc5737), [3849](https://datatracker.ietf.org/doc/html/rfc3849), [7042](https://datatracker.ietf.org/doc/html/rfc7042#section-2.1.1), and [2606](https://datatracker.ietf.org/doc/html/rfc2606) in examples and documentation:
    - IPv4: `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`
    - IPv6: `2001:DB8::/32`
    - MAC: `00-00-5E-00-53-00` through `00-00-5E-00-53-FF` (unicast), `01-00-5E-90-10-00` through `01-00-5E-90-10-FF` (multicast)
    - Domains: `*.example`, `example.com`


---


## Check Plugin Developer Guidelines

Target audience: developers contributing a new check plugin or reworking an existing one. If you are an admin deploying the plugins, you do not need this document.

All plugins are written in Python and released under the [UNLICENSE](https://unlicense.org/), which dedicates the work to the public domain with no conditions attached. Use the [example](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/example/example) plugin as a skeleton for new plugins. It demonstrates all standard patterns, library functions, and coding conventions described below.


### Monitoring of an Application

One topic per check ("one tool, one task"), for uniform thresholds, few interdependent parameters and independent Grafana panels: `myapp-threading --warning 1500 --critical 2000`, `myapp-memory-usage --warning 80 --critical 90` and `myapp-deployment-status` instead of one `myapp --action ...`.


### Setting up your Development Environment

All plugins target Python 3.9 or newer (Python 3.9 is required for RHEL 8 compatibility). Clone both repositories side by side:

```bash
git clone git@github.com:Linuxfabrik/lib.git
git clone git@github.com:Linuxfabrik/monitoring-plugins.git
```


### Directory Layout

Each plugin directory `plugin-name/` contains the plugin `plugin-name` and, as needed, `assets/` (helper scripts like `monitoring.php`), `grafana/` (dashboard), `icingaweb2-module-director/` (basket), `icingaweb2-module-grafana/` (panel for Icinga's Grafana module), `icon/` (SVG icon), `lib` (link to the Linuxfabrik Python libraries) and `unit-test/` (`run` plus `retc/`, `stdin/`, `stdout/` fixtures).


### Deliverables

A new plugin delivers:

* The plugin itself, tested on RHEL and Debian.
* README file explaining "How?" and "Why?"
* A free, monochrome, transparent SVG icon from <https://simpleicons.org> or <https://fontawesome.com/search?ic=free> in the `icon` directory.
* Optional: `unit-test/run` (see [Unit Tests](#unit-tests)).
* Optional: new Python deps in the repo-root `requirements.in`; the lockfiles under `lockfiles/pyXX/requirements.txt` are regenerated from it.
* If providing performance data: Grafana dashboard (see [GRAFANA.md](GRAFANA.md)) and `.ini` file for the Icinga Web 2 Grafana Module.
* Icinga Director Basket Config. Run `tools/build-basket --auto` before every commit (not just for new plugins), otherwise a stale basket surfaces as an unrelated diff in someone else's later run.
* Icinga Service Set in `all-the-rest.json` if appropriate (see "Icinga Director: Service Set vs. Service Template").
* Optional: sudoers file (see [sudoers File](#sudoers-file)).
* Optional: a screenshot of the output in Icinga, 423x106, background-color `#f5f9fa`, hosted on [download.linuxfabrik.ch](https://download.linuxfabrik.ch/monitoring-plugins/assets/screenshots/) and listed alphabetically in [POSTER.md](POSTER.md).
* Update `CHANGELOG.md`.


### Icinga Director: Service Set vs. Service Template

A Service Set activates one or more services on every host carrying its tag, with one default configuration each.

* **Service Set** when the check runs identically on every tagged host, or bundles several related checks (status + version + systemd unit). Examples: `chronyd`, `firewalld`, `Apache httpd`, `OS - RHEL 10 Basic Service Set`.
* **Service Template only** when the check needs per-instance parameters (URL, hostname, account, API token, page id, repository path); admins create those services manually or via Apply rules. Examples: `atlassian-statuspage`, `kemp-services`, `uptimerobot`, `virustotal-scan-url`.

Ship the Service Template in `build-basket` either way, and add a Service Set to `all-the-rest.json` only for the generic or bundled shape.

Deliberate exception: a per-instance check whose subject is too important for an unconfigured host to stay silent may join a Set anyway. Its service reports UNKNOWN until the parameter is supplied; document that in the README so it is not read as a defect. Reference: [wordpress-security-scan](check-plugins/wordpress-security-scan.md) in the WordPress Service Set, where `--url` cannot be guessed.


### Icinga Director: Cluster Zones

`tpl-host-generic` and `tpl-service-generic` in `all-the-rest.json` pin `"zone": "master"`; every other template sets no zone and inherits it. This security default keeps configuration and credentials on the master and its HA peers instead of on every agent.

* Keep the two base templates pinned to `master`, every other zone unset. A distributed site unsets the base-template zone, accepting distribution to every agent (see ICINGA.md).
* Never put a credential (password, SNMP community, API token) on a template or a Service Set: it applies to every importing or generated service and reaches every agent once the zone is unset. Keep secrets on the concrete host or service object.


### Rules of Thumb

* Be brief by default; report what is needed to fix a problem. Offer more via `--lengthy`, and add `--brief` where the default output grows unbounded on large systems (see "Verbosity parameter convention").
* Be "self configuring" with best-practice defaults, so the plugin runs without parameters wherever possible.
* Develop with a minimal Linux and with Icinga 2 in mind.
* Avoid complicated or fancy (and therefore unreadable) Python statements.
* Avoid libraries that have to be installed, if possible.
* Validate user input.
* Temp files are ok if needed, a local SQLite database is much better.
* Plugins have a limited runtime (typically 10 seconds max), so execute fast and use minimal resources.
* Timeout gracefully on errors (for example `df` on a failed network drive) and return WARN.
* Return UNKNOWN on missing dependencies or wrong parameters.
* Mainly return WARN. CRIT means "react immediately", only if the operators want to or have to wake up at night.
* EAFP: assume valid keys or attributes and catch the exceptions (many `try` / `except`).
* **Pick the right unit-test flavor.** Fixture-based tests (`lib.lftest.run()` and a `TESTS` list) for command output, file bodies or HTTP endpoints with a stable format: fast, reproducible, full `tox` matrix. Container-based tests (`lib.lftest.run_container()`) only when the behaviour depends on live runtime state (log markers, cluster topology, write-then-read flows, version-dependent API responses).
* **Combine container tests with fixtures for real coverage.** One testcontainers scenario for the nominal state (catches vendor API changes), plus fixture testcases for the weird states a fresh container never shows (crashed service, stale cache, half-configured cluster, 503, overflowed counter, valid but broken config), ideally captured from real incidents. Both live in one `unit-test/run`; `tools/run-unit-tests --no-container` and `tools/run-container-tests` pick their part.


### Return Codes

Plugins return one of the following exit codes, using the constants from `lib.base`:

| Exit Code | Status | Constant | Meaning |
|---|---|---|---|
| 0 | OK | `STATE_OK` | Service functioning properly |
| 1 | Warning | `STATE_WARN` | Service above warning threshold or not working properly |
| 2 | Critical | `STATE_CRIT` | Service not running or above critical threshold |
| 3 | Unknown | `STATE_UNKNOWN` | Invalid arguments, missing dependencies, or internal plugin failures |

* `STATE_WARN` and `STATE_CRIT` trigger notifications. Reserve them for conditions the user needs to act on, never for plugin-internal problems.
* Return `STATE_UNKNOWN` on missing dependencies, wrong parameters, `--help` / `--version`, and internal failures such as unhandled exceptions or tracebacks; a broken plugin says nothing about the service.
* Exception: when the missing thing is an external tool that belongs on the host because the check was deployed there, return `STATE_WARN`, so the gap lands on the to-fix list instead of the UNKNOWN pile. Only for tools the administrator installs (not Python modules the package pulls in), and say so in the README. Reference: [wordpress-security-scan](check-plugins/wordpress-security-scan.md) reporting a missing `wpscan`.
* Return `STATE_WARN` for most alert conditions, `STATE_CRIT` only if immediate human intervention is required ("wake up at night").
* Never return anything other than 0, 1, 2 or 3.
* Use `lib.base.oao()` (output and out) to print the result and exit in a single call.


### Bytes vs. Unicode

Use `txt.to_text()` and `txt.to_bytes()`. Incoming data is UTF-8 bytes: decode it as early as possible, **use unicode throughout the plugin**, and let library functions (`base.oao`, `url.fetch_json`, ...) do the output conversion. See <https://nedbatchelder.com/text/unipain.html>.

External bytes of unreliable encoding (subprocess output, a file over SMB, a sensor payload) that end up in the printed result are decoded with `lib.txt.to_text(raw_bytes, errors='strict_or_latin1')`: UTF-8, and on any invalid byte the whole input as Latin-1. The default `surrogateescape` produces lone surrogates that raise `UnicodeEncodeError` later at print time, far from the cause ([Linuxfabrik/lib#256](https://github.com/Linuxfabrik/lib/issues/256)). Always-ASCII values or values with a declared encoding do not need it.


### Names, Naming Conventions

The plugin name matches `^[a-zA-Z0-9\-\_]*$`, so it can serve as the Grafana dashboard uid (see [here](https://github.com/grafana/grafana/blob/552ecfeda320a422bfc7ca9978c94ffea887134a/pkg/util/shortid_generator.go#L11)).


### Parameters, Option Processing

Nagios-compatible reserved options, not to be used for other purposes: `-a, --authentication` (authentication password), `-C, --community` (SNMP community), `-c, --critical` (critical threshold), `-h, --help`, `-H, --hostname`, `-l, --logname` (login name), `-p, --password`, `-p, --port` (network port), `-t, --timeout`, `-u, --url`, `-u, --username`, `-V, --version`, `-v, --verbose`, `-w, --warning` (warning threshold).

Every plugin supports at least:

* `--help` (`-h`): short usage, then all options with their defaults, ending with a link to the online documentation. Within 80 characters width. Exits with `STATE_UNKNOWN` (3).
* `--version` (`-V`): plugin name and `__version__`. Exits with `STATE_UNKNOWN` (3).

The documentation link comes from `lib.args`:

```python
    parser = argparse.ArgumentParser(
        description=DESCRIPTION,
        epilog=lib.args.epilog(__file__),
        formatter_class=lib.args.HelpFormatter,
    )
```

`lib.args.epilog()` derives the URL from the file name, `lib.args.HelpFormatter` keeps it on one line. Notification and event plugins name their family, e.g. `lib.args.epilog(__file__, section='notification-plugins')`.

No positional arguments. All other options are long parameters only, words separated by `-`. Recommended names: `--activestate`, `--alarm-duration`, `--always-ok`, `--argument`, `--authtype`, `--brief`, `--cache-expire`, `--command`, `--community`, `--config`, `--count`, `--critical` (also `--critical-count`, `-cpu`, `-maxchildren`, `-mem`, `-pattern`, `-regex`, `-slowreq`, `-steal`), `--database`, `--datasource`, `--date`, `--device`, `--donor`, `--filename`, `--filter`, `--full`, `--hide-ok`, `--hostname`, `--icinga-callback` (also `--icinga-password`, `-service-name`, `-url`, `-username`), `--idsite`, `--ignore`, `--input`, `--insecure`, `--instance`, `--interface`, `--interval`, `--ipv6`, `--key`, `--latest`, `--lengthy`, `--loadstate`, `--match`, `--message`, `--message-key`, `--metric`, `--mib`, `--mibdir`, `--mode`, `--module`, `--mount`, `--no-kthreads`, `--no-match-severity`, `--no-perfdata`, `--no-proxy`, `--no-summary`, `--node`, `--only-dirs`, `--only-files`, `--password`, `--path`, `--pattern`, `--per-cpu`, `--perfdata`, `--perfdata-key`, `--period`, `--port`, `--portname`, `--prefix`, `--privlevel`, `--response`, `--service`, `--severity`, `--snmp-version`, `--starttype`, `--state`, `--state-key`, `--status`, `--substate`, `--suppress-lines`, `--task`, `--team`, `--test`, `--timeout`, `--timerange`, `--token`, `--trigger`, `--type`, `--unit`, `--unitfilestate`, `--url`, `--username`, `--version`, `--virtualenv`, `--warning` (with the same suffixes as `--critical`).

Usual [parameter types](https://docs.python.org/3/library/argparse.html): `type=float`, `type=int`, `type=lib.args.csv`, `type=lib.args.float_or_none`, `type=lib.args.int_or_none`, `type=str` (default), `choices=[...]`, and `action='store_true'` / `'store_false'` for switches.

**Threshold parameters** (`--warning`, `--critical`) in new plugins use `type=str` to support [Nagios range expressions](https://www.monitoring-plugins.org/doc/guidelines.html#THRESHOLDFORMAT) (`80`, `10:`, `~:50`, `@10:20`), evaluated with `lib.base.get_state(value, args.WARN, args.CRIT, _operator='range')`. See the `example` plugin and [Threshold and Ranges](#threshold-and-ranges).

Hints:

* `csv` type for complex tuples: `--input='Name, Value, Warn, Crit'` gives `['Name', 'Value', 'Warn', 'Crit']`.
* `append` action for repeating parameters (the `default` must be a list): `--input=a --input=b` gives `['a', 'b']`. Combined with `csv`, a two-dimensional list.
* For `append` defaults, leave `default=None` in `add_argument()` and fill in the default list after `parse_args()` if the value is still `None` (see <https://bugs.python.org/issue16399>).
* An `append` parameter with a non-empty default list gets an `--extend-<name>` companion that appends instead of replacing (see `example`).
* Stay backwards compatible: keep renamed or dropped parameters, silently ignored, with `help=argparse.SUPPRESS`, so hosts can be updated before the monitoring server.
* Tolerate unknown parameters with `parser.parse_known_args()`, so a new parameter in the service definition does not turn not-yet-updated hosts UNKNOWN.


#### Parameter Help Text Format

Help texts are consistent across all plugins. Each property goes on its own line (implicit string concatenation), in this order:

1. Purpose (what the parameter does)
2. Data type or format (if not obvious)
3. Regex or case-sensitivity note (if applicable)
4. Repeating note (if applicable)
5. Nagios range support (if applicable)
6. Example (if helpful)
7. Default value (always last, always present if there is one)

Standard help texts live in `lib.args.HELP_TEXTS`; use `lib.args.help('--parameter-name')` wherever possible, write plugin-specific ones inline in the same format, or prefix the standard one:

```python
parser.add_argument(
    '--url',
    help='GitLab health URL endpoint. ' + lib.args.help('--url'),
    dest='URL',
    default=DEFAULT_URL,
)
```

* Use `%(default)s`, never a hardcoded value. For `append` defaults, join the `DEFAULT_X` constant. No default for `store_true` / `store_false` switches (`--always-ok`, `--insecure`, `--no-perfdata`, `--no-proxy`, `--lengthy`).
* "Replaces the default list, use `--extend-<name>` to append to it." / "..., appended to the default or the `--<name>` list."
* Defaults and examples go on their own lines.
* "Can be specified multiple times." for `action='append'` (not "(repeating)").
* "Supports Nagios ranges." when the value goes through `lib.base.get_state()`.
* Always state "Case-insensitive." or "Case-sensitive."
* "Uses Python regular expressions." when the parameter accepts a regex.
* End every help text with a period.
* Identical parameters across plugins get identical help texts.
* The developer-only `--test` is mapped to `argparse.SUPPRESS` in `lib.args` (accepted, but hidden from `--help`, READMEs and baskets). Declare it with `help=lib.args.help('--test')`, never inline.


### Commit Scopes

Use the plugin name as commit scope, e.g. `fix(about-me): cryptography deprecation warning (fix #341)`. The first commit is `Add <plugin-name>`.


### Threshold and Ranges

The range syntax (`start:end`, `~`, `@`, inclusive/exclusive) is documented in [THRESHOLDS.md](THRESHOLDS.md). In a plugin, keep `type=str` and evaluate with the library, never with a per-plugin range parser:

```python
item_state = lib.base.get_state(value, args.WARN, args.CRIT, _operator='range')
state = lib.base.get_worst(state, item_state)
```

References with multiple metrics and per-row worst-state aggregation: `check-plugins/procs/procs` and `example`. Example `--warning 2:100 --critical 1:150`:

```text
val   0   1   2 .. 100 101 .. 150 151
-w   WA  WA  OK     OK  WA     WA  WA
-c   CR  OK  OK     OK  OK     OK  CR
=>   CR  WA  OK     OK  WA     WA  CR
```

Single-bound ranges (`--warning 190: --critical 200:`) aggregate the same way.

Ranges cover every bound the operator picks (a percentage, count, age, temperature). A parameter naming a fixed classification boundary defined outside the plugin keeps a plain numeric type with a direct comparison, e.g. a CVSS base score, where range syntax would mean nothing. Reference: `--critical-cvss` in [wordpress-security-scan](check-plugins/wordpress-security-scan.md). Say so in the README, so the missing range support reads as a decision.


### Caching temporary data, SQLite database

Use `cache` for a simple key-value store (see `nextcloud-version`), otherwise `db_sqlite` (see `cpu-usage`).


### Error Handling

* Catch exceptions with `try` / `except`, never bare `except:`; `except Exception:` is the broadest acceptable catch-all.
* A function that catches exceptions returns `(False, errormessage)` on error and `(True, result)` otherwise (`(True, False)` means no exception, result `False`). A caller of such a function returns a `(retc, result)` tuple itself.
* In `main()`, use `lib.base.coe()`. See `nextcloud-version`.
* For a missing module, `print('Python module "psutil" is not installed.')` plus `sys.exit(STATE_UNKNOWN)` in the `except ImportError:` gives a clean error in the compiled variants, while `lib.base.cu()` there leads to an ugly multi-exception stacktrace.


### Timeout Handling

Every plugin handles timeouts gracefully (e.g. `df` on a failed network drive, unresponsive APIs, stuck database connections):

* Always support `--timeout` (default: 8 seconds, below Icinga's own 10s).
* HTTP: `lib.base.coe(lib.url.fetch(..., timeout=args.TIMEOUT))`. Shell commands: pass a timeout to `lib.shell.shell_exec()`.
* On timeout, return `STATE_WARN` with a meaningful message (e.g. "Timeout after 8s while connecting to ...").


### Security

Ask two questions for every plugin that runs as root (it ships in `assets/sudoers/`, or its README tells the admin to grant sudo), and again for every parameter you add:

1. **What else can a local attacker who controls all arguments do?** The monitoring user (`icinga` / `nagios`) supplies every value and owns what they can create (`/tmp`, their home). Follow each parameter to the file, command or socket it reaches, assuming value and filesystem are hostile.
2. **Who may set the parameter, and with what privileges does the resulting action run?** Selecting *data the plugin reads back and filters* is low risk; *redirecting a privileged action* (file opened as root, binary executed, socket used) hands over that privilege unless confined. That is the class behind [GHSA-q8c8-wxhc-3h4c](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-q8c8-wxhc-3h4c) and [GHSA-f54c-p5vg-mr5c](https://github.com/Linuxfabrik/monitoring-plugins/security/advisories/GHSA-f54c-p5vg-mr5c).

* **External commands**: Use `lib.shell.shell_exec()` with an argv list (always `shell=False`), never `os.system()` or `subprocess` with `shell=True`. Put each user-supplied value in its own element (`['restic', f'--repo={repo}', 'check']`, `['ping', '-q', hostname]`), never assemble a command string. A value starting with `-` can still become an *option* (an ssh destination `-oProxyCommand=...`, `ping -f`), so guard values that reach a command as a positional argument or target with `coe(lib.shell.safe_cli_value(args.HOSTNAME, '--hostname'))`. Unlike the official Monitoring Plugins guidelines, we accept PATH-based resolution for cross-platform compatibility, aware that a compromised PATH could redirect commands.
* **Input validation**: Validate all user input; use `argparse` type converters (`type=int`, `type=float`, `type=lib.args.csv`).
* **Temporary files**: Avoid them; prefer `lib.db_sqlite` or `lib.cache`. If unavoidable, fail cleanly when the file cannot be created, and delete it when done.
* **Confining a path a privileged plugin was pointed at**: When a root plugin opens, stats, globs or lists a location a caller-supplied value can steer (`--path`, `--filename`, `--socket`, a scanned directory or a file found *inside* it), a planted symlink makes root read e.g. `/etc/shadow`; `--path=/var/crash` and `--path=/tmp/attacker` look alike without a containment check. Confine **every** edge (directory, each file found, final read):

    * **Reading a file**: let `lib.disk` open it, `success, content = lib.disk.read_file(candidate, allowed_roots=[root], nofollow=True)`. Never check and then `open()` yourself (check-then-use; `O_NOFOLLOW` guards only the last component): `lib.disk.open_file()`, behind `read_file()` and `read_env()`, verifies the opened handle against the path and accepts only regular files. Take everything from that handle; a second look at the path (`os.stat()`, `file_exists()`, `open()`) may see another file. For log lines, `lib.logsource.read(..., allowed_roots=...)` does the same.
    * **Executing a file, connecting to a socket, or taking an account from a file's owner**: these cannot be checked on a handle, so call `success, resolved = lib.disk.resolve_trusted_path(candidate)` (`lib.base.cu(resolved)` on failure) and use `resolved`, never `candidate`. It requires that only root (and the given `owners`) can change the object and every directory above it. References: `--command` in `apache-httpd-security` and `nginx-security`, `--socket` in `fail2ban` and `strongswan-connections`, and `lib.nextcloud.run_occ()`, which runs `occ` as the owner of `config/config.php` and refuses a symlinked `config.php`.
    * A location is never trusted by its prefix: the monitoring user owns `/run/icinga2` and `/var/log/icinga2`, `/run/user/<uid>` exists per session, and `/opt` trees often belong to service accounts. Only the ownership check decides.
    * Answer "does not exist" and "not allowed" identically for paths outside the roots, and check the roots first, otherwise the plugin reveals which files exist. Under `--test`, read fixtures only through `lib.lftest.test_text()` or `lib.lftest.test_json()`, never with `file_exists()` first.
    * Never weaken this to a filename check (`if name == 'vmcore-dmesg.txt'`), which binds the symlink's name, not its target. Where a shared `lib` function reads, the guard belongs in the `lib`. As defense in depth, pin arguments in the sudoers entry (see the `LF_LIBRENMS_VALIDATE` alias in `assets/sudoers/`), but never rely on it alone. Treat a socket like a binary: a planted one feeds root a chosen response, which is code execution when the client deserializes it (`fail2ban-client` uses `pickle`).

* **Credentials**: Never log or print passwords, tokens or other secrets, not even in verbose mode.
* **Network communication**: HTTPS by default. Support `--insecure` for self-signed certificates, never make insecure the default.
* **Internal management endpoints** (Icinga API, BMC, storage controller, backup appliance) are the one exception: they practically always use their own CA, so plugins for them may set `DEFAULT_INSECURE = True` and must then offer `--no-insecure` (`help=lib.args.help('--no-insecure')`, `action='store_false'`) as the counterpart to `--insecure` (`action='store_true'`). Both share `dest='INSECURE'` and the same `default=DEFAULT_INSECURE`, so declaration order does not matter. Checks against public or customer-facing endpoints keep `DEFAULT_INSECURE = False` and offer `--insecure` only.


### Plugin Output

Print to STDOUT only, never to STDERR (Icinga/Nagios does not capture it). Structure:

```text
message | perfdata
detailed line 1
detailed line 2 | more_perfdata
```

The first line is used for notifications, the web interface and SMS; everything after the first newline is "long output" for detail views.

* A short, concise first line within 80 chars if possible (`msg_header`), details in further lines (`msg_body`).
* Perfdata follows a pipe (`|`), also on subsequent lines. Never use `|` in the text itself; `lib.base.oao()` replaces stray pipes.
* Don't print "OK".
* Print "\[WARNING\]" or "\[CRITICAL\]" next to a specific item using `lib.base.state2str()`.
* If possible give a help text to solve the problem.
* Multiple items checked: print "Everything is ok." or "There are warnings." / "There are errors." (or the most important output) in the first line, optionally followed by the items.
* Nothing checked because of the parameters: "Nothing checked.", or better name what the filters dropped ("2 version locks and 1 exclusion in place, filtered out by `--match` or `--ignore`."). Prefix "Everything is ok." only once nothing else affects the state. References: `rpm-versionlock`, `deb-versionlock`.
* Wrong username or password: print "Failed to authenticate."
* Short units without white space: bits `human.bits2human()`, bytes `human.bytes2human()`, throughput `human.bytes2human() + '/s'`, network "Rx/s" / "Tx/s" with `human.bps2human()`, numbers `human.number2human()`, percentage `93.2%`, "R/s", "W/s", "IO/s", durations `human.seconds2human()`, temperatures `7.3C`, `45F`.
* ISO dates ("yyyy-mm-dd", "yyyy-mm-dd hh:mm:ss") and human-readable periods ("Up 3d 4h", "1.5s").


### Verbose Output

With `-v` / `--verbose`, up to three stackable levels: 0 single-line summary, 1 (`-v`) single line with more detail, 2 (`-v -v`) multi-line debug info (commands, API endpoints), 3 (`-v -v -v`) extensive diagnostics. Most plugins use `--lengthy` instead.


### Verbosity parameter convention: `--lengthy` and `--brief`

The two knobs are **orthogonal**: `--lengthy` **adds** columns to every row, `--brief` **hides** rows within the thresholds (only WARN/CRIT remain), both together hide OK rows and widen the rest.

* **Perfdata is always complete**; both only reshape the message.
* **Alerting is unaffected**; hidden items still drive the state.
* **When `--brief` hides everything**, print only the summary header ("Everything is ok. (thresholds)"), not an empty table.
* **Always combinable**; never mutually exclusive in `argparse`.
* **Support `--brief`** whenever the default output can grow unbounded (hundreds of mounts, thousands of DHCP scopes, hundreds of HAProxy backends). References: `check-plugins/disk-usage`, `check-plugins/dhcp-scope-usage`.
* The `--brief` **help text** states the filter semantic and that perfdata and alerting are unaffected.


### Plugin Performance Data, Perfdata

Format, space-separated, UOM = Unit of Measurement: `'label'=value[UOM];[warn];[crit];[min];[max]`

* Labels may contain anything except `=` and `'`.
* **Prefer `snake_case` labels** (`active_processes`), per-instance as `<instance>_<metric>` (`sda_read_bytes`, `www_saturation`), as in `procs` and `disk-io`. This eases Grafana regex and InfluxDB tag matching and makes quotes unnecessary. Sanitize names with `re.sub(r'\W+', '_', name)`.
* Quotes around the label are required only if it contains spaces.
* The first 19 characters of a label should be unique (RRD limitation).
* `value`, `min` and `max` match `[-0-9.]` and share the same UOM; `min` / `max` are not required for `%`.
* `warn` and `crit` use the range format (see [Threshold and Ranges](#threshold-and-ranges)).
* Trailing unfilled semicolons may be dropped.
* UOM: none (a number of things), `s` (also `us`, `ms`), `%`, `B` (also `KB`, `MB`, `TB`; bytes preferred, they are exact), `c` (continuous counter, do not use).

**Do not use continuous counters** (`c`). Compute the delta between two runs in the plugin, store the previous measurement with `lib.db_sqlite`, and emit an absolute value with a real unit ([#320](https://github.com/Linuxfabrik/monitoring-plugins/issues/320)). This spares Grafana `non_negative_difference()`, keeps aggregations and legend tables correct, and preserves the unit. The `example` plugin implements the pattern.

Prefer percentages over absolute values, so systems of different size compare. Never emit already-aggregated values such as Apache's lifetime average "137.5 kB/request" (a flat line); calculate them in the plugin or discard them.


### PEP 8

We use [PEP 8](https://www.python.org/dev/peps/pep-0008/) where it makes sense.

**String quoting:** single quotes by default; double quotes only inside f-string expressions (`f'{lib.base.state2str(state, prefix=" ")}'`) or when the string contains single quotes. `"""` for all triple-quoted strings (docstrings, `DESCRIPTION`, SQL). Enforced by `ruff format`.


### Imports

Import every `lib.X` module the plugin uses, even if another `lib.*` module pulls it in transitively (e.g. `import lib.time` for `lib.time.now()` although `lib.base` imports it). Transitive imports break when `lib` reorganises, and linters cannot warn. Keep `import lib.*` lines sorted; `ruff` groups them with the third-party imports.


### DESCRIPTION Variable

Every plugin defines a `DESCRIPTION`, passed to `argparse.ArgumentParser(description=DESCRIPTION)`:

* At least 2-3 sentences from the perspective of the admin deploying it, in fluent English, without implementation details (no library functions, class names, internal patterns).
* The first sentence states the purpose ("Monitors CPU utilization on ...", "Checks the installed ... version against ...").
* At least one "Alerts when ..." or "Alerts if ..." clause.
* `"""` triple quotes, lines around 90 characters.
* Plugins of the same type (all `-version` checks, all `huawei-dorado-*`) use identical or near-identical text with only the product name swapped. Mandatory.
* With a sudoers file in `assets/sudoers/`, end with "Requires root or sudo."
* With `lib.smb`, mention SMB share support.
* With `--count`, mention it, e.g. "Alerts only if the threshold has been exceeded for a configurable number of consecutive check runs (default: 5), suppressing short spikes."
* With `--lengthy`, mention "Supports extended reporting via --lengthy."
* The README Overview includes at least the `DESCRIPTION` text.


### Docstrings

Docstrings in the plugins and the [Libraries](https://github.com/Linuxfabrik/lib) follow the [numpydoc standard](https://numpydoc.readthedocs.io/en/latest/format.html#docstring-standard), so `pydoc lib/base.py` works.


### Ruff

[ruff](https://docs.astral.sh/ruff/) is the primary linter and formatter (PEP 8, import sorting, common bug patterns), configured in `pyproject.toml` and run by the pre-commit hooks `ruff-check` and `ruff-format`. By hand: `ruff check check-plugins/my-check/my-check`, `ruff format check-plugins/my-check/my-check`.


### PyLint

PyLint is a manual audit tool (`pylint check-plugins/my-check/my-check`), not a pre-commit hook: it finds what ruff misses, but its metric checks (`R0912`, `R0914`, `R0915`) fire on almost every plugin by design and `C0301` uses 100 instead of 88 characters. Read metric findings as a hint.


### Unit Tests

Tests use `unittest`, data-driven: a list of dicts (or platforms/images for container tests), one real test method per item via `lib.lftest.attach_tests()` or `lib.lftest.attach_each()`. Reference: [example](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/example/unit-test/run).


#### Test directory structure

`unit-test/` holds the `run` file and the fixtures, e.g. `stdout/empty-response`, `stdout/three-nodes-healthy` (scenario names, not `EXAMPLE01`). Create `stderr/` only when a test injects stderr, and no empty `retc/` or `stderr/` directories.

The directory names how the plugin reads a fixture:

| Directory | Holds | Reached through |
|---|---|---|
| `stdout/`, `stderr/`, `retc/` | one file per stream of a command | `--test` |
| `config/` | directory trees standing in for the host's `/etc` | a hidden root hook such as `--config-root` |
| `<app>/` | trees standing in for an inspected installation, named after the application (`wordpress/`) | a path parameter such as `--path` |
| `fixtures/` | single files opened by path, e.g. a token file | a path parameter such as `--api-token-file` |
| `<service>/` | answers of a remote service read through a library, named after it (`endoflifedate/`) | seeded where the library looks, before the plugin runs |

* Plugins reading configuration files get a second, `argparse.SUPPRESS`ed hook prefixing every path, with trees under `config/` (e.g. `config/two-locks/etc/dnf/plugins/versionlock.list`). `--config-root` works, `--test-config-root` does not: argparse would resolve an abbreviated `--test=` to it. References: `check-plugins/rpm-versionlock`, `check-plugins/deb-versionlock` (both hooks).
* `<app>/` and `fixtures/` hold input an admin points the plugin at deliberately, hence a documented parameter. References: `check-plugins/wordpress-checksums`, `check-plugins/wordpress-security-scan` (both side by side).
* `<service>/`: where a shared library answers from a remote service, pinning a verdict against the live service makes the test age. Seed the answer where the library looks and run the plugin normally. Cover the answer shapes in **one** plugin and point to it from the others' module docstring. Reference: `check-plugins/mysql-version` (`endoflifedate/` seeded into the `lib.cache` entry `lib.version.check_eol()` reads, `TMPDIR` pointed at a throwaway directory). One testcase asserts the seeded file landed there, so broken seeding cannot silently turn every case into a live test.
* Redfish checks keep `--verbose` runs (`### GET <path>` blocks) in `stdout/`, replayed by path via `lib.redfish.replay()`, so a bug report's output is a test case as is. Reference: `check-plugins/redfish-sensors`.


#### Test data file naming

Name fixtures after the **scenario**, not the expected state, which depends on fixture plus parameters: lowercase, hyphenated, describing the data (`empty-response`, `single-node`, `three-nodes-healthy`, `cpu-80-percent`, `disk-nearly-full`, `memory-400mb-used`, `three-nodes-one-down`, `malformed-json`, `service-unreachable`). Reuse a fixture across testcases with different parameters (`cpu-80-percent` for `ok-below-warn`, `warn-above-warn`, `crit-above-crit`). The state goes into the testcase `id`.


#### Writing tests

Define a `TESTS` list and materialise it with `lib.lftest.attach_tests()`:

```python
TESTS = [
    {
        'id': 'warn-above-warn',
        'test': 'stdout/cpu-80-percent,,0',
        'params': '--warning 70 --critical 95',
        'assert-retc': STATE_WARN,
        'assert-regex': r'80%.*\[WARNING\]',
    },
]


class TestCheck(unittest.TestCase):
    check = '../my-check'


lib.lftest.attach_tests(TestCheck, TESTS)
```

The complete file, with imports and `unittest.main()`, is [example/unit-test/run](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/example/unit-test/run).

`attach_tests()` creates one `test_<id>` method per entry, so `./run` reports the real count and `./run -v` names every scenario; a plain `for ... subTest()` loop reports `Ran 1 test`.

Testcase `id`:

* Lead with the expected state (`ok-`, `warn-`, `crit-`, `unknown-`), or, for a testcase pinning no state, with what it verifies (`parses-`).
* Follow with what the test verifies, not the fixture name: `crit-disk-full`, `unknown-missing-dependency`, `parses-rhel9-httpd-2-4-62`.
* Unique within `TESTS`.

Assertion keys:

* `assert-retc` (`int`, optional): expected return code. Pin it wherever fixture and parameters decide the state. Leave it out where something outside the testcase decides, e.g. a remote service the fixture does not stand in for; assert the parsed output instead. References: `check-plugins/apache-httpd-version` and the `TESTS` of `check-plugins/mysql-version`, whose `EOL_TESTS` cover the verdict against fixtures.
* `assert-in` / `assert-not-in` (`list` of `str`, optional): strings that must (not) appear in stdout.
* `assert-regex` (`str`, optional): regex that must match stdout.
* `assert-stderr` (`str`, optional): expected stderr, default `''`.


#### Iterating over TESTS vs. platforms

* **TESTS list** (default, fixtures via `--test=stdout/...`): `lib.lftest.attach_tests(TestCheck, TESTS)`.
* **Platform list** (container tests, each item needing its own setup): `lib.lftest.attach_each(TestCheck, ITEMS, action, id_func=...)` with an `action(test, item)` callable; `id_func` turns an item into the method name. Examples: `check-plugins/mysql-connections/unit-test/run` (`IMAGES` of `(image, label)`, `id_func=lambda it: it[1]`), `check-plugins/cpu-usage/unit-test/run` (`CONTAINERFILES`, default `id_func=str`), `check-plugins/apache-httpd-status/unit-test/run` (`SCENARIOS` dicts, resetting a cache DB per item).

Never fall back to a plain `for ... subTest()` loop; it hides the real coverage count from `./run` and `tox`.


#### Running tests

* **Fast tests** inject fixtures via `--test`, run in a fraction of a second, and are safe for CI and the `tox` matrix.
* **Container tests** use testcontainers or a `lib.lftest` container helper, need podman, and take minutes per plugin.

Run `./run` in a plugin's `unit-test/`, or from the repo root `python tools/run-unit-tests [my-check]` with `--no-container` (fast tests only, used by `tox`) or `--only-container` (same as `tools/run-container-tests`). `tox` runs the fast tests for all Python versions, `tox -e py39` one environment.

Each `tox` environment installs `lockfiles/pyXX/requirements.txt` (pure wheels and a few pure-Python sdists, no compiler needed), and the plugins import the lib via their `lib` symlink, so check it out beside this repository (`../lib`). Missing Pythons are skipped. Run `tools/run-container-tests` before a release.

#### Continuous integration

`Linuxfabrik: Unit Tests` runs every night on `main` (not per push or pull request), against `main` of the lib. Start it by hand with `gh workflow run lf-unit-tests.yml`, plus `--field container-tests=true` for the container tests. It runs the fast tests per Python via `tox`, the fast tests of `.windows` plugins on Windows, a parse with Rocky Linux 8's Python 3.6 (warning only, plugins require 3.9), and weekly the container tests. The lib runs the same workflow.


#### Container-based tests

* **Plugin on the host, service in the container**: the common case, for plugins talking to a service over the network (Keycloak, Redis, a database, a web API).
* **Plugin inside the container**: for plugins reading host-local resources (`/proc`, `/sys`, distro binaries, distro-specific psutil fields) that cannot be fixtured. The plugin is bind-mounted and run via `container.exec()`. Reference: `check-plugins/cpu-usage/unit-test/run`.

##### Plugin runs from the host, service runs in the container

Use `lib.lftest.run_container()`, a wrapper around [testcontainers-python](https://testcontainers-python.readthedocs.io/) for lifecycle, ports, environment and log-based readiness waits: `with lib.lftest.run_container(image, env={...}, ports=[8080], command='start-dev', wait_log='Listening on:') as container:`, then point the plugin at `container.get_container_host_ip()` and `container.get_exposed_port(8080)`. Reference: `check-plugins/keycloak-version/unit-test/run`.

* **Pull upstream images whenever possible**; the plugin runs on the host, so no custom `Containerfile` is needed.
* **Wait on a log marker, not a sleep** (`wait_log`, e.g. `Listening on:` for Keycloak, `ready for connections.` for MariaDB; `wait_log_timeout` for services taking longer than 2 minutes).
* **Do not hardcode state-shifting assertions.** For date-dependent results (EOL windows, "last seen N days ago", "expires in X days"), assert only a valid state and the expected version or identifier.
* **Multi-version matrix** in an `IMAGES` list (or `CONTAINERFILES`, `SCENARIOS`) at the top, via `lib.lftest.attach_each()`. Add new major releases at the bottom.
* **Rootless podman**: set `TESTCONTAINERS_RYUK_DISABLED=true` and `CONTAINER_HOST=unix:///run/user/$UID/podman/podman.sock`; `tools/run-unit-tests` does both automatically.
* **Do not run container tests via `tox`**; `tools/run-unit-tests` detects them by `podman` or `testcontainers` in the `run` file.
* **No hand-rolled podman orchestration in new tests.** Migrate `subprocess.run(['podman', 'build', ...])` to `lib.lftest.run_container()`.


##### Plugin runs inside the container

For host-local data sources (a fixture would hide whether the plugin runs cleanly on our customers' distros), use a `Containerfile` per distro under `unit-test/containerfiles/<distro>-v<version>` that installs python3 and the requirements and keeps running via `CMD ["sleep", "infinity"]`. Iterate with `lib.lftest.attach_each()` (one `test_<distro>` per file), bind-mount `lib/` and the plugin into `/tmp`, and run them via `container.exec()`.

**Containerfile naming**: `<distro>-v<version>`, lowercase, dash-separated, with a mandatory `v` as the separator (sorts naturally, fits `archlinux-vlatest` into the scheme): `archlinux-vlatest`, `debian-v12` / `v13`, `fedora-v43`, `rhel-v8` / `v9` / `v10`, `sles-v15` / `v16`, `ubuntu-v2204` / `v2404` / `v2604`. Image tags follow as `lfmp-<plugin>-<distro>-v<version>`.

**SLE vs. SLES**: Containerfiles use `sles-v*` (the server product; BCI is SLES-derived), while `build/linuxfabrik-monitoring-plugins.sle.spec` and `repo.linuxfabrik.ch/monitoring-plugins/sle/<version>/` name the platform (SLES and SLED). The repo URL is a public contract with customer `/etc/zypp/repos.d/` files; never rename it without coordinated migration.

The canonical distro matrix is the cpu-usage `CONTAINERFILES` list; new tests of this kind target the same platforms where possible.

* **Reuse cpu-usage's `containerfiles/`**; the bootstrap (package manager + venv + `pip install -r lockfiles/pyXX/requirements.txt --require-hashes`) is identical, only the bind-mount path changes.
* **`clean_up=False` on `DockerImage`**, so the image stays and later runs hit podman's layer cache instead of rebuilding.
* **`,Z` on bind mounts** (`mode='ro,Z'`) on SELinux-enforcing hosts, otherwise `import lib` fails with "Permission denied" inside the container.
* **Rootless podman**: as above (`CONTAINER_HOST` / `DOCKER_HOST` at the rootless socket).


### sudoers File

If the plugin requires `sudo`, add it to the `sudoers` files of all supported operating systems in `assets/sudoers/`. File names match `ansible_facts['distribution'] + ansible_facts['distribution_major_version']` (e.g. `CentOS7`); use symbolic links to prevent duplicates.

> **Attention:** The newline at the end is required!


### Icinga Director Basket Config

Each plugin provides its Director config as a basket, usually at least one Command, one Service Template and some Datafields. Everything else (Host Templates, Service Sets, Notification Templates, Tag Lists, ...) goes into `assets/icingaweb2-module-director/all-the-rest.json`. Baskets are generated by `build-basket`.

> **Always review the basket before committing.**


#### Create a Basket File from Scratch

`./tools/build-basket --plugin-file check-plugins/new-check/new-check` writes `check-plugins/new-check/icingaweb2-module-director/new-check.json`. Inspect especially the Command `timeout` and the ServiceTemplate `check_interval`, `criticality`, `enable_perfdata`, `max_check_attempts` and `retry_interval`.


#### Fine-tune a Basket File

**Never directly edit a basket JSON file.** Put adjustments into `check-plugins/new-check/icingaweb2-module-director/new-check.yml` and re-run `build-basket`, also after adding, changing or deleting a parameter:

```yml
---
variants:
  - linux
  - windows

overwrites:
  '["Command"]["cmd-check-new-check"]["timeout"]': 30
  '["ServiceTemplate"]["tpl-service-new-check"]["check_interval"]': 3600
  '["ServiceTemplate"]["tpl-service-new-check"]["vars"]["criticality"]': 'C'
```

Any key of the generated JSON can be overwritten this way, e.g. `command`, `check_command`, `enable_perfdata`, `max_check_attempts`, `retry_interval` or `use_agent`.


#### Basket File for different OS

`variants` in the same `.yml` generate flavours of the command call:

* `linux` (default if none is defined): `cmd-check-...`, `tpl-service-...` and the datafields.
* `windows`: `cmd-check-...-windows`, `tpl-service-...-windows` and the datafields.
* `sudo`: `cmd-check-...-sudo` importing `cmd-check-...` with `/usr/bin/sudo` prepended, and `tpl-service...-sudo` using it as check command.
* `no-agent`: `tpl-service...-no-agent` importing `tpl-service...`, with the command endpoint set to the Icinga 2 master.


#### Create Basket Files for all Check Plugins

`./tools/build-basket --auto`, for example after a change to `build-basket` itself.


#### Service Sets

* Append new Service Sets to `assets/icingaweb2-module-director/all-the-rest.json` with new unique UUIDs, and check the syntax with `cat assets/icingaweb2-module-director/all-the-rest.json | jq`.
* Moving a service to another Service Set needs a new UUID (impossible in the Director GUI).
* Every service in a set needs a unique `object_name`, identical to the JSON key above it. The Director renders a set's services by name, so of two equal names only one runs, and `icingacli director basket restore` aborts with a duplicate UUID on every later run.
* Double every `$` in a variable value (`^linuxfabrik-monitoring-plugins$$`), otherwise config validation fails with "Closing $ not found in macro format string" and rejects the whole deployment. The plugin receives a single `$`.
* For a single-host exception, override the variable on that host's service instead of editing the set (`import DirectorOverrideTemplate` merges `host.vars._override_servicevars["<service name>"]` over the set's values). Editing the set changes every tagged host.


### README Structure

Each plugin README follows a fixed structure. Use [check-plugins/example/README.md](check-plugins/example/README.md) as the reference template for the structure, and [check-plugins/php-fpm-status/README.md](check-plugins/php-fpm-status/README.md) as the reference for the level of detail and especially for troubleshooting depth that a Linux system engineer expects. The sections are:

1. **Overview**: *what* the plugin does, starting with its main purpose and including at least the `DESCRIPTION` text. Subsections:

    * **Important Notes** (optional, first if present): operational edge cases the admin must know before deploying ("Requires sudo", "Only works with Redis 3.0+", "First run returns OK with 'Waiting for more data.'", counters reset after a reboot). No implementation details.
    * **Data Collection**: how data is gathered (shell command, API, psutil, ...), filtering options, SQLite usage, non-blocking measurement.

2. **Fact Sheet**: only applicable rows from this closed list, in this order; other facts go into the Overview. Separator `|----|----|`.

    | Fact | Value |
    |----|----|
    | Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/example>. Notification / event plugins: `Notification Plugin Download` / `Event Plugin Download`. |
    | Nagios/Icinga Check Name              | `check_example` (SEO for the Nagios-style name). Underscores, never dashes. |
    | Check Interval Recommendation         | Every minute, Every 5/15/30 minutes, Every hour, Every 4/8/12 hours, Every day, Every week |
    | Can be called without parameters      | Yes/No |
    | Runs on                               | Cross-platform (default) / Linux (only for Linux-specific APIs: `/proc`, `systemd`, `dmesg`, `dnf`/`apt`/`yum`, `journalctl`, ...) / Windows. A missing `.windows` file does not mean Linux-only. |
    | Compiled for Windows                  | Yes (when `.windows` file exists) / No (runs with Python interpreter). A bare "No" for Linux-only, notification and event plugins. |
    | Requirements                          | command-line tool `foo`; User with higher permissions |
    | 3rd Party Python modules              | `module-name` |
    | Handles Periods                       | Yes (alerts only after `--count` consecutive threshold violations) |
    | Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-<plugin-name>.db`. Everything kept between runs, SQLite included; no second label. `in_memory=True` databases get no row. |

3. **Help**: the full `--help` output in a code block, regenerated via `tools/update-readmes`.
4. **Usage Examples**: realistic invocations with output, at least one OK case, and both variants if `--lengthy` exists.
5. **States**: precisely *when* which state is returned (e.g. "WARN if the percentage value is >= `--warning`"), including `--always-ok`, consecutive-run requirements and first-run/reboot edge cases.
6. **Perfdata / Metrics**: table with Name, Type, Description; types `Bytes`, `Number`, `Percentage`, `Seconds`. Use the vendor's official metric descriptions where possible.
7. **Troubleshooting** (optional): one `### <short heading>` subsection per problem, ordered from most common to most obscure.

    * Heading: a short, complete error string in backticks; for long errors or placeholders (`host:port`, `<pattern>`, `/path/to/file`) a short descriptive heading with the literal string in backticks on its own line below. Never both.
    * Then the fix in flowing prose. Lead with the cause only when it is known and specific; never pad with a filler cause or invent one.
    * No **Cause:** / **Solution:** labels.
    * Alert-state problems without an error string (a threshold crossed, a first-run baseline) get a descriptive heading and a short numbered runbook.

    Reference implementations: [`lynis`](check-plugins/lynis.md) for the error → cause-then-solution shape, and [`php-fpm-status`](check-plugins/php-fpm-status.md) for alert-state runbooks.

8. **Credits, License**: always present.


### Grafana Dashboards

Dashboards live in `check-plugins/<plugin>/grafana/<plugin>.yml`. The title is capitalized, file name and `uid` match the plugin directory. Spaces in a panel-name component become `-`, `/` is dropped (`Network I/O` → `network-io`). Define only properties that differ from Grafana defaults. Sibling dashboards (memory-usage, cpu-usage) line up time ranges, thresholds and labels for side-by-side comparison. Provisioning and the Grizzly → grafanactl migration are in [GRAFANA.md](GRAFANA.md).


### Plugins and Capabilities

Non-obvious patterns and the plugin that demonstrates each:

| Pattern | Reference plugin |
|---|---|
| `--count`: alert only after N consecutive threshold violations | [cpu-usage](check-plugins/cpu-usage.md) |
| SQLite `cut()` to keep the local state DB bounded | [cpu-usage](check-plugins/cpu-usage.md) |
| Raw network communication via byte-structs and sockets | [dhcp-relayed](check-plugins/dhcp-relayed.md) |
| Check minimum required 3rd-party library version at import time | [disk-io](check-plugins/disk-io.md) |
| Threshold warm-up (learns a baseline before alerting) | [disk-io](check-plugins/disk-io.md) |
| `--icinga-callback`: acknowledgement-aware plugin | [logfile](check-plugins/logfile.md) |
| Credential file via MySQL option-file / `configparser` | All mysql-\* plugins, [icinga-topflap-services](check-plugins/icinga-topflap-services.md) |
| Network scan of a subnet (host discovery via `--host`/`--network`/`--interface`, parallel per-host probing, worst-of aggregation) | [lynis](check-plugins/lynis.md) |
| Optional asset script (`monitoring.php`) alongside the plugin | [php-status](check-plugins/php-status.md) |
| Session caching (reuse an API session token / cookie across runs to avoid rate-limited logins) | [huawei-dorado-system](check-plugins/huawei-dorado-system.md) |
| Cross-platform branching (`lib.base.LINUX` / `lib.base.WINDOWS`) | [users](check-plugins/users.md) |
