#!/bin/bash

sed -i '\|WorkingDirectory|c\WorkingDirectory='$PWD ./mqtt-automation.service
cp mqtt-automation.service /etc/systemd/system/
systemctl enable mqtt-automation
