
# Mesosphere DC/OS Kafka Installer

![Support DC/OS Version](https://img.shields.io/badge/Supported%20on%20DC/OS-1.10-7d58ff.svg?longCache=true&style=flat-square)

An Ansible based installer for Kafka & [Confluent Platform](https://www.confluent.io/product/confluent-platform/) on [DC/OS](https://mesosphere.com/product/)

![screenshot](https://raw.githubusercontent.com/aggress/mesosphere-dcos-kafka-installer/master/docs/make-screenshot.png)

## Features

* Deploys Confluent Platform Kafka with full security - Active Directory/Kerberos GSSAPI & SASL_SSL authentication
* Supports deployment of multiple Kafka clusters for multi-tenant environments
* DC/OS group/folder support for organising clusters such as /dev/123456-kafka/
* DC/OS strict mode security out of the box (only strict at this time)
* Deployment of an Active Directory server on AWS for testing
* Dynamic generation of:
  * a batch script to add Active Directory users, principals and generate keytabs
  * options.json configs for every service
  * client-jass.conf for every service
  * endpoint dependencies for each service
* Automation of:
  * generating and adding binary and text secrets to the DC/OS secret store
  * configuring DC/OS security service accounts and ACLs
* Menu system to wrap the Ansible playbooks using GNU make
* Janitor cleanup with one command
* End to end client testing scripts with documented steps
* Easy access to Confluent Control Center
* Archive of each cluster's configuration assets

## Planned Features

* DC/OS 1.11 support
* CCM support
* Endpoint management
* Configurable resources for JSON options
* Apache Kafka support
* DC/OS permissive and disabled security modes
* MIT Kerberos support
* Standalone monitoring deployment integrated with dcos-metrics
* Performance benchmarking

## Limitations

* DC/OS 1.10 only
* Strict mode only
* Cluster identifier limited to 9 chars due to Active Directory Kerberos naming limitations
* Confluent Connect does not provide security on its REST API endpoint, this is a limitation in the Confluent product
* External (to DC/OS ) service discovery is work in progress

## Design

Ansible does the heavy lifting, talking over localhost, to generate configuration files based on templates and talking directly to the DC/OS CLI to manage the deployment.

Really, all this is doing is automating the manual process and myriad of configurations required.

## Why use this?

* You're running a multi-tenant / private cloud environment based on DC/OS where you want to deploy multiple Confluent Platform Kafka clusters
* You want to test the full Confluent Platform stack on a DC/OS strict mode cluster with all security features enabled
* You want a convenient testing framework to validate the components are working correctly
* You don't want to run through >50 manual steps

## Documentation

* [Setup](docs/setup.md)
* [Active Directory](docs/active_directory.md)
* [Usage](docs/usage.md)
* [Client Testing](docs/client_testing.md)
* [Schema Registry Testing](docs/schema_registry_testing.md)
* [REST Proxy Testing](docs/rest_proxy_testing.md)
* [Connect Testing](docs/connect_testing.md)
* [Control Center Testing](docs/control_center_testing.md)
* [DC/OS build for testing](docs/dcos_build.md)
* [Troubleshooting](docs/troubleshooting.md)