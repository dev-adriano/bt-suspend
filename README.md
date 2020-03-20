# Bluetooth Suspend Service
The service disables Wifi and Bluetooth on suspend, then re-enables both upon resume.

With a text editor create:
```
/etc/systemd/system/bt-restart.service
```
bt restart service file contents:
```
#/etc/systemd/system/bt-restart.service
#sudo systemctl enable bt-restart.service
#sudo systemctl start bt-restart.service
#sudo systemctl stop bt-restart.service
#sudo systemctl disable bt-restart.service
#systemctl status bt-restart.service
#sudo systemctl daemon-reload

[Unit]
Description=Disable, then restart bt
Before=sleep.target
StopWhenUnneeded=yes

[Service]
User=root
Type=oneshot
RemainAfterExit=yes
ExecStartPre=-/usr/bin/sudo -u $USER /bin/bash -lc 'nmcli networking off'
ExecStart=/usr/bin/sleep 1
ExecStart=/usr/bin/sudo -E  /usr/local/bin/disable_bt.sh
ExecStop=/usr/bin/sudo -E  /usr/local/bin/enable_bt.sh
ExecStop=/usr/bin/sleep 2
ExecStopPost=-/usr/bin/sudo -u $USER /bin/bash -lc 'nmcli networking on'

[Install]
WantedBy=sleep.target
```
## Disable BT Suspend Script

Create the script that is to disable BT before suspending.

With a text editor create:
```
/usr/local/bin/disable_bt.sh
```
Suspend script contents:
```
#!/bin/bash
#Disable BT device
#/usr/local/bin/disable_bt.sh
set -euo pipefail
IFS=$'\n\t'

VENDOR="0489"
PRODUCT="e0a2"

for DIR in $(find /sys/bus/usb/devices/ -maxdepth 1 -type l); do
  if [[ -f $DIR/idVendor && -f $DIR/idProduct &&
        $(cat $DIR/idVendor) == $VENDOR && $(cat $DIR/idProduct) == $PRODUCT ]]; then
    echo 0 > $DIR/authorized
  fi
done
```
Save the file, and exit the text editor.

## Enable BT Resume Script

Create the script that is to be executed after coming out of suspend.

With a text editor create:
```
/usr/local/bin/enable_bt.sh
```
Resume script contents:
```
#!/bin/bash
#Enable BT device
#/usr/local/bin/enable_bt.sh
set -euo pipefail
IFS=$'\n\t'

VENDOR="0489"
PRODUCT="e0a2"

for DIR in $(find /sys/bus/usb/devices/ -maxdepth 1 -type l); do
  if [[ -f $DIR/idVendor && -f $DIR/idProduct &&
        $(cat $DIR/idVendor) == $VENDOR && $(cat $DIR/idProduct) == $PRODUCT ]]; then
    echo 1 > $DIR/authorized
  fi
done
```
Enable the service.
```
sudo systemctl enable bt-restart.service
```
Then, ensure both scripts are executable:
```
chmod +x /usr/local/bin/disable_bt.sh
chmod +x /usr/local/bin/enable_bt.sh
```
Then restart.

Anyone wishing to disable a different USB device can easily do so by altering the script, inserting your devices ID.

You can find the device ID of of the USB component you wish disabled with the command ```lsusb```.

Substitute your devices ID you wish disabled in the fields for "VENDOR" and "PRODUCT" in the script above.

These are the fields you must insert your own device ID:
```
VENDOR="0489"
PRODUCT="e0a2"
```
Source: [Manjaro Forum](https://forum.manjaro.org/t/writing-systemd-service-units/60350/98)
