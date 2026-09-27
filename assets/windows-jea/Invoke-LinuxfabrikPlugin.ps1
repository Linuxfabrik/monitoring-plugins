# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.

# Runs a Linuxfabrik Monitoring Plugin through the JEA endpoint
# `LinuxfabrikMonitoringPlugins` and hands its output and exit code to the monitoring
# agent. See PLUGINS-WINDOWS.md.
#
# Usage:
#   powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
#       -File Invoke-LinuxfabrikPlugin.ps1 <plugin> [<argument> ...]
#
# The plugin arguments arrive through `-File` as plain strings. Put into a `-Command`
# script instead, they would be parsed as PowerShell code: the Icinga 2 agent passes the
# command line in the ANSI code page, which turns a "€" into characters that PowerShell
# reads as a quote, and every "$" would have to be written as "$$" in the command
# definition.

$ErrorActionPreference = 'Stop'

# the agent reads the output as UTF-8 and splits it at CR and LF alike, so a CRLF would
# add an empty line
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)

if ($args.Count -lt 1) {
    [Console]::Out.Write('Usage: Invoke-LinuxfabrikPlugin.ps1 <plugin> [<argument> ...]')
    exit 3
}
$plugin = [string]$args[0]
$arguments = [string[]]@($args | Select-Object -Skip 1)

try {
    $result = Invoke-Command -ComputerName localhost `
        -ConfigurationName LinuxfabrikMonitoringPlugins `
        -ScriptBlock { param($p, $a) Invoke-LinuxfabrikPlugin -Plugin $p -Arguments $a } `
        -ArgumentList $plugin, $arguments
} catch {
    [Console]::Out.Write(($_.Exception.Message -replace "`r`n", "`n"))
    exit 3
}

# a plugin that is not allowed, or an error inside the endpoint, returns no result; that
# must not end as OK
if ($null -eq $result) {
    [Console]::Out.Write("The JEA endpoint LinuxfabrikMonitoringPlugins returned no result for $plugin.")
    exit 3
}
[Console]::Out.Write(($result.Output -replace "`r`n", "`n"))
exit $result.ExitCode
