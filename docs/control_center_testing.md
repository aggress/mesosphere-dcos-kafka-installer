# Control Center Testing

Control Center provides useful information around the health of Kafka as well as allowing you to configure Connect tasks more easily than using the REST API.

## Access Control Center

Ensure you have Control Center installed and access it with
```
make open-control-center
```
This'll open an SSH tunnel to the container running Control Center and open it in your browser, or you can access it over `https://127.0.0.1:9021`

## System Health

The first screen that comes is the System Health and displays information about your Kafka cluster, it should look like this

![screenshot](https://raw.githubusercontent.com/aggress/mesosphere-dcos-smack-installer/master/docs/control-center-screenshot.png)


## Data Streams

Complete [Connect Testing](connect_testing.md) which sets up a Connect source and sink to populate data. It will then look like

![screenshot](https://raw.githubusercontent.com/aggress/mesosphere-dcos-smack-installer/master/docs/data-stream-screenshot.png)
