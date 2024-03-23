FROM grafana/grafana

# Copy Influxdb datasources conf
COPY ./datasources.yaml /etc/grafana/provisioning/datasources/datasources.yaml

# Copy a sample dashboard showing RPI system data
COPY ./dashboards.yaml /etc/grafana/provisioning/dashboards/dashboards.yaml
COPY ./example-dashboard.json /etc/grafana/provisioning/dashboards/example-dashboard.json