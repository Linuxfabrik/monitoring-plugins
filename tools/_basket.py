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

`join_all()` merges every per-plugin basket into the one basket that is
imported into a Director. `tools/basket-join` writes it on demand, and
`tools/build-basket --auto` keeps the copy at `SHIPPED_BASKET` current,
which the installer and the packages place into `<plugin-dir>/assets/`.
"""

import collections
import json

import _common

__author__ = 'Linuxfabrik GmbH, Zurich/Switzerland'
__version__ = '2026110301'

ALL_THE_REST_BASKET = (
    _common.REPO_ROOT / 'assets/icingaweb2-module-director/all-the-rest.json'
)

# Plugin families whose per-plugin baskets are merged in.
PLUGIN_FAMILIES = (
    'check-plugins',
    'notification-plugins',
)

# The joined basket that ships with the plugins. Every file below a plugin's assets/
# folder is installed flat into <plugin-dir>/assets/ by the installer, the source zip
# and the packages, so it ends up next to the plugins at
# <plugin-dir>/assets/icingaweb2-module-director-basket.json, in the version of the
# plugins installed.
SHIPPED_BASKET = (
    _common.REPO_ROOT
    / 'check-plugins/icinga-director-basket-drift/assets'
    / 'icingaweb2-module-director-basket.json'
)


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


def dump_basket(data):
    """Return the basket JSON text in the project's style.

    4-space indent, `(',', ': ')` separators and a trailing newline,
    matching what existing committed baskets look like, so `git diff`
    after a regeneration only shows real content changes and not
    whitespace churn.
    """
    return json.dumps(data, sort_keys=False, indent=4, separators=(',', ': ')) + '\n'


class BasketJoiner:
    """Stateful merge of one or more per-plugin basket JSON files.

    The joiner keeps a running dict of merged objects plus the
    `uuid -> datafield_id` map it uses to detect "this datafield
    was already merged from an earlier file". Datafield IDs are
    renumbered as they are added so the merged output uses a
    dense, conflict-free 1..N range.
    """

    def __init__(self, verbose=True):
        self.verbose = verbose
        self.data = collections.defaultdict(dict)
        self.uuids2datafields = {}
        self.highest_datafield_id = 0

    def join_with_file(self, basket_file):
        """Merge the contents of `basket_file` into the running data."""
        if not basket_file.is_file():
            return
        if self.verbose:
            print(f'File: {basket_file}')
        basket_data = load_basket(basket_file)

        new_datafield_ids = {}  # reset per file
        try:
            if 'Datafield' in basket_data:
                for key, value in basket_data['Datafield'].items():
                    uuid = value.get('uuid')
                    if uuid in self.uuids2datafields:
                        current_value = self.data['Datafield'][
                            self.uuids2datafields[uuid]
                        ]
                        if current_value != value:
                            _common.die(
                                f'The objects "[Datafield][{value["varname"]}]"'
                                f' and "[Datafield][{current_value["varname"]}]"'
                                f' have the same uuid ("{uuid}") but not the'
                                f' same content. Fix this, aborting...',
                            )
                    else:
                        self.highest_datafield_id += 1
                        if uuid:
                            self.uuids2datafields[uuid] = str(self.highest_datafield_id)
                        self.data['Datafield'][str(self.highest_datafield_id)] = value
                        new_datafield_ids[key] = self.highest_datafield_id
        except Exception as exc:  # pylint: disable=broad-except
            _common.die(f'Invalid basket definition file {basket_file}: {exc}')

        for parent_key, parent_value in basket_data.items():
            if parent_key == 'Datafield':
                # already handled above
                continue
            for key, value in parent_value.items():
                fields = value.get('fields')
                if fields:
                    for field in fields:
                        old_datafield_id = field['datafield_id']
                        field['datafield_id'] = new_datafield_ids[str(old_datafield_id)]
                self.data[parent_key][key] = value

    def validate_uuids(self):
        """Check that every merged object carries a uuid, once.

        Prints a warning for objects without a uuid and aborts
        via `_common.die()` if any uuid is used twice - duplicate
        uuids break the Linuxfabrik Director fork's import.
        """
        uuids = []
        objects_without_uuids = []
        for parent_key, parent_value in self.data.items():
            for key, value in parent_value.items():
                if 'uuid' in value:
                    uuids.append(value['uuid'])
                elif parent_key == 'Datafield':
                    objects_without_uuids.append(
                        f'[{parent_key}][{value["varname"]}] (Datafield)',
                    )
                else:
                    objects_without_uuids.append(f'[{parent_key}][{key}]')
                # descent into services of Service Sets
                services = value.get('services')
                if not services:
                    continue
                for service_key, service_value in services.items():
                    if 'uuid' in service_value:
                        uuids.append(service_value['uuid'])
                    else:
                        objects_without_uuids.append(
                            f'[{parent_key}][{key}][{service_key}] (Service)',
                        )

        if objects_without_uuids:
            _common.err('\nFound objects without uuids:')
            _common.err('* ' + '\n* '.join(objects_without_uuids))

        unique_uuids = set(uuids)
        if len(uuids) != len(unique_uuids):
            for uuid in unique_uuids:
                uuids.remove(uuid)
            duplicates = '\n* '.join(uuids)
            _common.die(f'There are duplicate uuids:\n* {duplicates}')


def join_all(verbose=True):
    """Merge `all-the-rest.json` and every per-plugin basket into one basket.

    Returns the merged basket as a dict. Aborts via `_common.die()` on
    an invalid basket or on duplicate uuids.
    """
    joiner = BasketJoiner(verbose=verbose)
    joiner.join_with_file(ALL_THE_REST_BASKET)
    for family in PLUGIN_FAMILIES:
        for plugin_dir in _common.iter_plugin_dirs(family):
            joiner.join_with_file(
                plugin_dir / 'icingaweb2-module-director' / f'{plugin_dir.name}.json'
            )
    joiner.validate_uuids()
    return dict(joiner.data)


def save_basket(path, data):
    """Write a Director basket JSON file with the project's style, see
    `dump_basket()`.
    """
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(dump_basket(data), encoding='utf-8')
    except OSError as exc:
        _common.die(f'basket: cannot write {path}: {exc}')
