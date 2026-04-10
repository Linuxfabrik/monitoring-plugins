# Check strongswan-connections

## Overview

Checks IPSec connection states on a strongSwan VPN gateway by connecting to the charon daemon via the VICI (Versatile IKE Control Interface) socket. Reports IKE SA and CHILD SA states, re-authentication/re-keying timers, and traffic counters. "EST" in the output means "Established".

**Data Collection:**

* Connects to the VICI socket (default: `/run/strongswan/charon.vici`) to enumerate configured and active connections
* Iterates over all IKE SAs and their CHILD SAs, collecting state, timing, and traffic data
* `--lengthy` provides additional columns: established time, IKE version, local/remote endpoints, encryption/integrity details, and per-child local/remote traffic selectors

**Important Notes:**

* Must be run locally on the strongSwan host (needs access to the VICI socket)
* Requires root or sudo

**Compatibility:**

* strongSwan with VICI interface (swanctl); tested with VICI protocol versions 5.7 and 5.9


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/strongswan-connections> |
| Nagios/Icinga Check Name              | `check_strongswan_connections` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `vici` |


## Help

```text
usage: strongswan-connections [-h] [-V] [--always-ok] [--lengthy]
                              [--socket SOCKET] [--test TEST]

Checks IPSec connection states on a strongSwan VPN gateway. Connects to the
charon daemon via the VICI interface to retrieve IKE SA and CHILD SA states.
Alerts on connections that are not in the expected established state. Requires
root or sudo.

options:
  -h, --help       show this help message and exit
  -V, --version    show program's version number and exit
  --always-ok      Always returns OK.
  --lengthy        Extended reporting.
  --socket SOCKET  Path to the Versatile IKE Control Interface (VICI) socket.
                   Default: /run/strongswan/charon.vici
  --test TEST      For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                   file,expected-retc".
```


## Usage Examples

```bash
./strongswan-connections
```

Output:

```text
Everything is ok.

Conn.     ! State ! Re-Authentication   ! Child     ! Mode:State       ! Re-Keying           ! Expires             ! Rx       ! Tx       
----------+-------+---------------------+-----------+------------------+---------------------+---------------------+----------+----------
example   ! EST   ! 2022-05-11 13:36:24 ! example   ! TUNNEL:INSTALLED ! 2022-05-11 11:02:36 ! 2022-05-11 11:12:53 ! 0.0B     ! 0.0B     
acme      ! EST   ! 2022-05-11 14:57:14 ! acme1     ! TUNNEL:INSTALLED ! 2022-05-11 14:03:57 ! 2022-05-11 15:02:29 ! 1.3MiB   ! 997.0KiB 
acme      ! EST   ! 2022-05-11 14:57:14 ! acme2     ! TUNNEL:INSTALLED ! 2022-05-11 13:38:36 ! 2022-05-11 15:10:18 ! 633.2KiB ! 634.5KiB
```

With `--lengthy`:

```text
Everything is ok.

Conn.     ! State ! Established         ! Re-Authentication   ! IKE ! Local               ! Remote             ! Encryption/Integrity/Pseudo Random/DH                     ! Child     ! Mode:State       ! Local         ! Remote        ! Prot:Encryption/Integrity/DH                ! Installed           ! Re-Keying           ! Expires             ! Rx       ! Tx       
----------+-------+---------------------+---------------------+-----+---------------------+--------------------+-----------------------------------------------------------+-----------+------------------+---------------+---------------+---------------------------------------------+---------------------+---------------------+---------------------+----------+----------
example   ! EST   ! 2022-05-11 06:08:24 ! 2022-05-11 13:36:24 ! v2  ! 198.51.100.246:500  ! 203.0.113.226:500  ! AES_CBC-256/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/ECP_256   ! example   ! TUNNEL:INSTALLED ! 192.0.2.0/24  ! 10.0.11.0/24  ! ESP:AES_GCM_16-256/None/ECP_256             ! 2022-05-11 10:06:53 ! 2022-05-11 11:02:36 ! 2022-05-11 11:12:53 ! 0.0B     ! 0.0B     
acme      ! EST   ! 2022-05-10 15:03:43 ! 2022-05-11 14:57:14 ! v2  ! 198.51.100.246:4500 ! 203.0.113.28:4500  ! AES_CBC-256/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_1536 ! acme1     ! TUNNEL:INSTALLED ! 192.0.2.0/24  ! 172.16.0.0/16 ! ESP:AES_CBC-256/HMAC_SHA2_256_128/MODP_1536 ! 2022-05-11 06:14:29 ! 2022-05-11 14:03:57 ! 2022-05-11 15:02:29 ! 1.2MiB   ! 934.5KiB 
acme      ! EST   ! 2022-05-10 15:03:43 ! 2022-05-11 14:57:14 ! v2  ! 198.51.100.246:4500 ! 203.0.113.28:4500  ! AES_CBC-256/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/MODP_1536 ! acme2     ! TUNNEL:INSTALLED ! 192.0.99.0/24 ! 172.16.0.0/16 ! ESP:AES_CBC-256/HMAC_SHA2_256_128/MODP_1536 ! 2022-05-11 06:22:18 ! 2022-05-11 13:38:36 ! 2022-05-11 15:10:18 ! 599.7KiB ! 601.2KiB
```


## States

* OK if all configured connections are active and all child SAs are connected.
* WARN if there are no active connections at all.
* WARN if configured connections do not match active connections.
* WARN if any child SA is not connected.
* UNKNOWN if no connections are configured.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<connname\>\_established | Seconds | Seconds the IKE SA has been established |
| \<connname\>\_rekey-time | Seconds | Seconds before IKE SA gets rekeyed |
| \<connname\>\_\<childname\>\_bytes-in | Bytes | Number of input bytes processed |
| \<connname\>\_\<childname\>\_bytes-out | Bytes | Number of output bytes processed |
| \<connname\>\_\<childname\>\_install-time | Seconds | Seconds the CHILD SA has been installed |
| \<connname\>\_\<childname\>\_life-time | Seconds | Seconds before CHILD SA expires |
| \<connname\>\_\<childname\>\_rekey-time | Seconds | Seconds before CHILD SA gets rekeyed |


## Troubleshooting

`[Errno 2] No such file or directory`
Check the path to `charon.vici`, and specify `--socket` accordingly.

`Python module "vici" is not installed.`
Install `vici`: `pip install vici`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
