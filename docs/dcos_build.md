# DC/OS Build

the `make deploy-dcos` command calls on both Terraform and Ansible to deploy a stack of resources on AWS and then install DC/OS in strict mode.

Those are not included with this repository as they're forks of great work by two colleagues which can be found here:

* https://bitbucket.org/pumphouse_p/dcos-ansible.git
* https://github.com/jrx/terraform-dcos

If you need to build a DC/OS environment for testing, I recommend checking out the new [DC/OS labs repository](https://github.com/dcos-labs/ansible-dcos) which combines both Terraform and Ansible in one and covers AWS, GCP and on-prem.