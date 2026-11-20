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
* `Build, CI/CD:`

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

Each plugin directory `plugin-name/` contains the plugin `plugin-name` and, as needed, `assets/` (helper scripts like `monitoring.php`), `grafana/` (dashboard), `icingaweb2-module-director/` (basket), `icingaweb2-module-grafana/` (panel for Icinga's Grafana module), `icon/` (SVG icon), `lib` (link to the Linuxfabrik Python libraries) and `unit-test/` (`run` plus fixtures, see [Test directory structure](docs/developer-guide/testing.md#test-directory-structure)).


### Deliverables

A new plugin delivers:

* The plugin itself, tested on RHEL and Debian.
* README file explaining "How?" and "Why?"
* A free, monochrome, transparent SVG icon from <https://simpleicons.org> or <https://fontawesome.com/search?ic=free> in the `icon` directory.
* Optional: `unit-test/run` (see [Unit Tests](docs/developer-guide/testing.md#unit-tests)).
* Optional: new Python deps in the repo-root `requirements.in`; regenerate the lockfiles under `lockfiles/pyXX/requirements.txt` with `tools/update-lockfiles`.
* If providing performance data: Grafana dashboard (see [GRAFANA.md](GRAFANA.md)) and `.ini` file for the Icinga Web 2 Grafana Module.
* Icinga Director Basket Config. Run `tools/build-basket --auto` before every commit (not just for new plugins), otherwise a stale basket surfaces as an unrelated diff in someone else's later run. It also refreshes the joined basket that ships with the plugins, which a pre-commit hook checks.
* Icinga Service Set in `all-the-rest.json` if appropriate (see [Icinga Director: Service Set vs. Service Template](docs/developer-guide/integrations.md#icinga-director-service-set-vs-service-template)).
* Optional: sudoers file (see [sudoers File](docs/developer-guide/security.md#sudoers-file)).
* Optional: a screenshot of the output in Icinga, 423x106, background-color `#f5f9fa`, hosted on [download.linuxfabrik.ch](https://download.linuxfabrik.ch/monitoring-plugins/assets/screenshots/) and listed alphabetically in [POSTER.md](POSTER.md).
* Update `CHANGELOG.md`.


### Rules of Thumb

* Be brief by default; report what is needed to fix a problem. Offer more via `--lengthy`, and add `--brief` where the default output grows unbounded on large systems (see [Verbosity parameter convention](docs/developer-guide/output.md#verbosity-parameter-convention-lengthy-and-brief)).
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


### Commit Scopes

Use the plugin name as commit scope, e.g. `fix(about-me): cryptography deprecation warning (fix #341)`. The first commit is `Add <plugin-name>`.


### Developer Guide

Before you change code, read the file in `docs/developer-guide/` that matches the task, completely:

| File | Read before |
|---|---|
| [code.md](docs/developer-guide/code.md) | writing plugin code: text encoding, names, caching, error and timeout handling, imports, the `DESCRIPTION`, docstrings, linting, and plugins that show special techniques |
| [integrations.md](docs/developer-guide/integrations.md) | adding or changing a Director basket, a Service Set or a Grafana dashboard |
| [output.md](docs/developer-guide/output.md) | changing what a plugin prints: the message, `--lengthy` and `--brief`, or the perfdata |
| [parameters.md](docs/developer-guide/parameters.md) | adding or changing a parameter, its help text, or a threshold |
| [plugin-readme.md](docs/developer-guide/plugin-readme.md) | writing or changing a plugin README |
| [security.md](docs/developer-guide/security.md) | writing a plugin that runs as root, adding a parameter that reaches a file, command or socket, or adding a sudoers entry |
| [testing.md](docs/developer-guide/testing.md) | writing or running unit tests, fixture or container based |
