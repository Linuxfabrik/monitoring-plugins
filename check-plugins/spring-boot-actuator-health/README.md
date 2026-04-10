# Check spring-boot-actuator-health

## Overview

Monitors a [Spring Boot Actuator](https://docs.spring.io/spring-boot/api/rest/actuator/health.html) `/health` endpoint, checking overall application health and individual component states (database, disk, mail, etc.).

**Data Collection:**

* Fetches JSON from the configured Spring Boot Actuator health endpoint via HTTP(S)
* Iterates over all components and their detail values reported by the API
* All numeric detail values are automatically exposed as perfdata

**Compatibility:**

* Cross-platform

**Important Notes:**

* Tested with Spring PetClinic and Better EHR
* Any application exposing a Spring Boot Actuator `/health` endpoint should work


## 