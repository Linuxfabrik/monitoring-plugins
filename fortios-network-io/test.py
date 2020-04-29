#! /usr/bin/env python2
# -*- encoding: utf-8; py-indent-offset: 4 -*-
#
# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.

# https://git.linuxfabrik.ch/linuxfabrik-icinga-plugins/checks-linux/-/blob/master/CONTRIBUTING.md

__author__  = 'Linuxfabrik GmbH, Zurich/Switzerland'
__version__ = '2020042401'

DESCRIPTION = ''

DEFAULT_INSECURE = False
DEFAULT_NO_PROXY = False
DEFAULT_COUNT    = 5       # measurements; if check runs once per minute, this is a 5 minute interval
DEFAULT_TIMEOUT  = 3


#====================
from lib.globals import *

import lib.base
import lib.db_sqlite
import lib.url

import argparse
from traceback import print_exc


def parse_args():
    parser = argparse.ArgumentParser(description=DESCRIPTION)

    parser.add_argument('-V', '--version',
        action = 'version',
        version = '{0}: v{1} by {2}'.format('%(prog)s', __version__, __author__)
        )

    parser.add_argument('--always-ok',
        help = 'Always returns OK.',
        dest = 'ALWAYS_OK',
        action = 'store_true',
        default = False,
        )

    parser.add_argument('--count',
        help = 'Number of times the value has to be above the given thresholds. Default: %(default)s',
        dest = 'COUNT',
        type = int,
        default = DEFAULT_COUNT,
        )
    
    parser.add_argument('-H', '--hostname', 
        help = 'FortiOS-based Appliance address.',
        dest = 'HOSTNAME',
        required = True,
        )

    parser.add_argument('--insecure',
        help = 'This option explicitly allows to perform "insecure" SSL connections. Default: %(default)s',
        dest = 'INSECURE',
        action = 'store_true',
        default = DEFAULT_INSECURE,
        )

    parser.add_argument('--no-proxy',
        help = 'Do not use a proxy. Default: %(default)s',
        dest = 'NO_PROXY',
        action = 'store_true',
        default = DEFAULT_NO_PROXY,
        )

    parser.add_argument('--password',
        help = 'FortiOS REST API Single Access Token.',
        dest = 'PASSWORD',
        required = True,
        )

    parser.add_argument('--timeout',
        help = 'Network timeout in seconds. Default: %(default)s (seconds)',
        dest = 'TIMEOUT',
        type = int,
        default = DEFAULT_TIMEOUT,
        )

    return parser.parse_args()


def get_interface_states_from_db(conn, interface):
    return lib.db_sqlite.select(conn, 
        '''
        SELECT *
        FROM state
        WHERE interface = :interface
        ''',
        {'interface': interface},
        fetchone=True
    )


def main():

    conn = lib.base.coe(lib.db_sqlite.connect(filename='fortios-network-io.db'))
    print(lib.db_sqlite.compute_load(conn, sensorcol='interface', datacols=['tx_bytes', 'rx_bytes'], table='perfdata'))



if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print_exc()
        exit(STATE_UNKNOWN)
