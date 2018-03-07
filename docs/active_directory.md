# Active Directory

Active Directory (AD) is used as an alternative to MIT Kerberos for authentication. For services running on DC/OS to authenticate with AD requires the creation of

- Users
- Principals mapped to users
- Keytab files which the services access as secrets

If you don't have an existing Active Directory (AD) server to hand, we can spin one up on AWS using CloudFormation.

## To deploy the AD server

Ensure you edit the `group_vars/all` Active Directory section as these are deployment specific variables, then run

```
make ad-deploy
```

This uses the AWS CLI to deploy a Windows 2008 R2 AD server using CloudFormation based on the template in `output/active_directory_cloudformation_template.json`

At the end of the deployment you'll find the public DNS name presented, along with the Administrator password, which you can copy into an RDP session.

Doing this manually through the AWS console, you'd need to find the EC2 instance and manually obtain the Administrator password, this playbook does it for you, but you must have the SSH key you specified in the following path `"~/.ssh/mysshkey.pem"` choose to server and spits out the public DNS name and the Administrator password - thereby saving one step on the AWS console. 

Install the Microsoft Remote Desktop client and create a new session using these credentials. Add a local resource to the connection (shared folder) and configure it to the `output` directory. 

## If you need to get the AD access credentials 
```
make ad-facts
```

Open the RDP session and navigate in File explorer to the mapped folder. Copy `create_keytabs.bat` to the Desktop

Run Powershell to get a command window, get to the desktop `cd Desktop` and run `create_keytabs.bat`

This will create the; users, principals and keytabs. Once complete, copy all generated files on the Desktop back into the mapped folder, to copy it back to your machine.

Now you can exit the RDP session.

If you're a Mesosphere employee and testing this on CCM, it will be termninated after 1 hour, so keep an eye on that time limit.

## To tear down the AD server
```
make ad-destroy
```

## To Fix

If you've spun up and torn down an AD server, then follow with another, the part of the playbook which gets the DNS name and password may error, as the logic there is only looking for the first instance and the array, it doesn't differentiate between terminated and active. This doesn't stop the service being deployed, just getting the DNS name and password, you'll need to go back to the AWS console.