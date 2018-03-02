
# SMACK Stack Installer For Mesosphere DC/OS

Ansible based installer for Big Data frameworks on DC/OS.

## Introduction

I needed to automate the installation of Confluent Platform with Kerberos and TLS for repeatable testing.
That began as a 100 line shell script, and I said to myself, once this works as a prototype, I'll rebuild in Ansible.
500 lines of shell script later.. drowning in fragile conditionals with poor validation, I scrapped it and rewrote in Ansible.
Which I should have done from the very start. So here we are.

## Features

- Deploys Confluent Platform with Active Directory/Kerberos and TLS
- Supports distinct naming of each cluster for multi-tenancy
- DC/OS Strict mode
- Active Directory support
- Deployment of an Active Directory server on AWS
- Generation of AD users, principals and keytabs
- Generated templates for JSON options
- Makefile support (thank you for the tip @jrx)

## Planned Features

- Folder support
- Configurable resources for JSON options
- Janitor automation
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

If you want to launch the AD server programmatically

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
The alternative is to install Microsoft Remote Desktop 10. from the app store which also works fine

## General Usage

Checkout this repository 
```
git clone @github.com:aggress/mesosphere-dcos-smack-installer.git
```
Change to the project directory
```
cd mesosphere-dcos-toolbox/mesosphere-dcos-smack-installer
```

Edit `group_vars/all` this contains a list of configuration options you must setup before moving forwards.

You must have the following: ad_hostname, ad_user_password, realm, ssh_user, ec2_keypair

Configure the DC/OS CLI to attach to your target cluster 

```
dcos cluster setup --insecure <master_ip> --username=<username>
```

Test the DC/OS cli `dcos node`

Run `make` with no options to review the options.

If you need a test AD server you must read the Active Directory setup notes below, then spin up AD with
```
make ad-deploy  
```

You will need to copy the generated `create_keytabs.bat` onto the AD server, run it and copy the generated keytabs back into `output`.

There are two setup stages before deploying a service. Firstly generate the AD keytabs batch script to generate credentials
```
make ad-keytabs-bat
```

With that you can create all the AD/Kerberos credentials for the service. Those need to be copied back to the `output` folder before you can proceed.

Then run the one time setup which creates a special certificate required for the l4lb service, adds the keytabs as DC/OS secrets, adds the Kerberos krb5.conf and client-jaas.conf as secrets and temporarily adds the confluent-aux-universe where the security enabled community packages currently reside.
```
make one-time-setup
```

Now you're read to deploy a stack. This should be done in the order below as there are dependencies. Zookeeper must come before Kafka and Schema Registry should come before the others.

Configure a service for deployment

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

## Active Directory

If you don't have an existing Active Directory (AD) server to hand, this can spin one up on AWS using CloudFormation. AD is used to manage users, Kerberos principals and create the keytabs, which you then must download from the AD server for the services to authenticate with.

### Workflow

To stand up the AD server, ensure you edit the `group_vars/all` Active Directory section as these are deployment specific variables, then run

```
make ad-deploy
```

This builds a Windows 2008 R2 AD server and spits out the public DNS name and the Administrator password - thereby saving one step on the AWS console. 

Install Microsoft Remote Desktop and creation a new session using these credentials. Add a local resource to the connection (shared folder) and configure it to the `output` directory. If you need to get the credentials again, run
```
make ad-facts
```

Open the RDP session and navigate in File explorer to the mapped folder. Copy `create_keytabs.bat` to the Desktop

Run Powershell to get a command window, get to the desktop `cd Desktop` and run `create_keytabs.bat`

This will add all users, create principals and keytabs. Once complete, copy all generated files on the Desktop back into the mapped folder, to copy it back to your desktop.

Now you can exit the RDP session.

If you're a Mesosphere employee and testing this on CCM, it will be termninated after 1 hour, so keep an eye on that time.

To tear down the AD server
```
make ad-destroy
```


## Todo

- Docs for AD testing
- All the other things

