# Check spring-boot-actuator-health

## Overview

This is a monitoring plugin for any application implementing the [Spring Boot Rest API Actuator](https://docs.spring.io/spring-boot/api/rest/actuator/health.html) `/health` endpoint. It supports fine-grained overrides to adjust alerting behaviour and applying Nagios-style threshold ranges to detailed numeric metrics.

If not overridden, the status from the health endpoint map to Nagios states as follows:

* UP, GREEN > OK
* DEGRADED, YELLOW > WARN
* DOWN and all other > CRIT

Hints:

* Tested with Better EHR
* Tested with petclinic


## Fact Sheet

| Fact                             | Value                                                                                       |
|----------------------------------|---------------------------------------------------------------------------------------------|
| Check Plugin Download            | https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/spring-boot-actuator-health |
| Check Interval Recommendation    | Once a minute                                                                               |
| Can be called without parameters | Yes                                                                                         |


## Help

```text
usage: spring-boot-actuator-health [-h] [-V] [--always-ok]
                                   [--component-severity COMPONENT_NAME,API_STATUS,NAGIOS_STATE]
                                   [--detail-severity COMPONENT_NAME,DETAIL_NAME,WARN,CRIT]
                                   [--insecure] [--no-proxy] [--test TEST]
                                   [--timeout TIMEOUT] [--url URL] [--verbose]

This is a monitoring plugin for the Spring Boot Actuator `/health` endpoint
(e.g. http://localhost:port/actuator/health/db). It supports fine-grained
overrides to adjust alerting behaviour and applying Nagios-style threshold
ranges to detailed numeric metrics.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --component-severity COMPONENT_NAME,API_STATUS,NAGIOS_STATE
                        Set the API status for a specific component like `UP`,
                        `DEGRADED` and `DOWN` to a Nagios state, where Nagios
                        state is one of `ok`, `warn`, `crit` or `unknown`
                        (repeating). Format: `component-name,api-
                        status,nagios-state`. Example:
                        `hikariConnectionPool,DEGRADED,crit`
  --detail-severity COMPONENT_NAME,DETAIL_NAME,WARN,CRIT
                        Set a threshold for a *numeric* component detail value
                        (repeating). Supports Nagios ranges. Format:
                        `component-name,detail-name,warn,crit`. Example:
                        `hikariConnectionPool,activeConnections,@10:20,@0:9`
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: False
  --no-proxy            Do not use a proxy. Default: False
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             Spring Boot Actuator Health Endpoint, for example
                        http://server:80/health/diskSpace. Default:
                        http://localhost:80/health
  --verbose             Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what's going on under the
                        hood. Default: False
```


## Usage Examples

```bash
./spring-boot-actuator-health --url=http://localhost:9966/petclinic/actuator/health
```

```bash
./spring-boot-actuator-health --url=http://localhost:9966/petclinic/actuator/health/diskSpace
```

```bash
./spring-boot-actuator-health \
    --url=http://localhost:9966/petclinic/actuator/health \
    --component-severity=db,DEGRADED,crit
```

```bash
./spring-boot-actuator-health \
    --url=http://localhost:9966/petclinic/actuator/health \
    --component-severity=diskSpace,DEGRADED,crit \
    --detail-severity=diskSpace,free,100000000,200000000 \
    --detail-severity=hikariConnectionPool,activeConnections,@10:20,@0:9
```


### Output:

```text
Overall status of the application: UP, API Status Code: 200 [CRITICAL]

Component ! Status ! State
----------+--------+------
db        ! UP     ! [OK] 
diskSpace ! UP     ! [OK] 
ping      ! UP     ! [OK] 
ssl       ! UP     ! [OK]

Component ! Detail          ! value                               ! State     
----------+-----------------+-------------------------------------+-----------
db        ! database        ! PostgreSQL                          ! [OK]      
db        ! validationQuery ! isValid()                           ! [OK]      
diskSpace ! total           ! 1998678130688                       ! [OK]      
diskSpace ! free            ! 1086117941248 > 100000000,200000000 ! [CRITICAL]
diskSpace ! threshold       ! 10485760                            ! [OK]      
diskSpace ! path            ! /.                                  ! [OK]      
diskSpace ! exists          ! True                                ! [OK]      
ssl       ! validChains     ! []                                  ! [OK]      
ssl       ! invalidChains   ! []                                  ! [OK]
```


## States

* Returns WARN on HTTP status code >= 300
* Returns CRIT if overall application status is DOWN
* Returns OK, WARN, CRIT or UNKNOWN depending on API state, component or component details states.
* `--always-ok` forces the check to always return OK.


## Perfdata / Metrics

Each *numeric*  component detail value is exposed as perfdata.

| Name              | Type   | Description             |
| ----------------- | ------ | ----------------------- |
| diskSpace_free    | Bytes  | Free disk space         |
| diskSpace_total   | Bytes  | Total disk space        |
| hikariConnectionPool_activeConnections | Number | Active DB connections   |
| ...               | ...    | Other component details |


## Development

For testing purposes, install a Spring Boot Actuator application providing a `/health` endpoint. For example:

```bash
podman rm -f petclinic pg >/dev/null 2>&1 || true

podman run -d --name pg --network pcnet -p 5432:5432 \
  -e POSTGRES_DB=petclinic \
  -e POSTGRES_USER=petclinic \
  -e POSTGRES_PASSWORD=petclinic \
  docker.io/library/postgres:16

sleep 10

podman run -d --name petclinic --network pcnet -p 9966:9966 \
  -e SPRING_PROFILES_ACTIVE=postgres,spring-data-jpa \
  -e spring.datasource.url="jdbc:postgresql://pg:5432/petclinic" \
  -e spring.datasource.username=petclinic \
  -e spring.datasource.password=petclinic \
  -e MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info \
  -e MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS=always \
  -e MANAGEMENT_ENDPOINT_HEALTH_SHOW_COMPONENTS=always \
  docker.io/springcommunity/spring-petclinic-rest

sleep 5

curl http://localhost:9966/petclinic/actuator/health
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
