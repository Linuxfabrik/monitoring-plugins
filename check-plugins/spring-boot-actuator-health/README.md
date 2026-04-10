# Check spring-boot-actuator-health


## Overview

Monitors a [Spring Boot Actuator](https://docs.spring.io/spring-boot/api/rest/actuator/health.html) `/health` endpoint, checking overall application health and individual component states (database, disk, mail, etc.).

**Important Notes:**

* Tested with Spring PetClinic and Better EHR
* Any application exposing a Spring Boot Actuator `/health` endpoint should work

**Data Collection:**

* Fetches JSON from the configured Spring Boot Actuator health endpoint via HTTP(S)
* Iterates over all components and their detail values reported by the API
* All numeric detail values are automatically exposed as perfdata


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/spring-boot-actuator-health> |
| Nagios/Icinga Check Name              | `check_spring_boot_actuator_health` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: spring-boot-actuator-health [-h] [-V] [--always-ok]
                                   [--component-severity COMPONENT_NAME,API_STATUS,NAGIOS_STATE]
                                   [--detail-severity COMPONENT_NAME,DETAIL_NAME,WARN,CRIT]
                                   [--insecure] [--no-proxy] [--test TEST]
                                   [--timeout TIMEOUT] [--url URL] [--verbose]

Monitors a Spring Boot application via its Actuator /health endpoint. Checks
overall health status and individual component states (database, disk, mail,
etc.). Supports fine-grained severity overrides per component and sub-
component. Alerts when the application or any component reports an unhealthy
state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --component-severity COMPONENT_NAME,API_STATUS,NAGIOS_STATE
                        Map an API status (`UP`, `DEGRADED`, `DOWN`) for a
                        specific component to a Nagios state (`ok`, `warn`,
                        `crit`, `unknown`). Can be specified multiple times.
                        Format: `component-name,api-status,nagios-state`.
                        Example: `--component-severity
                        hikariConnectionPool,DEGRADED,crit`.
  --detail-severity COMPONENT_NAME,DETAIL_NAME,WARN,CRIT
                        Threshold for a numeric component detail value. Can be
                        specified multiple times. Format: `component-
                        name,detail-name,warn,crit`. Example: `--detail-
                        severity
                        hikariConnectionPool,activeConnections,@10:20,@0:9`.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             Spring Boot Actuator health endpoint URL. Example:
                        `--url http://server:80/health/diskSpace`. Default:
                        http://localhost:80/health
  --verbose             Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
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

Output:

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

* OK if all components report UP/GREEN and no detail thresholds are exceeded.
* WARN on HTTP status code >= 300.
* WARN if any component reports DEGRADED/YELLOW (unless overridden via `--component-severity`).
* CRIT if overall application status is DOWN.
* CRIT if any component reports DOWN (unless overridden via `--component-severity`).
* CRIT if any numeric detail value exceeds the `--detail-severity` threshold.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Each numeric component detail value is exposed as perfdata. Additionally, the Nagios state of each component is exposed (0=OK, 1=WARN, 2=CRIT, 3=UNKNOWN).

| Name | Type | Description |
|----|----|----|
| diskSpace_free | Bytes | Free disk space |
| diskSpace_total | Bytes | Total disk space |
| hikariConnectionPool_activeConnections | Number | Active DB connections |
| ... | ... | Other numeric component details |


## Development

For testing purposes, install a Spring Boot Actuator application providing a `/health` endpoint. For example:

```bash

podman network create --ignore pcnet

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
  --health-cmd='curl --fail --show-error --silent --max-time 2 http://localhost:9966/petclinic/actuator/health' \
  --health-interval=30s \
  --health-on-failure=kill \
  --health-retries=5 \
  --health-start-period=5s \
  --health-timeout=10s \
  docker.io/springcommunity/spring-petclinic-rest

sleep 5

curl http://localhost:9966/petclinic/actuator/health

podman inspect petclinic | jq '.[0].State.Health'
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
