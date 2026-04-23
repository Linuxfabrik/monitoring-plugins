# Maintainer Tools

Helper scripts under `tools/` used while developing, testing and
packaging the Linuxfabrik Monitoring Plugins. Not part of the shipped
plugin collection. Every tool has a module docstring and supports
`--help`.

All tools are run from the repository root.


## Icinga Director Basket

Tooling for generating, joining, comparing and cleaning the Icinga
Director basket that is shipped with the monitoring plugins. See
[ICINGA.md](ICINGA.md) for how the basket is consumed.

### basket-compare

Compare two Director baskets and print the differences as one table per
object class (Datafield, Command, Host Template, Service Template,
Service Set). Useful before committing a regenerated basket to see what
actually changed.

```bash
tools/basket-compare old-basket.json new-basket.json
```

### basket-join

Merge every per-plugin `icingaweb2-module-director/<plugin>.json` plus
the shared `assets/icingaweb2-module-director/all-the-rest.json` into
one importable basket for `icingacli director basket restore`.

```bash
tools/basket-join --output /tmp/basket.json
```

### basket-remove-uuids

Strip the `uuid` fields from a basket JSON. Only needed for
pre-v1.9 Director installations or when a uuid collides with an
existing object on the target.

```bash
tools/basket-remove-uuids /tmp/basket.json
```

### build-basket

Generate a single-plugin Director basket from a check-plugin script.
Imports the plugin without running `main()`, walks its argparse
definition and translates it into Datafields, a Command and a Service
Template. Run with `--auto` to regenerate baskets for every plugin
non-interactively.

```bash
tools/build-basket --plugin-file check-plugins/cpu-usage/cpu-usage
tools/build-basket --auto
```


## Documentation

### build-docs

Generate the `docs/` directory structure (symlinks to every
check-plugin, notification-plugin and event-plugin README plus the
top-level Markdown files) and rewrite `mkdocs.yml`. The resulting tree
is consumed by the GitHub Pages workflow at
[linuxfabrik.github.io/monitoring-plugins](https://linuxfabrik.github.io/monitoring-plugins/).

```bash
tools/build-docs
```

### update-readmes

Refresh the `## Help` section of every check-plugin README by running
each plugin with `--help` and replacing the fenced code block between
`## Help` and `## Usage Examples`. Run after changing a plugin's
argparse definition or in bulk before a release.

```bash
source ~/venvs/monitoring-plugins/bin/activate
tools/update-readmes
```


## Testing

### run-container-tests

Discover and run all container-based plugin unit tests (those importing
`testcontainers` or using `lib.lftest` container helpers). Builds or
pulls a podman container per plugin, injects plugin + `lib/`, and
exercises the check against a live service. Minutes per plugin.

```bash
tools/run-container-tests
```

### run-linter-checks

Run `ruff`, `bandit` and `vulture` across the whole repository, not
just staged files. Pre-commit hooks only cover staged files; this
script sweeps everything so old issues cannot hide in untouched files.
`pylint` is intentionally not invoked here because its metric-based
checks produce thousands of false positives across similar plugins.

```bash
tools/run-linter-checks
```

### run-tox-tests

Thin wrapper around `tox` for running the unit-test suite across every
supported Python version (py39 through py314). The Python matrix and
per-env plugin list live in `tox.ini`. All arguments are passed through
to tox.

```bash
tools/run-tox-tests
tools/run-tox-tests -e py39
```

### run-unit-tests

Discover and run all plugin unit tests from each plugin's
`unit-test/run`. Fast fixture-based tests run in under a second;
container-based tests are detected automatically by inspecting the
`run` file. Flags `--no-container` and `--only-container` split the two
categories.

```bash
tools/run-unit-tests
tools/run-unit-tests cpu-usage
tools/run-unit-tests --no-container
```


## Operations

### influxdb-remove-old-measurements

Remove measurements from an InfluxDB instance where the latest entry
per host is older than the given threshold. Useful when the monitoring
system does not automatically drop measurements for hosts or services
that have been removed. See
[tools/influxdb-remove-old-measurements/README.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/tools/influxdb-remove-old-measurements/README.md)
for the full fact sheet.

```bash
tools/influxdb-remove-old-measurements --database icinga2 \
    --username influxdb-user --password linuxfabrik --threshold 90
```
