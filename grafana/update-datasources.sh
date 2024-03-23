#!/bin/bash

if [ `docker container ls | grep -c grafana$` -gt 0 ]
then
	docker cp ./datasources.yaml telegraf:/etc/grafana/provisioning/datasources/datasources.yaml
else
	echo "ERROR: The 'grafana' container must be running."
fi
