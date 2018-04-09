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
	@echo "  archive               Archive all assets before deploying a new cluster"
	@echo "  clean                 Remove existing artifcats from the output folders"
	@echo "  open-control          Tunnel and open Control Center in your browser"
	@echo "  testing               Testing menu"
	@echo ""
	@echo "== I n s t a l l ========"
	@echo ""
	@echo "  install-prereqs       One-time install per cluster for l4lb cert, keytabs, krb5, client-jaas, aux-universe"
	@echo "  install-zookeeper     Install Confluent Platform Zookeeper"
	@echo "  install-kafka         Install Confluent Platform Kafka"
	@echo "  install-schema        Install Confluent Schema Registry"
	@echo "  install-rest          Install Confluent REST Proxy"
	@echo "  install-connect       Install Confluent Connect"
	@echo "  install-control       Install Confluent Control Center"
	@echo ""

testing:
	@echo ""
	@echo "== Testing ============"
	@echo ""
	@echo "  build-keytabs-script  Configure the powershell script to generate AD keytabs"
	@echo "  get-keytabs           SSH to Active Directory, generate and retrieve the keytabs"
	@echo "  deploy-ad             Deploy an Active Directory server on AWS"
	@echo "  get-ad-facts          Get the public DNS name and Administrator password for the AD server on AWS"
	@echo "  setup-client-test     Send creds and configs to a master for client-server testing"
	@echo "  destroy-ad            Destroy the AWS Active Directory server"
	@echo "  destroy-full-stack    Uninstall a full stack"
	@echo "  janitor               Run Janitor to clean up reservations, roles and principals"
	@echo "  deploy-dcos           Terraform and build a DC/OS cluster using Ansible"
	@echo "  destroy-dcos          Destroy the DC/OS test environment"
	@echo ""


archive:
	ansible-playbook -i hosts tasks/archive.yaml

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

open-control:
	ansible-playbook -i hosts tasks/open_control_center.yaml

install-prereqs:
	ansible-playbook -i hosts tasks/install_cli_subcommands.yaml
	ansible-playbook -i hosts tasks/check_keytabs.yaml
	rm -f $(BUILDDIR)/cert/*
	ansible-playbook -i hosts tasks/deploy_l4lb_cert.yaml
	ansible-playbook -i hosts tasks/make_configs.yaml
	ansible-playbook -i hosts tasks/add_keytab_secrets.yaml
	dcos package repo add --index=0 "confluent-aux-universe" https://s3.amazonaws.com/mbgl-universe/repo-up-to-1.10.json

install-zookeeper:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-zookeeper"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-zookeeper"

install-kafka:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-kafka"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-kafka"

install-schema:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-schema-registry"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-schema-registry"

install-rest:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-rest-proxy"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-rest-proxy"

install-connect:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-connect"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-connect"

install-control:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-control-center"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-control-center"

install-full-stack:
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-kafka-zookeeper"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-kafka-zookeeper"
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-kafka"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-kafka"
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-schema-registry"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-schema-registry"
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-rest-proxy"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-rest-proxy"
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-connect"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-connect"
	ansible-playbook -i hosts tasks/setup.yaml -e "package_to_install=confluent-control-center"
	ansible-playbook -i hosts tasks/deploy.yaml -e "package_to_install=confluent-control-center"

build-keytabs-script:
	ansible-playbook -i hosts tasks/build_ad_keytabs.yaml

get-keytabs:
	ansible-playbook -i hosts tasks/active_directory_over_ssh.yaml

deploy-ad:
	ansible-playbook -i hosts tasks/ad_cloudformation_stack.yaml -e "ad_action=deploy"

get-ad-facts:
	ansible-playbook -i hosts tasks/ad_cloudformation_stack.yaml -e "ad_action=facts"

setup-client-test:
	ansible-playbook -vvv -i hosts tasks/setup_client_test.yaml

open-dcos-ui:
	open https://$(shell grep masters -A 1 ~/code/dcos-ansible/hosts | tail -n1)

destroy-ad:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to destroy your test AD server [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	ansible-playbook -i hosts tasks/ad_cloudformation_stack.yaml -e "ad_action=destroy"

destroy-full-stack:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to delete the entire stack [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	ansible-playbook -i hosts tasks/delete_full_stack.yaml

janitor:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to run Janitor on both Zookeeper and Kafka [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	ansible-playbook -i hosts tasks/janitor.yaml -e "package_to_janitor=confluent-kafka-zookeeper"
	ansible-playbook -i hosts tasks/janitor.yaml -e "package_to_janitor=confluent-kafka"

deploy-dcos:
	cd ~/code/terraform-ansible-dcos; \
	  terraform init; \
	  terraform get; \
	  terraform apply -auto-approve; \
	  sleep 45; \
	  bash ansibilize.sh
	cd ~/code/dcos-ansible ;\
	  ansible-playbook -i hosts -u centos -b main.yaml

destroy-dcos:
	@while [ -z "$$CONTINUE" ]; do \
      read -r -p "Confirm to destroy your test DC/OS cluster [y/n]: " CONTINUE; \
    done ; \
    [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	cd ~/code/terraform-ansible-dcos; \
	  terraform destroy -force
