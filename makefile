BUILDDIR = "output"
kafka_cluster_identifier = $(shell grep kafka_cluster_identifier group_vars/all | awk '{print $2}')
service_group = $(shell grep service_group group_vars/all | awk '{print $2}' | head -n1)
dcos_cluster = $(shell dcos cluster list --attached | tail -n1)
blah = "test"

.DEFAULT_GOAL := help

.PHONY: addup addown help clean testing

help:
	@echo ""
	@echo "Please use \`make <target>' where <target> is one of:"
	@echo ""
	@echo "  Mesosphere DC/OS Kafka Installer:"
	@echo ""
	@echo "  $(dcos_cluster)"
	@echo "  $(service_group)"
	@echo "  $(kafka_cluster_identifier)"
	@echo ""
	@echo "== Admin ============"
	@echo ""
	@echo "  build-keytabs-bat      Configure the batch script to generate AD keytabs"
	@echo "  get-keytabs            SSH to Active Directory, generate and retrieve the keytabs"
	@echo "  run-setup              One-time setup for l4lb cert, keytabs, krb5, client-jaas, aux-universe"
	@echo "  destroy-full-stack     Delete a full cp stack"
	@echo "  clean                  Remove existing build artifacts"
	@echo "  janitor                Run Janitor to clean up reservations, roles and principals"
	@echo "  open-control-center    Tunnel and open Control Center in your browswer"
	@echo "  archive                Archive all assets before deploying a new cluster"
	@echo "  testing                Testing menu"
	@echo ""
	@echo "== I n s t a l l ========"
	@echo ""
	@echo "  install-cp-zookeeper   Install Confluent Platform Zookeeper"
	@echo "  install-cp-kafka       Install Confluent Platform Kafka"
	@echo "  install-cp-schema      Install Confluent Schema Registry"
	@echo "  install-cp-rest        Install Confluent REST Proxy"
	@echo "  install-cp-connect     Install Confluent Connect"
	@echo "  install-cp-control     Install Confluent Control Center"
	@echo ""

testing:
	@echo ""
	@echo "== Testing ============"
	@echo ""
	@echo "  deploy-ad              Deploy an Active Directory server on AWS"
	@echo "  get-ad-facts           Get the public DNS name and Administrator password for the AD server on AWS"
	@echo "  destroy-ad             Destroy the AWS Active Directory server"
	@echo "  setup-client-test      Send creds and configs to a master for client-server testing"
	@echo "  deploy-dcos            Terraform and build a DC/OS cluster using Ansible"
	@echo "  destroy-dcos           Destroy the DC/OS test environment"
	@echo ""


build-keytabs-bat:
	ansible-playbook -i hosts tasks/build_ad_keytabs.yaml

get-keytabs:
	ansible-playbook -i hosts tasks/active_directory_over_ssh.yaml

run-setup:
	ansible-playbook -i hosts tasks/check_dcos_enterprise_cli.yaml
	ansible-playbook -i hosts tasks/check_keytabs.yaml
	rm -f $(BUILDDIR)/cert/*
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
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-rest-proxy-x"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-rest-proxy-x"

install-cp-connect:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-connect-x"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-connect-x"

install-cp-control:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-control-center-x"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-control-center-x"

install-cp-full-stack:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=beta-confluent-kafka-zookeeper"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=beta-confluent-kafka-zookeeper"
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=beta-confluent-kafka"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=beta-confluent-kafka"
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-schema-registry-x"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-schema-registry-x"
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-rest-proxy-x"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-rest-proxy-x"
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-connect-x"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-connect-x"
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-control-center-x"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-control-center-x"

clean:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to reset for a new deployment [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	rm -f $(BUILDDIR)/cert/*
	rm -f $(BUILDDIR)/keytabs/*
	rm -f $(BUILDDIR)/options/*
	rm -f $(BUILDDIR)/other/*
	rm -f tasks/*.retry

destroy-full-stack:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to delete the entire stack [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	ansible-playbook -i hosts tasks/delete_full_stack.yaml

deploy-ad:
	ansible-playbook -i hosts tasks/ad_cloudformation_stack.yaml -e "ad_action=deploy"

get-ad-facts:
	ansible-playbook -i hosts tasks/ad_cloudformation_stack.yaml -e "ad_action=facts"

destroy-ad:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to destroy your test AD server [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	ansible-playbook -i hosts tasks/ad_cloudformation_stack.yaml -e "ad_action=destroy"

setup-client-test:
	ansible-playbook -vvv -i hosts tasks/setup_client_test.yaml

janitor:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to run Janitor on both Zookeeper and Kafka [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	ansible-playbook -i hosts tasks/janitor.yaml -e "package_to_janitor=beta-confluent-kafka-zookeeper"
	ansible-playbook -i hosts tasks/janitor.yaml -e "package_to_janitor=beta-confluent-kafka"

open-control-center:
	ansible-playbook -i hosts tasks/open_control_center.yaml

archive:
	ansible-playbook -i hosts tasks/archive.yaml

deploy-dcos:
	cd ~/code/terraform-ansible-dcos; \
	  terraform init; \
	  terraform get; \
	  terraform apply -auto-approve; \
	  sleep 45; \
	  bash ansibilize.sh
	cd ~/code/dcos-ansible ;\
	  ansible-playbook -i hosts -u centos -b main.yaml
	  sleep 60
	  dcos cluster setup --insecure $(shell grep masters -A 1 ~/code/dcos-ansible/hosts | tail -n1)

destroy-dcos:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to destroy your test DC/OS cluster [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	cd ~/code/terraform-ansible-dcos; \
	  terraform destroy -force