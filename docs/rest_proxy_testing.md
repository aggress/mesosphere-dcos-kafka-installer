# REST Proxy Testing

To validate REST Proxy's working correctly, follow the same steps as with [Schema Registry](schema_registry_testing.md)
```
make setup-client-test
```

In `/tmp/kafkatest` on your master, you'll find:
```
/tmp/kafkatest/<kafka_cluster_identifier>-rest-proxy-testing.sh
```
This tests producing and consuming both JSON and Avro messages which proves REST Proxy can talk to Kafka and to Schema Registry respectively. Based on https://docs.confluent.io/current/kafka-rest/docs/intro.html#produce-and-consume-json-messages and the Avro section below it.