
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

## Tooling

- Ansible <3
- aws-shell
- DC/OS CLI

## Setup

Instructions below are for macOS only

### Ansible
```
brew install ansible
```

### AWS shell

If you want to launch an Active Directory server on AWS for testing, programmatically

```
brew install awscli
```

Add your AWS secret and key with `aws configure` or edit the `~/aws/credentials` directly

### Python modules for some of the more esoteric Ansible activities

If you're using brew, you may have multiple versions of Python on your system in different locations.
Ansible calls `/usr/bin/python`, so any required modules need to be installed in its context.
Why the strange param when installing boto3? https://github.com/PokemonGoF/PokemonGo-Bot/issues/245.
..Working through all the **** so you don't have to.

```
sudo /usr/bin/python -m easy_install pip
sudo /usr/bin/python -m pip install boto3 --ignore-installed six
sudo /usr/bin/python -m pip install boto
sudo /usr/bin/python -m pip install cryptography
```
### DC/OS CLI

https://docs.mesosphere.com/1.10/cli/install/#manually-installing-the-cli

### RDP client

Now I've been using xfreerdp but it requires Quartz and a reboot
```
brew cask install xfreerdp
```
The alternative is to install [Microsoft Remote Desktop 10](https://itunes.apple.com/gb/app/microsoft-remote-desktop-10/id1295203466?mt=12) from the app store which also works fine.

## General Usage

Checkout this repository 
```
git clone @github.com:aggress/mesosphere-dcos-smack-installer.git
```
Change to the project directory
```
cd mesosphere-dcos-smack-installer
```

Edit `group_vars/all` which contains a list of configuration options you must setup before moving forwards.

You must have the following: ad_hostname, ad_user_password, realm, ssh_user, ec2_keypair

Configure the DC/OS CLI to attach to your target cluster 

```
dcos cluster setup --insecure <master_ip> --username=<username>
```

Test the DC/OS cli `dcos node`

Run `make` with no options to review the options.

If you need a test AD server, please read [Active Directory](https://github.com/aggress/mesosphere-dcos-smack-installer/docs/activedirectory.md) first, then spin up AD with:
```
make ad-deploy  
```

Whether you're using a test AD server or a corporate one, you now need to create the batch script which automates the user, principal, keytab creation.

```
make ad-keytabs-bat
```

Copy `output/create_keytabs.bat` onto the AD server, run it and copy the generated keytabs back into `output`. Again see the [Active Directory](https://github.com/aggress/mesosphere-dcos-smack-installer/docs/activedirectory.md) notes for the quickest way to do this with a test AD server.

Next, run the one-time-setup which:

- Creates a special certificate required for the l4lb service
- Adds the keytabs as DC/OS secrets
- Adds the Kerberos krb5.conf as a secret
- Adds the client-jaas.conf as a secrets
- Adds the (temporary) confluent-aux-universe where the security enabled community packages currently reside

```
make one-time-setup
```

Now you're read to deploy a stack. This should be done in the order below as there are dependencies. Zookeeper must come before Kafka and Schema Registry should come before the others.
```
make install-cp-zookeeper
```

Watch Ansible do its magic and your new service is deployed

Repeat for the rest of the stack
```
make install-cp-kafka
make install-cp-schema
make install-cp-rest
make install-cp-connect
make install-cp-control
```

Or go crazy
```
make install-cp-stack
```


