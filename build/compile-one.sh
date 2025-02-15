#!/usr/bin/env bash
# 2025021501

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
python3 -m nuitka \
    --assume-yes-for-downloads \
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
