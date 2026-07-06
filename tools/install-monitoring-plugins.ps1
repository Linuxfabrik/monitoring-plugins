#Requires -Version 5.1
<#
    Author:  Linuxfabrik GmbH, Zurich, Switzerland
    Contact: info (at) linuxfabrik (dot) ch
             https://www.linuxfabrik.ch/
    License: The Unlicense, see LICENSE file.

    One-liner installer for the Linuxfabrik Monitoring Plugins on Windows, the
    counterpart of the Linux `install-monitoring-plugins` shell script.

    Two install paths:

      (default)   Download the signed MSI from download.linuxfabrik.ch, verify its
                  Authenticode signature and install it silently. Installs the latest
                  release by default; pin an exact release with -Version. Recommended,
                  upgradeable. Single-file EXEs, no Python required.
      -Source     Install the latest source from GitHub into a Python 3.13
                  virtual environment: download the monitoring-plugins and lib
                  source zips, create the venv and install the plugin
                  dependencies into it. No MSI and no git client required.

    Usage (recommended path, in an elevated PowerShell):
      irm https://repo.linuxfabrik.ch/install-monitoring-plugins.ps1 | iex

    Or download first and run with parameters:
      irm https://repo.linuxfabrik.ch/install-monitoring-plugins.ps1 -OutFile install.ps1
      .\install.ps1                        # latest release
      .\install.ps1 -Version 2.3.0-1       # pinned release
      .\install.ps1 -Source -TargetDir C:\Users\me\lf

    Set -DryRun to print every action without executing it.
#>

[CmdletBinding()]
param(
    # Install the latest source from GitHub into a venv instead of the MSI.
    [switch]$Source,

    # MSI path: the release to install. Omit for the latest release, or pin an exact
    # '<version>-<iteration>' (for example '2.3.0-1').
    [string]$Version,

    # Source path: branch or tag to download from GitHub. Default: main.
    [string]$Ref = 'main',

    # Source path: parent directory that receives the two clones and the venv.
    # Default: a 'linuxfabrik' folder in the current directory.
    [string]$TargetDir,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Windows PowerShell 5.1 defaults to TLS 1.0/1.1, which GitHub and the download
# server reject. Enable TLS 1.2 so Invoke-WebRequest can reach them.
[Net.ServicePointManager]::SecurityProtocol = `
    [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$DownloadBaseUrl = 'https://download.linuxfabrik.ch/monitoring-plugins'
$GitHubBase = 'https://github.com/Linuxfabrik'

function Write-Info { param([string]$Message) Write-Host "[*] $Message" }

function Invoke-Step {
    param([string]$Message, [scriptblock]$Action)
    if ($DryRun) {
        Write-Host "[dry-run] $Message"
        return
    }
    Write-Info $Message
    & $Action
}

function Get-WindowsArch {
    # Only an x86_64 Windows build is published, so the release file name is always x86_64.
    # On Windows-on-ARM the x86_64 MSI runs under the built-in x64 emulation.
    'x86_64'
}

function Assert-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "'$Name' is required but was not found in PATH."
    }
}

function Assert-Admin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "The MSI install writes to C:\Program Files and must run in an elevated PowerShell (Run as Administrator)."
    }
}

function Install-Msi {
    if (-not $DryRun) { Assert-Admin }
    # Default to the 'latest' alias on the download server when no release is pinned, so the
    # MSI path works without looking up a version. Pin -Version <version>-<iteration> for a
    # reproducible rollout.
    if (-not $Version) {
        $Version = 'latest'
        Write-Info "no -Version given, using the latest release"
    }

    $arch = Get-WindowsArch
    $zipName = "lfmp-$Version.signed-packaged.windows.$arch.zip"
    $zipUrl = "$DownloadBaseUrl/$zipName"
    $workDir = Join-Path ([System.IO.Path]::GetTempPath()) "lfmp-install-$([System.IO.Path]::GetRandomFileName())"
    $zipPath = Join-Path $workDir $zipName

    Invoke-Step "creating work directory $workDir" {
        New-Item -ItemType Directory -Path $workDir -Force | Out-Null
    }
    Invoke-Step "downloading $zipName" {
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    }
    Invoke-Step "extracting $zipName" {
        Expand-Archive -Path $zipPath -DestinationPath $workDir -Force
    }

    if ($DryRun) {
        Write-Host "[dry-run] verify the Authenticode signature of the extracted .msi and run: msiexec /i <msi> /qn"
        return
    }

    $msi = Get-ChildItem -Path $workDir -Filter '*.msi' -Recurse | Select-Object -First 1
    if (-not $msi) {
        throw "No .msi found inside $zipName."
    }

    $signature = Get-AuthenticodeSignature -FilePath $msi.FullName
    if ($signature.Status -ne 'Valid') {
        throw "MSI signature is not valid (status: $($signature.Status)). Aborting."
    }
    Write-Info "MSI signature valid, signed by: $($signature.SignerCertificate.Subject)"

    Write-Info "installing $($msi.Name)"
    $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i', "`"$($msi.FullName)`"", '/qn' -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "msiexec failed with exit code $($process.ExitCode)."
    }
    Write-Info "installed to C:\Program Files\ICINGA2\sbin\linuxfabrik\"
}

function Expand-GitHubZip {
    # Download <repo>@<ref> as a zip from GitHub and extract it into DestDir,
    # returning the extracted directory. GitHub serves any branch or tag at
    # /archive/<ref>.zip and extracts to a '<repo>-<ref>' folder (a leading 'v'
    # is stripped from tag names), so the directory is located by pattern rather
    # than by an assumed name. No git client is needed.
    param([string]$Repo, [string]$Ref, [string]$DestDir)

    $zipUrl = "$GitHubBase/$Repo/archive/$Ref.zip"
    if ($DryRun) {
        Write-Host "[dry-run] download $zipUrl and extract into $DestDir\$Repo"
        return (Join-Path $DestDir $Repo)
    }

    $zipPath = Join-Path $DestDir ('{0}-{1}.zip' -f $Repo, ($Ref -replace '[\\/]', '-'))
    Write-Info "downloading $Repo@$Ref"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    Write-Info "extracting $Repo@$Ref"
    Expand-Archive -Path $zipPath -DestinationPath $DestDir -Force
    Remove-Item $zipPath -Force

    $extracted = Get-ChildItem -Path $DestDir -Directory -Filter "$Repo-*" |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $extracted) {
        throw "Could not find the extracted '$Repo' directory in $DestDir."
    }
    # GitHub names the folder '<repo>-<ref>'; rename it to a clean '<repo>' so
    # the layout is predictable and monitoring-plugins and lib end up as
    # siblings.
    $cleanDir = Join-Path $DestDir $Repo
    if ($extracted.FullName -ne $cleanDir) {
        if (Test-Path $cleanDir) { Remove-Item -Path $cleanDir -Recurse -Force }
        Move-Item -Path $extracted.FullName -Destination $cleanDir
    }
    return $cleanDir
}

function Install-Source {
    Assert-Command 'python'

    # The Windows binaries are pinned to Python 3.13; the only Windows lockfile
    # is lockfiles/py313-windows/requirements.txt, so the venv must be 3.13.
    # Parse `python --version` ("Python 3.13.1") rather than passing a `-c`
    # snippet: PowerShell strips embedded double quotes when it hands arguments
    # to a native command, which would corrupt an f-string.
    if (-not $DryRun) {
        $pyVersionRaw = (& python --version 2>&1 | Out-String)
        if ($pyVersionRaw -match 'Python (\d+)\.(\d+)') {
            if ([int]$Matches[1] -ne 3 -or [int]$Matches[2] -ne 13) {
                Write-Warning "Python $($Matches[1]).$($Matches[2]) detected. The Windows lockfile targets Python 3.13; other versions may fail --require-hashes."
            }
        } else {
            Write-Warning "Could not determine the Python version from '$($pyVersionRaw.Trim())'."
        }
    }

    if (-not $TargetDir) {
        $TargetDir = Join-Path (Get-Location) 'linuxfabrik'
    }
    $venvDir = Join-Path $TargetDir '.venv'
    $venvPython = Join-Path $venvDir 'Scripts\python.exe'

    Invoke-Step "creating $TargetDir" {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    # Fetch both source trees as zips from GitHub (no git client). lib is a
    # separate repository that the monitoring-plugins repo normally reaches
    # through a symlink; installing it editable into the venv below makes
    # `import lib` work without relying on symlinks, which need Developer Mode
    # or elevation on Windows.
    $mpDir = Expand-GitHubZip -Repo 'monitoring-plugins' -Ref $Ref -DestDir $TargetDir
    $libDir = Expand-GitHubZip -Repo 'lib' -Ref $Ref -DestDir $TargetDir

    Invoke-Step "creating virtual environment in $venvDir" {
        & python -m venv $venvDir
    }
    Invoke-Step "upgrading pip" {
        & $venvPython -m pip install --upgrade pip
    }
    Invoke-Step "installing plugin dependencies (py313-windows lockfile)" {
        & $venvPython -m pip install --requirement (Join-Path $mpDir 'lockfiles\py313-windows\requirements.txt') --require-hashes
    }
    # Override the pinned linuxfabrik-lib from the lockfile with the local
    # source, so `import lib` resolves without the in-repo symlinks.
    Invoke-Step "installing local lib (editable)" {
        & $venvPython -m pip install --editable $libDir
    }

    if (-not $DryRun) {
        Write-Host ''
        Write-Info "Installed the latest source into $TargetDir."
        Write-Host "  Run a plugin with the environment's Python (no activation needed):"
        Write-Host "    & `"$venvPython`" `"$mpDir\check-plugins\about-me\about-me`" --help"
        Write-Host "  Or activate the environment once, then just use 'python':"
        Write-Host "    & `"$venvDir\Scripts\Activate.ps1`""
    }
}

if ($Source) {
    Install-Source
} else {
    Install-Msi
}
