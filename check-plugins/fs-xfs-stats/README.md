# Check fs-xfs-stats


## Overview

Reports internal XFS filesystem statistics from `/proc/fs/xfs/stat`. Useful for understanding I/O characteristics and identifying performance bottlenecks on XFS volumes. This is a data-collection plugin that does not perform threshold-based alerting. For further information, see <https://xfs.org/index.php/Runtime_Stats>.

**Data Collection:**

* Reads `/proc/fs/xfs/stat` and parses the following statistic groups: extent allocation, allocation B-tree, block mapping, block map B-tree, directory operations, inode operations, vnode, and read/write calls
* All metrics are reported as continuous counters


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fs-xfs-stats> |
| Nagios/Icinga Check Name              | `check_fs_xfs_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: fs-xfs-stats [-h] [-V]

Reports internal XFS filesystem statistics from /proc/fs/xfs/stat. Useful for
understanding I/O characteristics and identifying performance bottlenecks on
XFS volumes.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
```


## Usage Examples

```bash
./fs-xfs-stats
```

Output:

```text
Everything is ok. Extent allocation, btree, block mapping, btree, directory operation, inode operation, vnode and read write stats collected.
```


## States

* OK if all statistic groups are parsed successfully.
* WARN if any statistic group has an unexpected number of values (malformed data in `/proc/fs/xfs/stat`).
* UNKNOWN if `/proc/fs/xfs/stat` does not exist (no mounted XFS filesystem).


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| allocation_btree_compares_total | Continuous Counter | Number of allocation B-tree compares. |
| allocation_btree_lookups_total | Continuous Counter | Number of allocation B-tree lookups. |
| allocation_btree_records_deleted_total | Continuous Counter | Number of allocation B-tree records deleted. |
| allocation_btree_records_inserted_total | Continuous Counter | Number of allocation B-tree records inserted. |
| block_map_btree_compares_total | Continuous Counter | Number of block map B-tree compares. |
| block_map_btree_lookups_total | Continuous Counter | Number of block map B-tree lookups. |
| block_map_btree_records_deleted_total | Continuous Counter | Number of block map B-tree records deleted. |
| block_map_btree_records_inserted_total | Continuous Counter | Number of block map B-tree records inserted. |
| block_mapping_extent_list_compares_total | Continuous Counter | Number of extent list compares. |
| block_mapping_extent_list_deletions_total | Continuous Counter | Number of extent list deletions. |
| block_mapping_extent_list_insertions_total | Continuous Counter | Number of extent list insertions. |
| block_mapping_extent_list_lookups_total | Continuous Counter | Number of extent list lookups. |
| block_mapping_reads_total | Continuous Counter | Number of block map read operations. |
| block_mapping_unmaps_total | Continuous Counter | Number of block unmaps (deletes). |
| block_mapping_writes_total | Continuous Counter | Number of block map write operations. |
| directory_operation_create_total | Continuous Counter | Number of directory entry creations. |
| directory_operation_getdents_total | Continuous Counter | Number of directory getdents operations. |
| directory_operation_lookup_total | Continuous Counter | Number of directory name lookups that missed the OS cache. |
| directory_operation_remove_total | Continuous Counter | Number of directory entry removals. |
| extent_allocation_blocks_allocated_total | Continuous Counter | Number of blocks allocated. |
| extent_allocation_blocks_freed_total | Continuous Counter | Number of blocks freed. |
| extent_allocation_extents_allocated_total | Continuous Counter | Number of extents allocated. |
| extent_allocation_extents_freed_total | Continuous Counter | Number of extents freed. |
| inode_operation_attempts_total | Continuous Counter | Number of inode cache lookup attempts. |
| inode_operation_attribute_changes_total | Continuous Counter | Number of explicit inode attribute changes. |
| inode_operation_duplicates_total | Continuous Counter | Number of duplicate inode cache insertions (added by another process). |
| inode_operation_found_total | Continuous Counter | Number of successful inode cache lookups. |
| inode_operation_missed_total | Continuous Counter | Number of inode cache lookup misses. |
| inode_operation_reclaims_total | Continuous Counter | Number of inode cache reclaims to free memory. |
| inode_operation_recycled_total | Continuous Counter | Number of inode cache hits where the inode was being recycled. |
| read_calls_total | Continuous Counter | Number of read(2) system calls to XFS files. |
| vnode_active_total | Continuous Counter | Number of vnodes not on free lists. |
| vnode_allocate_total | Continuous Counter | Number of vn_alloc calls. |
| vnode_free_total | Continuous Counter | Number of vn_free calls. |
| vnode_get_total | Continuous Counter | Number of vn_get calls. |
| vnode_hold_total | Continuous Counter | Number of vn_hold calls. |
| vnode_reclaim_total | Continuous Counter | Number of vn_reclaim calls. |
| vnode_release_total | Continuous Counter | Number of vn_rele calls. |
| vnode_remove_total | Continuous Counter | Number of vn_remove calls. |
| write_calls_total | Continuous Counter | Number of write(2) system calls to XFS files. |


## Troubleshooting

`No mounted XFS filesystem found.`
The system does not have any mounted XFS filesystem. `/proc/fs/xfs/stat` does not exist. Disable this check for this machine.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
