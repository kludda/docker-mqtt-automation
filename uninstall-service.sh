#!/bin/bash

systemctl stop mqtt-automation
systemctl disable mqtt-automation
rm /etc/systemd/system/mqtt-automation
rm /etc/systemd/system/mqtt-automation # and symlinks that might be related
rm /usr/lib/systemd/system/mqtt-automation 
rm /usr/lib/systemd/system/mqtt-automation # and symlinks that might be related
rm /etc/init.d/mqtt-automation
systemctl daemon-reload
systemctl reset-failed
