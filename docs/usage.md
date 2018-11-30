# Usage

## Checkout this repository 
```
git clone @github.com:aggress/mesosphere-dcos-smack-installer.git
```
Change to the project directory
```
cd mesosphere-dcos-smack-installer
```

Edit `group_vars/all` to set the following:

* `ad_hostname` - The hostname of your Active Directory server
* `ad_user_password` - Required for testing
* `realm` - Required for Kerberos principals
* `ssh_user` - The user used to SSH to DC/OS masters, used to setup client testing
* `ec2_keypair` - Used to deploy a test Active Directory server
* `service_group` - The DC/OS folder to install the Kafka cluster into
* `kafka_cluster_identifier` - A 6 digit numeric identifier for the cluster

## Configure the DC/OS CLI to attach to your target cluster 

```
dcos cluster setup --insecure <master_ip> --username=<username>
```

Test the DC/OS cli `dcos node`

Run `make` with no options to review the options.


## Active Directory / Kerberos create keytabs

If you need a test AD server, please read [Active Directory](https://github.com/aggress/mesosphere-dcos-smack-installer/blob/master/docs/activedirectory.md) first, then spin up AD with:
```
make ad-deploy  
```

Whether you're using a test AD server or a corporate one, you now need to create the batch script which automates the user, principal and keytab creation.

```
make ad-keytabs-bat
```

Copy `output/create_keytabs.bat` onto the AD server, run it and copy the generated keytabs back into `output`. Again see the [Active Directory](https://github.com/aggress/mesosphere-dcos-smack-installer/blob/master/docs/activedirectory.md) notes for the quickest way to do this with a test AD server.

## Run the one-time-setup which:

- Creates a special certificate required for the l4lb service
- Validates the keytabs in `output/keytabs`
- Adds the keytabs as DC/OS secrets
- Adds the Kerberos krb5.conf as a secret
- Adds the client-jaas.conf as secrets
- Adds the (temporary) confluent-aux-universe where the security enabled community packages currently reside

```
make install-prereqs
```

Now you're read to deploy a stack. This should be done in the order below as there are dependencies. Zookeeper must come before Kafka and Schema Registry should come before the others.
```
make install-cp-zookeeper
```

Watch Ansible do its magic and your new service is deployed. You want to let this complete before moving onto Kafka as it has a dependency on getting the Zookeeper endpoints as does Schema Registry with Kafka.



## Repeat for the rest of the stack
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

## Archive all assets

After the deployment of a stack, archive all assets - option.jsons, certs, keytabs etc
```
make archive
```

This will create an archive directory in output/archive, copy over all the assets from `output/{certs,keytabs,options,other}` and remove them from those directories, ready for a fresh deployment.


## Deploy a second stack

Edit group_vars/all and change the `kafka_cluster_identifier`

Now repeat from Active Directory / Kerberos create keytabs

