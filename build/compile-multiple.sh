#!/usr/bin/env bash
# 2025021501

# This script can run in a container (absolute paths) or in a Windows-VM.

set -e -x

if uname -a | grep -q "_NT"; then
    # We are on Windows.
    REPO_DIR="$LFMP_DIR_REPOS"
else
    # We are in a container.
    REPO_DIR="/repos"
fi

if ! uname -a | grep -q "_NT"; then
    # We are in a container.
    source /opt/venv/bin/activate
    python3 -m pip install --requirement="$REPO_DIR/monitoring-plugins/requirements.txt" --require-hashes
fi
python3 --version

# Loop through each plugin in the list.
for PLUGINS in check-plugins notification-plugins event-plugins; do
    if [[ ! -d "$REPO_DIR/monitoring-plugins/$PLUGINS" ]]; then
        echo "✅ $REPO_DIR/monitoring-plugins/$PLUGINS does not exist, ignoring..."
        continue
    fi
    echo "✅ Processing $PLUGINS..."

    # If $LFMP_COMPILE_PLUGINS is empty, find all plugin directories under
    # $REPO_DIR/monitoring-plugins/$PLUGINS/ and create a space-separated list.
    if [[ -z "$LFMP_COMPILE_PLUGINS" ]]; then
        echo "✅ No plugin list provided. Discovering all plugins..."
        # Find directories immediately under $PLUGINS/, extract their basenames, and join them with commas.
        LFMP_COMPILE_PLUGINS=$(find "$REPO_DIR/monitoring-plugins/$PLUGINS" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort)
        echo "✅ Found '$LFMP_COMPILE_PLUGINS'"
    fi

    for PLUGIN in $LFMP_COMPILE_PLUGINS; do
        if [ "$PLUGIN" == "example" ]; then
            continue
        fi
        echo "✅ Processing $PLUGIN"
        if [[ -d "$REPO_DIR/monitoring-plugins/$PLUGINS/$PLUGIN" ]]; then
            echo $(pwd)
            bash $(dirname "$0")/compile-one.sh $PLUGINS $PLUGIN
        else
            echo "✅ Directory $REPO_DIR/$PLUGINS/$PLUGIN does not exist. Ignoring..."
        fi
    done
    LFMP_COMPILE_PLUGINS=""
done

# On RHEL? Then also compile the Linuxfabrik Type Enforcement Policy
if ! command -v getenforce &> /dev/null; then
    exit 0
fi
mkdir /tmp/selinux
cp $REPO_DIR/monitoring-plugins/assets/selinux/linuxfabrik-monitoring-plugins.te /tmp/selinux/
cd /tmp/selinux/
make --file /usr/share/selinux/devel/Makefile linuxfabrik-monitoring-plugins.pp
\cp --archive linuxfabrik-monitoring-plugins.pp /compiled/check-plugins
