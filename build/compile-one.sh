#!/usr/bin/env bash
# 2026053001

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

# The compiled plugin is left in its own `$PLUGIN.dist` directory on purpose.
# Flattening every plugin's dist into the shared `$COMPILE_DIR/$PLUGINS/`
# directory is done centrally by compile-multiple.sh *after* all plugins are
# built, so that several compile-one.sh runs can execute in parallel without
# racing on the shared runtime files (python3xx.dll etc.) they all carry.
