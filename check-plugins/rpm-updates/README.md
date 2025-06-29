# Check rpm-updates

## Overview

Displays available updates, including a list of advisories about newer versions of installed packages. For these advisories, the plugin takes only the latest installed versions of packages into account. In case of the kernel packages (when multiple version could be installed simultaneously) also packages of the currently running version of kernel are added. This plugin only lists updates and upgrades and provides relevant alerts. It never actually runs an update.

Plugin execution may take more than 10 seconds.

The plugin stores all relevant information in a local SQLite database. For the `--query` parameter, the following database columns can be used (see examples below):

* package (TEXT)
* arch (TEXT)
* version_installed (TEXT)
* repo_installed (TEXT)
* version_upgrade (TEXT)
* repo_upgrade (TEXT)

Example content of the `list` table:

```text
package              ! arch   ! version_installed       ! repo_installed ! version_upgrade         ! repo_upgrade
---------------------+--------+-------------------------+----------------+-------------------------+-------------
NetworkManager       ! x86_64 ! 1:1.40.16-9             ! @anaconda      ! 1:1.40.16-19            ! baseos      
NetworkManager-libnm ! x86_64 ! 1:1.40.16-9             ! @anaconda      ! 1:1.40.16-19            ! baseos      
acl                  ! x86_64 ! 2.2.53-1.el8            ! @anaconda      ! 2.2.53-3                ! baseos      
audit                ! x86_64 ! 3.0.7-5                 ! @anaconda      ! 3.1.2-1                 ! baseos      
autoconf             ! noarch ! 2.69-29                 ! @appstream     ! 2.69-29.el8_10          ! appstream   
bash                 ! x86_64 ! 4.4.20-4                ! @anaconda      ! 4.4.20-5                ! baseos      
bind-libs            ! x86_64 ! 32:9.11.36-11           ! @appstream     ! 32:9.11.36-16.el8_10    ! appstream   
binutils             ! x86_64 ! 2.30-123                ! @baseos        ! 2.30-125                ! baseos      
bzip2-libs           ! x86_64 ! 1.0.6-26                ! @anaconda      ! 1.0.6-28                ! baseos      
c-ares               ! x86_64 ! 1.13.0-9.el8_9          ! @anaconda      ! 1.13.0-11               ! baseos      
ca-certificates      ! noarch ! 2023.2.60_v7.0.306-80.0 ! @anaconda      ! 2024.2.69_v8.0.303-80.0 ! baseos      
chrony               ! x86_64 ! 4.2-1.el8.rocky.1       ! @anaconda      ! 4.5-2                   ! baseos      
cmake                ! x86_64 ! 3.20.2-5                ! @appstream     ! 3.26.5-2                ! appstream   
cpp                  ! x86_64 ! 8.5.0-20                ! @appstream     ! 8.5.0-26                ! appstream   
cronie               ! x86_64 ! 1.5.2-8                 ! @anaconda      ! 1.5.2-10                ! baseos      
cronie-anacron       ! x86_64 ! 1.5.2-8                 ! @anaconda      ! 1.5.2-10                ! baseos      
curl                 ! x86_64 ! 7.61.1-33               ! @anaconda      ! 7.61.1-34.el8_10        ! baseos      
dracut               ! x86_64 ! 049-228.git20230802     ! @anaconda      ! 049-233.git20240115     ! baseos  
```

The 'Type' column in the output lists the type of update for each intermediate version. For example, the abbreviation 'BSEB' indicates that there are four available versions: a bug fix release, a security release, an enhancement release and another bug fix release. The meaning of the abbreviations is:

* B: Bugfix
* E: Enhancement
* S: Security
* U: Unspecified
* no character: unknown


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rpm-updates> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-rpm-updates.db` |


## Help

```text
usage: rpm-updates [-h] [-V] [--always-ok] [--only-critical] [--query QUERY]
                   [--timeout TIMEOUT] [-w WARN]

Displays available updates, including a list of advisories about newer
versions of installed packages. For these advisories, the plugin takes only
the latest installed versions of packages into account. In case of the kernel
packages (when multiple version could be installed simultaneously) also
packages of the currently running version of kernel are added. This plugin
only lists updates and upgrades and provides relevant alerts. It never
actually runs an update.

options:
  -h, --help          show this help message and exit
  -V, --version       show program's version number and exit
  --always-ok         Always returns OK.
  --only-critical     Only collect critical updates and upgrades.
  --query QUERY       The list of available updates and upgrades is stored in
                      a SQL table. Provide the SQL `WHEN` statement part to
                      narrow down results. Example: `--query='package like
                      "bind9-%"'`. Also supports regular expressions via a
                      REGEXP statement. Have a look at the README for a list
                      of available columns. If this parameter is used, a list
                      of matching updates is printed. Default: 1
  --timeout TIMEOUT   Plugin timeout in seconds. Default: 120 (seconds)
  -w, --warning WARN  Minimum number of packages to return WARNING. Default:
                      1.
```


## Usage Examples

```bash
./rpm-updates --only-critical --query='package in ("audit", "bind-utils", "gcc-c++")'
```

Output:

```text
30 updates available. [WARNING]

Package    ! Installed     ! Upgrade to           ! Type 
-----------+---------------+----------------------+------
audit      ! 3.0.7-5       ! 3.1.2-1              ! B    
bind-utils ! 32:9.11.36-11 ! 32:9.11.36-16.el8_10 !      
gcc-c++    ! 8.5.0-20      ! 8.5.0-26             ! BSB  
```


## States

* WARN if the number of updatable packages exceeds the specified threshold value


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| updates | Number | Number of updatable packages matching the current `--query`. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
