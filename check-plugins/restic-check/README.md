# Check restic-check

## Overview

This check command tests the restic repository for errors and reports any errors it finds. In contrast to the `restic check` sub-command it cannot be used to read all data and therefore simulate a restore.

`restic-check` will always load all data directly from the repository and not use a local cache, so take into account that this might take several minutes to execute, especially if the restic repository is corrupted.

Refer to the [online manual](https://restic.readthedocs.io/en/latest/index.html) for more details about restic.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/restic-check> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |


## Help

```text
usage: restic-check [-h] [-V] [--password-file PASSWORD_FILE] --repo REPO
                    [--test TEST]

Check the restic repository for errors.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --password-file PASSWORD_FILE
                        File to read the repository password from
  --repo REPO           Repository location
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
```


## Usage Examples

```bash
./restic-check --repo=/path/to/restic-repo --password-file=/path/to/restic-pwd
```

Output:

```text
There are warnings.

pack 74f3c4c9: does not exist
pack 590110aa: does not exist
pack 3a551e0f: does not exist
pack 1c9901af: does not exist
pack e577c6b0: does not exist
...
Load(<data/74f3c4c9f6>, 484, 616018) returned error, retrying after 13.811796615s: open /path/to/restic-repo/data/74/74f3c4c9f6d2c5d2d85acd07b7c72dc53926002f234fb4f8e161e51e2cd67ab7: no such file or directory
error for tree 5e730b1a:
  ReadFull(<data/74f3c4c9f6>): open /path/to/restic-repo/data/74/74f3c4c9f6d2c5d2d85acd07b7c72dc53926002f234fb4f8e161e51e2cd67ab7: no such file or directory
Fatal: repository contains errors
```


## States

* WARN if exit status of `restic check` != 0
* WARN if output of `restic check` does not contain `no errors`


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
