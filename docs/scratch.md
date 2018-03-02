netsh advfirewall firewall add rule name=winrm dir=in action=allow protocol=TCP localport=5986


net user ansible MesosphereAD2018 /add /expires:NEVER /domain /yes

export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES



[realms]
    ad.mesosphere.com = {
        kdc = ad.mesosphere.com
    }

[domain_realm]
    .ad.mesosphere.com = ad.mesosphere.com


xfreerdp --plugin cliprdr -u Administrator 



#################################
SSL
#################################

ssl

openssl pkcs12 -export -in pub.crt -inkey priv.key \
               -out keypair.p12 -name keypair \
               -CAfile ca-bundle.crt -caname root

keytool -importkeystore \
        -deststorepass changeit -destkeypass changeit -destkeystore /tmp/kafkatest/keystore.jks \
        -srckeystore /tmp/kafkatest/keypair.p12 -srcstoretype PKCS12 -srcstorepass export \
        -alias keypair


keytool -import \
  -trustcacerts \
  -alias root \
  -file /tmp/kafkatest/ca-bundle.crt \
  -storepass changeit \
  -keystore /tmp/kafkatest/truststore.jks



##############################
Client Testing
##############################

  docker run --rm -ti \
-v /tmp/kafkatest:/tmp/kafkatest:rw \
-e KAFKA_OPTS="-Djava.security.auth.login.config=/tmp/kafkatest/client-jaas.conf -Djava.security.krb5.conf=/tmp/kafkatest/krb5.conf -Dsun.security.krb5.debug=true" \
confluentinc/cp-kafka:4.0.0 \
bash

echo "This is a secure test at $(date)" | kafka-console-producer --broker-list kafka-0-broker.cl3453-beta-confluent-kafka.mesos:1025 --topic securetest --producer.config /tmp/kafkatest/client.properties




dcos node ssh --proxy-ip=54.245.56.204 --leader --user=centos "sudo docker run mesosphere/janitor /janitor.py -z dcos-service-cl3454-beta-confluent-kafka -r cl3453-beta-confluent-kafka-zookeeper-role -p cl3453-beta-confluent-kafka-zookeeper-principal"


get-keytabs:
  ansible-playbook -vvv -i hosts roles/deploy/tasks/check_dcos_enterprise_cli.yaml
  ansible-playbook -vvv -i hosts roles/deploy/tasks/get_keytabs.yaml