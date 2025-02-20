#!/usr/bin/env bash
# 2025022002

set -e

if ! command -v jq &> /dev/null; then
    sudo apt update
    sudo apt -y install jq
fi

echo "✅ Fetching all artifacts via REST and filtering by name to get the latest version"
ARTIFACT_NAME="version"
PAGE=1
ARTIFACT_INFO="{}"

while true; do
    echo "✅ Fetching page $PAGE..."
    RESPONSE=$(curl --silent \
      --header "Authorization: Bearer $GITHUB_TOKEN" \
      --header "Accept: application/vnd.github.v3+json" \
      "$GITHUB_API_URL/repos/$GITHUB_REPOSITORY/actions/artifacts?per_page=100&page=$PAGE")

    # Check if there are any artifacts on this page.
    ARTIFACT_COUNT=$(echo "$RESPONSE" | jq ".artifacts | length")
    if [[ "$ARTIFACT_COUNT" -eq 0 ]]; then
        echo "❌ No more artifacts found. Exiting..."
        exit 1
    fi

    # Filter for artifacts with the name "version" and get the one with the latest created_at.
    ARTIFACT_INFO=$(echo "$RESPONSE" | jq --raw-output \
        ".artifacts | map(select(.name == \"$ARTIFACT_NAME\")) | sort_by(.created_at) | last // {}")

    # If we found an artifact, break out of the loop.
    if [[ "$ARTIFACT_INFO" != "{}" ]]; then
        echo "✅ Found $ARTIFACT_COUNT artifcats with '$ARTIFACT_NAME' artifact on page $PAGE."
        break
    fi

    PAGE=$((PAGE+1))
done

# Extract the download URL.
ARTIFACT_URL=$(echo "$ARTIFACT_INFO" | jq --raw-output ".archive_download_url // empty")
echo "✅ Artifact URL: $ARTIFACT_URL"

if [[ -z "$ARTIFACT_URL" ]]; then
    echo "❌ No previous version artifact found. Exiting..."
    exit 1
else
    echo "✅ Downloading artifact from: $ARTIFACT_URL"
    curl --silent \
        --header "Authorization: Bearer $GITHUB_TOKEN" \
        --location \
        --output version.zip \
        "$ARTIFACT_URL"
    unzip -o version.zip
    LFMP_VERSION=$(cat version.txt)
    rm -f version.txt version.zip
    echo "✅ Extracted version: $LFMP_VERSION"
    # Append an environment variable for later steps
    if [[ -z $GITHUB_ENV ]]; then
        # we are not on a GitHub runner
        export LFMP_VERSION=$LFMP_VERSION
    else
        echo "LFMP_VERSION=$LFMP_VERSION" >> "$GITHUB_ENV"
    fi
fi
