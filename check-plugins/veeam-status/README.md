# Check veeam-status

## Overview

Monitors a Veeam Backup & Replication environment via the Veeam Enterprise Manager REST API. Checks for failed VMs and jobs, jobs running longer than expected, and backup repository usage. Also reports backup infrastructure component status and recent job results in a summary table.

**Data Collection:**

* Queries the Veeam Enterprise Manager REST API endpoints: `/reports/summary/overview`, `/reports/summary/job_statistics`, `/reports/summary/vms_overview`, `/reports/summary/repository`
* Authenticates via the Veeam session token mechanism using `--username` and `--password`

**Important Notes:**

* This check uses the Veeam Enterprise Manager API, not that of an individual Backup & Replication server.
* An Enterprise License may be required to take full advantage of the RESTful API functionality.
* Make sure that the account you use to access REST has sufficient privileges.
* The check always accepts self-signed Veeam certificates (`--insecure` defaults to True).



**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/veeam-status> |
| Nagios/Icinga Check Name              | `check_veeam_status` |
| Check Interval Recommendation         | Every 8 hours |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Compiled for Windows                  | No |
| Requirements                          | Veeam Enterprise License |


## Help

```text
usage: veeam-status [-h] [-V] [--always-ok] [-c CRIT]
                    [--failed-job-runs FAILED_JOB_RUNS]
                    [--failed-vm-lastest-states FAILED_VM_LASTEST_STATES]
                    [--insecure]
                    [--max-backup-job-duration MAX_BACKUP_JOB_DURATION]
                    [--max-replica-job-duration MAX_REPLICA_JOB_DURATION]
                    [--no-proxy] -p PASSWORD [--test TEST] [--timeout TIMEOUT]
                    [--url URL] --username USERNAME [-w WARN]
                    [--warnings-job-runs WARNINGS_JOB_RUNS]
                    [--warning-vm-lastest-states WARNING_VM_LASTEST_STATES]

Monitors Veeam Backup & Replication via PowerShell, checking for failed VMs
and jobs, jobs running longer than expected, and backup repository usage. Also
reports backup infrastructure component status and recent job results.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for backup repository usage as a
                        percentage. Default: >= 90
  --failed-job-runs FAILED_JOB_RUNS
                        Veeam threshold for `FailedJobRuns`. Default: > 0.
  --failed-vm-lastest-states FAILED_VM_LASTEST_STATES
                        Veeam threshold for `FailedVmLastestStates`. Default:
                        > 0.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --max-backup-job-duration MAX_BACKUP_JOB_DURATION
                        Maximum allowed backup job duration in seconds.
                        Default: > 86400.
  --max-replica-job-duration MAX_REPLICA_JOB_DURATION
                        Maximum allowed replica job duration in seconds.
                        Default: > 86400.
  --no-proxy            Do not use a proxy.
  -p, --password PASSWORD
                        Veeam REST API password.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             Veeam REST API URL. Default: https://localhost:9398
  --username USERNAME   Veeam REST API username. Default: Administrator
  -w, --warning WARN    WARN threshold for backup repository usage as a
                        percentage. Default: >= 80
  --warnings-job-runs WARNINGS_JOB_RUNS
                        Veeam threshold for `WarningsJobRuns`. Default: > 0.
  --warning-vm-lastest-states WARNING_VM_LASTEST_STATES
                        Veeam threshold for `WarningVmLastestStates`. Default:
                        > 0.
```


## Usage Examples

```bash
./veeam-status \
    --username=Administrator \
    --password=password \
    --timeout=3 \
    --warning=80 \
    --critical=90 \
    --url=https://veeam:9398
```

Output:

```text
1 Job failed [CRITICAL], 5 VMs failed [CRITICAL], "Backup_2014-10-18T044119" ran for 1W 3D [WARNING], Fileserver02 Replication ran for 1D 17h [WARNING], 2 Jobs with warnings [WARNING], 3 VMs with warnings [WARNING], "Backup Volume 01" 18.3% used - total: 1005.5GiB, used: 184.2GiB, free: 821.3GiB

Key                         ! Value                    
----------------------------+--------------------------
BackedUpVms                 ! 38                       
BackupServers               ! 2                        
FailedJobRuns               ! 1 [CRITICAL]             
FailedVmLastestStates       ! 5 [CRITICAL]             
FullBackupPointsSize        ! 1.1TiB                   
IncrementalBackupPointsSize ! 0.0B                     
MaxBackupJobDuration        ! 1W 3D [WARNING]          
MaxDurationBackupJobName    ! Backup_2014-10-18T044119 
MaxDurationReplicaJobName   ! Fileserver02 Replication 
MaxJobDuration              ! 16m                      
MaxReplicaJobDuration       ! 1D 17h [WARNING]         
ProtectedVms                ! 38                       
ProxyServers                ! 6                        
ReplicaRestorePointsSize    ! 0.0B                     
ReplicatedVms               ! 2                        
RepositoryServers           ! 6                        
RestorePoints               ! 38                       
RunningJobs                 ! 0                        
ScheduledBackupJobs         ! 2                        
ScheduledJobs               ! 8                        
ScheduledReplicaJobs        ! 0                        
SourceVmsSize               ! 2.7TiB                   
SuccessBackupPercents       ! 100%                     
SuccessfulJobRuns           ! 7                        
SuccessfulVmLastestStates   ! 38                       
TotalJobRuns                ! 12                       
WarningsJobRuns             ! 2 [WARNING]              
WarningVmLastestStates      ! 3 [WARNING]
```


## States

* CRIT if `FailedJobRuns` > `--failed-job-runs` (default: 0).
* CRIT if `FailedVmLastestStates` > `--failed-vm-lastest-states` (default: 0).
* WARN if `WarningsJobRuns` > `--warnings-job-runs` (default: 0).
* WARN if `WarningVmLastestStates` > `--warning-vm-lastest-states` (default: 0).
* WARN if `MaxBackupJobDuration` > `--max-backup-job-duration` (default: 86400 seconds).
* WARN if `MaxReplicaJobDuration` > `--max-replica-job-duration` (default: 86400 seconds).
* WARN or CRIT if backup repository usage >= `--warning` (default: 80%) or >= `--critical` (default: 90%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| BackedUpVms | Number | Number of backed up VMs. |
| BackupServers | Number | Number of backup servers. |
| FailedJobRuns | Number | Number of failed job runs. |
| FailedVmLastestStates | Number | Number of VMs in failed state. |
| FullBackupPointsSize | Bytes | Size of full backup restore points. |
| IncrementalBackupPointsSize | Bytes | Size of incremental backup restore points. |
| MaxBackupJobDuration | Seconds | Duration of the longest backup job. |
| MaxJobDuration | Seconds | Duration of the longest job overall. |
| MaxReplicaJobDuration | Seconds | Duration of the longest replica job. |
| ProtectedVms | Number | Number of protected VMs. |
| ProxyServers | Number | Number of proxy servers. |
| Repo BackupSize REPONAME | Bytes | Used backup size per repository. |
| Repo Capacity REPONAME | Bytes | Total capacity per repository. |
| Repo FreeSpace REPONAME | Bytes | Free space per repository. |
| Repo Usage REPONAME | Percentage | Disk usage per repository. |
| ReplicaRestorePointsSize | Bytes | Size of replica restore points. |
| ReplicatedVms | Number | Number of replicated VMs. |
| RepositoryServers | Number | Number of repository servers. |
| RestorePoints | Number | Number of restore points. |
| RunningJobs | Number | Number of currently running jobs. |
| ScheduledBackupJobs | Number | Number of scheduled backup jobs. |
| ScheduledJobs | Number | Number of scheduled jobs. |
| ScheduledReplicaJobs | Number | Number of scheduled replica jobs. |
| SourceVmsSize | Bytes | Total size of source VMs. |
| SuccessBackupPercents | Percentage | Backup success rate. |
| SuccessfulJobRuns | Number | Number of successful job runs. |
| SuccessfulVmLastestStates | Number | Number of VMs in successful state. |
| TotalJobRuns | Number | Total number of job runs. |
| WarningVmLastestStates | Number | Number of VMs in warning state. |
| WarningsJobRuns | Number | Number of job runs with warnings. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
