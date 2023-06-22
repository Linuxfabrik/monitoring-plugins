#!/usr/bin/env bash

mkdir -p /tmp/dist/summary/{check,notification}-plugins

for dir in /repos/monitoring-plugins/check-plugins/*; do
    check="$(basename $dir)"
    if [ "$check" != "example" ]; then
        echo -e "\ncompiling $check..."
        pyinstaller --clean --distpath /tmp/dist/check-plugins --workpath /tmp/build/check-plugins --specpath /tmp/spec/check-plugins --noconfirm --noupx --onedir "$dir/${check}"
    fi
done
\cp -a /tmp/dist/check-plugins/*/* /tmp/dist/summary/check-plugins

for dir in /repos/monitoring-plugins/notification-plugins/*; do
    notification="$(basename $dir)"
    if [ "$notification" != "example" ]; then
        echo -e "\ncompiling $notification..."
        pyinstaller --clean --distpath /tmp/dist/notification-plugins --workpath /tmp/build/notification-plugins --specpath /tmp/spec/notification-plugins --noconfirm --noupx --onedir "$dir/${notification}"
    fi
done
\cp -a /tmp/dist/notification-plugins/*/* /tmp/dist/summary/notification-plugins
