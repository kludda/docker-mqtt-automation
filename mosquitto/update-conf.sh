#!/bin/bash

if [ `docker container ls | grep -c mosquitto$` -gt 0 ]
then
	docker cp ./mosquitto.conf mosquitto:/mosquitto/config/
else
	echo "ERROR: The 'mosquitto' container must be running."
fi
