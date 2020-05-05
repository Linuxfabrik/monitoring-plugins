#! /usr/bin/env python2
# -*- encoding: utf-8; py-indent-offset: 4 -*-
#
# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.

# https://git.linuxfabrik.ch/linuxfabrik-icinga-plugins/checks-linux/-/blob/master/CONTRIBUTING.md

__author__ = 'Linuxfabrik GmbH, Zurich/Switzerland'
__version__ = '2020050101'

DESCRIPTION = 'Warns on the newest feed item of an RSS or Atom feed for a given amount of time.'

DEFAULT_FEED_URL = 'https://www.heise.de/security/rss/alert-news-atom.xml'
DEFAULT_NO_SUMMARY = False
DEFAULT_WARN = 96*60  # 96h in minutes


#====================
from lib.globals import *

import lib.base
import lib.icinga

import argparse
import time
from traceback import print_exc


def parse_args():
    parser = argparse.ArgumentParser(description=DESCRIPTION)

    parser.add_argument('-V', '--version',
        action='version',
        version='{0}: v{1} by {2}'.format('%(prog)s', __version__, __author__)
        )

    parser.add_argument('--always-ok',
        help='Always returns OK.',
        dest='ALWAYS_OK',
        action='store_true',
        default=False,
        )

    parser.add_argument('--no-summary',
        help='Do not show the feed item summary. Default: %(default)s',
        dest='NO_SUMMARY',
        action='store_true',
        default=DEFAULT_NO_SUMMARY,   # False
        )

    parser.add_argument('--icinga-service-name',
        help='Unique name of the service using this check within Icinga. Take it from the `__name` service attribute, for example `icinga-server!Feed: Heise Security`.',
        dest='ICINGA_SERVICE_NAME',
        required=True,
        )

    parser.add_argument('--icinga-password',
        help='Icinga API password.',
        dest='ICINGA_PASSWORD',
        required=True,
        )

    parser.add_argument('--icinga-url',
        help='Icinga API URL, for example https://icinga-server:5665',
        dest='ICINGA_URL',
        required=True,
        )

    parser.add_argument('--icinga-username',
        help='Icinga API username.',
        dest='ICINGA_USERNAME',
        required=True,
        )

    parser.add_argument('--url',
        help='The Feed URL. Default: %(default)s',
        dest='FEED_URL',
        default=DEFAULT_FEED_URL,
        )

    parser.add_argument('-w', '--warning',
        help='How long should this check return a warning on new entries? Default: %(default)s (minutes)',
        dest='WARN',
        type=int,
        default=DEFAULT_WARN,
        )
    
    return parser.parse_args()


def fetch_feed_last_entry(feed_url):
    # got this function from https://github.com/jrottenberg/check_rss/blob/master/check_rss.py
    try:
        myfeed = feedparser.parse(feed_url)
    except:
        lib.base.oao('Could not parse URL (%s)' % feed_url, STATE_UNKNOWN)

    # slightly enhanced
    if ('status' not in myfeed):
        lib.base.oao('HTTP Error, maybe wrong URL', STATE_UNKNOWN)

    if (myfeed.status != 200):
        lib.base.oao('Status %s - %s' % (myfeed.status, myfeed.feed.summary), STATE_UNKNOWN)

    # feed with 0 entries is good too
    if (len(myfeed.entries) == 0): 
        lib.base.oao('No news are good news.', STATE_OK)
    
    return myfeed.entries[0]


def main():
    # parse the command line, exit with UNKNOWN if it fails
    try:
        args = parse_args()
    except SystemExit as e:
        exit(STATE_UNKNOWN)

    # lets have a look if the check shows a warning and/or was acknowledged
    result = lib.base.coe(lib.icinga.get_service(args.ICINGA_URL, args.ICINGA_USERNAME, args.ICINGA_PASSWORD, servicename=args.ICINGA_SERVICE_NAME, attrs='acknowledgement,state'))
    print(result['results'][0]['attrs'])
    print('--------')



    result = lib.base.coe(lib.icinga.remove_ack(args.ICINGA_URL, args.ICINGA_USERNAME, args.ICINGA_PASSWORD, objectname='p1-db01.linuxfabrik.it!XCA - net74'))
    print(result)
    print('--------')

    result = lib.base.coe(lib.icinga.remove_ack(args.ICINGA_URL, args.ICINGA_USERNAME, args.ICINGA_PASSWORD, objectname='p1-cloud01.linuxfabrik.it!Nextcloud Stats'))
    print(result)
    print('--------')


    exit()


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print_exc()
        exit(STATE_UNKNOWN)
