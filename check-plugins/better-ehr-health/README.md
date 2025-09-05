# Check better-ehr-health

## Overview

Monitoring plugin for Better EHR, querying the JSON health endpoint (for example, `http://server:port/health`).
Supports overriding component states and applying Nagios-style threshold ranges to detail metrics.

Hints:

* Useful for monitoring Better EHR availability and component health.
* Allows fine-grained overrides to adjust alerting behaviour.

## Fact Sheet

| Fact                             | Value                                                                                       |
|----------------------------------|---------------------------------------------------------------------------------------------|
| Check Plugin Download            | https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/better-ehr-health |
| Check Interval Recommendation    | Once a minute                                                                               |
| Can be called without parameters | No                                                                                          |

## Help

```text
usage: better-ehr-health [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                         [--url URL] [--test TEST] [--record-json FILE]
                         [--timeout TIMEOUT]
                         [--override-status COMPONENT:API_STATE:NAGIOS_STATE]
                         [--override-threshold COMPONENT:DETAIL[:WARN[:CRIT]]]
                         [-v]

Monitoring plugin for Better EHR, querying the JSON health endpoint (e.g.
http://server:port/health). Supports overriding component states and applying
Nagios-style threshold ranges to detail metrics.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: True
  --no-proxy            Do not use a proxy. Default: False
  --url URL             Better EHR Health Endpoint. Default:
                        http://localhost:80/health
  --test TEST           For unit tests. Provide a path to a JSON file
                        containing a captured API response.
  --record-json FILE    Write the full fetched JSON (including status_code and
                        response_json) to the given file.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --override-status COMPONENT:API_STATE:NAGIOS_STATE
                        Override mapping from API state to Nagios state.
                        Format: component:api_state:nagios_state Example:
                        diskSpace:DEGRADED:WARN
  --override-threshold COMPONENT:DETAIL[:WARN[:CRIT]]
                        Override threshold check for a component detail.
                        Nagios format: component:detail[:warn[:crit]] Example:
                        diskSpace:free::20000000
  -v, --verbose         Set the verbosity level.
```

## Usage Examples

```bash
./better-ehr-health --url http://server:8080/health
```

```bash
./better-ehr-health --override-status diskSpace:DEGRADED:WARN
```

```bash
./better-ehr-health --override-threshold diskSpace:free::20000000
```

### Output:
```text
[WARNING] overridden from  API Status: UP
Component            ! Status             ! Details                  
---------------------+--------------------+--------------------------
db                   ! UP                 !                          
                     !                    ! database=Oracle          
                     !                    ! validationQuery=isValid()
diskSpace            ! UP                 !                          
                     !                    ! total=61041709056        
                     ! [WARNING]          ! free=35045371904         
                     !                    ! threshold=10485760       
                     !                    ! exists=True              
hikariConnectionPool ! UP                 !                          
                     !                    ! activeConnections=0      
                     !                    ! maxPoolSize=40           
indexStatus          ! GREEN -> [WARNING] !                          
indexSynchronization ! GREEN              !                          
                     !                    ! queuedEntries=0          
                     !                    ! erroredEntries=0         
ping                 ! UP                 !|'diskSpace_free'=35045371904;20;2000000000000000000000;61041709056; 'diskSpace_exists'=1;;;; 'hikariConnectionPool_activeConnections'=0;;;; 'hikariConnectionPool_maxPoolSize'=40;;;; 'indexSynchronization_queuedEntries'=0;;;; 'indexSynchronization_erroredEntries'=0;;;;
```

## States

* Returns **OK**, **WARN**, **CRIT**, or **UNKNOWN** depending on API state, component overrides, and threshold checks.
* `--always-ok` forces the check to always return OK.

## Perfdata / Metrics

Each numeric detail is exposed as perfdata unless explicitly excluded (`threshold`, `total`).

| Name               | Type   | Description             |
| ------------------ | ------ | ----------------------- |
| diskSpace\_free    | Bytes  | Free disk space         |
| diskSpace\_total   | Bytes  | Total disk space        |
| hikari\_activeConn | Number | Active DB connections   |
| ...                | ...    | Other component details |

## Troubleshooting

**Error:** Connection refused
**Solution:** Verify Better EHR endpoint is reachable and correct URL is provided with `--url`.

**Error:** SSL error
**Solution:** Use `--insecure` for testing, but configure proper certificates in production.

## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
