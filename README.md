
# SMACK Stack Installer For Mesosphere DC/OS

WORK IN PROGRESS

Ansible based installer for Big Data frameworks on DC/OS.

![screenshot](https://raw.githubusercontent.com/aggress/mesosphere-dcos-smack-installer/master/docs/make-screenshot.png)

## Features

- Deploys Confluent Platform with Active Directory/Kerberos and TLS
- Supports distinct naming of each cluster for multi-tenancy
- Folder support
- DC/OS Strict mode
- Deployment of an Active Directory server on AWS for testing
- Generation of AD users, principals and keytabs
- Generated templates for JSON options
- Makefile support (thank you for the tip @jrx)
- Janitor cleanup

## Planned Features

- Configurable resources for JSON options
- Apache Kafka, Cassandra, DSE
- MIT Kerberos testing environment
- End to end client testing - reading and writing data
- Standalone monitoring deployment integrated with dcos-metrics

## Design

Ansible does the heavy lifting and talks over localhost directly to the DC/OS CLI which then deploys frameworks. Really, all this is doing is automating all the steps you'd need to perform manually.

## Documentation

- [Setup](docs/setup.md)
- [Active Directory](docs/active_directory.md)
- [Usage](docs/usage.md)
- [Client Testing](docs/client_testing.md)
- [Schema Registry Testing](docs/schema_registry_testing.md)
- [REST Proxy Testing](docs/rest_proxy_testing.md)
- [Connect Testing](docs/connect_testing.md)
- TODO [Troubleshooting](docs/troubleshooting.md)