# Usage

## Checkout this repository 
```
git clone @github.com:aggress/mesosphere-dcos-smack-installer.git
```
Change to the project directory
```
cd mesosphere-dcos-smack-installer
```

Edit `group_vars/all` which contains a list of configuration options you must setup before moving forwards.

You must have the following: ad_hostname, ad_user_password, realm, ssh_user, ec2_keypair

## Configure the DC/OS CLI to attach to your target cluster 

```
dcos cluster setup --insecure <master_ip> --username=<username>
```

## Test the DC/OS cli `dcos node`

Run `make` with no options to review the options.

If you need a test AD server, please read [Active Directory](https://github.com/aggress/mesosphere-dcos-smack-installer/blob/master/docs/activedirectory.md) first, then spin up AD with:
```
make ad-deploy  
```

Whether you're using a test AD server or a corporate one, you now need to create the batch script which automates the user, principal, keytab creation.

```
make ad-keytabs-bat
```

Copy `output/create_keytabs.bat` onto the AD server, run it and copy the generated keytabs back into `output`. Again see the [Active Directory](https://github.com/aggress/mesosphere-dcos-smack-installer/blob/master/docs/activedirectory.md) notes for the quickest way to do this with a test AD server.

## Run the one-time-setup which:

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