#! /usr/bin/env python3
# -*- coding: utf-8; py-indent-offset: 4 -*-
#
# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.

# https://github.com/Linuxfabrik/monitoring-plugins/blob/main/CONTRIBUTING.md

"""Shared helpers for the basket-* tools.

Icinga Director basket JSON files are the repo's exchange format for
Director objects (datafields, commands, host templates, service
templates, service sets). Every tool under `tools/` that reads or
writes a basket goes through `load_basket()` / `save_basket()` here
so the error handling (duplicate keys, missing file, invalid JSON)
looks identical across tools and the on-disk format (4-space indent,
trailing newline) stays byte-stable across regenerations.
"""

import json

import _common

__author__ = 'Linuxfabrik GmbH, Zurich/Switzerland'
__version__ = '2026041301'


class DuplicateKeyError(ValueError):
    """Raised by `_raise_on_duplicate_keys` when a basket carries two
    entries under the same key. Director baskets must not contain
    duplicates - the import fails silently and drops the earlier
    value if we let json.load() handle it on its own, so we fail
    fast instead."""


def _raise_on_duplicate_keys(ordered_pairs):
    """object_pairs_hook for json.load that refuses duplicate keys.

    Returns a plain dict on success; raises DuplicateKeyError the
    moment any key appears twice in the ordered pair list. Use as
    `json.load(f, object_pairs_hook=_raise_on_duplicate_keys)`.
    """
    result = {}
    for key, value in ordered_pairs:
        if key in result:
            raise DuplicateKeyError(f'Duplicate key: {key}')
        result[key] = value
    return result


def load_basket(path):
    """Load a Director basket JSON file and return the parsed dict.

    Aborts via `_common.die()` on file-read error, on invalid JSON
    and on duplicate keys. All three are conditions the caller
    cannot meaningfully recover from, so every basket-* tool would
    otherwise grow the same `if not success: sys.exit()` dance
    around the call.
    """
    try:
        text = path.read_text(encoding='utf-8')
    except OSError as exc:
        _common.die(f'basket: cannot read {path}: {exc}')
    try:
        return json.loads(text, object_pairs_hook=_raise_on_duplicate_keys)
    except json.JSONDecodeError as exc:
        _common.die(f'basket: cannot parse {path}: {exc}')
    except DuplicateKeyError as exc:
        _common.die(f'basket: {path}: {exc}')


def save_basket(path, data):
    """Write a Director basket JSON file with the project's style.

    Writes 4-space indent, `(',', ': ')` separators and a trailing
    newline - matching what existing committed baskets look like,
    so `git diff` after a regeneration only shows real content
    changes and not whitespace churn.
    """
    try:
        with path.open('w', encoding='utf-8') as f:
            json.dump(
                data,
                f,
                sort_keys=False,
                indent=4,
                separators=(',', ': '),
            )
            f.write('\n')
    except OSError as exc:
        _common.die(f'basket: cannot write {path}: {exc}')
