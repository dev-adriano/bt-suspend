#!/bin/bash
#Enable BT device
#/usr/local/bin/enable_bt.sh
set -euo pipefail
IFS=$'\n\t'

#lsusb
VENDOR="0cf3"
PRODUCT="e009"

for DIR in $(find /sys/bus/usb/devices/ -maxdepth 1 -type l); do
  if [[ -f $DIR/idVendor && -f $DIR/idProduct &&
        $(cat $DIR/idVendor) == $VENDOR && $(cat $DIR/idProduct) == $PRODUCT ]]; then
    echo 1 > $DIR/authorized
  fi
done
