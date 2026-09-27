# Windows Plugins

On Windows, the Icinga 2 agent starts the plugins with the rights of its own service account. That is `NT AUTHORITY\NetworkService` after a default installation, and it is enough for almost every plugin. A few plugins need to see more than that account may see. This page lists them and shows how to grant them those rights without handing them to the agent and to every other plugin as well.


## Plugins that need more rights

Measured with the Icinga 2 agent on Windows Server 2025. Under `NetworkService`, or under any other account without administrative rights:

* `procs`: `--argument` and `--username` cannot read the command line and the user of processes that belong to SYSTEM or to other accounts. The check skips them and says how many it skipped.
* `scheduled-task`: does not see tasks that an administrator created in a folder of their own and reports them as not found.
* `updates`: the Windows Update search fails with `0x80070005 (E_ACCESSDENIED)`.

Every other plugin with a Windows build works with the rights of the agent's account.


## Recommended: a JEA Endpoint for These Plugins

[Just Enough Administration (JEA)](https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/jea/overview) lets an account without administrative rights run a fixed set of commands with administrative rights. The setup below creates a JEA endpoint named `LinuxfabrikMonitoringPlugins` that runs the plugins listed above, and nothing else, as a temporary virtual account with administrative rights. The agent and every other plugin keep running without those rights.

The JEA profile of Icinga for Windows (`Install-IcingaSecurity`, `Install-IcingaJEAProfile`) does not help here: it only covers the PowerShell commands of the Icinga for Windows modules, while the agent starts these plugins as programs of their own. The endpoint below can be used alongside it.


### How It Works

* The Icinga 2 agent runs as a local account without administrative rights, `icinga` by default. A JEA endpoint is reached over WinRM, even from the same host, and `NetworkService` authenticates there as the computer account, which cannot be given a role. An account the agent already runs as, for example the one `Install-IcingaSecurity` created, is kept.
* The endpoint admits only that account. It exposes a single command, which starts one of the allowed plugins and returns its output and exit code.
* The agent calls a wrapper script instead of the plugin. The wrapper connects to the endpoint, runs the plugin there and passes on output and exit code. A plugin that is not allowed ends as UNKNOWN.
* Module, wrapper and endpoint definition live below `C:\Program Files\WindowsPowerShell\Modules\LinuxfabrikMonitoringPlugins`, where only administrators may change them.


### Requirements

* Windows PowerShell 5.1.
* WinRM enabled. It is on by default on Windows Server. On Windows 10 and 11, run `Enable-PSRemoting` in an elevated PowerShell first.
* The Linuxfabrik Monitoring Plugins installed from the MSI or the ZIP to `C:\Program Files\ICINGA2\sbin\linuxfabrik`.


### Setup

Download the three files from [assets/windows-jea](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/windows-jea) into one directory and run the setup script in an elevated PowerShell:

```powershell
.\Install-LinuxfabrikJea.ps1
```

To allow a different set of plugins or to use another account:

```powershell
.\Install-LinuxfabrikJea.ps1 -Plugin procs, scheduled-task, updates -User icinga
```

The script restarts WinRM at the end, which ends every open WinRM session, including a remote PowerShell that runs the script. Run it in a local console, over RDP or over SSH. It can be run again, for example after changing `-Plugin`.

The script:

1. Creates the local account (with a random password nobody needs to know), grants it the right to log on as a service and write access to `C:\ProgramData\icinga2`, and switches the Icinga 2 agent to it.
2. Installs the module `LinuxfabrikMonitoringPlugins` and the wrapper `Invoke-LinuxfabrikPlugin.ps1`.
3. Registers the endpoint `LinuxfabrikMonitoringPlugins` for that account.
4. Restarts WinRM.


### Check Command

Call the wrapper with the name of the plugin, followed by the plugin's usual arguments:

```text
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "C:\Program Files\WindowsPowerShell\Modules\LinuxfabrikMonitoringPlugins\Invoke-LinuxfabrikPlugin.ps1" updates --warning=2
```

In the Icinga DSL:

```text
object CheckCommand "cmd-check-updates-windows-jea" {
    command = [
        "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
        "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass",
        "-File", "C:\\Program Files\\WindowsPowerShell\\Modules\\LinuxfabrikMonitoringPlugins\\Invoke-LinuxfabrikPlugin.ps1",
        "updates",
    ]
    arguments = {
        "--warning" = "$updates_windows_warning$"
        "--critical" = "$updates_windows_critical$"
    }
}
```

In Icinga Director, clone the plugin's `-windows` command, set the command to the path of `powershell.exe`, and add the fixed arguments `-NoProfile`, `-NonInteractive`, `-ExecutionPolicy Bypass`, `-File <wrapper>` and the plugin name as arguments without a key and with a negative position, so that they come before the plugin's own arguments.

The wrapper takes the plugin's arguments through `-File`, so they reach the plugin as they are. Written into a `-Command` script instead, they would be parsed as PowerShell code, a `$` would have to be written as `$$` because the agent reads it as a macro, and a `€` in an argument would break the command: the agent passes the command line in the ANSI code page, which turns a `€` into characters PowerShell reads as a quote.


### Security Considerations

* The allowed plugins run with administrative rights, and the endpoint cannot restrict their arguments. Whoever can run checks as the agent's account can call them with any argument. Allow only plugins that read and never write, and never one that opens a file or runs a program a parameter names (`logfile`, `file-*`, `csv-values`, ...). The plugins listed above only read.
* The endpoint needs WinRM. `Enable-PSRemoting` also opens WinRM to the network; the endpoint itself admits only the agent's account, and the Windows firewall decides who can reach WinRM at all.
* An update of the Linuxfabrik Monitoring Plugins replaces the plugins, while the endpoint stays as it is. Run the setup script again after adding a plugin to `-Plugin`.


## Not Recommended: Running the Agent as LocalSystem

Running the Icinga 2 agent as `LocalSystem` also gives the plugins above what they need, and it is a single setting. It is the fallback where JEA is not possible or not wanted, and it comes with these drawbacks:

* Every plugin runs with full system rights, not just the three that need them, including those that open files or run programs a parameter names.
* The agent itself runs with full system rights. It listens on the network (port 5665), so a flaw in the agent gives the attacker the whole host instead of an unprivileged account. [CVE-2024-49369](https://github.com/Icinga/icinga2/security/advisories/GHSA-j7wq-r9mg-9wpv) was such a flaw, a TLS certificate validation bypass fixed in Icinga 2 2.14.3, 2.13.10 and 2.12.11.
* Every command a monitoring server can send to the agent runs with full system rights.

If you still choose it, keep the agent updated and restrict who can reach port 5665.
