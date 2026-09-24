#!/usr/bin/env bash
# 2026092401

set -e -o pipefail -u -x

# Fail fast if the checkout does not contain the code tagged vLFMP_VERSION, so a
# stale checkout cannot ship outdated code under a newer version label
# (fix #1406). Runs here on the host because git is not available inside the
# build containers.
bash "$LFMP_DIR_REPO_MP/build/verify-version.sh"

# LFMP_TARGET_DISTROS comes from the environment and is a space-separated list, so it
# is split on purpose
# shellcheck disable=SC2086,SC2153
for LFMP_TARGET_DISTRO in $LFMP_TARGET_DISTROS; do
     # Create folders for packages by distro
    mkdir -p "$LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO"

    echo "✅ Start container for $LFMP_TARGET_DISTRO"
    podman build \
        --file "$LFMP_DIR_REPO_MP/build/containerfiles/$LFMP_TARGET_DISTRO" \
        --tag "lfmp-build-$LFMP_TARGET_DISTRO"

    echo "✅ Package the plugins on $LFMP_TARGET_DISTRO to the host's disk"
    # docker/podman does not like the "export VAR=VALUE" in our env-file, so we pass them directly
    podman run \
        --env="LFMP_ARCH=$LFMP_ARCH" \
        --env="LFMP_VERSION=$LFMP_VERSION" \
        --env="LFMP_PACKAGE_ITERATION=$LFMP_PACKAGE_ITERATION" \
        --env=LFMP_DIR_PACKAGED=/packaged \
        --env=LFMP_DIR_REPOS=/repos \
        --env=LFMP_DIR_SOURCES=/sources \
        --env="LFMP_TARGET_DISTRO=$LFMP_TARGET_DISTRO" \
        --mount "type=bind,source=$LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO,destination=/packaged,relabel=private" \
        --mount "type=bind,source=$LFMP_DIR_REPO_MP,destination=/repos/monitoring-plugins,relabel=shared,ro=true" \
        --rm \
        "lfmp-build-$LFMP_TARGET_DISTRO" \
        /bin/bash /repos/monitoring-plugins/build/create-package.sh

    echo "✅ Smoke-test the package on a fresh $LFMP_TARGET_DISTRO"
    bash "$LFMP_DIR_REPO_MP/build/smoke-test-package.sh" "$LFMP_TARGET_DISTRO"
done
