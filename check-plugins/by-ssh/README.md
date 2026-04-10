# Check by-ssh

## Overview

Executes a command on a remote host via SSH and evaluates the result. Returns STDOUT and, in case of failure, STDERR and the command's exit code. Supports pattern matching on STDOUT to detect specific conditions, with configurable alert severities per match. Can also alert on single numeric return values against warning and critical thresholds.

**Data Collection:**

* Connects to the remote host via SSH and executes the specified command
* Captures STDOUT, STDERR, and the command's return code
* Evaluates results through pattern matching (`--warning-pattern`, `--critical-pattern`), regex matching (`--warning-regex`, `--critical-regex`), and numeric threshold checks (`--warning`, `--critical` with Nagios range support)
* Configurable severity levels for different failure modes (STDOUT, STDERR, return code, connection timeout)
* Supports `--skip-stdout` and `--skip-stderr` to ignore all or the first N lines of output

**Compatibility:**

* Cross-platform


**