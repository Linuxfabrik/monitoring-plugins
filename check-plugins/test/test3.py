#! /usr/bin/env python3
# -*- coding: utf-8; py-indent-offset: 4 -*-
#
# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.

# https://git.linuxfabrik.ch/linuxfabrik-icinga-plugins/checks-linux/-/blob/master/CONTRIBUTING.md

"""Have a look at the check's README for further details.
"""

import os

# considering a virtual environment
ACTIVATE_THIS = False
venv_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'monitoring-plugins-venv3')
if os.path.exists(venv_path):
    ACTIVATE_THIS = os.path.join(venv_path, 'bin/activate_this.py')

if os.getenv('MONITORING_PLUGINS_VENV3'):
    ACTIVATE_THIS = os.path.join(os.getenv('MONITORING_PLUGINS_VENV3') + 'bin/activate_this.py')

if ACTIVATE_THIS and os.path.isfile(ACTIVATE_THIS):
    exec(open(ACTIVATE_THIS).read(), {'__file__': ACTIVATE_THIS}) # pylint: disable=W0122


import argparse # pylint: disable=C0413
import sys # pylint: disable=C0413

import lib.args3 # pylint: disable=C0413
import lib.base3 # pylint: disable=C0413
import lib.shell3 # pylint: disable=C0413
import lib.test3 # pylint: disable=C0413
from lib.globals3 import STATE_CRIT, STATE_OK, STATE_UNKNOWN, STATE_WARN # pylint: disable=C0413

__author__ = 'Linuxfabrik GmbH, Zurich/Switzerland'
__version__ = '2022021501'

DESCRIPTION = """A working Linuxfabrik monitoring plugin, written in Python 3, as a basis for
                further development, and much more text to help admins get this check up and
                running."""

DEFAULT_WARN = 80
DEFAULT_CRIT = 90


def parse_args():
    """Parse command line arguments using argparse.
    """
    parser = argparse.ArgumentParser(description=DESCRIPTION)

    parser.add_argument(
        '-V', '--version',
        action='version',
        version='%(prog)s: v{} by {}'.format(__version__, __author__)
    )

    parser.add_argument(
        '--always-ok',
        help='Always returns OK.',
        dest='ALWAYS_OK',
        action='store_true',
        default=False,
    )

    return parser.parse_args()


def main():
    """The main function. Hier spielt die Musik.
    """

    # parse the command line, exit with UNKNOWN if it fails
    try:
        args = parse_args()
    except SystemExit:
        sys.exit(STATE_UNKNOWN)

    # fetch data
    cmd = 'dmesg   --level emerg,alert,crit,err --ctime   '
    cmd = '. /etc/os-release && echo $NAME $VERSION'
    print(lib.shell3.shell_exec(cmd, shell=True)) 
    exit()
    stdout, stderr, retc = lib.base3.coe(lib.shell3.run_cmd(cmd)) # pylint: disable=W0612
    if stderr:
        lib.base3.oao('{}'.format(stderr), STATE_UNKNOWN)


if __name__ == '__main__':
    try:
        main()
    except Exception:   # pylint: disable=W0703
        lib.base3.cu()
