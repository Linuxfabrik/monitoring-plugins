# QNAP Plugins

The QNAP plugins talk to the HTTP API of a QNAP appliance running QTS or QuTScloud. They log in, read one or two answers of the API and evaluate them on the monitoring host, so nothing has to be installed on the appliance.


## Plugins in this group

* `qts-cpu-usage`: CPU usage, alerts after a configurable number of consecutive threshold violations.
* `qts-disk-smart`: health and temperature of every disk, against the temperature thresholds configured in QTS.
* `qts-memory-usage`: memory usage.
* `qts-temperatures`: system and CPU temperature, against the thresholds configured in QTS.
* `qts-uptime`: uptime.
* `qts-version`: installed firmware, alerts when QTS knows of an update.


## Requirements

The plugins need the Python module `xmltodict`, since the API answers in XML.


## Monitoring Account

The user used for monitoring must be a member of the "administrators" group. Membership in the "everyone" group is not sufficient.


## Testing Without a QNAP Appliance

The QuTScloud image for KVM serves the same API and does not need a license key for it:

1. Download `https://download.qnap.com/Storage/QuTScloud/TS-KVM-CLD/QuTScloud_<version>.qcow2`, for example [QuTScloud_c5.2.9.3468.qcow2](https://download.qnap.com/Storage/QuTScloud/TS-KVM-CLD/QuTScloud_c5.2.9.3468.qcow2). The available versions are listed in the [QuTScloud release notes](https://www.qnap.com/en/release-notes/overview?os=qutscloud).
2. Import the image into KVM, for example with `virt-install --import --osinfo=ubuntu18.04 --memory=2048 --disk=path=QuTScloud_c5.2.9.3468.qcow2,bus=virtio --network=network=default,model=virtio`. The console shows the IP address once the boot has finished.
3. Do not run the Smart Installation in the browser, it asks for a license key. Instead, call the plugins right away with `--url=http://<ip>:8080`, `--username=admin` and the MAC address of the VM as password, in uppercase letters and without colons (`--password=00005E005301` for `00:00:5e:00:53:01`).

QuTScloud has no sensors: it reports its temperatures as 0°C and its disks without temperature.


## Common Parameters

Shared across all QNAP plugins (run `<plugin> --help` for the full list):

* `--url`: URL of the appliance, for example `--url=https://nas.example.com:443`.
* `--username` / `--password`: credentials of the monitoring user.
* `--insecure`: skip TLS certificate verification, for the self-signed certificate QTS ships with.
* `--no-proxy` / `--proxy`: bypass or name the proxy to reach the appliance through.
* `--timeout`: network timeout in seconds.
