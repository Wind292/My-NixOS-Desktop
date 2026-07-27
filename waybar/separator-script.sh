#!/bin/sh

if busctl --user get-property \
    org.kde.StatusNotifierWatcher \
    /StatusNotifierWatcher \
    org.kde.StatusNotifierWatcher \
    RegisteredStatusNotifierItems \
    2>/dev/null | grep -q '"'; then
    echo " |"
fi

