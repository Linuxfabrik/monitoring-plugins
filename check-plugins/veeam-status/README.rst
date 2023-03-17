Check veeam-status
==================

Overview
--------

Using the Veeam Enterprise Manager API (requires a Veeam Enterprise license), it checks Veeam for failed VMs or jobs, jobs that are running too long, and overuse of backup repositories. It also provides information on

* Backup infrastructure components and backup and replication jobs performed (API: ``/reports/summary/overview``)
* Jobs run, their status and duration (API: ``/reports/summary/job_statistics``)
* Backed up and replicated VMs, available recovery points (API: ``/reports/summary/vms_overview``)
* Backup repositories, their capacity, free space, and size of backup files (API: ``/reports/summary/repository``)

Notes:

* This check uses the Veeam Enterprise Manager API, not that of an individual Backup & Replication server.
* An **Enterprise License** may be required to take full advantage of the RESTful API functionality.
* Also make sure that the account you use to access REST has sufficient privileges.
* The check always accepts self-signed Veeam certificates.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/veeam-status"
    "Check Interval Recommendation",        "Every 8 hours"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "Veeam Enterprise License"


Help
----

.. code-block:: text

    usage: veeam-status [-h] [-V] [--always-ok] [-c CRIT]
                        [--failed-job-runs FAILED_JOB_RUNS]
                        [--failed-vm-lastest-states FAILED_VM_LASTEST_STATES]
                        [--max-backup-job-duration MAX_BACKUP_JOB_DURATION]
                        [--max-replica-job-duration MAX_REPLICA_JOB_DURATION] -p
                        PASSWORD [--test TEST] [--timeout TIMEOUT] [--url URL]
                        --username USERNAME [-w WARN]
                        [--warnings-job-runs WARNINGS_JOB_RUNS]
                        [--warning-vm-lastest-states WARNING_VM_LASTEST_STATES]

    Checks Veeam for failed VM or jobs, jobs that are running too long, and
    overuse of the backup repositories. In addition, the check provides
    information about backup infrastructure components and performed backup and
    replication jobs, executed jobs, their status and duration, backed up and
    replicated VMs, available recovery points and backup repositories, their
    capacity, free storage space and size of the backup files - using the Veeam
    Enterprise Manager API (requires a Veeam Enterprise License).

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold for Backup Size as a
                            percentage. Default: >= 90
      --failed-job-runs FAILED_JOB_RUNS
                            Veeam threshold for `FailedJobRuns`. Default: > 0
      --failed-vm-lastest-states FAILED_VM_LASTEST_STATES
                            Veeam threshold for `FailedVmLastestStates`. Default:
                            > 0
      --max-backup-job-duration MAX_BACKUP_JOB_DURATION
                            Veeam threshold for `MaxBackupJobDuration`. Default: >
                            86400
      --max-replica-job-duration MAX_REPLICA_JOB_DURATION
                            Veeam threshold for `MaxDurationReplicaJobName`.
                            Default: > 86400
      -p PASSWORD, --password PASSWORD
                            Veeam API password.
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             Veeam API URL. Default: https://localhost:9398
      --username USERNAME   Veeam API username. Default: Administrator
      -w WARN, --warning WARN
                            Set the WARN threshold for Backup Size as a
                            percentage. Default: >= 80
      --warnings-job-runs WARNINGS_JOB_RUNS
                            Veeam threshold for `WarningsJobRuns`. Default: > 0
      --warning-vm-lastest-states WARNING_VM_LASTEST_STATES
                            Veeam threshold for `WarningVmLastestStates`. Default:
                            > 0


Usage Examples
--------------

.. code-block:: bash

    ./veeam-status --username Administrator --password password --timeout 3 --warning 80 --critical 90 --url https://veeam:9398

Output:

.. code-block:: text

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


States
------

* WARN or CRIT if disk usage in any backup repository is above the given thresholds (percentages)
* CRIT if number of FailedJobRuns > 0
* CRIT if number of FailedVmLastestStates > 0
* WARN if number of WarningsJobRuns > 0
* WARN if number of WarningVmLastestStates > 0
* WARN if duration of MaxBackupJobDuration > 24h
* WARN if duration of MaxReplicaJobDuration > 24h


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    Repo Usage <Reponame>,                      Percentage,         Disk Usage of Backup Repo
    Repo Capacity <Reponame>,                   Bytes,              https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_repository.html?ver=110
    Repo FreeSpace <Reponame>,                  Bytes,              https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_repository.html?ver=110
    Repo BackupSize <Reponame>,                 Bytes,              https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_repository.html?ver=110
    BackedUpVms,                                Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    BackupServers,                              Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110
    FailedJobRuns,                              Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    FailedVmLastestStates,                      Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110
    FullBackupPointsSize,                       Bytes,              https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    IncrementalBackupPointsSize,                Bytes,              https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    MaxBackupJobDuration,                       Seconds,            https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    MaxJobDuration,                             Seconds,            https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    MaxReplicaJobDuration,                      Seconds,            https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    ProtectedVms,                               Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    ProxyServers,                               Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110
    ReplicaRestorePointsSize,                   Bytes,              https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    ReplicatedVms,                              Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    RepositoryServers,                          Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110
    RestorePoints,                              Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    RunningJobs,                                Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    ScheduledBackupJobs,                        Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    ScheduledJobs,                              Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    ScheduledReplicaJobs,                       Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    SourceVmsSize,                              Bytes,              https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    SuccessBackupPercents,                      Percentage,         https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    SuccessfulJobRuns,                          Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    SuccessfulVmLastestStates,                  Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110
    TotalJobRuns,                               Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    WarningsJobRuns,                            Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    WarningVmLastestStates,                     Number,             https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
