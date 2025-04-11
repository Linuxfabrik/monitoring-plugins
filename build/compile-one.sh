#!/usr/bin/env bash
# 2025021602

# This script can run in a container (absolute paths) or in a Windows-VM.

set -e -x

# inputs:
PLUGINS=$1  # what to compile - "check-plugins", "notification-plugins" or "event-plugins"
PLUGIN=$2   # which plugin to compile, for example "cpu-usage"

if uname -a | grep -q "_NT"; then
    # We are on Windows.
    REPO_DIR="$LFMP_DIR_REPOS"
    if [[ ! -f "$REPO_DIR/monitoring-plugins/$PLUGINS/$PLUGIN/.windows" ]]; then
        echo "✅ Ignoring '$PLUGIN' on Windows"
        exit 0
    fi
    COMPILE_DIR="$LFMP_DIR_COMPILED"
    #ADDITIONAL_PARAMS="--include-plugin-directory=$REPO_DIR/lib --msvc=latest"
    ADDITIONAL_PARAMS="--msvc=latest"
else
    # We are in a container.
    REPO_DIR="/repos"
    COMPILE_DIR="/compiled"
    source /opt/venv/bin/activate
fi

echo "✅ Compiling $PLUGIN into $COMPILE_DIR/$PLUGINS/..."
# --no-deployment-flag=self-execution: https://github.com/Linuxfabrik/monitoring-plugins/issues/864
python3 -m nuitka \
    --assume-yes-for-downloads \
    --no-deployment-flag=self-execution \
    --output-dir=$COMPILE_DIR/$PLUGINS/ \
    --remove-output \
    --standalone \
    $ADDITIONAL_PARAMS \
    $REPO_DIR/monitoring-plugins/$PLUGINS/$PLUGIN/$PLUGIN

# rename files
if [[ -e "$COMPILE_DIR/$PLUGINS/$PLUGIN.dist/$PLUGIN.bin" ]]; then
    # happens on Linux
    mv "$COMPILE_DIR/$PLUGINS/$PLUGIN.dist/$PLUGIN.bin" "$COMPILE_DIR/$PLUGINS/$PLUGIN.dist/$PLUGIN"
fi

# move files to a merged flattened directory to save disk space if directory exists and is not empty.
if [[ -d "$COMPILE_DIR/$PLUGINS/$PLUGIN.dist" && -n "$(ls --almost-all $COMPILE_DIR/$PLUGINS/$PLUGIN.dist)" ]]; then
    # Note that we use the special /.' suffix to copy **only the contents** of the *.dist directory (preserving attributes).
    # Unfortunately, mv does not have a built‐in equivalent to "move the contents of a directory" using the/.' trick.
    # Therefore we copy and remove later to save disk space, important in github runners.
    echo "✅ cp --archive $COMPILE_DIR/$PLUGINS/$PLUGIN.dist/. $COMPILE_DIR/$PLUGINS/"
    \cp --archive --verbose $COMPILE_DIR/$PLUGINS/$PLUGIN.dist/. $COMPILE_DIR/$PLUGINS/
    rm -rf $COMPILE_DIR/$PLUGINS/$PLUGIN.dist
fi
