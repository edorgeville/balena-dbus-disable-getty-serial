#!/bin/sh

set -ex

# Mask the service, making it point to /dev/null
DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket \
  dbus-send \
  --system \
  --print-reply \
  --dest=org.freedesktop.systemd1 \
  /org/freedesktop/systemd1 \
  org.freedesktop.systemd1.Manager.MaskUnitFiles \
  array:string:"serial-getty@serial0.service" \
  boolean:true \
  boolean:true

# Stop the service.
# Details about the second parameter: 
#> The mode needs to be one of replace, fail, isolate, ignore-dependencies,
#> ignore-requirements. If "replace" the call will start the unit and its
#> dependencies, possibly replacing already queued jobs that conflict with this.
DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket \
  dbus-send \
  --system \
  --print-reply \
  --dest=org.freedesktop.systemd1 \
  /org/freedesktop/systemd1 \
  org.freedesktop.systemd1.Manager.StopUnit \
  string:"serial-getty@serial0.service" \
  string:replace

balena-idle