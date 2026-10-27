# Credentials

Plugins that log in to a database, an API or a device need a secret. This page covers how to hand it to a plugin, and how to keep it encrypted on disk with systemd credentials.


## Passing a Secret to a Plugin

| Parameter | Where the secret lives | Used by |
|---|---|---|
| `--password`, `--token` | On the command line: in the monitoring configuration and, while the check runs, in the process list of the node that executes it. | Most plugins that log in to an API or a device. |
| `--password-file`, `--token-file`, `--api-token-file` and similar | In a file on the node that executes the check. The plugins read its first line, `restic-*` hand the whole file to restic. | `huawei-dorado-*`, `huawei-pacific-*`, `icingaweb2-module-updates`, `restic-*` and `wordpress-security-scan`. The plugin's README lists the parameter. |
| `--defaults-file` | In a MySQL option file. | All `mysql-*` plugins, `librenms-alerts`, `librenms-health` and `xca-cert`, see [MySQL Plugins](PLUGINS-MYSQL.md). |

Prefer a file wherever the plugin offers one, and make it readable only by the user that runs the plugins. In the Icinga Director, keep the secret, or the path to its file, on the concrete host or service object, never on a template or a Service Set (see [ICINGA.md](ICINGA.md)).


## Encrypting a Secret File with systemd Credentials

A plain secret file is readable by anyone who can read the file system it lives on. systemd credentials keep it encrypted at rest:

* `systemd-creds encrypt` encrypts the file with a host key (`/var/lib/systemd/credential.secret`, readable only by root) and, if the host has one, its TPM2 chip.
* When the service starts, systemd decrypts the file into a non-swappable in-memory file system at `/run/credentials/<unit>/<name>`, readable only by the service's user. When the service stops, the file is gone.
* The plugins read the decrypted file like any other file. Point `--password-file` or `--defaults-file` at it; nothing else changes.

How far this protects depends on the TPM2 chip (`systemd-creds has-tpm2`):

* With a TPM2 chip, the credential can only be decrypted with that chip. A copy of the disk or a backup is not enough.
* Without one, which is the usual case on a VM, the host key and the machine ID it is bound to (`/etc/machine-id`) lie on the same disk as the credential. Whoever has a full copy of the disk, a VM snapshot or a backup that includes `/etc/` and `/var/lib/systemd/` can decrypt it on another host. What remains is that the secret is no longer readable as plain text in a copied configuration directory or a partial backup.

What it never protects against: root, and every process that runs as the monitoring user. While the service runs, they can read the plain file.

Requirements: Linux with systemd 251 or newer (`systemctl --version`). Verified on RHEL 9, RHEL 10 (SELinux enforcing) and Debian 13. RHEL 8 (systemd 239) and Ubuntu 22.04 (systemd 249) cannot use it.


### Icinga 2

The plugins run as child processes of `icinga2.service`, so the credential is loaded into that unit. On an agent check this is the `icinga2.service` of the agent, because the plugin runs there.

1. Encrypt the secret. Type the password, press Enter, then Ctrl+D:

    ```bash
    sudo mkdir --parents /etc/credstore.encrypted
    sudo systemd-creds encrypt --name=storage-password - /etc/credstore.encrypted/storage-password
    ```

2. Load it into Icinga 2 with a drop-in. `sudo systemctl edit icinga2` opens an editor for it. On the RHEL family:

    ```ini
    [Service]
    User=icinga
    Group=icinga
    ExecStartPre=
    ExecStartPre=+/usr/lib/icinga2/prepare-dirs /etc/sysconfig/icinga2
    LimitNPROC=16384
    LoadCredentialEncrypted=storage-password
    ```

    * `User=` and `Group=`: systemd gives read access to a credential only to the user the unit starts as. Without these lines, `icinga2` starts as root and drops its privileges itself, so only root can read the decrypted file and the plugins cannot. On Debian and Ubuntu the user and group are `nagios`.
    * `ExecStartPre=`: `prepare-dirs` creates and chowns the runtime directories and needs root. The empty line removes the original entry, the `+` runs the replacement with full privileges. Copy the original line from `systemctl cat icinga2`, the argument differs per distribution.
    * `LimitNPROC=`: Icinga 2 raises the process limit to 16384 itself only when it starts as root.
    * `LoadCredentialEncrypted=`: one line per credential. Without a path, systemd looks it up in `/etc/credstore.encrypted/`.

3. Restart Icinga 2. A reload does not pick up new or changed credentials:

    ```bash
    sudo systemctl restart icinga2
    sudo ls -l /run/credentials/icinga2.service/
    ```

    On RHEL 10 and Debian 13 the file belongs to root and the monitoring user reads it through an ACL (`-r--r-----+ 1 root root`). On RHEL 9 it belongs to the monitoring user (`-r-------- 1 icinga root`).

4. Point the plugin at the decrypted file, for example `--password-file=/run/credentials/icinga2.service/storage-password`

To change a secret, encrypt it again under the same name and restart Icinga 2.


### MySQL / MariaDB

The `mysql-*` plugins take a whole option file (see [MySQL Plugins](PLUGINS-MYSQL.md)), which is encrypted the same way:

```bash
sudo systemd-creds encrypt --name=mysql-monitoring.cnf /var/spool/icinga2/.my.cnf /etc/credstore.encrypted/mysql-monitoring.cnf
sudo rm /var/spool/icinga2/.my.cnf
```

Add `LoadCredentialEncrypted=mysql-monitoring.cnf` to the Icinga 2 drop-in, restart Icinga 2, and call the plugins with `--defaults-file=/run/credentials/icinga2.service/mysql-monitoring.cnf`


## Troubleshooting


### `Unknown lvalue 'LoadCredentialEncrypted' in section 'Service'`

The systemd on this host is older than 250 (`systemctl --version`), for example on RHEL 8. Keep the secret in a plain file readable only by the monitoring user. systemd 250 knows the setting, but cannot find the credential in `/etc/credstore.encrypted/` without a path, so this page requires 251.


### Plugin cannot read the file under `/run/credentials/icinga2.service/`

The `mysql-*` plugins report `Access denied for user 'root'@'localhost'` or `Access denied for user 'icinga'@'localhost'`, plugins with `--password-file` report that they cannot read the file. Check the owner with `sudo ls -l /run/credentials/icinga2.service/`. If the file belongs to `root` with mode `-r--------` and no `+` for an ACL, the drop-in lacks `User=` and `Group=`.
