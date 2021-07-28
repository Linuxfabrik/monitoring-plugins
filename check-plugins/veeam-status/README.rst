Check veeam-status
==================

Overview
--------

Checks Veeam for failed VM or jobs, jobs that are running too long, and overuse of the backup repositories, using the Veeam Enterprise Manager API (requires a Veeam Enterprise License). In addition, the check provides information about

* backup infrastructure components and performed backup and replication jobs (API: `/reports/summary/overview`)
* performed jobs, their status and duration (API: `/reports/summary/job_statistics`)
* backed up and replicated VMs, available restore points (API: `/reports/summary/vms_overview`)
* backup repositories, their capacity, free storage space and size of the backup files (API: `/reports/summary/repository`)

Hints:

* This check fetches the API of the Veeam Enterprise Manager, not the one of an individual Backup & Replication server.
* Maybe an **Enterprise license is required** to make full use of the RESTful API functionality.
* Also, make sure the account you access REST with has enough privileges.
* The check always accepts self-signed Veeam certificates.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/veeam-status"
    "Check Interval Recommendation",        "Every 8 hours"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Veeam Enterprise License"


Help
----

.. code-block:: text

    usage: veeam-status [-h] [-V] [--always-ok] [-c CRIT] [-p PASSWORD]
                        [--test TEST] [--timeout TIMEOUT] [--url URL]
                        [--username USERNAME] [-w WARN]

    Checks Veeam for failed VM or jobs, jobs that are running too long, and
    overuse of the backup repositories. In addition, the check provides
    information about backup infrastructure components and performed backup and
    replication jobs, executed jobs, their status and duration, backed up and
    replicated VMs, available recovery points and backup repositories, their
    capacity, free storage space and size of the backup files - using the Veeam
    Enterprise Manager API (requires a Veeam Enterprise License).

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold as a percentage. Default: >= 90
      -p PASSWORD, --password PASSWORD
                            Veeam API password.
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             Veeam API URL. Default: https://localhost:9398/api
      --username USERNAME   Veeam API username. Default: Administrator
      -w WARN, --warning WARN
                            Set the WARN threshold as a percentage. Default: >= 80


Usage Examples
--------------

.. code-block:: bash

    ./veeam-status --username Administrator --password password --timeout 3 --warning 80 --critical 90 --url https://veeam:9398

Output:

.. code-block:: text

    1 VM failed [CRITICAL], 2 VMs with warnings [WARNING], 5 Jobs failed [CRITICAL], 3 Jobs with warnings [WARNING], "Backup_2014-10-18T044119" ran for 1D 9m [WARNING], "Backup Volume 01" 18.3% used - total: 1005.5GiB, used: 184.2GiB, free: 821.3GiB, "Default Backup Repository" 17.6% used - total: 119.7GiB, used: 21.0GiB, free: 98.6GiB

    Key                         ! Value                    
    --------------------------- ! ------------------------ 
    BackedUpVms                 ! 38                       
    BackupServers               ! 2                        
    FailedJobRuns               ! 5                        
    FailedVmLastestStates       ! 1                        
    FullBackupPointsSize        ! 1.1TiB                   
    IncrementalBackupPointsSize ! 0.0B                     
    MaxBackupJobDuration        ! 1D 9m                    
    MaxDurationBackupJobName    ! Backup_2014-10-18T044119 
    MaxDurationReplicaJobName   ! Fileserver02 Replication 
    MaxJobDuration              ! 16m                      
    MaxReplicaJobDuration       ! 1D 3h                    
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
    WarningsJobRuns             ! 3                        
    WarningVmLastestStates      ! 2|


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
    BackedUpVms,                                None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    BackupServers,                              None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110
    FailedJobRuns,                              None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    FailedVmLastestStates,                      None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110
    FullBackupPointsSize,                       Bytes,              https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    IncrementalBackupPointsSize,                Bytes,              https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    MaxBackupJobDuration,                       Seconds,            https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    MaxJobDuration,                             Seconds,            https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    MaxReplicaJobDuration,                      Seconds,            https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    ProtectedVms,                               None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    ProxyServers,                               None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110
    ReplicaRestorePointsSize,                   Bytes,              https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    ReplicatedVms,                              None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    RepositoryServers,                          None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110
    RestorePoints,                              None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    RunningJobs,                                None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    ScheduledBackupJobs,                        None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    ScheduledJobs,                              None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    ScheduledReplicaJobs,                       None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    SourceVmsSize,                              Bytes,              https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    SuccessBackupPercents,                      Percentage,         https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_vms_overview.html?ver=110
    SuccessfulJobRuns,                          None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    SuccessfulVmLastestStates,                  None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110
    TotalJobRuns,                               None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    WarningsJobRuns,                            None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_statistics.html?ver=110
    WarningVmLastestStates,                     None,               https://helpcenter.veeam.com/docs/backup/em_rest/reports_summary_overview.html?ver=110


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
