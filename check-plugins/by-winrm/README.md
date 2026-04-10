# Check by-winrm

## Overview

This plugin executes PowerShell commands or scripts on remote Windows hosts via WinRM, supporting JEA. It returns standard output (STDOUT) and, in case of failure, standard error (STDERR) along with the command's exit code. By evaluating these results - through threshold checks or pattern matching on STDOUT - the plugin can generate alerts with configurable severity levels.

**Data Collection:**

* Connects to the remote Windows host via WinRM and executes the specified PowerShell command
* Automatically prefers PSRP (PowerShell Remoting / JEA) when `pypsrp` is installed, and falls back to classic WinRM (`pywinrm`) when needed
* Captures STDOUT, STDERR, and the command's return code
* Evaluates results through pattern matching (`--warning-pattern`, `--critical-pattern`), regex matching (`--warning-regex`, `--critical-regex`), and numeric threshold checks (`--warning`, `--critical` with Nagios range support)
* Configurable severity levels for different failure modes (STDOUT, STDERR, return code, connection timeout)
* Supports `--skip-stdout` and `--skip-stderr` to ignore all or the first N lines of output

**Compatibility:**

* Runs on Linux and connects to remote Windows hosts


**