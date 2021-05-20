Check fs-xfs-stats
==================

Overview
--------

This plugin provides some internal XFS statistics to user's view, which can be helpful on debugging/understanding IO characteristics and optimizing performance. It does not check anything.

For further information, have a look at https://xfs.org/index.php/Runtime_Stats.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fs-xfs-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Available for ",                       "Python 2, Python 3"
    "Perfdata compatible to Prometheus",    "Yes"


Help
----

.. code-block:: text

    usage: fs-xfs-stats [-h] [-V]

    This check provides some internal XFS statistics to user's view, which can be
    helpful on debugging/understanding IO characteristics and optimizing
    performance.

    optional arguments:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./fs-xfs-stats

Output:

.. code-block:: text

    Everything is ok. Extent allocation, btree, block mapping, btree, directory operation, inode operation, vnode and read write stats collected.


States
------

* WARN if returned statistic is malformed.
* Otherwise always OK.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
        
    Name                                      , Type             , Description                                                                                                                          
    allocation_btree_compares_total           , Continous Counter, Number of allocation B-tree compares for a filesystem.                                                                               
    allocation_btree_lookups_total            , Continous Counter, Number of allocation B-tree lookups for a filesystem.                                                                                
    allocation_btree_records_deleted_total    , Continous Counter, Number of allocation B-tree records deleted for a filesystem.                                                                        
    allocation_btree_records_inserted_total   , Continous Counter, Number of allocation B-tree records inserted for a filesystem.                                                                       
    block_map_btree_compares_total            , Continous Counter, Number of block map B-tree compares for a filesystem.                                                                                
    block_map_btree_lookups_total             , Continous Counter, Number of block map B-tree lookups for a filesystem.                                                                                 
    block_map_btree_records_deleted_total     , Continous Counter, Number of block map B-tree records deleted for a filesystem.                                                                         
    block_map_btree_records_inserted_total    , Continous Counter, Number of block map B-tree records inserted for a filesystem.                                                                        
    block_mapping_extent_list_compares_total  , Continous Counter, Number of extent list compares for a filesystem.                                                                                     
    block_mapping_extent_list_deletions_total , Continous Counter, Number of extent list deletions for a filesystem.                                                                                    
    block_mapping_extent_list_insertions_total, Continous Counter, Number of extent list insertions for a filesystem.                                                                                   
    block_mapping_extent_list_lookups_total   , Continous Counter, Number of extent list lookups for a filesystem.                                                                                      
    block_mapping_reads_total                 , Continous Counter, Number of block map for read operations for a filesystem.                                                                            
    block_mapping_unmaps_total                , Continous Counter, Number of block unmaps (deletes) for a filesystem.                                                                                   
    block_mapping_writes_total                , Continous Counter, Number of block map for write operations for a filesystem.                                                                           
    directory_operation_create_total          , Continous Counter, Number of times a new directory entry was created for a filesystem.                                                                  
    directory_operation_getdents_total        , Continous Counter, Number of times the directory getdents operation was performed for a filesystem.                                                     
    directory_operation_lookup_total          , Continous Counter, Number of file name directory lookups which miss the operating systems directory name lookup cache.                                  
    directory_operation_remove_total          , Continous Counter, Number of times an existing directory entry was created for a filesystem.                                                            
    extent_allocation_blocks_allocated_total  , Continous Counter, Number of blocks allocated for a filesystem.                                                                                         
    extent_allocation_blocks_freed_total      , Continous Counter, Number of blocks freed for a filesystem.                                                                                             
    extent_allocation_extents_allocated_total , Continous Counter, Number of extents allocated for a filesystem.                                                                                        
    extent_allocation_extents_freed_total     , Continous Counter, Number of extents freed for a filesystem.                                                                                            
    inode_operation_attempts_total            , Continous Counter, Number of times the OS looked for an XFS inode in the inode cache.                                                                   
    inode_operation_attribute_changes_total   , Continous Counter, Number of times the OS explicitly changed the attributes of an XFS inode.                                                            
    inode_operation_duplicates_total          , Continous Counter, "Number of times the OS tried to add a missing XFS inode to the inode cache, but found it had already been added by another process."
    inode_operation_found_total               , Continous Counter, Number of times the OS looked for and found an XFS inode in the inode cache.                                                         
    inode_operation_missed_total              , Continous Counter, "Number of times the OS looked for an XFS inode in the cache, but did not find it."                                                  
    inode_operation_reclaims_total            , Continous Counter, Number of times the OS reclaimed an XFS inode from the inode cache to free memory for another purpose.                               
    inode_operation_recycled_total            , Continous Counter, "Number of times the OS found an XFS inode in the cache, but could not use it as it was being recycled."                             
    read_calls_total                          , Continous Counter, Number of read(2) system calls made to files in a filesystem.                                                                        
    vnode_active_total                        , Continous Counter, Number of vnodes not on free lists for a filesystem.                                                                                 
    vnode_allocate_total                      , Continous Counter, Number of times vn_alloc called for a filesystem.                                                                                    
    vnode_get_total                           , Continous Counter, Number of times vn_get called for a filesystem.                                                                                      
    vnode_hold_total                          , Continous Counter, Number of times vn_hold called for a filesystem.                                                                                     
    vnode_reclaim_total                       , Continous Counter, Number of times vn_reclaim called for a filesystem.                                                                                  
    vnode_release_total                       , Continous Counter, Number of times vn_rele called for a filesystem.                                                                                     
    vnode_remove_total                        , Continous Counter, Number of times vn_remove called for a filesystem.                                                                                   
    write_calls_total                         , Continous Counter, Number of write(2) system calls made to files in a filesystem.                                                                       


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
