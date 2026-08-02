TF := terraform -chdir=terraform
ANSIBLE_DIR := ansible

.PHONY: help setup secrets vault-init vault-edit vault-view init fmt validate lint plan apply destroy output ssh \
        galaxy inventory ping syntax provision deploy release

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

# --- Подготовка проекта ---

setup: vault-init init galaxy ## Create the encrypted vault, initialize Terraform, install Ansible roles

secrets: ## Print the command that loads secrets into the current shell
	@echo 'eval "$$(./scripts/secrets.sh)"'

vault-init: ## Build ansible/vault.yml from a service account key
	./scripts/make-vault.sh

vault-edit: ## Edit the encrypted vault
	ansible-vault edit $(ANSIBLE_DIR)/vault.yml

vault-view: ## Show the decrypted vault contents
	ansible-vault view $(ANSIBLE_DIR)/vault.yml

# --- Инфраструктура ---

init: ## Initialize Terraform and connect the remote backend
	$(TF) init

fmt: ## Format Terraform files
	$(TF) fmt -recursive

validate: ## Validate the Terraform configuration
	$(TF) validate

lint: fmt validate syntax ## Check both Terraform and Ansible

plan: ## Show what would change
	$(TF) plan

apply: ## Create or update the infrastructure
	$(TF) apply

destroy: ## Delete the infrastructure
	$(TF) destroy

output: ## Show the addresses of created resources
	$(TF) output

ssh: ## Connect to the first web server
	ssh ubuntu@$$($(TF) output -json web_public_ips | python3 -c 'import json,sys; print(json.load(sys.stdin)[0])')

# --- Деплой ---

galaxy: ## Install external Ansible roles and collections
	cd $(ANSIBLE_DIR) && ansible-galaxy install -r requirements.yml --roles-path .galaxy_roles

inventory: ## Show the inventory generated from Terraform outputs
	cd $(ANSIBLE_DIR) && ./inventory/terraform.sh

ping: ## Check that the servers are reachable
	cd $(ANSIBLE_DIR) && ansible webservers -m ping

syntax: ## Check the playbook syntax
	cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml --syntax-check

provision: ## Install Docker on the web servers
	cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml --tags setup

deploy: ## Deploy the application containers
	cd $(ANSIBLE_DIR) && ansible-playbook playbook.yml --tags deploy

release: apply provision deploy ## Create the infrastructure and deploy the application
