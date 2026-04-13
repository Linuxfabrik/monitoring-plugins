#! /usr/bin/env python3
# -*- coding: utf-8; py-indent-offset: 4 -*-
#
# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.

# https://github.com/Linuxfabrik/monitoring-plugins/blob/main/CONTRIBUTING.md

"""Shared helpers for the `tools/` scripts.

Kept deliberately small. Every tool under `tools/` imports `REPO_ROOT`
and the `err()` / `die()` / `iter_check_plugins()` helpers from here so
the top of each tool looks identical; anything specific to a single
tool lives next to its caller.

The shebang-named tools under `tools/` (`run-unit-tests`, `build-docs`,
...) import this module as `_common`. Python's default `sys.path[0]`
when running a script is the directory containing that script, so the
relative import works without any PYTHONPATH gymnastics.
"""

import sys
from pathlib import Path

__author__ = 'Linuxfabrik GmbH, Zurich/Switzerland'
__version__ = '2026041301'


# Resolve the repository root from this file's location. Any tool that
# sits next to `_common.py` inside `tools/` inherits the same value.
REPO_ROOT = Path(__file__).resolve().parent.parent
CHECK_PLUGINS_DIR = REPO_ROOT / 'check-plugins'
TOOLS_DIR = REPO_ROOT / 'tools'

# Plugins that exist only as code skeletons and must not be included
# when tools iterate over `check-plugins/` (or its sibling directories
# for notification/event plugins): `example` is the reference plugin
# we copy-paste new plugins from, `dummy` is a minimal variant that
# exercises argparse and the output library without talking to any
# real data source. Tools that need to sweep the entire tree anyway
# can pass `skip=frozenset()` to `iter_plugin_dirs()`.
SKIP_PLUGINS = frozenset({'dummy', 'example'})


def err(msg):
    """Print a message to stderr.

    Used for warnings and errors so the stdout of a tool stays clean
    for piping into other tools or for CI log capture. Callers that
    want to abort after printing should use `die()` instead.
    """
    print(msg, file=sys.stderr, flush=True)


def die(msg, code=1):
    """Print a message to stderr and exit with the given code.

    Convenience wrapper around `err()` + `sys.exit()` so the call-site
    reads as one statement. The default exit code `1` matches the Unix
    convention for a generic failure.
    """
    err(msg)
    sys.exit(code)


def iter_plugin_dirs(subdir, skip=SKIP_PLUGINS):
    """Yield every `<subdir>/<name>` directory in sorted order.

    `subdir` is relative to the repo root and names one of the
    plugin families the repo ships - typically `check-plugins`,
    `notification-plugins` or `event-plugins`. Missing subdirs
    yield nothing (tools can iterate over all three without
    having to check for existence first).

    Yields `pathlib.Path` objects so callers can chain the usual
    `.name`, `.is_dir()`, `/ "sub"` operations without dragging
    `os` and `os.path` imports into the caller.
    """
    target = REPO_ROOT / subdir
    if not target.is_dir():
        return
    for entry in sorted(target.iterdir()):
        if not entry.is_dir():
            continue
        if entry.name in skip:
            continue
        yield entry


def iter_check_plugins(skip=SKIP_PLUGINS):
    """Yield every `check-plugins/<name>` directory in sorted order.

    Thin wrapper around `iter_plugin_dirs('check-plugins', ...)`
    that documents the common-case entry point. Skips the
    `example` / `dummy` skeletons by default; pass
    `skip=frozenset()` to walk the entire check-plugins tree.
    """
    yield from iter_plugin_dirs('check-plugins', skip=skip)
