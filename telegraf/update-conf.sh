#!/bin/bash

if [ `docker container ls | grep -c telegraf$` -gt 0 ]
then
	docker cp ./telegraf.conf telegraf:/etc/telegraf/
else
	echo "ERROR: The telegraf container must be running."
fi
