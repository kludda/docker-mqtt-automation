#!/bin/bash



#WD = "WorkingDirectory=$PWD"
WD = "WorkingDirectory=test"

sed -i '/WorkingDirectory/c\$WD' /tmp/foo

#cp mqtt-automation.service /etc/systemd/system/
#systemctl enable mqtt-automation
#systemctl start mqtt-automation
