# Check "file-count" - Overview

Checks the number of matching files or directories found. It can be also used to check the existence / absence of a single file. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.
It supports glob in accordance with https://docs.python.org/3/library/pathlib.html#pathlib.Path.glob (python3) or https://docs.python.org/2.7/library/glob.html (python2).
Beware that using recursive globs might cause high memory usage.
Also note that there are small differences in recursive file matching between python2 and python3.
Optionally, the check can be restricted to only consider files that were modified in a given timerange.

We recommend to run this check every minute.


# Installation and Usage

```bash
# check the existence of a file; if missing warn
./file-count --filename '/path/to/file' --warning 1

# check the absence of a file; if present warn
./file-count --filename '/path/to/file' --warning '~:0'

# check that there are at least 5 `.md` files, else warn
./file-count --filename '/path/to/*.md' --warning 5

# check that there are at least 5 files modified in the last 10 seconds, else warn
./file-count --filename '/path/to/file/*' --warning 5 --timerange 5 

./file-count --help
```


# States

tbd


# Perfdata

tbd


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
