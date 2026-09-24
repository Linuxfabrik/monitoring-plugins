#!/usr/bin/env bash
# 2026092401

# Install the package just built for the target distro given as $1 into a fresh container
# of that distro, and check it the way a monitored host uses it: as the unprivileged
# monitoring user, every plugin starts and every .pyc in the venv loads and is used.
# The build container is no stand-in for that host: it carries compilers and headers, and
# it never installs the package. #1543 shipped in every RPM since 2.0.0 for want of this.

set -e -o pipefail -u -x

LFMP_TARGET_DISTRO="$1"

CONTAINER="lfmp-smoke-test-$LFMP_TARGET_DISTRO"
# the plain distro image the build container starts from
IMAGE="$(awk '/^FROM / { print $2; exit }' "$LFMP_DIR_REPO_MP/build/containerfiles/$LFMP_TARGET_DISTRO")"
PLUGIN_DIR=/usr/lib64/nagios/plugins
# nobody, which exists on every distro and owns nothing below the venv
UNPRIVILEGED_USER=65534:65534
VENV=/usr/lib64/linuxfabrik-monitoring-plugins/venv

echo "✅ Install the $LFMP_TARGET_DISTRO package into a fresh $IMAGE container"
podman run \
    --detach \
    --mount "type=bind,source=$LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO,destination=/packaged,relabel=private,ro=true" \
    --name "$CONTAINER" \
    --replace \
    --rm \
    "$IMAGE" \
    sleep infinity
trap 'podman stop --time 0 "$CONTAINER" >/dev/null' EXIT

case "$LFMP_TARGET_DISTRO" in
debian-* | ubuntu-*)
    podman exec --env=DEBIAN_FRONTEND=noninteractive "$CONTAINER" /bin/bash -c \
        'apt-get update --quiet --quiet && apt-get install --no-install-recommends --quiet --quiet --yes /packaged/linuxfabrik-monitoring-plugins_*.deb'
    ;;
rocky-*)
    podman exec "$CONTAINER" /bin/bash -c \
        'dnf --assumeyes --quiet --setopt=install_weak_deps=False install /packaged/linuxfabrik-monitoring-plugins-[0-9]*.rpm'
    ;;
sles-*)
    podman exec "$CONTAINER" /bin/bash -c \
        'zypper --non-interactive --no-gpg-checks install --allow-unsigned-rpm --no-recommends /packaged/linuxfabrik-monitoring-plugins-[0-9]*.rpm'
    ;;
*)
    echo "Unsupported target distro"
    exit 1
    ;;
esac

echo "✅ Check the bytecode in the venv"
podman exec --interactive --user="$UNPRIVILEGED_USER" "$CONTAINER" \
    "$VENV/bin/python" - < "$LFMP_DIR_REPO_MP/build/check-bytecode.py"

echo "✅ Start every plugin"
# --version still imports every module the plugin needs, which is where a broken venv
# shows, and it needs neither a service nor privileges
podman exec --user="$UNPRIVILEGED_USER" "$CONTAINER" /bin/bash -c '
    failed=0
    total=0
    for plugin in '"$PLUGIN_DIR"'/*; do
        [ -f "$plugin" ] || continue
        total=$((total + 1))
        retc=0
        output="$("$plugin" --version 2>&1)" || retc=$?
        # argparse ends --version with 0, the plugins turn that into 3 (UNKNOWN)
        if { [ $retc -ne 0 ] && [ $retc -ne 3 ]; } || grep --quiet Traceback <<< "$output"; then
            echo "❌ $plugin --version, exit code $retc:"
            echo "$output"
            failed=$((failed + 1))
        fi
    done
    echo "$total plugins started, $failed failed"
    [ $total -gt 0 ] && [ $failed -eq 0 ]
'
