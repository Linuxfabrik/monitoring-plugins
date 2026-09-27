# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.

# The only command the JEA endpoint `LinuxfabrikMonitoringPlugins` exposes. It runs one
# of the plugins listed in `ValidateSet` below with the rights of the endpoint's virtual
# account and returns its output and exit code. `Install-LinuxfabrikJea.ps1` writes the
# list of plugins into `ValidateSet` when it installs this module.
#
# A JEA session of type RestrictedRemoteServer runs in the language mode NoLanguage, in
# which the caller cannot even read `$LASTEXITCODE`. A function of a module that the role
# capability imports runs in FullLanguage, which is why the plugin is started here and not
# by the caller. Verified on Windows Server 2025 with Windows PowerShell 5.1.

function ConvertTo-LinuxfabrikArgument {
    # Quote one argument so that `CommandLineToArgvW()` reads it back unchanged: quotes are
    # escaped, and backslashes in front of a quote or at the end are doubled.
    param([string]$Value)
    if ($Value -ne '' -and $Value -notmatch '[\s"]') {
        return $Value
    }
    $escaped = [regex]::Replace($Value, '(\\*)"', '$1$1\"')
    $escaped = [regex]::Replace($escaped, '(\\+)$', '$1$1')
    return '"' + $escaped + '"'
}

function Invoke-LinuxfabrikPlugin {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('procs', 'scheduled-task', 'updates')]
        [string]$Plugin,
        [string[]]$Arguments = @()
    )
    # $env:ProgramFiles is empty in the virtual account of a JEA session
    $programFiles = [Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)
    $exe = Join-Path -Path $programFiles -ChildPath "ICINGA2\sbin\linuxfabrik\$Plugin.exe"
    # The TEMP of the virtual account is C:\Windows\Temp, where every user may create
    # files, so a state database there could be planted beforehand. The state directory
    # next to this module is writable by SYSTEM and Administrators only.
    $state = Join-Path -Path $PSScriptRoot -ChildPath 'state'
    if (-not (Test-Path -LiteralPath $state -PathType Container)) {
        return [pscustomobject]@{
            ExitCode = 3
            Output   = "The state directory $state is missing. Run Install-LinuxfabrikJea.ps1 again."
        }
    }
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $exe
    $psi.Arguments = ($Arguments | ForEach-Object { ConvertTo-LinuxfabrikArgument $_ }) -join ' '
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    # the plugins write UTF-8
    $psi.StandardOutputEncoding = New-Object System.Text.UTF8Encoding($false)
    $psi.StandardErrorEncoding = New-Object System.Text.UTF8Encoding($false)
    $psi.EnvironmentVariables['TEMP'] = $state
    $psi.EnvironmentVariables['TMP'] = $state
    $process = [System.Diagnostics.Process]::Start($psi)
    # read both streams asynchronously, so that neither a full pipe nor a hanging plugin
    # can block the session
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    # The agent stops waiting for the check at its own timeout, but the plugin would go
    # on running in the endpoint. The plugins time out on their own well before this
    # (`updates` after 300 seconds); it is the safety net for one that does not.
    if (-not $process.WaitForExit(600 * 1000)) {
        taskkill.exe /T /F /PID $process.Id | Out-Null
        return [pscustomobject]@{
            ExitCode = 3
            Output   = "$Plugin did not finish within 600 seconds and was stopped."
        }
    }
    [pscustomobject]@{
        ExitCode = $process.ExitCode
        Output   = $stdout.Result + $stderr.Result
    }
}

Export-ModuleMember -Function 'Invoke-LinuxfabrikPlugin'
