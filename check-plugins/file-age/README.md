# Check "file-age" - Overview

Checks the time of last data modification for a file or directory, in seconds. The plugin is able to follow symlinks. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.
It supports glob in accordance with https://docs.python.org/3/library/pathlib.html#pathlib.Path.glob (python3) or https://docs.python.org/2.7/library/glob.html (python2).
Beware that using recursive globs might cause high memory usage.
Also note that there are small differences in recursive file matching between python2 and python3.

We recommend to run this check every minute.


# Installation and Usage

```bash
# file is more than 5 seconds old -> warning
# file is more than 10 seconds old -> critical
./file-age --filename '/path/to/file' --warning 5 --critical 10

# same thresholds, but checking multiple files
./file-age --filename '/path/to/files/*' --warning 5 --critical 10

# same thresholds, but recursive (might use a lot of memory)
./file-age --filename '/path/to/files/**/*' --warning 5 --critical 10

./file-age --help
```


# States

tbd


# Perfdata

tbd


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
