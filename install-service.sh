#!/bin/bash

sed '\|WorkingDirectory|c\WorkingDirectory='$PWD ./mqtt-automation.service > /etc/systemd/system/mqtt-automation.service

systemctl enable mqtt-automation
