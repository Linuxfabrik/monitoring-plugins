# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.

<#
.SYNOPSIS
Sets up the JEA endpoint `LinuxfabrikMonitoringPlugins`, through which the Icinga 2 agent
runs the plugins that need more rights than its own account has. See PLUGINS-WINDOWS.md.

.DESCRIPTION
1. Runs the Icinga 2 agent service as the local account `-User`, creating the account if
   needed. A JEA endpoint is reached over WinRM, and the agent's default account
   NetworkService authenticates there as the computer account, which cannot be granted a
   role. An account the agent already runs as, for example the one that Icinga for
   Windows' `Install-IcingaSecurity` created, is left alone.
2. Installs the module `LinuxfabrikMonitoringPlugins` and the wrapper
   `Invoke-LinuxfabrikPlugin.ps1` below `C:\Program Files\WindowsPowerShell\Modules`,
   where only administrators may change them.
3. Registers the endpoint. It runs the plugins listed in `-Plugin`, and nothing else, as a
   virtual account with administrative rights, and only `-User` may connect.
4. Restarts WinRM, which ends every open WinRM session, a remote PowerShell running this
   script included. Run it in a local console, over RDP or over SSH.

Run it again after changing `-Plugin`. Needs an elevated Windows PowerShell 5.1.

.PARAMETER Uninstall
Removes the endpoint, the module and the state of the plugins, and restarts WinRM. The
local account and the account the Icinga 2 agent runs as stay as they are; switch the
agent back with `sc.exe config icinga2 obj= <account>` if needed.

.PARAMETER User
Local account the Icinga 2 agent runs as. Default: icinga

.PARAMETER DomainController
Set up the endpoint on a domain controller anyway. There the virtual account the endpoint
runs the plugins as is a member of Domain Admins, not of the local Administrators.

.PARAMETER Plugin
Plugins the endpoint may run. Only plugins that read and never open a file or run a program
a parameter names are accepted: procs, scheduled-task, updates. Default: all three

.EXAMPLE
.\Install-LinuxfabrikJea.ps1

.EXAMPLE
.\Install-LinuxfabrikJea.ps1 -User icinga -Plugin procs, scheduled-task, updates

.EXAMPLE
.\Install-LinuxfabrikJea.ps1 -Uninstall
#>

param(
    [string]$User = 'icinga',
    # The endpoint cannot restrict a plugin's arguments, and the plugins run with
    # administrative rights. A plugin that opens a file or runs a program a parameter
    # names (logfile, file-*, csv-values, ...) would hand the agent's account every file
    # on the host, so only these read-only plugins are accepted.
    [ValidateSet('procs', 'scheduled-task', 'updates')]
    [string[]]$Plugin = @('procs', 'scheduled-task', 'updates'),
    [switch]$DomainController,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
$name = 'LinuxfabrikMonitoringPlugins'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$programFiles = [Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)
$pluginDir = Join-Path $programFiles 'ICINGA2\sbin\linuxfabrik'
$moduleDir = Join-Path $programFiles "WindowsPowerShell\Modules\$name"

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this script in an elevated PowerShell.'
}

if ($Uninstall) {
    if (Get-PSSessionConfiguration -Name $name -ErrorAction SilentlyContinue) {
        Write-Host "[*] unregistering the JEA endpoint $name"
        Unregister-PSSessionConfiguration -Name $name -NoServiceRestart
    }
    if (Test-Path -LiteralPath $moduleDir) {
        Write-Host "[*] removing $moduleDir"
        Remove-Item -LiteralPath $moduleDir -Recurse -Force
    }
    Write-Host '[*] restarting WinRM'
    Restart-Service WinRM
    Write-Host "[*] done. The Icinga 2 agent still runs as $((Get-CimInstance Win32_Service -Filter "Name='icinga2'").StartName)."
    exit 0
}

# On a domain controller, a JEA virtual account is a member of Domain Admins instead of
# the local Administrators (Microsoft Learn, "JEA Session Configurations"), which would
# give the plugins the whole domain. DomainRole 4 and 5 are backup and primary DC.
if ((Get-CimInstance Win32_ComputerSystem).DomainRole -ge 4 -and -not $DomainController) {
    throw ('This host is a domain controller, where the endpoint would run the plugins ' +
        'as a member of Domain Admins. Run the script with -DomainController to set it ' +
        'up anyway.')
}

foreach ($p in $Plugin) {
    if (-not (Test-Path -LiteralPath (Join-Path $pluginDir "$p.exe") -PathType Leaf)) {
        throw "Plugin $p is not installed in $pluginDir."
    }
}

# Work directory for secedit and the session configuration file. Run as SYSTEM, for
# example by a deployment tool, TEMP is C:\Windows\Temp, where every user may create
# files: a predictable name there could be planted beforehand and the file changed
# before it is registered. A random name, readable only by SYSTEM and Administrators,
# rules that out.
$work = Join-Path ([IO.Path]::GetTempPath()) ('lfmp-jea-' + [IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $work | Out-Null
icacls $work /inheritance:r /grant:r '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F' | Out-Null

# The endpoint is reached over WinRM, even from the same host.
try {
    Test-WSMan -ComputerName localhost | Out-Null
} catch {
    throw 'WinRM does not answer on this host. Enable it with `Enable-PSRemoting`, then run this script again.'
}

# 1. service account of the Icinga 2 agent
$service = Get-CimInstance Win32_Service -Filter "Name='icinga2'"
if ($null -eq $service) {
    Write-Warning 'The Icinga 2 agent is not installed. Let it run as the account the endpoint admits.'
} elseif (
    $service.StartName -in @(".\$User", "$env:COMPUTERNAME\$User") -and
    (Get-LocalUser -Name $User -ErrorAction SilentlyContinue)
) {
    Write-Host "[*] the Icinga 2 agent already runs as $User"
} else {
    # a random password nobody needs to know; the service is the only one using it
    $bytes = New-Object byte[] 30
    [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $password = [Convert]::ToBase64String($bytes) + 'a1!'
    $secure = ConvertTo-SecureString $password -AsPlainText -Force
    if (Get-LocalUser -Name $User -ErrorAction SilentlyContinue) {
        Write-Host "[*] setting a new random password on the local account $User"
        Set-LocalUser -Name $User -Password $secure
    } else {
        Write-Host "[*] creating the local account $User"
        New-LocalUser -Name $User -Password $secure -PasswordNeverExpires -UserMayNotChangePassword `
            -Description 'Icinga 2 agent service' | Out-Null
    }

    # the right to log on as a service, which `sc.exe config` does not grant by itself
    $sid = (Get-LocalUser -Name $User).SID.Value
    secedit /export /cfg "$work\export.inf" /areas USER_RIGHTS | Out-Null
    $inf = Get-Content "$work\export.inf"
    if (-not ($inf | Where-Object { $_ -match "^SeServiceLogonRight .*\*$sid(,|$)" })) {
        if ($inf | Where-Object { $_ -like 'SeServiceLogonRight*' }) {
            $inf = $inf -replace '^(SeServiceLogonRight = .*)$', "`$1,*$sid"
        } else {
            $inf = $inf -replace '^\[Privilege Rights\]$', "[Privilege Rights]`r`nSeServiceLogonRight = *$sid"
        }
        $inf | Set-Content "$work\import.inf" -Encoding Unicode
        secedit /configure /db "$work\secedit.sdb" /cfg "$work\import.inf" /areas USER_RIGHTS | Out-Null
    }

    # the agent keeps its configuration, state and logs below ProgramData
    icacls (Join-Path $env:ProgramData 'icinga2') /grant "${User}:(OI)(CI)M" /T /Q | Out-Null

    Write-Host "[*] running the Icinga 2 agent as $User"
    sc.exe config icinga2 obj= ".\$User" password= "$password" | Out-Null
    $password = $null
    Restart-Service icinga2
}

# 2. module, role capability and wrapper, where only administrators may change them
Write-Host "[*] installing the module to $moduleDir"
New-Item -ItemType Directory -Path (Join-Path $moduleDir 'RoleCapabilities') -Force | Out-Null
$validateSet = ($Plugin | Sort-Object -Unique | ForEach-Object { "'$_'" }) -join ', '
(Get-Content (Join-Path $here "$name.psm1") -Raw) `
    -replace "\[ValidateSet\([^)]*\)\]", "[ValidateSet($validateSet)]" |
    Set-Content (Join-Path $moduleDir "$name.psm1") -Encoding UTF8
Copy-Item (Join-Path $here 'Invoke-LinuxfabrikPlugin.ps1') $moduleDir -Force
New-ModuleManifest -Path (Join-Path $moduleDir "$name.psd1") -RootModule "$name.psm1" `
    -FunctionsToExport 'Invoke-LinuxfabrikPlugin'
New-PSRoleCapabilityFile -Path (Join-Path $moduleDir "RoleCapabilities\$name.psrc") `
    -ModulesToImport $name -VisibleFunctions 'Invoke-LinuxfabrikPlugin'
# TEMP of the plugins run through the endpoint, where they keep their state. The TEMP of
# the endpoint's virtual account would be C:\Windows\Temp, where every user may create
# files. SYSTEM and Administrators only.
$state = Join-Path $moduleDir 'state'
New-Item -ItemType Directory -Path $state -Force | Out-Null
icacls $state /inheritance:r /grant:r '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F' | Out-Null

# 3. endpoint
Write-Host "[*] registering the JEA endpoint $name for $env:COMPUTERNAME\$User"
$pssc = Join-Path $work "$name.pssc"
# Windows 10 and 11 default to the execution policy Restricted, under which the session
# could not load the module. RemoteSigned applies to this endpoint only; the module is
# written locally by this script and carries no mark of the web.
New-PSSessionConfigurationFile -Path $pssc -SessionType RestrictedRemoteServer -RunAsVirtualAccount `
    -ExecutionPolicy RemoteSigned `
    -RoleDefinitions @{ "$env:COMPUTERNAME\$User" = @{ RoleCapabilities = $name } }
Register-PSSessionConfiguration -Name $name -Path $pssc -Force -NoServiceRestart | Out-Null
Remove-Item -Recurse -Force $work

# 4. WinRM picks up the endpoint only after a restart
Write-Host '[*] restarting WinRM'
Restart-Service WinRM

Write-Host "[*] done. Plugins available through the endpoint: $($Plugin -join ', ')"
Write-Host "[*] command: powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$moduleDir\Invoke-LinuxfabrikPlugin.ps1`" <plugin> [<argument> ...]"
