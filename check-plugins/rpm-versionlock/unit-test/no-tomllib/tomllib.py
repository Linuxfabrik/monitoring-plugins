# -*- coding: utf-8; py-indent-offset: 4 -*-
#
# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.

"""Stand-in for the `tomllib` the plugin reads the dnf 5 lock file with.

`tomllib` joined the standard library in Python 3.11, and the plugin ships no backport,
so on an older interpreter it cannot read that file and says so instead of reporting no
locks. Putting this directory on `PYTHONPATH` shadows the real module and makes the
import fail on any interpreter, which is what lets the test assert that answer without
an old Python having to be installed.
"""

raise ImportError('tomllib is not available on this interpreter')
