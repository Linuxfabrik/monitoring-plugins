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
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $exe
    $psi.Arguments = ($Arguments | ForEach-Object { ConvertTo-LinuxfabrikArgument $_ }) -join ' '
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    # the plugins write UTF-8
    $psi.StandardOutputEncoding = New-Object System.Text.UTF8Encoding($false)
    $psi.StandardErrorEncoding = New-Object System.Text.UTF8Encoding($false)
    $process = [System.Diagnostics.Process]::Start($psi)
    # read stderr asynchronously, so that a full stderr pipe cannot block the plugin while
    # stdout is read
    $stderr = $process.StandardError.ReadToEndAsync()
    $stdout = $process.StandardOutput.ReadToEnd()
    $process.WaitForExit()
    [pscustomobject]@{
        ExitCode = $process.ExitCode
        Output   = $stdout + $stderr.Result
    }
}

Export-ModuleMember -Function 'Invoke-LinuxfabrikPlugin'
