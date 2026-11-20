# Code

## Bytes vs. Unicode

Use `txt.to_text()` and `txt.to_bytes()`. Incoming data is UTF-8 bytes: decode it as early as possible, **use unicode throughout the plugin**, and let library functions (`base.oao`, `url.fetch_json`, ...) do the output conversion. See <https://nedbatchelder.com/text/unipain.html>.

External bytes of unreliable encoding (subprocess output, a file over SMB, a sensor payload) that end up in the printed result are decoded with `lib.txt.to_text(raw_bytes, errors='strict_or_latin1')`: UTF-8, and on any invalid byte the whole input as Latin-1. The default `surrogateescape` produces lone surrogates that raise `UnicodeEncodeError` later at print time, far from the cause ([Linuxfabrik/lib#256](https://github.com/Linuxfabrik/lib/issues/256)). Always-ASCII values or values with a declared encoding do not need it.


## Names, Naming Conventions

The plugin name matches `^[a-zA-Z0-9\-\_]*$`, so it can serve as the Grafana dashboard uid (see [here](https://github.com/grafana/grafana/blob/552ecfeda320a422bfc7ca9978c94ffea887134a/pkg/util/shortid_generator.go#L11)).


## Caching temporary data, SQLite database

Use `cache` for a simple key-value store (see `nextcloud-version`), otherwise `db_sqlite` (see `cpu-usage`).


## Error Handling

* Catch exceptions with `try` / `except`, never bare `except:`; `except Exception:` is the broadest acceptable catch-all.
* A function that catches exceptions returns `(False, errormessage)` on error and `(True, result)` otherwise (`(True, False)` means no exception, result `False`). A caller of such a function returns a `(retc, result)` tuple itself.
* In `main()`, use `lib.base.coe()`. See `nextcloud-version`.
* For a missing module, `print('Python module "psutil" is not installed.')` plus `sys.exit(STATE_UNKNOWN)` in the `except ImportError:` gives a clean error in the compiled variants, while `lib.base.cu()` there leads to an ugly multi-exception stacktrace.


## Timeout Handling

Every plugin handles timeouts gracefully (e.g. `df` on a failed network drive, unresponsive APIs, stuck database connections):

* Always support `--timeout`, well below the check timeout of the monitoring server (often 10 seconds): 3 seconds for a network connect or an HTTP/API request (it applies per connect and per read, leaving time for the run), 8 seconds for the whole runtime of a local command. Another default needs a measured reason in a comment next to `DEFAULT_TIMEOUT` and a matching command timeout in the basket `.yml`.
* HTTP: `lib.base.coe(lib.url.fetch(..., timeout=args.TIMEOUT))`. Shell commands: pass a timeout to `lib.shell.shell_exec()`.
* On timeout, return `STATE_WARN` with a meaningful message (e.g. "Timeout after 8s while connecting to ...").


## PEP 8

We use [PEP 8](https://www.python.org/dev/peps/pep-0008/) where it makes sense.

**String quoting:** single quotes by default; double quotes only inside f-string expressions (`f'{lib.base.state2str(state, prefix=" ")}'`) or when the string contains single quotes. `"""` for all triple-quoted strings (docstrings, `DESCRIPTION`, SQL). Enforced by `ruff format`.


## Imports

Import every `lib.X` module the plugin uses, even if another `lib.*` module pulls it in transitively (e.g. `import lib.time` for `lib.time.now()` although `lib.base` imports it). Transitive imports break when `lib` reorganises, and linters cannot warn. Keep `import lib.*` lines sorted; `ruff` groups them with the third-party imports.


## DESCRIPTION Variable

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


## Docstrings

Docstrings in the plugins and the [Libraries](https://github.com/Linuxfabrik/lib) follow the [numpydoc standard](https://numpydoc.readthedocs.io/en/latest/format.html#docstring-standard), so `pydoc lib/base.py` works.


## Ruff

[ruff](https://docs.astral.sh/ruff/) is the primary linter and formatter (PEP 8, import sorting, common bug patterns), configured in `pyproject.toml` and run by the pre-commit hooks `ruff-check` and `ruff-format`. By hand: `ruff check check-plugins/my-check/my-check`, `ruff format check-plugins/my-check/my-check`.


## PyLint

PyLint is a manual audit tool (`pylint check-plugins/my-check/my-check`), not a pre-commit hook: it finds what ruff misses, but its metric checks (`R0912`, `R0914`, `R0915`) fire on almost every plugin by design and `C0301` uses 100 instead of 88 characters. Read metric findings as a hint.


## Plugins and Capabilities

Non-obvious patterns and the plugin that demonstrates each:

| Pattern | Reference plugin |
|---|---|
| `--count`: alert only after N consecutive threshold violations | [cpu-usage](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/cpu-usage/README.md) |
| SQLite `cut()` to keep the local state DB bounded | [cpu-usage](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/cpu-usage/README.md) |
| Raw network communication via byte-structs and sockets | [dhcp-relayed](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/dhcp-relayed/README.md) |
| Check minimum required 3rd-party library version at import time | [disk-io](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/disk-io/README.md) |
| Threshold warm-up (learns a baseline before alerting) | [disk-io](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/disk-io/README.md) |
| `--icinga-callback`: acknowledgement-aware plugin | [logfile](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/logfile/README.md) |
| Credential file via MySQL option-file / `configparser` | All mysql-\* plugins, [icinga-topflap-services](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/icinga-topflap-services/README.md) |
| Network scan of a subnet (host discovery via `--host`/`--network`/`--interface`, parallel per-host probing, worst-of aggregation) | [lynis](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/lynis/README.md) |
| Optional asset script (`monitoring.php`) alongside the plugin | [php-status](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/php-status/README.md) |
| Session caching (reuse an API session token / cookie across runs to avoid rate-limited logins) | [huawei-dorado-system](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/huawei-dorado-system/README.md) |
| Cross-platform branching (`lib.base.LINUX` / `lib.base.WINDOWS`) | [users](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/users/README.md) |
