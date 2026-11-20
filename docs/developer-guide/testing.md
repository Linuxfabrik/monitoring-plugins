# Unit Tests

Tests use `unittest`, data-driven: a list of dicts (or platforms/images for container tests), one real test method per item via `lib.lftest.attach_tests()` or `lib.lftest.attach_each()`. Reference: [example](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/check-plugins/example/unit-test/run).


## Test directory structure

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


## Test data file naming

Name fixtures after the **scenario**, not the expected state, which depends on fixture plus parameters: lowercase, hyphenated, describing the data (`empty-response`, `single-node`, `three-nodes-healthy`, `cpu-80-percent`, `disk-nearly-full`, `memory-400mb-used`, `three-nodes-one-down`, `malformed-json`, `service-unreachable`). Reuse a fixture across testcases with different parameters (`cpu-80-percent` for `ok-below-warn`, `warn-above-warn`, `crit-above-crit`). The state goes into the testcase `id`.


## Writing tests

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


## Iterating over TESTS vs. platforms

* **TESTS list** (default, fixtures via `--test=stdout/...`): `lib.lftest.attach_tests(TestCheck, TESTS)`.
* **Platform list** (container tests, each item needing its own setup): `lib.lftest.attach_each(TestCheck, ITEMS, action, id_func=...)` with an `action(test, item)` callable; `id_func` turns an item into the method name. Examples: `check-plugins/mysql-connections/unit-test/run` (`IMAGES` of `(image, label)`, `id_func=lambda it: it[1]`), `check-plugins/cpu-usage/unit-test/run` (`CONTAINERFILES`, default `id_func=str`), `check-plugins/apache-httpd-status/unit-test/run` (`SCENARIOS` dicts, resetting a cache DB per item).

Never fall back to a plain `for ... subTest()` loop; it hides the real coverage count from `./run` and `tox`.


## Running tests

* **Fast tests** inject fixtures via `--test`, run in a fraction of a second, and are safe for CI and the `tox` matrix.
* **Container tests** use testcontainers or a `lib.lftest` container helper, need podman, and take minutes per plugin.

Run `./run` in a plugin's `unit-test/`, or from the repo root `python tools/run-unit-tests [my-check]` with `--no-container` (fast tests only, used by `tox`) or `--only-container` (same as `tools/run-container-tests`). `tox` runs the fast tests for all Python versions, `tox -e py39` one environment.

Each `tox` environment installs `lockfiles/pyXX/requirements.txt` (pure wheels and a few pure-Python sdists, no compiler needed), and the plugins import the lib via their `lib` symlink, so check it out beside this repository (`../lib`). Missing Pythons are skipped. Run `tools/run-container-tests` before a release.

## Continuous integration

`Linuxfabrik: Unit Tests` runs every night on `main` (not per push or pull request), against `main` of the lib. Start it by hand with `gh workflow run lf-unit-tests.yml`, plus `--field container-tests=true` for the container tests. It runs the fast tests per Python via `tox`, the fast tests of `.windows` plugins on Windows, a parse with Rocky Linux 8's Python 3.6 (warning only, plugins require 3.9), and weekly the container tests. The lib runs the same workflow.


## Container-based tests

* **Plugin on the host, service in the container**: the common case, for plugins talking to a service over the network (Keycloak, Redis, a database, a web API).
* **Plugin inside the container**: for plugins reading host-local resources (`/proc`, `/sys`, distro binaries, distro-specific psutil fields) that cannot be fixtured. The plugin is bind-mounted and run via `container.exec()`. Reference: `check-plugins/cpu-usage/unit-test/run`.

### Plugin runs from the host, service runs in the container

Use `lib.lftest.run_container()`, a wrapper around [testcontainers-python](https://testcontainers-python.readthedocs.io/) for lifecycle, ports, environment and log-based readiness waits: `with lib.lftest.run_container(image, env={...}, ports=[8080], command='start-dev', wait_log='Listening on:') as container:`, then point the plugin at `container.get_container_host_ip()` and `container.get_exposed_port(8080)`. Reference: `check-plugins/keycloak-version/unit-test/run`.

* **Pull upstream images whenever possible**; the plugin runs on the host, so no custom `Containerfile` is needed.
* **Wait on a log marker, not a sleep** (`wait_log`, e.g. `Listening on:` for Keycloak, `ready for connections.` for MariaDB; `wait_log_timeout` for services taking longer than 2 minutes).
* **Do not hardcode state-shifting assertions.** For date-dependent results (EOL windows, "last seen N days ago", "expires in X days"), assert only a valid state and the expected version or identifier.
* **Multi-version matrix** in an `IMAGES` list (or `CONTAINERFILES`, `SCENARIOS`) at the top, via `lib.lftest.attach_each()`. Add new major releases at the bottom.
* **Rootless podman**: set `TESTCONTAINERS_RYUK_DISABLED=true` and `CONTAINER_HOST=unix:///run/user/$UID/podman/podman.sock`; `tools/run-unit-tests` does both automatically.
* **Do not run container tests via `tox`**; `tools/run-unit-tests` detects them by `podman` or `testcontainers` in the `run` file.
* **No hand-rolled podman orchestration in new tests.** Migrate `subprocess.run(['podman', 'build', ...])` to `lib.lftest.run_container()`.


### Plugin runs inside the container

For host-local data sources (a fixture would hide whether the plugin runs cleanly on our customers' distros), use a `Containerfile` per distro under `unit-test/containerfiles/<distro>-v<version>` that installs python3 and the requirements and keeps running via `CMD ["sleep", "infinity"]`. Iterate with `lib.lftest.attach_each()` (one `test_<distro>` per file), bind-mount `lib/` and the plugin into `/tmp`, and run them via `container.exec()`.

**Containerfile naming**: `<distro>-v<version>`, lowercase, dash-separated, with a mandatory `v` as the separator (sorts naturally, fits `archlinux-vlatest` into the scheme): `archlinux-vlatest`, `debian-v12` / `v13`, `fedora-v43`, `rhel-v8` / `v9` / `v10`, `sles-v15` / `v16`, `ubuntu-v2204` / `v2404` / `v2604`. Image tags follow as `lfmp-<plugin>-<distro>-v<version>`.

**SLE vs. SLES**: Containerfiles use `sles-v*` (the server product; BCI is SLES-derived), while the RPM packages and the repository path `repo.linuxfabrik.ch/sle/<version>/` name the platform (SLES and SLED). The repo URL is a public contract with customer `/etc/zypp/repos.d/` files; never rename it without coordinated migration.

The canonical distro matrix is the cpu-usage `CONTAINERFILES` list; new tests of this kind target the same platforms where possible.

* **Reuse cpu-usage's `containerfiles/`**; the bootstrap (package manager + venv + `pip install -r lockfiles/pyXX/requirements.txt --require-hashes`) is identical, only the bind-mount path changes.
* **`clean_up=False` on `DockerImage`**, so the image stays and later runs hit podman's layer cache instead of rebuilding.
* **`,Z` on bind mounts** (`mode='ro,Z'`) on SELinux-enforcing hosts, otherwise `import lib` fails with "Permission denied" inside the container.
* **Rootless podman**: as above (`CONTAINER_HOST` / `DOCKER_HOST` at the rootless socket).
