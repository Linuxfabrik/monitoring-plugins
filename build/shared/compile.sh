#!/usr/bin/env bash

mkdir -p /tmp/dist/summary/{check,notification}-plugins

for dir in /repos/monitoring-plugins/check-plugins/*; do
    check="$(basename $dir)"
    if [ "$check" != "example" ]; then
        echo -e "\ncompiling $check..."
        pyinstaller_extra_cmdline=''
        if [ -f "$dir/.build_options" ]; then
            echo "Found .build_options, sourcing them"
            . "$dir/.build_options"
        fi
        pyinstaller --clean --distpath /tmp/dist/check-plugins --workpath /tmp/build/check-plugins --specpath /tmp/spec/check-plugins --noconfirm --noupx --onedir $pyinstaller_extra_cmdline "$dir/${check}"
    fi
done
\cp -a --no-clobber /tmp/dist/check-plugins/*/* /tmp/dist/summary/check-plugins

for dir in /repos/monitoring-plugins/notification-plugins/*; do
    notification="$(basename $dir)"
    if [ "$notification" != "example" ]; then
        echo -e "\ncompiling $notification..."
        pyinstaller --clean --distpath /tmp/dist/notification-plugins --workpath /tmp/build/notification-plugins --specpath /tmp/spec/notification-plugins --noconfirm --noupx --onedir "$dir/${notification}"
    fi
done
\cp -a --no-clobber /tmp/dist/notification-plugins/*/* /tmp/dist/summary/notification-plugins
