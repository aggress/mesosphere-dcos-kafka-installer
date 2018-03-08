# Schema Registry Testing

To validate Schema Registry's working correctly, a test script is deployed alongside the (Client Testing)[client_testing.md] when you run
```
make setup-client-test
```

In `/tmp/kafkatest` on your master, you'll find the following file
```
/tmp/kafkatest/<kafka_cluster_identifier>-schema-registry-testing.sh
```
That shell script's configured to point at the correct instance of Schema Registry and automates some steps from https://docs.confluent.io/current/schema-registry/docs/intro.html#quickstart.

Exectuting it runs through basic actions and provides the expected output. If it looks good, it looks good.