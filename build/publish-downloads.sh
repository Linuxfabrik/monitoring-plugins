#!/usr/bin/env bash
#
# Author:  Linuxfabrik GmbH, Zurich, Switzerland
# Contact: info (at) linuxfabrik (dot) ch
#          https://www.linuxfabrik.ch/
# License: The Unlicense, see LICENSE file.
#
# Runs on the server behind download.linuxfabrik.ch, from a systemd timer.
# Publishes the zips attached to the GitHub releases of
# Linuxfabrik/monitoring-plugins:
#
#   lfmp-<version>-<iteration>.source.noarch.zip                 (lf-release.yml)
#   lfmp-<version>-<iteration>.signed-compiled.windows.x86_64.zip (lf-build-windows-x86_64.yml)
#   lfmp-<version>-<iteration>.signed-packaged.windows.x86_64.zip (lf-build-windows-x86_64.yml)
#
# Pull, not push: only this server holds the GnuPG key. Each zip is checked
# against its build provenance attestation from the workflow that builds it,
# then gets a <zip>.sha256 and a detached <zip>.asc, which
# `install-monitoring-plugins --zip` verifies. The lfmp-latest.* links point to
# the highest iteration of the latest release; a prerelease never becomes
# latest. Nothing is ever deleted here.
#
# Required environment:
#   GH_TOKEN                     read-only GitHub token, for the API and for
#                                `gh attestation verify`
#   PUBLISH_GPG_KEY              fingerprint of the signing key in the GnuPG
#                                keyring of the user running this script
#   PUBLISH_GPG_PASSPHRASE_FILE  file holding the passphrase of that key
#
# Optional environment (defaults in brackets):
#   DOWNLOADS_DIR       [/var/www/html/download.linuxfabrik.ch/monitoring-plugins]
#   DOWNLOADS_RELEASES  [10] how many of the newest releases are looked at
#   DOWNLOADS_REPO      [Linuxfabrik/monitoring-plugins]
#
# Needs: gh, gpg, sha256sum.

set -e -o pipefail -u

DOWNLOADS_DIR="${DOWNLOADS_DIR:-/var/www/html/download.linuxfabrik.ch/monitoring-plugins}"
DOWNLOADS_RELEASES="${DOWNLOADS_RELEASES:-10}"
DOWNLOADS_REPO="${DOWNLOADS_REPO:-Linuxfabrik/monitoring-plugins}"

KINDS='source.noarch signed-compiled.windows.x86_64 signed-packaged.windows.x86_64'

# The workflow that builds a zip of the given kind.
signer_workflow() {
    case "$1" in
    source.noarch) echo "$DOWNLOADS_REPO/.github/workflows/lf-release.yml" ;;
    signed-*.windows.x86_64) echo "$DOWNLOADS_REPO/.github/workflows/lf-build-windows-x86_64.yml" ;;
    esac
}

# Verify one downloaded zip and publish it with its .sha256 and .asc. The
# sidecars go first and the zip last, each by a rename inside DOWNLOADS_DIR, so a
# zip is never visible without them and every file gets the SELinux context of
# the directory.
publish_zip() {
    local file="$1" kind="$2"
    local name tmp
    name="$(basename "$file")"

    gh attestation verify "$file" \
        --repo "$DOWNLOADS_REPO" \
        --signer-workflow "$(signer_workflow "$kind")" >/dev/null

    tmp="$DOWNLOADS_DIR/.$name.tmp"
    cp "$file" "$tmp"
    (cd "$(dirname "$file")" && sha256sum "$name") > "$tmp.sha256"
    gpg --armor --batch --detach-sign --yes \
        --local-user "$PUBLISH_GPG_KEY" \
        --passphrase-file "$PUBLISH_GPG_PASSPHRASE_FILE" \
        --pinentry-mode loopback \
        --output "$tmp.asc" \
        "$tmp"
    chmod 0644 "$tmp" "$tmp.sha256" "$tmp.asc"
    touch --reference="$tmp" "$tmp.sha256" "$tmp.asc"
    mv "$tmp.sha256" "$DOWNLOADS_DIR/$name.sha256"
    mv "$tmp.asc" "$DOWNLOADS_DIR/$name.asc"
    mv "$tmp" "$DOWNLOADS_DIR/$name"
    echo "published $name"
}

# Publish the zips of one release that are not on the server yet.
publish_release() {
    local tag="$1" work="$2"
    local version="${tag#v}" asset kind dir="$work/$tag"

    mkdir "$dir"
    gh release view "$tag" --repo "$DOWNLOADS_REPO" --json assets \
        --jq '.assets[].name | select(endswith(".zip"))' > "$dir.assets"
    while read -r asset; do
        [ -n "$asset" ] || continue
        [ -e "$DOWNLOADS_DIR/$asset" ] && continue
        kind=''
        for k in $KINDS; do
            # the quoted parts match literally, dots included
            if [[ "$asset" =~ ^lfmp-"$version"-[0-9]+\."$k"\.zip$ ]]; then
                kind="$k"
            fi
        done
        if [ -z "$kind" ]; then
            echo "$tag: ignoring the unexpected asset $asset" >&2
            continue
        fi
        gh release download "$tag" --repo "$DOWNLOADS_REPO" --pattern "$asset" --dir "$dir"
        publish_zip "$dir/$asset" "$kind"
    done < "$dir.assets"
}

# Point lfmp-latest.<kind>.zip (and its sidecars) at the highest iteration of
# the latest release.
update_latest() {
    local latest version kind newest suffix
    latest="$(gh release view --repo "$DOWNLOADS_REPO" --json tagName --jq '.tagName')"
    version="${latest#v}"
    for kind in $KINDS; do
        newest="$(cd "$DOWNLOADS_DIR" &&
            find . -maxdepth 1 -type f -name "lfmp-$version-*.$kind.zip" -printf '%f\n' |
            sort --version-sort | tail -n 1)"
        [ -n "$newest" ] || continue
        for suffix in '' .sha256 .asc; do
            if [ "$(readlink "$DOWNLOADS_DIR/lfmp-latest.$kind.zip$suffix" || true)" != "$newest$suffix" ]; then
                ln --force --no-dereference --symbolic "$newest$suffix" \
                    "$DOWNLOADS_DIR/lfmp-latest.$kind.zip$suffix"
                echo "lfmp-latest.$kind.zip$suffix -> $newest$suffix"
            fi
        done
    done
}

main() {
    local work tag
    work="$(mktemp -d)"
    # shellcheck disable=SC2064 # expand now, the variable is local
    trap "rm -rf '$work'" EXIT

    # Not `done < <(gh ...)`, here and in publish_release: bash ignores the exit
    # code of a process substitution, and a failed listing must fail the run.
    gh release list --repo "$DOWNLOADS_REPO" --exclude-drafts \
        --limit "$DOWNLOADS_RELEASES" --json tagName --jq '.[].tagName' > "$work/releases"
    while read -r tag; do
        publish_release "$tag" "$work"
    done < "$work/releases"

    update_latest
}

main "$@"
