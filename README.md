# MQTT Automation

Thiss Docker app contains an automation, data logger and vizualization stack intended for quick setup in a closed R&D environment or home network.

The stack contains:

* [Mosquitto](https://mosquitto.org/)
* [Node-RED](https://nodered.org/)
* [InfluxDB](https://www.influxdata.com/)
* [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/)
* [Grafana](https://grafana.com/)

> [!WARNING]
> This Docker app is unsecure.


## Installation

These instructions asumes you are working from the command line.

### Install `docker`

Install `docker` using the convinience script and add your user to the docker group:

```
$ curl -sSL https://get.docker.com/ | sh
$ sudo usermod -aG docker $USER
```

Logout and login to apply. Or run:

```
$ sudo su $USER
```

And check that it is working:

```
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
1b930d010525: Pull complete 
Digest: sha256:2557e3c07ed1e38f26e389462d03ed943586f744621577a99efb77324b0fe535
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
...

```


### Install `git`

Install `git`

```
$ sudo apt install git
```

### Clone this repository

Clone repository:

```
$ cd $HOME
$ git clone https://github.com/kludda/docker-mqtt-automation.git

```


### Running the app using `systemctl`

The app can be installed by installing a `systemd` service using the provided script. The app will then be restarted on boot.

`docker` will build the images the first time the service is started which takes a significant time. Starting the containers also takes quite some time. The `systemctl` command is quiet so you will not see the startup process.

Go to the app folder:
```
$ cd $HOME/docker-mqtt-automation
```

Install the service:
```
$ sudo sh install-service.sh
```

To start the app run:
```
$ sudo systemctl start mqtt-automation
```

To stop the app run:
```
$ sudo systemctl stop mqtt-automation
```


### Running the app using `docker compose`

Alternatively to the above the app can be run using the `docker compose` command.

Go to the app folder:
```
$ cd $HOME/docker-mqtt-automation
```

To start the app run:
```
$ docker compose up -d
```

If you want the to see the output from the containers for debuging purpose, start the containers attached:
```
$ docker compose up
```

To stop the app run:
```
$ docker compose down
```

The app will not restart on reboot when using this method.

Stop the app before you install the service and use the `systemctl` command to control the app instead.


## Usage


### MQTT topic convention

The suggested MQTT topic convention is inspired from the [Homie convention](https://homieiot.github.io/).

```
<root topic>/<device>/<node>/<property>
<root topic>/<device>/<node>/<property>/set
```

Example:
```
home/device123/thermostat/temperature -> 23
1 -> home/device123/thermostat/switch/set
home/device123/thermostat/switch -> 1
```


### Write data point to InfluxDB with MQTT

Telegraf collects metrics and outputs to the database.
Telegraf is configured by default to subscribe to `influxdb/#`.

To write a data point to InfluxDB just publish a message to any topic under the root topic `influxdb`.

```
influxdb/<any topic>
```

The message shall be formated according to [InfluxDB line protocol](https://docs.influxdata.com/influxdb/v2/reference/syntax/line-protocol/).

```
// Syntax
<measurement>[,<tag_key>=<tag_value>[,<tag_key>=<tag_value>]] <field_key>=<field_value>[,<field_key>=<field_value>] [<timestamp>]

// Example
thermostat,device=device123 temperature=23
```

A device can publish to this topic directly. This is reasonable only if a device only need to write data points to the database and there is no need to notify other devices. 



### Automation and control UI

Automation and message manipulation is done in the Node-RED visual programming tool.

Node-RED serves a web interface on port 1880 of your host manchine, e.g. http://localhost:1880.

Control UI is the Node-RED dashboard. The additional node `node-red-dashboard` is installed by default.


#### Write datapoint to InfluxDB in Node-RED
In the Node-RED environment there is a "catch-all" MQTT example flow that compose a InfluxDB line protocol from the topic structure and publish this to `influxdb/write`. 

MQTT topic convention (from above):
```
<root topic>/<device>/<node>/<property>
home/device123/thermostat/temperature -> 23
```
The line protocol is composed acc to this schema: 

```
<node>,device=<device> <property>=<message>
```
Example:
```
thermostat,device=device123 temperature=23
```
#### Read datapoint from InfluxDB in NodeRED

In the Node-RED environment there is an example flow that reads datapoint(s) from InfluxDB.

The query language is [Flux](https://docs.influxdata.com/influxdb/v2/query-data/).

Example query that retrieves the last datapoint within the last 30d:

```
from(bucket: "{{bucket}}")
    |> range(start: -30d)
    |> filter(fn: (r) => r._measurement == "thermostat" and r.device == "device123")
    |> filter(fn: (r) => r._field == "temperature")
    |> last()
```

Note that `{{bucket}}` is Mustache syntax to substitute with property of the NodeRED msg object, not Flux syntax.


### Data visualizing

Grafana is used for data visualizing. Grafana serves a web interface on port 3000 of your host machine, e.g. http://localhost:3000. The first time it will ask you for a user (`admin`) and password (`admin`) and immeditely will ask you to change the admin password.

The datasource is already configured in Grafana.

In Grafana a query would look like this:
```
SELECT "temperature" FROM "thermostat" WHERE ("device"::tag = 'device123') AND $timeFilter
```

To show more info in the label in the of a graph legend, add a `GROUP BY`.
```
SELECT "temperature" FROM "thermostat" WHERE ("device"::tag = 'device123') AND $timeFilter GROUP BY "device"::tag
```

An example dashboard is provided in the grafana folder. To import the dashboard follow this process in the Grafana UI:

Home -> Dashboards -> New -> Import

### InfluxDB admin interface

InfluxDB serves a web interface on port 8086 of your host machine, e.g. http://localhost:8086. A user and bucket is setup by default first time the app is run.


### Mosquitto

Mosquitto will be listening on port 1883 of your host machine and is already configured by default.


## Maintenance 


### Update the app

If the repository gets updated and you want to have the latest changes you can do it without losing any info in your persisted volumes. Only stop, pull the changes and start again the containers:

Go to the app folder:
```
$ cd $HOME/docker-mqtt-automation
```

Stop the app according to the method it was started:
```
$ sudo systemctl stop mqtt-automation
or
$ docker compose down
```

If you made changes to the files in the repository the `git pull` will not work. Copy those files to outside the repository (if you want) and reset the repository. WARNING: your changes in the repository will be lost!
```
git reset --hard HEAD
```

Update your copy of the repository:
```
$ git pull
```

Get latest images. It might be that latest images have changes that breaks this app so maybe do this only if you are experiencing bugs in the softwares.
```
$ docker compose pull
```

Start the app:
```
$ sudo systemctl start mqtt-automation
or
$ docker compose up -d
```

If a config file has changed it will not be updated since it already exist in the persisting volume. If you want to update the configuration file of a software you can do so with the provided script. The containers must be running. WARNING: This will overwrite any changes you have made to the configuration file!

```
$ cd telegraf
$ sh update-conf.sh
$ cd ..
```

If you want to update all the configuration files you can do so with the provided script. The containers must be running. WARNING: This will overwrite any changes you have made to the configuration files!

```
$ sh update-all-conf.sh
```

Restart the app for the changes to take effect:
```
$ docker compose restart
```


### Backing up the app

To be completed.


## Uninstall

Go to the app folder:
```
$ cd $HOME/docker-mqtt-automation
```

Stop the app according to the method it was started:
```
$ sudo systemctl stop mqtt-automation
or
$ docker compose down
```

Uninstall the service if it was installed using the provided script. You will probably se a few errors "rm: cannot remove...", that is ok.
```
$ sudo sh uninstall-service.sh
```

Delete the persisted files, if you want.
WARNING: The data will be lost.
WARNING: This command delete ALL volumes not currently attached to a container. Be carefull if you have other docker containers on your system except this app.
```
$ docker volume prune -a
```

Remove images.
WARNING: This command delete ALL images not currently used by a container.
```
$ docker image prune -a
```

Remove repository:
```
$ cd ..
$ rm -Rf docker-mqtt-automation
```

All files associated with this app should now be removed from your host machine.

`docker` and `git` are still installed on your host machine.


### Working with Docker

A few commands as note for myself.

#### Running containers

See runnning containers 
```
$ docker ps
```

#### Volumes

See volumes 
```
$ docker volume ls
```

Inspect volumes, e.g. see their location in your drive:
```
$ docker volume inspect myvolumename
```

#### Images

List images:
```
$ docker image ls
```

Remove image (triggers a rebuild on bringing a docker app up):
```
$ docker image rm myimagename
```




## Installation of Raspberry Pi OS
(Notes for myself)

Insert SD card in computer

Download Raspberry Pi Imager
https://www.raspberrypi.com/software/

Install and run Raspberry Pi Imager

For 3 B+ I selected
Raspberry Pi OS (Legacy, 64-bit) Lite 

Edit OS settings
* Required: enable SSH

https://superuser.com/questions/1374323/how-do-i-fix-my-sd-card-after-it-was-split-into-multiple-drives-by-windows-lot-c

## Inspiration
https://github.com/ttncat/ttncat-docker-compose was used as a boiler plate for this repo.
