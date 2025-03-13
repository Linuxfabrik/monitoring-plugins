#!/usr/bin/env bash
# 2025021104

set -e -x

for LFMP_TARGET_DISTRO in $LFMP_TARGET_DISTROS; do
    # Create folders for compiled plugins as well as the base for packaging
    mkdir -p $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO

    echo "✅ Start container for $LFMP_TARGET_DISTRO"
    podman build \
        --file "$LFMP_DIR_REPOS/monitoring-plugins/build/containerfiles/$LFMP_TARGET_DISTRO" \
        --tag "lfmp-build-$LFMP_TARGET_DISTRO"

    echo "✅ Compile the check plugins on $LFMP_TARGET_DISTRO to the host's disk"
    # docker/podman does not like the "export VAR=VALUE" in our env-file, so we pass them directly
    podman run \
        --env=LFMP* \
        --mount type=bind,source=$LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO,destination=/compiled,relabel=private \
        --mount type=bind,source=$LFMP_DIR_REPOS,destination=/repos,relabel=shared,ro=true \
        --rm \
        lfmp-build-$LFMP_TARGET_DISTRO \
        /bin/bash /repos/monitoring-plugins/build/compile-multiple.sh
done
