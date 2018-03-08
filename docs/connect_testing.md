# Connect Testing

Connect has both a REST interface and the ability to be configured through Control Center. We'll go with the latter to configure a Connect task, as it also confirms Control Center is working with it, and Schema Registry correctly. 

This is based on https://docs.confluent.io/current/control-center/docs/quickstart.html

## Setup the test environment

A pre-requisite is to complete setting up the test environment in [Client Testing](client_testing.md)

## Setup our source and sink data files

We want to get onto the Connect container to setup a shell script to continuously write data into a text file which the Connect FileStreamSourceConnector will read from, write into our test topic.  The FileStreamSinkConnector will then read from that topic and write out to our output file.  This then simulates connecting to a data source, ingesting into Kafka and writing out to a sink.

Let's `task exec` onto the Connect container
```
dcos task exec -it $(dcos task | grep 999999-confluent-connect | awk '{print $5}') /bin/bash
```

We'll use `/tmp/` as our working dir and we're going to setup our test script
```
cd /tmp

cat <<EOF > cake.sh
#!/usr/bin/env bash

file=/tmp/cake-source.txt

while true; do
    echo Victoria >> \${file}
    echo Plum >> \${file}
    echo Chocolate \${file}
    echo Christmas >> \${file}
    echo Sponge \${file}
    echo Orange \${file}
    echo Ginger \${file}
    echo Madeira \${file}
    echo Fruit \${file}
    echo Lemon Drizzle \${file}
    echo Carrot \${file}
    sleep 2
done
EOF

chmod +x cake.sh
```

Now let's run this in the background and check it's writing data to the source file:
```
./cake.sh &
cat cake-source.txt
```

If you see cake names and now begin thinking about wanting a slice, move forwards.


## Access Control Center

Ensure you have Control Center installed and access it with
```
make open-control-center
```
This'll open an SSH tunnel to the container running Control Center and open it in your browser.  Hint, switch to your browser.

On the Control Center home page, Go to Management > Kafka Connect and select New source

```
Connector Class > FileStreamSourceConnector
Name > cake-source
Tasks Max > 1
Key Converter Class > org.apache.kafka.connect.storage.StringConverter
Value Converter Class > org.apache.kafka.connect.storage.StringConverter
Transforms > Leave empty
File > /tmp/cake-source.txt
Topic > cake
```
Select Continue
```
Select Sinks and New Sink
Topics > cake
Select Continue
Connector Class > FileStreamSinkConnector
Nam > cake-sink
Tasks Max > 1
Key Converter Class > org.apache.kafka.connect.storage.StringConverter
Value Converter Class > org.apache.kafka.connect.storage.StringConverter
Transforms > Leave empty
File > /tmp/cake-sink.txt
```
Select Continue

What's happening behind the scenes is Control Center talks to Connect over its REST API and also Schema Registry.

## Validation

Switch back to your Connect container, we should expect to see data being written to our sink file
```
cat cake-sink.txt
```

If you do, all is good. If not, check both the Control Center stdout and Connect stdout logs.

## Directly accessing the Connect REST API

This is also worth doing as Control Center only scratches the surface of managing Connect. Note that Connect *does not* provide authentication for its REST API.

List all Connect tasks - get the Connect endpoint address from the UI for the task, or from the master, run 
```
curl $(/opt/mesosphere/bin/detect_ip):63053/v1/records | grep l4lb
```

```
curl -k -X GET http://dev999999-kafka999999-confluent-connect-x.marathon.l4lb.thisdcos.directory:8083/connectors
```

Inspect a task
```
curl -k -X GET http://dev999999-kafka999999-confluent-connect-x.marathon.l4lb.thisdcos.directory:8083/connectors/cake-source
```

Query its status
```
curl -k -X GET http://dev999999-kafka999999-confluent-connect-x.marathon.l4lb.thisdcos.directory:8083/connectors/cake-source/status
```

## Teardown testing

On the Connect container bring cake.sh into the foreground with 
```
fg
```
and `ctrl+c` to stop it

Exit the container with
```
exit
```