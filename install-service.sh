#!/bin/bash

WD="WorkingDirectory=$PWD"

sed -i '@WorkingDirectory@c'"$PWD"'@' ./mqtt-automation.service

#cp mqtt-automation.service /etc/systemd/system/
#systemctl enable mqtt-automation
#systemctl start mqtt-automation
