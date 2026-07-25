#!/usr/bin/env bash
# 2026072501

# Guard against packaging a checkout whose code does not correspond to
# LFMP_VERSION (fix #1406).
#
# create-src-tarball.sh archives whatever code is in the checkout and uses
# LFMP_VERSION only to name the tarball, so a stale checkout silently ships
# outdated code under a newer version label. The only reliable link between the
# code and the version is the vLFMP_VERSION git tag, so we verify it here.
#
# The build workflows check out "main" HEAD (no explicit ref) so that
# re-running a failed build picks up a post-release fix on main. HEAD may
# therefore sit ahead of the vLFMP_VERSION tag, and we must NOT require an exact
# tag match. We only require that the tag is reachable from HEAD: a stale
# checkout that predates or diverges from the tag fails here.
#
# git is not installed inside the build containers and the repo is bind-mounted
# read-only there, so this runs on the host (the runner or the release
# manager's machine), not inside create-src-tarball.sh.
#
# Set LFMP_SKIP_VERSION_CHECK to a non-empty value to bypass this guard for an
# intentional build of an untagged development checkout.

set -e -o pipefail -u -x

echo "✅ Verify checkout matches LFMP_VERSION"

REPO_DIR="${1:-$LFMP_DIR_REPO_MP}"
LFMP_TAG="v$LFMP_VERSION"

if [ -n "${LFMP_SKIP_VERSION_CHECK:-}" ]; then
    echo "⚠️  LFMP_SKIP_VERSION_CHECK is set, skipping the $LFMP_TAG version check."
    exit 0
fi

if ! git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "❌ $REPO_DIR is not a git repository, cannot verify it matches $LFMP_TAG." >&2
    echo "   Set LFMP_SKIP_VERSION_CHECK=1 to build anyway." >&2
    exit 1
fi

if ! git -C "$REPO_DIR" rev-parse --verify --quiet "refs/tags/$LFMP_TAG" >/dev/null; then
    echo "❌ Tag $LFMP_TAG not found in $REPO_DIR." >&2
    echo "   Fetch tags (git fetch --tags) or set LFMP_SKIP_VERSION_CHECK=1 to build anyway." >&2
    exit 1
fi

if ! git -C "$REPO_DIR" merge-base --is-ancestor "$LFMP_TAG" HEAD; then
    echo "❌ The checkout does not contain the code tagged $LFMP_TAG." >&2
    echo "   HEAD is $(git -C "$REPO_DIR" rev-parse --short HEAD), which predates or diverges from $LFMP_TAG." >&2
    echo "   Packaging it would label outdated code as $LFMP_VERSION." >&2
    echo "   Check out $LFMP_TAG (or a descendant) or set LFMP_SKIP_VERSION_CHECK=1 to build anyway." >&2
    exit 1
fi

echo "✅ Checkout at $(git -C "$REPO_DIR" rev-parse --short HEAD) contains $LFMP_TAG, version label matches."
