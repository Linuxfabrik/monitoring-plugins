# Check csv-values

## Overview

Imports a CSV file (local, remote via URL, or from an SMB share) into a temporary SQLite database and runs configurable SQL queries against it. Separate queries can be defined for warning and critical conditions. The query result - either a row count or a specific value - is checked against Nagios range expressions. This makes it possible to monitor any data source that can export CSV.

**Data Collection:**

* Reads CSV data from the local filesystem (`--filename`), from an HTTP/HTTPS URL (`--url`), or from an SMB share (`--url=smb://...`)
* HTTP and SMB sources support authentication via `--username` and `--password`
* The CSV data is imported into a local SQLite database table named `data`
* Column names and types are defined via `--columns-query` using SQLite `CREATE TABLE` syntax (the actual CSV header names are irrelevant, columns are mapped positionally)
* Large CSV files are handled in chunks (`--chunksize`, default: 1000 rows) to avoid memory exhaustion
* Warning and critical SQL queries are executed independently against the `data` table
* If a query returns one row with one column, that single value is checked against the threshold; otherwise the row count is checked
* Result tables with more than 10 rows are truncated to the first 5 and last 5 entries

**Compatibility:**

* Cross-platform

**Important Notes:**

* `--filename` and `--url` are mutually exclusive
* At least one of `--warning-query` or `--critical-query` must be provided
* The `data` table has no `PRIMARY KEY` and no constraints; the default value for each column is `NULL`, the default collation is `BINARY`
* Useful SQLite column datatypes: `TEXT`, `NUMERIC`, `INTEGER`, `REAL`, and SQLite 3.31.0+ generated columns

As an example, consider a simple CSV list of clients:

```text
PC-Hostname, Waiting Updates
alice,        3
bob,         11
charlie,      5
david,        7
erin,         0
frank,        6
```

The use case: Issue a warning when the number of clients with 5 or more waiting updates is greater than 2.

First you need to tell `csv-values` the structure/data types of your CSV file like in the SQLite `CREATE TABLE` format. Important: The names of the the columns in the CSV file don't matter, you simply define names for the columns in the SQLite database. `csv-values` simply goes through the CSV file column by column and creates the columns specified here in the SQLite database. The names specified are therefore only important for the subsequent SQL queries.

```text
Hostname TEXT, WaitingUpdates INTEGER
```

One possible SQL statement for getting the number of clients with 5 or more waiting updates is:

```text
select *
from data
where WaitingUpdates >= 5
```

In the above example, 4 *rows* are returned, so `csv-values` checks the number of rows against the given threshold.

You also may count the number of clients directly, which just returns one row with a value of `4` in one column:

```text
select count(*) as cnt
from data
where WaitingUpdates >= 5
```

In this case, `csv-values` checks the returned value `4` with the specified threshold.

The full command line call describing the columns, retrieving the data and applying the thresholds (which are [ranges](https://github.com/Linuxfabrik/monitoring-plugins#threshold-and-ranges)) is:

```bash
csv-values \
    --filename path/to/hosts-with-waiting-updates.csv \
    --columns-query='Hostname TEXT, WaitingUpdates INTEGER' \
    --warning-query='select * from data where WaitingUpdates >= 5' \
    --warning=2
```

Helpful resources:

* SQLite Tutorial: <https://www.sqlitetutorial.net>
* SQLite Documentation: <https://www.sqlite.org/doclist.html>


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/csv-values> |
| Nagios/Icinga Check Name              | `check_csv_values` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--columns-query` and at least one query are required) |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `PySmbClient`, `smbprotocol` (only for SMB access) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-csv-values-*.db` |


## Help

```text
usage: csv-values [-h] [-V] [--always-ok] [--chunksize CHUNKSIZE]
                  --columns-query COLUMNS_QUERY [-c CRIT]
                  [--critical-query CRITICAL_QUERY] [--delimiter DELIMITER]
                  [--filename FILENAME] [--insecure] [--newline NEWLINE]
                  [--no-proxy] [--password PASSWORD] [--quotechar QUOTECHAR]
                  [--skip-header] [--timeout TIMEOUT] [-u URL]
                  [--username USERNAME] [-w WARN]
                  [--warning-query WARNING_QUERY]

Imports a CSV file (local, remote via URL, or from an SMB share) into a
temporary SQLite database and runs configurable SQL queries against it.
Separate queries can be defined for warning and critical conditions. The query
result - either a row count or a specific value - is checked against Nagios
range expressions. This makes it possible to monitor any data source that can
export CSV.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --chunksize CHUNKSIZE
                        Breaks up the transfer of data from the csv to the
                        SQLite database in chunks as to not run out of memory.
                        Default: 1000
  --columns-query COLUMNS_QUERY
                        Describe the columns and their datatypes using an sql
                        statement. Example: `"col1 INTEGER PRIMARY KEY, col2
                        TEXT NOT NULL, col3 TEXT NOT NULL UNIQUE"`
  -c, --critical CRIT   CRIT threshold. Supports ranges.
  --critical-query CRITICAL_QUERY
                        `SELECT` statement. If its result contains more than
                        one column, the number of rows is checked against
                        `--critical`, otherwise the single value is used.
  --delimiter DELIMITER
                        CSV delimiter. Default: `","`.
  --filename FILENAME   Path to CSV file. Mutually exclusive with --url.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --newline NEWLINE     CSV newline. When reading input from the CSV, if
                        newline is `None`, universal newlines mode is enabled.
                        Lines in the input can end in `" "`, `" "`, or `" "`,
                        and these are translated into `" "` before being
                        returned to this plugin. If it is `""`, universal
                        newlines mode is enabled, but line endings are
                        returned to this plugin untranslated. If it has any of
                        the other legal values, input lines are only
                        terminated by the given string, and the line ending is
                        returned to this plugin untranslated. Default: None
  --no-proxy            Do not use a proxy.
  --password PASSWORD   SMB or HTTP Basic Auth Password.
  --quotechar QUOTECHAR
                        CSV quotechar. Default: `"`.
  --skip-header         Treat the first row as header names, and skip this
                        row. Default: False
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         URL of the CSV file, either starting with "http://",
                        "https://" or "smb://". This is mutually exclusive
                        with --filename.
  --username USERNAME   SMB or HTTP Basic Auth Username.
  -w, --warning WARN    WARN threshold. Supports ranges.
  --warning-query WARNING_QUERY
                        `SELECT` statement. If its result contains more than
                        one column, the number of rows is checked against
                        `--warning`, otherwise the single value is used.
```


## Usage Examples

Local CSV file (example):

```bash
cat > /tmp/example.csv << 'EOF'
Date,Network,Hostname,WaitingUpdates
2023-01-01,A,alice,0
2023-01-01,A,bob,1
2023-01-01,A,charlie,2
2023-01-01,A,david,3
2023-01-01,A,erin,4
2023-01-01,A,faythe,5
2023-01-01,A,frank,6
2023-01-01,A,grace,7
2023-01-01,A,heidi,8
2023-01-01,A,ivan,9
2023-01-01,A,judy,10
2023-01-01,B,mallory,0
2023-01-01,B,michael,1
2023-01-01,B,niaj,2
2023-01-01,B,olivia,3
2023-01-01,B,oscar,4
2023-01-01,B,peggy,5
2023-01-01,B,rupert,6
2023-01-01,B,sybil,7
2023-01-01,C,trent,0
2023-01-01,C,trudy,1
2023-01-01,C,victor,2
2023-01-01,C,walter,3
2023-01-01,C,wendy,4
EOF
```

Checking this local CSV file: WARN if more than 6 hosts in network A have more than 3 waiting updates, and CRIT if more than 2 hosts in networks B and C have more than 4 waiting updates:

```bash
./csv-values \
    --filename=tmp/example.csv \
    --columns-query='date TEXT, network TEXT, hostname TEXT, waitingupdates INTEGER' \
    --warning-query='select * from data where network = "A" and WaitingUpdates > 3' \
    --warning=6 \
    --critical-query='select * from data where network <> "A" and WaitingUpdates > 4' \
    --critical=2 \
    --skip-header
```

Output:

```text
7 results from warning query `select * from data where network = "A" and WaitingUpdates > 3` [WARNING] and 3 results from critical query `select * from data where network <> "A" and WaitingUpdates > 4` [CRITICAL]

date       ! network ! hostname ! waitingupdates 
-----------+---------+----------+----------------
2023-01-01 ! A       ! erin     ! 4              
2023-01-01 ! A       ! faythe   ! 5              
2023-01-01 ! A       ! frank    ! 6              
2023-01-01 ! A       ! grace    ! 7              
2023-01-01 ! A       ! heidi    ! 8              
2023-01-01 ! A       ! ivan     ! 9              
2023-01-01 ! A       ! judy     ! 10             

date       ! network ! hostname ! waitingupdates 
-----------+---------+----------+----------------
2023-01-01 ! B       ! peggy    ! 5              
2023-01-01 ! B       ! rupert   ! 6              
2023-01-01 ! B       ! sybil    ! 7
```

Checking a remote CSV file on a webserver, plus HTTP basic authentication:

```bash
./csv-values \
    --url=http://example.com/example.csv \
    --username=user \
    --password=linuxfabrik
    ...
```

Checking a remote CSV file on a (not-mounted) samba/cifs share, plus authentication:

```bash
./csv-values \
    --url=smb://example.com/share/example.csv \
    --username=user \
    --password=linuxfabrik
    ...
```


## States

* OK if both query results are within their respective threshold ranges.
* WARN if the row count or single value of `--warning-query` is outside the `--warning` range.
* CRIT if the row count or single value of `--critical-query` is outside the `--critical` range.
* UNKNOWN if no queries are provided, or if `--filename` and `--url` are both specified, or if the URL protocol is unsupported.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cnt_crit | Number | Row count or single value returned by `--critical-query`. |
| cnt_warn | Number | Row count or single value returned by `--warning-query`. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
