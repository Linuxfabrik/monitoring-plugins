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

# The `example` plugin is a code skeleton that new plugins are based
# on; it is not meant to be discovered, tested or shipped. Tools that
# walk the check-plugins tree should skip it by default.
SKIP_PLUGINS = frozenset({'example'})


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


def iter_check_plugins(skip=SKIP_PLUGINS):
    """Yield every `check-plugins/<name>` directory in sorted order.

    Skips any plugin whose name is in `skip` (default: the `example`
    skeleton). Tools that need a different skip set - for example, to
    rerun a single plugin that is normally skipped - can pass
    `skip=frozenset()` to walk the entire tree.

    Yields `pathlib.Path` objects, so callers can chain the usual
    `.name`, `.is_dir()`, `/ "sub"` operations without dragging `os`
    and `os.path` imports into the caller.
    """
    for entry in sorted(CHECK_PLUGINS_DIR.iterdir()):
        if not entry.is_dir():
            continue
        if entry.name in skip:
            continue
        yield entry
