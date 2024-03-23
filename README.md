# Data logger stack

This repository contains a data logger stack intended for quick setup in a closed R&D environment for the purpose of logging of test.

* [Mosquitto](https://mosquitto.org/)
* [Node-RED](https://nodered.org/)
* [InfluxDB](https://www.influxdata.com/)
* [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/)
* [Grafana](https://grafana.com/)

> [!CAUTION]
> This stack is not secured.

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


#### Write datapoint to InfluxDB in NodeRED
In the Node-RED environment there is a "catch-all" MQTT example flow that compose a InfluxDB line protocol from the topic structure and publish this to `influxdb/write`. 

MQTT topic convention:
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

To show more info in the label in the legend add a `GROUP BY`.
```
SELECT "temperature" FROM "thermostat" WHERE ("device"::tag = 'device123') AND $timeFilter GROUP BY "device"::tag
```


### InfluxDB admin interface

InfluxDB serves a web interface on port 8086 of your host machine, e.g. http://localhost:8086. A user and bucket is setup by default first time `docker compose up` is run.


### Mosquitto

Mosquitto will be listening on port 1883 of your host machine and is already configured by default.

You can use any MQTT client to connect to it. Using debian and `mosquitto-client` utilities is as simple as:

```
$ sudo apt install mosquitto-clients
$ mosquitto_sub -v -t /mytopic &
$ mosquitto_pub -t /mytopic -m hello
```


## Installation 

The instructions below will asume you are working from the command line.

### Install docker

Installing `docker` using the convinience script:

```
$ curl -sSL https://get.docker.com/ | sh
```

Add your user to the docker group:

```
$ sudo usermod -aG docker $USER
```

Logout and login to apply. Or run:

```
$ sudo su $USER
```

And check it is working:

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

### Checkout the repo

Install git

```
$ sudo apt install git
```

Clone repo:

```
$ cd $HOME
$ git clone https://github.com/kludda/data-logger-stack.git --branch rpi
$ cd data-logger-stack
```






### Run the project

Run the containers detached:

```
$ docker compose up -d
```


## Maintenance 


### Update the project

TBD: rm images and rebuild..

If the repository gets updated and you want to have the latest changes you can do it without losing any info in your persisted volumes. Only stop, pull the changes and start again the containers:

chmod +x update-conf.sh 


```
$ cd $HOME/data-logger-stack
$ docker compose stop
$ git pull
$ docker compose pull
$ docker compose up -d
```
If e.g. a config file has changed the image needs to be built.
The --no-cache option is needed else old config is used.
```
docker compose build --no-cache mosquitto
```






### Working with Docker

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


#### Bringing up
In the folder, where the `docker-composer.yml` file is.



#### Starting and stoping

In the folder, where the `docker-composer.yml` file is.


Stop containers:

```
$ docker compose stop
```

start them again 

```
$ docker compose start
```


#### Taking down
In the folder, where the `docker-composer.yml` file is.



To remove the project from your drive: 

```
$ docker compose down
```

and, if you also want to delete the persisted files: 

```
$ docker volume prune
```

List images 

```
$ docker image ls
```
Remove images

```
$ docker image rm myimagename
```

## Components



## Installation of Raspberry Pi OS

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
