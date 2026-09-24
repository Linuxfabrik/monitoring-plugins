#!/usr/bin/env python3
# -*- coding: utf-8; py-indent-offset: 4 -*-
#
# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.

"""Check the bytecode a package ships in its venv.

Run it with the interpreter of the installed venv, as the unprivileged monitoring user.
Exits 1 if any .pyc is corrupt or out of date:

* A corrupt .pyc that matches its source is loaded and breaks every plugin importing the
  module ("EOFError: marshal data too short", #1543). One that does not match is ignored
  today, but the next build may happen to match it, so any corrupt file fails the check.
* An out-of-date .pyc is ignored by Python. The monitoring user cannot write a new one
  into the venv, so every check run compiles the module again.

Handles both invalidation modes: timestamp-based files (the RPM build) and hash-based
ones, which the Debian build writes because debhelper sets SOURCE_DATE_EPOCH.
"""

import importlib.util
import marshal
import os
import sys


def is_up_to_date(data, source):
    """Tell whether Python would use a .pyc with this content for this source file."""
    if data[:4] != importlib.util.MAGIC_NUMBER:
        return False
    flags = int.from_bytes(data[4:8], 'little')
    if flags & 0b01:
        # hash-based; without the check_source bit, Python uses it unconditionally
        if not flags & 0b10:
            return True
        with open(source, 'rb') as f:
            return importlib.util.source_hash(f.read()) == data[8:16]
    stat = os.stat(source)
    return (
        int.from_bytes(data[8:12], 'little') == int(stat.st_mtime) & 0xFFFFFFFF
        and int.from_bytes(data[12:16], 'little') == stat.st_size & 0xFFFFFFFF
    )


def main():
    corrupt = []
    outdated = []
    total = 0
    for dirpath, _, filenames in os.walk(os.path.join(sys.prefix, 'lib')):
        if os.path.basename(dirpath) != '__pycache__':
            continue
        for filename in sorted(filenames):
            if not filename.endswith('.pyc'):
                continue
            pyc = os.path.join(dirpath, filename)
            source = os.path.join(
                os.path.dirname(dirpath),
                filename.split('.')[0] + '.py',
            )
            if not os.path.isfile(source):
                continue
            total += 1
            with open(pyc, 'rb') as f:
                data = f.read()
            try:
                # the bytecode the package ships, not input from anyone else
                marshal.loads(data[16:])  # nosec B302
            # besides EOFError and ValueError, a mangled code object can raise
            # SystemError ("bad argument to internal function") or TypeError
            except Exception as e:
                corrupt.append(f'{pyc}: {e}')
                continue
            if not is_up_to_date(data, source):
                outdated.append(pyc)

    for line in corrupt:
        print(f'corrupt: {line}')
    for pyc in outdated:
        print(f'out of date: {pyc}')
    print(f'{total} .pyc checked, {len(corrupt)} corrupt, {len(outdated)} out of date')
    if total == 0 or corrupt or outdated:
        sys.exit(1)


if __name__ == '__main__':
    main()
