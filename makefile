
BUILDDIR = "output"
.DEFAULT_GOAL := help

.PHONY: addup addown help clean

help:
	@echo ""
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo ""
	@echo "== S e t u p ============"
	@echo ""
	@echo "  ad-keytabs-bat         Configure the batch script to generate AD keytabs"	
	@echo "  one-time-setup         One-time setup for l4lb cert, keytabs, krb5, client-jaas, aux-universe"
	@echo ""
	@echo "== I n s t a l l ========"
	@echo ""
	@echo "  install-cp-zookeeper   Install Confluent Platform Zookeeper"
	@echo "  install-cp-kafka       Install Confluent Platform Kafka"
	@echo "  install-cp-schema      Install Confluent Schema Registry"
	@echo "  install-cp-rest        Install Confluent Rest Proxy"
	@echo "  install-cp-connect     Install Confluent Connect"
	@echo "  install-cp-control     Install Confluent Control Center"
	@echo "  install-cp-full-stack  Install Confluent Platform Full Stack"
	@echo ""
	@echo "== A d m i n ============"
	@echo ""
	@echo "  clean                  Remove existing build artifacts"
	@echo "  delete-full-stack      Delete a full cp stack"
	@echo "  ad-deploy              Deploy an Active Directory server on AWS"
	@echo "  ad-facts               Get the public DNS name and Administrator password for the AD server on AWS"
	@echo "  ad-destroy             Destroy the AWS Active Directory server"
	@echo "  client-test            Send creds and configs to a master for client-server testing"
	@echo "  janitor-aws            Run Janitor to clean up reservations, roles and principals"
	@echo "  dcos-build             Terraform and build a DC/OS cluster using Ansible"
	@echo "  dcos-destroy           Destroy the DC/OS test environment"
	@echo ""


ad-keytabs-bat:
	ansible-playbook -i hosts tasks/setup_ad_keytabs.yaml

one-time-setup:
	ansible-playbook -i hosts tasks/check_dcos_enterprise_cli.yaml
	ansible-playbook -i hosts tasks/check_keytabs.yaml
	ansible-playbook -i hosts tasks/deploy_l4lb_cert.yaml
	ansible-playbook -i hosts tasks/make_configs.yaml
	ansible-playbook -i hosts tasks/add_keytab_secrets.yaml
	dcos package repo add --index=0 "confluent-aux-universe" https://s3.amazonaws.com/mbgl-universe/repo-up-to-1.10.json

install-cp-zookeeper:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=beta-confluent-kafka-zookeeper"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=beta-confluent-kafka-zookeeper"

install-cp-kafka:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=beta-confluent-kafka"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=beta-confluent-kafka"

install-cp-schema:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-schema-registry-x"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-schema-registry-x"

install-cp-rest:
	ansible-playbook -vvv -i hosts tasks/setup.yaml -e "package_to_install=confluent-rest-proxy-x"
	ansible-playbook -vvv -i hosts tasks/deploy.yaml -e "package_to_install=confluent-rest-proxy-x"

install-cp-connect:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-connect-x"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-connect-x"

install-cp-control:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-control-center-x"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-control-center-x"

install-cp-full-stack: install-cp-zookeeper install-cp-kafka install-cp-schema install-cp-rest install-cp-connect install-cp-control

clean:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to clear out the output directory [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	rm -rf $(BUILDDIR)/*

delete-full-stack:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to delete the entire stack [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	ansible-playbook -i hosts tasks/delete_full_stack.yaml

ad-deploy:
	ansible-playbook -i hosts tasks/ad_cloudformation_stack.yaml -e "ad_action=deploy"

ad-facts:
	ansible-playbook -vvv -i hosts tasks/ad_cloudformation_stack.yaml -e "ad_action=facts"

ad-destroy:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to destroy your test AD server [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	ansible-playbook -i hosts tasks/ad_cloudformation_stack.yaml -e "ad_action=destroy"

client-test:
	ansible-playbook -vvv -i hosts tasks/client_test.yaml

janitor:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to run Janitor on both Zookeeper and Kafka [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	ansible-playbook -i hosts tasks/janitor.yaml -e "package_to_janitor=beta-confluent-kafka-zookeeper"
	ansible-playbook -i hosts tasks/janitor.yaml -e "package_to_janitor=beta-confluent-kafka"


dcos-build:
	cd ~/code/terraform-ansible-dcos; \
	  terraform init; \
	  terraform get; \
	  terraform apply -auto-approve; \
	  sleep 45; \
	  bash ansibilize.sh
	cd ~/code/dcos-ansible ;\
	  ansible-playbook -i hosts -u centos -b main.yaml
	$(info ***  Please configure your DC/OS CLI ***)
	$(info ***  And get your keytabs            ***)

dcos-destroy:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to destroy your test DC/OS cluster [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	cd ~/code/terraform-ansible-dcos; \
	  terraform destroy -force