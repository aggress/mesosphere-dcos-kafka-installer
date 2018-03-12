#!/bin/bash

# Patches Zookeeper to fix https://issues.apache.org/jira/browse/ZOOKEEPER-2184
# Zookeeper tries to do a reverse DNS lookup of the container IP which then resolves to the host's address
# Any client then trying to connect to this address will fail

cp /tmp/kafkatest/zookeeper-3.4.10.1.jar /usr/share/java/kafka/zookeeper-3.4.10.jar