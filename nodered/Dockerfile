FROM nodered/node-red

# Copy example flows
COPY ./flows.json /data/flows.json

# Get latsest npm
RUN npm update -g

# Install the dashboard
RUN npm install node-red-dashboard

# Install the Influxdb node
RUN npm install node-red-contrib-influxdb

# RUN npm install node-red-contrib-telegrambot
# RUN npm install node-red-contrib-timeout

# Install a source of data to log in Influxdb with sample flows.
# https://flows.nodered.org/flow/c87d62e3b0d9f1ebfbbdf6aa9300c690
# RUN npm install node-red-contrib-os
