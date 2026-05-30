#!/usr/bin/env bash
# 2026053001

# This script can run in a container (absolute paths) or in a Windows-VM.

set -e -x

if uname -a | grep -q "_NT"; then
    # We are on Windows.
    IS_WINDOWS='yes'
    REPO_DIR="$LFMP_DIR_REPOS"
    COMPILE_DIR="$LFMP_DIR_COMPILED"
else
    # We are in a container.
    IS_WINDOWS='no'
    REPO_DIR="/repos"
    COMPILE_DIR="/compiled"
fi

if [ "$IS_WINDOWS" = 'no' ]; then
    # We are in a container.
    source /opt/venv/bin/activate
    PY_TAG="py$(python3 -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')"
    REQS="$REPO_DIR/monitoring-plugins/lockfiles/${PY_TAG}/requirements.txt"
    if [ ! -f "$REQS" ]; then
        echo "❌ No requirements file for Python ${PY_TAG} at $REQS" >&2
        exit 1
    fi
    python3 -m pip install --requirement="$REQS" --require-hashes
fi
python3 --version

SCRIPT_DIR="$(dirname "$0")"
COMPILE_ONE="$SCRIPT_DIR/compile-one.sh"

# Number of plugins to compile concurrently. Defaults to 4 (the GitHub Windows
# runner has 4 vCPUs). Override with LFMP_COMPILE_JOBS.
JOBS="${LFMP_COMPILE_JOBS:-4}"

# Capture the optional user-provided plugin list once. The per-group logic
# below mirrors the original behaviour: when a list is given it applies to
# check-plugins only; event-plugins and notification-plugins are skipped.
USER_PLUGIN_LIST="$LFMP_COMPILE_PLUGINS"

# Build a flat list of "<group> <plugin>" tasks to compile.
TASKS=()
for PLUGINS in event-plugins notification-plugins check-plugins ; do
    if [[ -n "$USER_PLUGIN_LIST" && "$PLUGINS" != "check-plugins" ]]; then
        # if a check-plugin list is given, skip event-plugins and notification-plugins to save time
        echo "✅ Skipping $REPO_DIR/monitoring-plugins/$PLUGINS..."
        continue
    fi
    if [[ ! -d "$REPO_DIR/monitoring-plugins/$PLUGINS" ]]; then
        echo "✅ $REPO_DIR/monitoring-plugins/$PLUGINS does not exist, ignoring..."
        continue
    fi
    echo "✅ Processing $PLUGINS..."

    if [[ -z "$USER_PLUGIN_LIST" ]]; then
        echo "✅ No plugin list provided. Discovering all plugins..."
        # List the directories immediately under $PLUGINS/ by basename.
        # avoid using `find` as this is sometimes problematic in Github runners
        GROUP_PLUGINS=$(
            for d in "$REPO_DIR/monitoring-plugins/$PLUGINS"/*; do
                [ -d "$d" ] && basename "$d"
            done | sort
        )
        echo "✅ Found '$GROUP_PLUGINS'"
    else
        GROUP_PLUGINS="$USER_PLUGIN_LIST"
    fi

    for PLUGIN in $GROUP_PLUGINS; do
        if [ "$PLUGIN" == "example" ]; then
            continue
        fi
        if [[ ! -d "$REPO_DIR/monitoring-plugins/$PLUGINS/$PLUGIN" ]]; then
            echo "✅ Directory $REPO_DIR/$PLUGINS/$PLUGIN does not exist. Ignoring..."
            continue
        fi
        # On Windows only plugins carrying a `.windows` marker get compiled
        # (compile-one.sh enforces this too). Filter them out here so the
        # parallel pool below is not filled with immediate no-op invocations.
        if [[ "$IS_WINDOWS" = 'yes' && ! -f "$REPO_DIR/monitoring-plugins/$PLUGINS/$PLUGIN/.windows" ]]; then
            echo "✅ Ignoring '$PLUGIN' on Windows (no .windows marker)"
            continue
        fi
        TASKS+=("$PLUGINS $PLUGIN")
    done
done

# Compile. The first plugin runs alone to warm up Nuitka's download/cache dir
# (depends.exe, ccache, ...), so the parallel batch that follows does not race
# on first-time downloads. The rest run up to $JOBS at a time. xargs returns
# non-zero if any invocation fails, so `set -e` aborts the whole build.
if (( ${#TASKS[@]} > 0 )); then
    echo "✅ Compiling ${#TASKS[@]} plugin(s), up to $JOBS in parallel..."
    read -r WARM_GROUP WARM_PLUGIN <<< "${TASKS[0]}"
    bash "$COMPILE_ONE" "$WARM_GROUP" "$WARM_PLUGIN"
    if (( ${#TASKS[@]} > 1 )); then
        printf '%s\n' "${TASKS[@]:1}" | xargs -P "$JOBS" -L 1 bash "$COMPILE_ONE"
    fi
fi

# Merge each plugin's standalone `*.dist` directory into the shared, flattened
# group directory to save disk space (important on Github runners). Done here,
# serially, after all parallel compiles finished, so the shared runtime files
# the plugins all carry (python3xx.dll etc.) are never written concurrently.
# The special `/.` suffix copies only the *contents* of each dist directory.
for PLUGINS in event-plugins notification-plugins check-plugins ; do
    GROUP_DIR="$COMPILE_DIR/$PLUGINS"
    [ -d "$GROUP_DIR" ] || continue
    for DIST in "$GROUP_DIR"/*.dist ; do
        [ -d "$DIST" ] || continue
        if [ -n "$(ls --almost-all "$DIST")" ]; then
            echo "✅ cp --archive $DIST/. $GROUP_DIR/"
            \cp --archive "$DIST"/. "$GROUP_DIR"/
        fi
        rm -rf "$DIST"
    done
done

# On RHEL? Then also compile the Linuxfabrik Type Enforcement Policy
if ! command -v getenforce &> /dev/null; then
    exit 0
fi
mkdir /tmp/selinux
cp $REPO_DIR/monitoring-plugins/assets/selinux/linuxfabrik-monitoring-plugins.te /tmp/selinux/
cd /tmp/selinux/
make --file /usr/share/selinux/devel/Makefile linuxfabrik-monitoring-plugins.pp
mkdir -p /compiled/check-plugins/assets/
\cp --archive linuxfabrik-monitoring-plugins.pp /compiled/check-plugins/assets/
